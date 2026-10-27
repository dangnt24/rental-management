using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Incidents;
/// <summary>Sự cố và bảo trì; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class IncidentService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertIncident(int? id, IncidentRequest r)
    {
        await Room(r.RoomId);
        Money(r.Cost);
        Require(new[] { "Open", "InProgress", "Resolved" }.Contains(r.Status), "Trạng thái sự cố không hợp lệ.");
        var entity = id.HasValue ? await db.Incidents.FindAsync(id.Value) ?? throw new BusinessError("Không tìm thấy sự cố.", 404) : new Incident();
        if (id.HasValue)
        {
            await Room(entity.RoomId);
            Require(entity.ReportedByTenantId == null || entity.RoomId == r.RoomId, "Không chuyển phòng của yêu cầu do người thuê gửi.");
        }
        entity.RoomId = r.RoomId;
        entity.Description = Text(r.Description, "Nội dung sự cố", 2000);
        entity.Status = r.Status;
        entity.Resolution = Text(r.Resolution, "Cách xử lý", 2000, r.Status == "Resolved");
        entity.Cost = r.Cost;
        if (!id.HasValue)
            db.Incidents.Add(entity);
        await Save("incident.save", $"Phòng #{r.RoomId}, trạng thái {r.Status}");
        return entity;
    }
}
