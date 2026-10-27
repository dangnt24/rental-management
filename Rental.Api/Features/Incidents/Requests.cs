namespace Rental.Api.Features.Incidents;
public record IncidentRequest(int RoomId, string Description, string Status, string Resolution, long Cost);
