using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Rooms;
/// <summary>Phòng trọ; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class RoomService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertRoom(int? id, RoomRequest r)
    {
        await CheckBranch(r.BranchId);
        Money(r.Price);
        Require(r.Capacity is >= 1 and <= 50, "Sức chứa từ 1 đến 50 người.");
        var entity = id.HasValue ? await Room(id.Value) : new Room();
        if (id.HasValue)
        {
            Require(entity.BranchId == r.BranchId, "Không chuyển khu của phòng đã tạo.");
            var contract = await db.Contracts.SingleOrDefaultAsync(x => x.RoomId == id && x.Status == "Active");
            Require(contract == null || !r.IsMaintenance, "Phòng đang thuê không thể chuyển sang đang sửa.");
            if (contract != null)
                Require(await db.ContractTenants.CountAsync(x => x.ContractId == contract.Id) <= r.Capacity, "Sức chứa nhỏ hơn số người đang ở.");
        }

        entity.BranchId = r.BranchId;
        entity.Name = Text(r.Name, "Tên phòng", 50);
        entity.Price = r.Price;
        entity.Capacity = r.Capacity;
        entity.IsMaintenance = r.IsMaintenance;
        entity.Description = Text(r.Description, "Mô tả", 2000, false);
        if (!id.HasValue)
            db.Rooms.Add(entity);
        await Save("room.save", entity.Name);
        return entity;
    }

    public async Task ArchiveRoom(int id)
    {
        var room = await Room(id);
        Require(!await db.Contracts.AnyAsync(x => x.RoomId == id && x.Status == "Active"), "Cần quyết toán hợp đồng trước khi ngừng sử dụng phòng.");
        room.IsArchived = true;
        await Save("room.archive", $"Phòng #{id}");
    }
}
