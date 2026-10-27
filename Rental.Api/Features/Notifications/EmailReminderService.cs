using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Rental.Api.Data;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Notifications;

public record ReminderSettingsRequest(bool Enabled, bool InvoiceEnabled, bool ContractEnabled, int ContractDaysBefore);
public record ManualEmailRequest(string Kind, int EntityId, bool RetryUncertain = false, int? ReminderId = null);

public sealed class EmailReminderService(RentalDb database, IHttpContextAccessor accessor, ReminderComposer composer, EmailReminderQueue queue, IOptions<SmtpOptions> smtp, ILogger<EmailReminderService> logger) : FeatureService(database, accessor)
{
    public async Task<object> Overview()
    {
        OwnerOnly();
        var settings = await db.EmailReminderSettings.AsNoTracking().SingleAsync(x => x.Id == 1);
        var candidates = await composer.Candidates(settings);
        var logs = await db.EmailReminders.AsNoTracking().OrderByDescending(x => x.Id).Take(100).ToListAsync();
        var keys = candidates.Select(x => x.Key).ToArray();
        var statuses = await db.EmailReminders.AsNoTracking().Where(x => keys.Contains(x.DedupKey)).ToDictionaryAsync(x => x.DedupKey, x => x.Status);
        return new
        {
            Settings = settings,
            Delivery = new { Configured = smtp.Value.IsConfigured, JobsEnabled = queue.JobsEnabled, smtp.Value.Host, smtp.Value.Port, smtp.Value.FromAddress, smtp.Value.FromName, Schedule = "09:00 mỗi ngày · giờ Việt Nam" },
            Candidates = candidates.Select(x => new { x.Kind, x.EntityId, x.ContractId, x.TenantId, x.EventDate, x.Recipient, x.RecipientName, x.RoomName, x.BranchName, Status = statuses.GetValueOrDefault(x.Key, x.Recipient.Length == 0 ? "Skipped" : "Ready") }),
            History = logs.Select(x => new { x.Id, x.Kind, x.EntityId, x.ContractId, x.EventDate, x.Recipient, x.Subject, Status = x.Status == "Sending" && x.LastAttemptAt < DateTime.UtcNow.AddMinutes(-10) ? "Uncertain" : x.Status, x.Attempts, x.LastAttemptAt, x.SentAt, x.Error, x.CreatedAt })
        };
    }
    public async Task SaveSettings(ReminderSettingsRequest request)
    {
        OwnerOnly();
        Require(request.ContractDaysBefore is >= 1 and <= 90, "Số ngày nhắc hợp đồng cần từ 1 đến 90.");
        Require(!request.Enabled || smtp.Value.IsConfigured && queue.JobsEnabled, "Cần cấu hình SMTP và bật Hangfire trước khi bật gửi tự động.");
        var settings = await db.EmailReminderSettings.SingleAsync(x => x.Id == 1);
        settings.Enabled = request.Enabled; settings.InvoiceEnabled = request.InvoiceEnabled; settings.ContractEnabled = request.ContractEnabled; settings.ContractDaysBefore = request.ContractDaysBefore;
        await Save("email.settings", $"Nhắc email tự động={request.Enabled}, hợp đồng trước {request.ContractDaysBefore} ngày");
    }
    public async Task<object> Manual(ManualEmailRequest request)
    {
        Require(request.Kind is "InvoiceDue" or "ContractExpiry", "Loại thông báo không hợp lệ.");
        if (request.Kind == "InvoiceDue") await Invoice(request.EntityId); else await Contract(request.EntityId);
        Require(smtp.Value.IsConfigured && queue.JobsEnabled, "Chưa cấu hình gửi email. Chủ trọ cần cấu hình SMTP/Hangfire trước.");
        var payload = await composer.Compose(request.Kind, request.EntityId) ?? throw new BusinessError("Không gửi: hóa đơn đã thanh toán/hủy hoặc hợp đồng không còn phù hợp.");
        if (request.ReminderId.HasValue)
            Require(await db.EmailReminders.AnyAsync(x => x.Id == request.ReminderId && x.DedupKey == payload.Key), "Thông tin hóa đơn/hợp đồng đã thay đổi. Tải lại danh sách trước khi gửi.", 409);
        Require(payload.Recipient.Length > 0, "Người đại diện chưa có email hợp lệ. Chủ trọ cần cập nhật email tài khoản người thuê.");
        var reminder = await queue.Persist(payload, Actor, true, request.RetryUncertain);
        if (reminder.Status == "Sending") return new { reminder.Id, Message = "Thông báo đang được gửi." };
        try { queue.Dispatch(reminder.Id); }
        catch (Exception ex) { logger.LogError(ex, "Email saved but enqueue failed"); throw new BusinessError("Đã lưu yêu cầu nhưng hàng đợi chưa sẵn sàng. Thử lại sau; yêu cầu không bị mất.", 503); }
        return new { reminder.Id, Message = "Đã xếp hàng gửi email. Xem kết quả trong Nhật ký email." };
    }
    public async Task<object> Preview(string kind, int entityId)
    {
        Require(kind is "InvoiceDue" or "ContractExpiry", "Loại thông báo không hợp lệ.");
        if (kind == "InvoiceDue") await Invoice(entityId); else await Contract(entityId);
        var payload = await composer.Compose(kind, entityId) ?? throw new BusinessError("Hóa đơn đã thanh toán/hủy hoặc hợp đồng không còn phù hợp để nhắc.");
        return new { payload.Recipient, payload.RecipientName, payload.Subject, payload.EventDate, payload.RoomName, payload.BranchName };
    }
    public async Task<object> ScanNow()
    {
        OwnerOnly(); Require(smtp.Value.IsConfigured && queue.JobsEnabled, "Chưa cấu hình SMTP/Hangfire để gửi email.");
        await Save("email.scan", "Yêu cầu quét và gửi các thông báo đến hạn bằng tay");
        var jobId = queue.ScanNow(); return new { JobId = jobId, Message = "Đã xếp hàng quét và gửi thông báo đến hạn." };
    }
}
