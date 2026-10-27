using System.Data;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;

namespace Rental.Api.Features.Notifications;

public sealed class EmailReminderQueue(RentalDb db, IServiceProvider services, IConfiguration configuration)
{
    public bool JobsEnabled => configuration.GetValue("Hangfire:Enabled", true);
    public string Dispatch(int id) => services.GetRequiredService<IBackgroundJobClient>().Enqueue<EmailReminderJob>(job => job.Send(id, CancellationToken.None));
    public string ScanNow() => services.GetRequiredService<IBackgroundJobClient>().Enqueue<EmailReminderJob>(job => job.ScanAndQueue(true, CancellationToken.None));

    public async Task<EmailReminder> Persist(ReminderPayload payload, string actor, bool manual, bool retryUncertain, CancellationToken token = default)
    {
        await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.Serializable, token);
        var row = await db.EmailReminders.SingleOrDefaultAsync(x => x.DedupKey == payload.Key, token);
        if (row?.Status == "Sent")
        {
            if (manual) throw new BusinessError("Thông báo này đã gửi. Hệ thống không gửi trùng cho cùng hóa đơn/ngày hết hạn.");
            await transaction.CommitAsync(token); return row;
        }
        var staleSending = row?.Status == "Sending" && row.LastAttemptAt < DateTime.UtcNow.AddMinutes(-10);
        if (row?.Status == "Uncertain" || staleSending)
        {
            if (!manual) { await transaction.CommitAsync(token); return row!; }
            BusinessRules.Require(retryUncertain, "Lượt trước chưa xác định kết quả. Kiểm tra hộp thư rồi xác nhận gửi lại tại Nhật ký email.", 409);
        }
        else if (row?.Status == "Sending") { await transaction.CommitAsync(token); return row; }
        if (row == null)
        {
            row = new EmailReminder { DedupKey = payload.Key, Kind = payload.Kind, EntityId = payload.EntityId, ContractId = payload.ContractId, TenantId = payload.TenantId, EventDate = payload.EventDate, CreatedBy = actor };
            db.EmailReminders.Add(row);
        }
        row.Recipient = payload.Recipient; row.Subject = payload.Subject;
        row.Status = payload.Recipient.Length > 0 ? "Pending" : "Skipped";
        row.Error = payload.Recipient.Length > 0 ? "" : "Người đại diện chưa có tài khoản người thuê hoạt động với email hợp lệ. Chủ trọ cần cập nhật tại Tài khoản & phạm vi quản lý.";
        if (manual) db.AuditEntries.Add(new AuditEntry { Action = "email.queue", Detail = $"Yêu cầu gửi {payload.Kind} #{payload.EntityId}" + (retryUncertain ? "; đã xác nhận kiểm tra lượt gửi trước" : ""), CreatedBy = actor });
        await db.SaveChangesAsync(token);
        await transaction.CommitAsync(token);
        return row;
    }
}
