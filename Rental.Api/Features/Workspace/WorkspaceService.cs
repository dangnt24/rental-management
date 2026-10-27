using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Workspace;
/// <summary>Dữ liệu tổng hợp và chỉ số tổng quan; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class WorkspaceService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> Workspace()
    {
        var ids = await AllowedBranches();
        var branches = await db.Branches.AsNoTracking().Where(x => ids.Contains(x.Id)).OrderBy(x => x.Id).ToListAsync();
        var rooms = await db.Rooms.AsNoTracking().Where(x => ids.Contains(x.BranchId)).OrderBy(x => x.Name).ToListAsync();
        var roomIds = rooms.Select(x => x.Id).ToArray();
        var contracts = await db.Contracts.AsNoTracking().Where(x => roomIds.Contains(x.RoomId)).OrderByDescending(x => x.StartDate).ThenByDescending(x => x.Id).ToListAsync();
        var contractIds = contracts.Select(x => x.Id).ToArray();
        var invoices = await db.Invoices.AsNoTracking().Include(x => x.Items).Where(x => contractIds.Contains(x.ContractId)).OrderByDescending(x => x.Year).ThenByDescending(x => x.Month).ThenByDescending(x => x.Id).ToListAsync();
        var invoiceIds = invoices.Select(x => x.Id).ToArray();
        var payments = await db.Payments.AsNoTracking().Where(x => invoiceIds.Contains(x.InvoiceId)).OrderByDescending(x => x.PaidDate).ThenByDescending(x => x.Id).ToListAsync();
        var deposits = await db.DepositEntries.AsNoTracking().Where(x => contractIds.Contains(x.ContractId)).ToListAsync();
        var incidents = await db.Incidents.AsNoTracking().Where(x => roomIds.Contains(x.RoomId)).OrderByDescending(x => x.Id).ToListAsync();
        var tenants = await db.Tenants.AsNoTracking().Where(x => ids.Contains(x.BranchId)).OrderBy(x => x.FullName).ToListAsync();
        var tenantIds = tenants.Select(x => x.Id).ToArray();
        var paymentIds = payments.Select(x => x.Id).ToArray();
        var incidentIds = incidents.Select(x => x.Id).ToArray();
        var attachments = await db.Attachments.AsNoTracking().Where(x => (x.EntityType == "room" && roomIds.Contains(x.EntityId)) || (x.EntityType == "tenant" && tenantIds.Contains(x.EntityId)) || (x.EntityType == "contract" && contractIds.Contains(x.EntityId)) || (x.EntityType == "incident" && incidentIds.Contains(x.EntityId)) || (x.EntityType == "payment" && paymentIds.Contains(x.EntityId))).Select(x => new { x.Id, x.EntityType, x.EntityId, x.OriginalName, x.ContentType, x.Size, x.IsPublic }).ToListAsync();
        var bills = invoices.Select(x => new { x.Id, x.ContractId, x.Year, x.Month, x.DueDate, x.Total, x.Status, x.CancellationReason, x.Items, Paid = payments.Where(p => p.InvoiceId == x.Id).Sum(p => p.Amount), Outstanding = x.Status == "Cancelled" ? 0 : x.Total - payments.Where(p => p.InvoiceId == x.Id).Sum(p => p.Amount) }).ToList();
        var currentBills = bills.Where(x => x.Status == "Issued" && x.Year == Today.Year && x.Month == Today.Month).ToList();
        var active = contracts.Where(x => x.Status == "Active").ToList();
        var available = rooms.Count(x => !x.IsArchived && !x.IsMaintenance && active.All(c => c.RoomId != x.Id));
        return new
        {
            Today,
            Branches = branches,
            Rooms = rooms.Select(x => new { x.Id, x.BranchId, x.Name, x.Price, x.Capacity, x.Description, x.IsMaintenance, x.IsArchived, Status = x.IsArchived ? "Archived" : active.Any(c => c.RoomId == x.Id) ? "Occupied" : x.IsMaintenance ? "Maintenance" : "Available" }),
            Tenants = tenants,
            Contracts = contracts.Select(x => new { x.Id, x.RoomId, x.StartDate, x.EndDate, x.ClosedDate, x.Rent, x.Deposit, x.Status, x.Note, DepositBalance = deposits.Where(d => d.ContractId == x.Id).Sum(d => d.Type == "Received" ? d.Amount : -d.Amount) }),
            ContractTenants = await db.ContractTenants.AsNoTracking().Where(x => contractIds.Contains(x.ContractId)).ToListAsync(),
            Fees = await db.Fees.AsNoTracking().Where(x => ids.Contains(x.BranchId)).OrderBy(x => x.Id).ToListAsync(),
            Readings = await db.Readings.AsNoTracking().Where(x => contractIds.Contains(x.ContractId)).OrderByDescending(x => x.Year).ThenByDescending(x => x.Month).ToListAsync(),
            Invoices = bills,
            Payments = payments,
            Deposits = deposits,
            Incidents = incidents,
            Attachments = attachments,
            Summary = new
            {
                TotalRooms = rooms.Count(x => !x.IsArchived),
                OccupiedRooms = active.Count,
                AvailableRooms = available,
                MaintenanceRooms = rooms.Count(x => !x.IsArchived && x.IsMaintenance),
                MonthlyBilled = currentBills.Sum(x => x.Total),
                MonthlyCollected = payments.Where(x => x.PaidDate.Year == Today.Year && x.PaidDate.Month == Today.Month).Sum(x => x.Amount),
                Outstanding = bills.Sum(x => x.Outstanding),
                Overdue = bills.Where(x => x.DueDate < Today).Sum(x => x.Outstanding),
                ExpiringContracts = active.Count(x => x.EndDate <= Today.AddDays(30)),
                OpenIncidents = incidents.Count(x => x.Status != "Resolved")
            },
            Users = IsOwner ? await db.Users.AsNoTracking().Select(x => new { x.Id, x.Username, x.FullName, x.Role, x.IsActive, x.TenantId }).ToListAsync() : null,
            UserBranches = IsOwner ? await db.UserBranches.AsNoTracking().ToListAsync() : null,
            Audit = IsOwner ? await db.AuditEntries.AsNoTracking().OrderByDescending(x => x.Id).Take(30).ToListAsync() : null
        };
    }
}
