using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Common;
/// <summary>DbContext theo request, kiểm tra phạm vi truy cập và lưu audit dùng chung.</summary>
public abstract class FeatureService(RentalDb database, IHttpContextAccessor accessor)
{
    protected RentalDb db { get; } = database;
    private ClaimsPrincipal Principal => accessor.HttpContext!.User;
    public bool IsOwner => Principal.IsInRole("Owner");
    protected int UserId => int.Parse(Principal.FindFirstValue(ClaimTypes.NameIdentifier)!);
    protected string Actor => Principal.Identity?.Name ?? "system";

    public void OwnerOnly() => Require(IsOwner, "Chỉ chủ trọ được thực hiện thao tác này.", 403);
    public async Task<int[]> AllowedBranches() => IsOwner ? await db.Branches.Select(x => x.Id).ToArrayAsync() : await db.UserBranches.Where(x => x.UserId == UserId).Select(x => x.BranchId).ToArrayAsync();
    public async Task CheckBranch(int id)
    {
        Require(await db.Branches.AnyAsync(x => x.Id == id && !x.IsArchived), "Không tìm thấy khu trọ.", 404);
        Require(IsOwner || await db.UserBranches.AnyAsync(x => x.UserId == UserId && x.BranchId == id), "Bạn không có quyền truy cập khu trọ này.", 403);
    }

    protected async Task<Room> Room(int id)
    {
        var room = await db.Rooms.FindAsync(id) ?? throw new BusinessError("Không tìm thấy phòng.", 404);
        await CheckBranch(room.BranchId);
        return room;
    }

    protected async Task<Contract> Contract(int id)
    {
        var contract = await db.Contracts.FindAsync(id) ?? throw new BusinessError("Không tìm thấy hợp đồng.", 404);
        await Room(contract.RoomId);
        return contract;
    }

    protected async Task<Invoice> Invoice(int id)
    {
        var invoice = await db.Invoices.Include(x => x.Items).SingleOrDefaultAsync(x => x.Id == id) ?? throw new BusinessError("Không tìm thấy hóa đơn.", 404);
        await Contract(invoice.ContractId);
        return invoice;
    }

    public async Task Save(string action, string detail)
    {
        foreach (var entry in db.ChangeTracker.Entries<Entity>().Where(x => x.State == EntityState.Added))
            entry.Entity.CreatedBy = Actor;
        db.AuditEntries.Add(new AuditEntry { Action = action, Detail = detail, CreatedBy = Actor });
        await db.SaveChangesAsync();
    }
}
