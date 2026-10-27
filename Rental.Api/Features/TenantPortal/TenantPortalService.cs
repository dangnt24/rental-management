using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.TenantPortal;

public record TenantIncidentRequest(int ContractId, string Description);

/// <summary>Phạm vi người thuê được suy ra từ tài khoản đăng nhập, không nhận TenantId từ trình duyệt.</summary>
public sealed class TenantPortalService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    private async Task<int> CurrentTenantId()
    {
        var user = await db.Users.AsNoTracking().SingleAsync(x => x.Id == UserId);
        Require(user.Role == "Tenant" && user.TenantId.HasValue, "Tài khoản chưa gắn với hồ sơ người thuê.", 403);
        return user.TenantId!.Value;
    }

    public async Task<object> Workspace()
    {
        var tenantId = await CurrentTenantId();
        var contractIds = await db.ContractTenants.Where(x => x.TenantId == tenantId).Select(x => x.ContractId).ToArrayAsync();
        var contracts = await db.Contracts.AsNoTracking().Where(x => contractIds.Contains(x.Id)).OrderByDescending(x => x.StartDate).ToListAsync();
        var roomIds = contracts.Select(x => x.RoomId).ToArray();
        var rooms = await db.Rooms.AsNoTracking().Where(x => roomIds.Contains(x.Id)).ToListAsync();
        var branchIds = rooms.Select(x => x.BranchId).ToArray();
        var invoices = await db.Invoices.AsNoTracking().Include(x => x.Items).Where(x => contractIds.Contains(x.ContractId)).OrderByDescending(x => x.Year).ThenByDescending(x => x.Month).ToListAsync();
        var invoiceIds = invoices.Select(x => x.Id).ToArray();
        var payments = await db.Payments.AsNoTracking().Where(x => invoiceIds.Contains(x.InvoiceId)).OrderByDescending(x => x.PaidDate).ToListAsync();
        var deposits = await db.DepositEntries.AsNoTracking().Where(x => contractIds.Contains(x.ContractId)).OrderByDescending(x => x.Id).ToListAsync();
        return new
        {
            Today,
            Profile = await db.Tenants.Where(x => x.Id == tenantId).Select(x => new { x.FullName, x.Phone }).SingleAsync(),
            Branches = await db.Branches.Where(x => branchIds.Contains(x.Id)).Select(x => new { x.Id, x.Name, x.Address }).ToListAsync(),
            Rooms = rooms.Select(x => new { x.Id, x.BranchId, x.Name }),
            Contracts = contracts.Select(x => new { x.Id, x.RoomId, x.StartDate, x.EndDate, x.ClosedDate, x.Rent, x.Deposit, x.Status,
                DepositBalance = deposits.Where(d => d.ContractId == x.Id).Sum(d => d.Type == "Received" ? d.Amount : -d.Amount) }),
            Invoices = invoices.Select(x => new { x.Id, x.ContractId, x.Year, x.Month, x.DueDate, x.Total, x.Status, x.CancellationReason,
                Items = x.Items.Select(i => new { i.Id, i.Description, i.Quantity, i.UnitPrice, i.Amount }),
                Paid = payments.Where(p => p.InvoiceId == x.Id).Sum(p => p.Amount),
                Outstanding = x.Status == "Cancelled" ? 0 : x.Total - payments.Where(p => p.InvoiceId == x.Id).Sum(p => p.Amount) }),
            Payments = payments.Select(x => new { x.Id, x.InvoiceId, x.Amount, x.Method, x.PaidDate }),
            Deposits = deposits.Select(x => new { x.Id, x.ContractId, x.Type, x.Amount, x.Note, x.CreatedAt }),
            Incidents = await db.Incidents.Where(x => x.ReportedByTenantId == tenantId).OrderByDescending(x => x.Id)
                .Select(x => new { x.Id, x.RoomId, x.Description, x.Status, x.Resolution, x.CreatedAt }).ToListAsync()
        };
    }

    public async Task<object> ReportIncident(TenantIncidentRequest r)
    {
        var tenantId = await CurrentTenantId();
        Require(await db.ContractTenants.AnyAsync(x => x.TenantId == tenantId && x.ContractId == r.ContractId), "Bạn không có quyền với hợp đồng này.", 403);
        var contract = await db.Contracts.SingleAsync(x => x.Id == r.ContractId);
        Require(contract.Status == "Active", "Chỉ gửi yêu cầu cho hợp đồng đang thuê.");
        var incident = new Incident { RoomId = contract.RoomId, ReportedByTenantId = tenantId, Description = Text(r.Description, "Nội dung yêu cầu", 2000) };
        db.Incidents.Add(incident);
        await Save("tenant.incident", $"Hợp đồng #{contract.Id}, người thuê #{tenantId}");
        return new { incident.Id, incident.Status };
    }
}
