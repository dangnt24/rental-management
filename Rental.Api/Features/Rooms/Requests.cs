namespace Rental.Api.Features.Rooms;
public record RoomRequest(int BranchId, string Name, long Price, int Capacity, bool IsMaintenance, string Description, RoomDetailsRequest? Details = null);

// Details không gửi: giữ thông tin cũ. Có gửi: cập nhật toàn bộ nhóm thông tin chi tiết.
public record RoomDetailsRequest(
    decimal? Area = null, string? Floor = null, string? RoomType = null,
    string[]? Amenities = null, bool AmenitiesConfirmed = false,
    string? ToiletType = null, string? AccessHours = null, string? LaundryType = null,
    string? ParkingType = null, int? MaxVehicles = null,
    bool? PetsAllowed = null, bool? ElectricVehiclesAllowed = null,
    bool? HasWindow = null, bool? HasBalcony = null,
    long? SuggestedDeposit = null, int? MinimumLeaseMonths = null,
    string? Neighborhood = null, string? RentalConditions = null,
    string? ContactName = null, string? ContactPhone = null);
