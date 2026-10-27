using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Branches;
/// <summary>Khu trọ; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class BranchService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertBranch(int? id, BranchRequest r)
    {
        OwnerOnly();
        var entity = id.HasValue ? await db.Branches.FindAsync(id.Value) ?? throw new BusinessError("Không tìm thấy khu trọ.", 404) : new Branch();
        entity.Name = Text(r.Name, "Tên khu trọ", 100);
        entity.Address = Text(r.Address, "Địa chỉ", 500);
        if (!id.HasValue)
            db.Branches.Add(entity);
        await Save("branch.save", entity.Name);
        return entity;
    }
}
