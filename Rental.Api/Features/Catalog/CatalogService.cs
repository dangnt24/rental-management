using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Catalog;

/// <summary>Thông tin công khai của phòng còn trống; không trả hồ sơ hay chứng từ.</summary>
public sealed class CatalogService(RentalDb db)
{
    public IQueryable<Room> AvailableRooms() => db.Rooms.AsNoTracking().Where(r =>
        !r.IsArchived && !r.IsMaintenance &&
        db.Branches.Any(b => b.Id == r.BranchId && !b.IsArchived) &&
        !db.Contracts.Any(c => c.RoomId == r.Id && c.Status == "Active"));

    public async Task<object> Browse(string? q, int? branchId, long? minPrice, long? maxPrice, int? capacity, string? sort)
    {
        Require(q == null || q.Length <= 200, "Từ khóa tối đa 200 ký tự.");
        Require((minPrice == null || minPrice >= 0) && (maxPrice == null || maxPrice >= 0), "Giá lọc không được âm.");
        Require(minPrice == null || maxPrice == null || minPrice <= maxPrice, "Giá tối đa phải lớn hơn hoặc bằng giá tối thiểu.");
        Require(capacity == null || capacity is >= 1 and <= 50, "Số người từ 1 đến 50.");
        Require(sort == null || new[] { "priceAsc", "priceDesc", "name" }.Contains(sort), "Cách sắp xếp không hợp lệ.");
        var query = AvailableRooms();
        if (branchId.HasValue) query = query.Where(r => r.BranchId == branchId);
        if (minPrice.HasValue) query = query.Where(r => r.Price >= minPrice);
        if (maxPrice.HasValue) query = query.Where(r => r.Price <= maxPrice);
        if (capacity.HasValue) query = query.Where(r => r.Capacity >= capacity);
        if (!string.IsNullOrWhiteSpace(q))
        {
            var term = q.Trim().ToLower();
            query = query.Where(r => r.Name.ToLower().Contains(term) || r.Description.ToLower().Contains(term) ||
                db.Branches.Any(b => b.Id == r.BranchId && (b.Name.ToLower().Contains(term) || b.Address.ToLower().Contains(term))));
        }
        query = sort switch { "priceAsc" => query.OrderBy(r => r.Price).ThenBy(r => r.Id), "priceDesc" => query.OrderByDescending(r => r.Price).ThenBy(r => r.Id), _ => query.OrderBy(r => r.Name).ThenBy(r => r.Id) };
        return new
        {
            Branches = await db.Branches.AsNoTracking().Where(b => !b.IsArchived).OrderBy(b => b.Name).Select(b => new { b.Id, b.Name, b.Address }).ToListAsync(),
            Rooms = await query.Select(r => new
            {
                r.Id, r.BranchId, r.Name, r.Price, r.Capacity, r.Description,
                r.Area, r.Floor, r.RoomType, r.Amenities, r.AmenitiesConfirmed, r.ToiletType, r.AccessHours,
                r.LaundryType, r.ParkingType, r.MaxVehicles, r.PetsAllowed, r.ElectricVehiclesAllowed,
                r.HasWindow, r.HasBalcony, r.SuggestedDeposit, r.MinimumLeaseMonths, r.Neighborhood,
                r.RentalConditions, r.ContactName, r.ContactPhone,
                Branch = db.Branches.Where(b => b.Id == r.BranchId).Select(b => new { b.Name, b.Address }).Single(),
                Photos = db.Attachments.Where(a => !a.IsArchived && a.EntityType == "room" && a.EntityId == r.Id && a.IsPublic && (a.ContentType == "image/jpeg" || a.ContentType == "image/png"))
                    .OrderBy(a => a.SortOrder).ThenBy(a => a.Id).Select(a => new { a.Id, a.SortOrder }).ToList(),
                Fees = db.Fees.Where(f => f.BranchId == r.BranchId && !f.IsArchived).Select(f => new { f.Name, f.Method, f.UnitPrice }).ToList()
            }).ToListAsync()
        };
    }

    public async Task<Attachment> Photo(int roomId, int id)
    {
        Require(await AvailableRooms().AnyAsync(r => r.Id == roomId), "Phòng không còn được đăng cho thuê.", 404);
        return await db.Attachments.AsNoTracking().SingleOrDefaultAsync(a => !a.IsArchived && a.Id == id && a.EntityId == roomId && a.EntityType == "room" && a.IsPublic && (a.ContentType == "image/jpeg" || a.ContentType == "image/png"))
            ?? throw new BusinessError("Không tìm thấy ảnh công khai.", 404);
    }
}
