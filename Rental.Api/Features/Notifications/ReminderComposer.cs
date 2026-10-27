using System.Globalization;
using System.Net;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Rental.Api.Data;
using Rental.Api.Features.Common;

namespace Rental.Api.Features.Notifications;

public sealed class ReminderComposer(RentalDb db, IOptions<SmtpOptions> smtp)
{
    public static readonly TimeZoneInfo VietnamTime = TimeZoneInfo.FindSystemTimeZoneById(OperatingSystem.IsWindows() ? "SE Asia Standard Time" : "Asia/Ho_Chi_Minh");
    public static DateOnly Today => DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, VietnamTime));
    private static string H(string value) => WebUtility.HtmlEncode(value);
    private static string Money(long value) => value.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " ₫";
    private static string Date(DateOnly value) => value.ToString("dd/MM/yyyy");

    public async Task<ReminderPayload?> Compose(string kind, int id, CancellationToken token = default)
    {
        var invoice = kind == "InvoiceDue" ? await db.Invoices.AsNoTracking().Include(x => x.Items).SingleOrDefaultAsync(x => x.Id == id, token) : null;
        if (kind == "InvoiceDue" && (invoice == null || invoice.IsArchived || invoice.Status != "Issued")) return null;
        if (kind is not ("InvoiceDue" or "ContractExpiry")) return null;
        var contract = await db.Contracts.AsNoTracking().SingleOrDefaultAsync(x => x.Id == (invoice != null ? invoice.ContractId : id), token);
        if (contract == null || contract.IsArchived || kind == "ContractExpiry" && (contract.Status != "Active" || contract.EndDate < Today)) return null;
        var room = await db.Rooms.AsNoTracking().SingleOrDefaultAsync(x => x.Id == contract.RoomId && !x.IsArchived, token);
        if (room == null) return null;
        var branch = await db.Branches.AsNoTracking().SingleOrDefaultAsync(x => x.Id == room.BranchId && !x.IsArchived, token);
        var tenantId = await db.ContractTenants.AsNoTracking().Where(x => x.ContractId == contract.Id && x.IsRepresentative).Select(x => (int?)x.TenantId).SingleOrDefaultAsync(token);
        var tenant = await db.Tenants.AsNoTracking().SingleOrDefaultAsync(x => x.Id == tenantId && !x.IsArchived, token);
        if (tenant == null || branch == null) return null;
        var email = await db.Users.AsNoTracking().Where(x => x.Role == "Tenant" && x.TenantId == tenant.Id && x.IsActive && !x.IsArchived).Select(x => x.Email).SingleOrDefaultAsync(token) ?? "";
        if (!MimeKit.MailboxAddress.TryParse(email, out var mailbox) || mailbox.Address != email) email = "";
        var greeting = $"<p>Chào {H(tenant.FullName)},</p><p>Phòng <strong>{H(room.Name)}</strong> · {H(branch.Name)}</p>";
        string subject, content, text;
        DateOnly eventDate;
        if (invoice != null)
        {
            var paid = await db.Payments.AsNoTracking().Where(x => x.InvoiceId == invoice.Id && !x.IsArchived).SumAsync(x => x.Amount, token);
            var outstanding = invoice.Total - paid;
            if (outstanding <= 0) return null;
            eventDate = invoice.DueDate;
            subject = $"DVP Home · Hóa đơn HĐN-{invoice.Id:D4} · Phòng {room.Name}";
            var rows = string.Join("", invoice.Items.OrderBy(x => x.Id).Select(x => $"<tr><td>{H(x.Description)}</td><td>{x.Quantity.ToString("0.###", CultureInfo.GetCultureInfo("vi-VN"))}</td><td>{Money(x.UnitPrice)}</td><td>{Money(x.Amount)}</td></tr>"));
            content = $"<h2>Hóa đơn tháng {invoice.Month}/{invoice.Year}</h2><p>Mã: HĐN-{invoice.Id:D4} · Hạn thanh toán: <strong>{Date(invoice.DueDate)}</strong></p><table><tr><th>Khoản thu</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr>{rows}</table><p>Tổng hóa đơn: {Money(invoice.Total)}<br>Đã thanh toán: {Money(paid)}<br><strong>Còn cần thanh toán: {Money(outstanding)}</strong></p><p>Số dư được kiểm tra tại thời điểm gửi. Nếu vừa thanh toán, vui lòng liên hệ quản lý để đối soát.</p>";
            text = $"Chào {tenant.FullName}. Phòng {room.Name}, {branch.Name}. Hóa đơn HĐN-{invoice.Id:D4}, tháng {invoice.Month}/{invoice.Year}, hạn {Date(invoice.DueDate)}.\n" + string.Join("\n", invoice.Items.Select(x => $"{x.Description}: {Money(x.Amount)}")) + $"\nTổng: {Money(invoice.Total)}. Đã trả: {Money(paid)}. Còn cần thanh toán: {Money(outstanding)}.";
        }
        else
        {
            eventDate = contract.EndDate;
            subject = $"DVP Home · Hợp đồng phòng {room.Name} sắp hết hạn";
            content = $"<h2>Nhắc thời hạn hợp đồng</h2><p>Hợp đồng HĐ-{contract.Id:D4} kết thúc vào <strong>{Date(contract.EndDate)}</strong>, còn {contract.EndDate.DayNumber - Today.DayNumber} ngày.</p><p>Vui lòng trao đổi với quản lý về việc gia hạn hoặc kế hoạch trả phòng. Email này không tự gia hạn hay kết thúc hợp đồng.</p>";
            text = $"Chào {tenant.FullName}. Hợp đồng HĐ-{contract.Id:D4}, phòng {room.Name}, {branch.Name}, hết hạn ngày {Date(contract.EndDate)}. Vui lòng liên hệ quản lý để trao đổi việc gia hạn hoặc trả phòng.";
        }
        var link = "";
        if (Uri.TryCreate(smtp.Value.PublicBaseUrl, UriKind.Absolute, out var url) && url.Scheme == "https" && !url.IsLoopback && url.UserInfo.Length == 0)
            link = $"<p><a href=\"{H(url.GetLeftPart(UriPartial.Authority) + url.AbsolutePath.TrimEnd('/') + "/#tenant")}\">Mở tài khoản người thuê</a></p>";
        var html = "<!doctype html><html lang=\"vi\"><meta charset=\"utf-8\"><body style=\"font-family:Arial,sans-serif;line-height:1.65;color:#243c37;max-width:720px;margin:24px auto;padding:16px\"><h1>DVP Home</h1>" + greeting + content + link + "<p>Trân trọng,<br>Ban quản lý nhà trọ</p></body></html>";
        return new(kind, id, contract.Id, tenant.Id, eventDate, email, tenant.FullName, room.Name, branch.Name, subject, html, text);
    }

    public async Task<List<ReminderPayload>> Candidates(EmailReminderSettings settings, CancellationToken token = default)
    {
        var targets = new List<(string Kind, int Id)>();
        if (settings.InvoiceEnabled)
            targets.AddRange((await db.Invoices.AsNoTracking().Where(x => !x.IsArchived && x.Status == "Issued" && x.DueDate <= Today).Select(x => x.Id).ToListAsync(token)).Select(id => ("InvoiceDue", id)));
        if (settings.ContractEnabled)
            targets.AddRange((await db.Contracts.AsNoTracking().Where(x => !x.IsArchived && x.Status == "Active" && x.EndDate >= Today && x.EndDate <= Today.AddDays(settings.ContractDaysBefore)).Select(x => x.Id).ToListAsync(token)).Select(id => ("ContractExpiry", id)));
        var result = new List<ReminderPayload>();
        foreach (var target in targets) { var payload = await Compose(target.Kind, target.Id, token); if (payload != null) result.Add(payload); }
        return result;
    }
}
