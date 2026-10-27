using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Attachments;
/// <summary>Phạm vi quyền truy cập file; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class AttachmentService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task CheckAttachmentScope(string type, int id)
    {
        switch (type)
        {
            case "room":
                await Room(id);
                break;
            case "contract":
                await Contract(id);
                break;
            case "tenant":
                var tenant = await db.Tenants.FindAsync(id) ?? throw new BusinessError("Không tìm thấy người thuê.", 404);
                await CheckBranch(tenant.BranchId);
                break;
            case "incident":
                var incident = await db.Incidents.FindAsync(id) ?? throw new BusinessError("Không tìm thấy sự cố.", 404);
                await Room(incident.RoomId);
                break;
            case "payment":
                var payment = await db.Payments.FindAsync(id) ?? throw new BusinessError("Không tìm thấy thanh toán.", 404);
                await Invoice(payment.InvoiceId);
                break;
            default:
                throw new BusinessError("Loại file đính kèm không hợp lệ.");
        }
    }
}
