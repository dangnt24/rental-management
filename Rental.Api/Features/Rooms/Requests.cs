namespace Rental.Api.Features.Rooms;
public record RoomRequest(int BranchId, string Name, long Price, int Capacity, bool IsMaintenance, string Description);
