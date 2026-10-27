using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Tenants;
/// <summary>Hồ sơ người thuê; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class TenantService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertTenant(int? id, TenantRequest r)
    {
        await CheckBranch(r.BranchId);
        var entity = id.HasValue ? await db.Tenants.FindAsync(id.Value) ?? throw new BusinessError("Không tìm thấy người thuê.", 404) : new Tenant();
        if (id.HasValue)
        {
            await CheckBranch(entity.BranchId);
            Require(entity.BranchId == r.BranchId, "Không chuyển khu của hồ sơ đã tạo.");
        }

        entity.BranchId = r.BranchId;
        entity.FullName = Text(r.FullName, "Họ tên", 100);
        entity.Phone = Text(r.Phone, "Số điện thoại", 20);
        entity.IdentityNumber = Text(r.IdentityNumber, "Số giấy tờ", 30, false);
        entity.Address = Text(r.Address, "Địa chỉ", 500, false);
        if (!id.HasValue)
            db.Tenants.Add(entity);
        await Save("tenant.save", $"Người thuê #{entity.Id}");
        return entity;
    }
}
