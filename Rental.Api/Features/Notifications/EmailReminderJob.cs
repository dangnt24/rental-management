using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Rental.Api.Data;

namespace Rental.Api.Features.Notifications;

public sealed class EmailReminderJob(RentalDb db, ReminderComposer composer, EmailReminderQueue queue, SmtpEmailSender sender, IOptions<SmtpOptions> smtp, ILogger<EmailReminderJob> logger)
{
    [DisableConcurrentExecution(120)]
    [AutomaticRetry(Attempts = 3, DelaysInSeconds = new[] { 60, 300, 900 })]
    public async Task ScanAndQueue(bool manual, CancellationToken token)
    {
        if (!smtp.Value.IsConfigured) return;
        var settings = await db.EmailReminderSettings.SingleAsync(x => x.Id == 1, token);
        if (settings.Enabled || manual)
        {
            var candidates = await composer.Candidates(settings, token);
            foreach (var candidate in candidates) await queue.Persist(candidate, manual ? "manual-scan" : "daily-job", false, false, token);
        }
        // Phục hồi Pending đã lưu nhưng chưa enqueue được lúc restart/lỗi storage.
        var pending = await db.EmailReminders.AsNoTracking().Where(x => x.Status == "Pending" || x.Status == "Failed").Select(x => x.Id).ToListAsync(token);
        foreach (var id in pending) queue.Dispatch(id);
        settings.LastScanAt = DateTime.UtcNow;
        await db.SaveChangesAsync(token);
    }

    [DisableConcurrentExecution(120)]
    [AutomaticRetry(Attempts = 3, DelaysInSeconds = new[] { 60, 300, 900 })]
    public async Task Send(int id, CancellationToken token)
    {
        if (!smtp.Value.IsConfigured) return;
        var row = await db.EmailReminders.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id, token);
        if (row == null || row.Status is not ("Pending" or "Failed")) return;
        var payload = await composer.Compose(row.Kind, row.EntityId, token);
        if (payload == null || payload.Key != row.DedupKey)
        {
            await db.EmailReminders.Where(x => x.Id == id && (x.Status == "Pending" || x.Status == "Failed")).ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, "Cancelled").SetProperty(x => x.Error, "Không gửi: hóa đơn đã trả/hủy, hợp đồng đã đổi hạn/kết thúc hoặc người đại diện đã thay đổi."), token);
            return;
        }
        if (payload.Recipient.Length == 0)
        {
            await db.EmailReminders.Where(x => x.Id == id && (x.Status == "Pending" || x.Status == "Failed")).ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, "Skipped").SetProperty(x => x.Error, "Chưa có email hợp lệ của người đại diện."), token);
            return;
        }
        // Claim trong DB trước SMTP: job trùng/retry không gửi lại Sent hoặc Sending.
        var claimed = await db.EmailReminders.Where(x => x.Id == id && (x.Status == "Pending" || x.Status == "Failed"))
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, "Sending").SetProperty(x => x.Attempts, x => x.Attempts + 1).SetProperty(x => x.LastAttemptAt, DateTime.UtcNow).SetProperty(x => x.Error, "").SetProperty(x => x.Recipient, payload.Recipient).SetProperty(x => x.Subject, payload.Subject), token);
        if (claimed != 1) return;
        try
        {
            await sender.Send(payload, $"dvp-reminder-{id}@{smtp.Value.FromAddress.Split('@').Last()}", token);
            await db.EmailReminders.Where(x => x.Id == id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, "Sent").SetProperty(x => x.SentAt, DateTime.UtcNow), CancellationToken.None);
        }
        catch (MailDeliveryError ex)
        {
            await db.EmailReminders.Where(x => x.Id == id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, ex.DefinitelyRejected ? "Failed" : "Uncertain").SetProperty(x => x.Error, ex.Message), CancellationToken.None);
            logger.LogWarning("Email reminder {Id}: {Reason}", id, ex.Message);
            if (ex.DefinitelyRejected) throw new InvalidOperationException(ex.Message); // Hangfire retry chỉ khi chắc chắn SMTP chưa nhận.
        }
        catch (Exception)
        {
            // Crash/DB timeout sau DATA có thể đã gửi: không tự gửi lại.
            await db.EmailReminders.Where(x => x.Id == id).ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, "Uncertain").SetProperty(x => x.Error, "Lượt gửi bị gián đoạn; kiểm tra hộp thư trước khi gửi lại."), CancellationToken.None);
            throw;
        }
    }
}
