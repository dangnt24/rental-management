using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Fees;
/// <summary>Đơn giá và loại phí; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class FeeService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertFee(int? id, FeeRequest r)
    {
        OwnerOnly();
        await CheckBranch(r.BranchId);
        Money(r.UnitPrice);
        Require(new[] { "Electricity", "Water", "Fixed", "PerPerson" }.Contains(r.Method), "Cách tính phí không hợp lệ.");
        var entity = id.HasValue ? await db.Fees.FindAsync(id.Value) ?? throw new BusinessError("Không tìm thấy phí.", 404) : new Fee();
        entity.BranchId = r.BranchId;
        entity.Name = Text(r.Name, "Tên phí", 100);
        entity.Method = r.Method;
        entity.UnitPrice = r.UnitPrice;
        entity.IsArchived = r.IsArchived;
        if (!id.HasValue)
            db.Fees.Add(entity);
        await Save("fee.save", entity.Name);
        return entity;
    }
}
