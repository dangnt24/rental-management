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
        if (r.Details is { } d)
        {
            Require(d.Area == null || d.Area is > 0 and <= 5000 && decimal.Round(d.Area.Value, 3) == d.Area, "Diện tích phải lớn hơn 0, tối đa 5.000 m² và tối đa 3 số lẻ.");
            Require(d.MaxVehicles == null || d.MaxVehicles is >= 0 and <= 50, "Số xe từ 0 đến 50.");
            Require(d.MinimumLeaseMonths == null || d.MinimumLeaseMonths is >= 1 and <= 120, "Thời hạn thuê tối thiểu từ 1 đến 120 tháng.");
            if (d.SuggestedDeposit.HasValue) Money(d.SuggestedDeposit.Value);
            var amenities = (d.Amenities ?? []).Distinct().ToArray();
            Require(amenities.All(x => new[] { "Bed", "Mattress", "Wardrobe", "Elevator", "Wifi", "AirConditioner", "Kitchen", "WaterHeater", "Refrigerator", "Mezzanine" }.Contains(x)), "Tiện nghi không hợp lệ.");
            Require(d.AmenitiesConfirmed || amenities.Length == 0, "Cần xác nhận danh sách tiện nghi khi chọn thiết bị.");
            var roomType = Text(d.RoomType, "Loại phòng", 50, false);
            var toilet = Text(d.ToiletType, "Nhà vệ sinh", 20, false);
            var laundry = Text(d.LaundryType, "Máy giặt", 20, false);
            var parking = Text(d.ParkingType, "Chỗ để xe", 20, false);
            Require(new[] { "", "Room", "Studio", "Apartment" }.Contains(roomType), "Loại phòng không hợp lệ.");
            Require(new[] { "", "Private", "Shared" }.Contains(toilet), "Thông tin nhà vệ sinh không hợp lệ.");
            Require(new[] { "", "None", "Private", "Shared" }.Contains(laundry), "Thông tin máy giặt không hợp lệ.");
            Require(new[] { "", "None", "Private", "Shared" }.Contains(parking), "Thông tin chỗ để xe không hợp lệ.");
            Require(parking != "None" || d.MaxVehicles is null or 0, "Phòng không có chỗ để xe thì số xe tối đa phải là 0 hoặc chưa cập nhật.");
            var phone = Text(d.ContactPhone, "Điện thoại liên hệ công khai", 20, false);
            Require(phone.Length == 0 || System.Text.RegularExpressions.Regex.IsMatch(phone, @"^\+?[0-9][0-9 .()\-]{6,19}$"), "Số điện thoại liên hệ không hợp lệ.");
            entity.Area = d.Area;
            entity.Floor = Text(d.Floor, "Tầng / vị trí", 60, false);
            entity.RoomType = roomType;
            entity.Amenities = amenities;
            entity.AmenitiesConfirmed = d.AmenitiesConfirmed;
            entity.ToiletType = toilet;
            entity.AccessHours = Text(d.AccessHours, "Giờ giấc", 200, false);
            entity.LaundryType = laundry;
            entity.ParkingType = parking;
            entity.MaxVehicles = d.MaxVehicles;
            entity.PetsAllowed = d.PetsAllowed;
            entity.ElectricVehiclesAllowed = d.ElectricVehiclesAllowed;
            entity.HasWindow = d.HasWindow;
            entity.HasBalcony = d.HasBalcony;
            entity.SuggestedDeposit = d.SuggestedDeposit;
            entity.MinimumLeaseMonths = d.MinimumLeaseMonths;
            entity.Neighborhood = Text(d.Neighborhood, "Khu vực xung quanh", 2000, false);
            entity.RentalConditions = Text(d.RentalConditions, "Điều kiện thuê", 2000, false);
            entity.ContactName = Text(d.ContactName, "Tên liên hệ công khai", 100, false);
            entity.ContactPhone = phone;
        }
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
