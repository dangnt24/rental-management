using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;
using Microsoft.AspNetCore.Identity;

namespace Rental.Api.Features.Accounts;
/// <summary>Tài khoản và phân quyền; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class UserService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> UpsertUser(int? id, UserRequest r)
    {
        OwnerOnly();
        Require(r.Role is "Owner" or "Manager" or "Tenant", "Vai trò không hợp lệ.");
        var entity = id.HasValue ? await db.Users.FindAsync(id.Value) ?? throw new BusinessError("Không tìm thấy tài khoản.", 404) : new User();
        if (id == UserId)
            Require(r.IsActive && r.Role == "Owner", "Không thể tự khóa hoặc hạ quyền tài khoản đang dùng.");
        var branchIds = r.Role == "Manager" ? r.BranchIds?.Distinct().ToArray() ?? [] : [];
        Require(await db.Branches.CountAsync(x => branchIds.Contains(x.Id) && !x.IsArchived) == branchIds.Length, "Khu trọ được phân quyền không tồn tại.");
        Require(r.Role != "Manager" || branchIds.Length > 0, "Quản lý cần được gán ít nhất một khu trọ.");
        var tenantId = r.Role == "Tenant" ? r.TenantId : null;
        if (r.Role == "Tenant")
        {
            Require(tenantId.HasValue && await db.Tenants.AnyAsync(x => x.Id == tenantId && !x.IsArchived), "Cần chọn hồ sơ người thuê hợp lệ.");
            Require(!await db.Users.AnyAsync(x => x.TenantId == tenantId && x.Id != id), "Hồ sơ người thuê này đã có tài khoản.");
        }
        entity.Username = Text(r.Username, "Tên đăng nhập", 50).ToLowerInvariant();
        entity.FullName = Text(r.FullName, "Họ tên", 100);
        entity.Role = r.Role;
        entity.TenantId = tenantId;
        entity.IsActive = r.IsActive;
        if (!id.HasValue || !string.IsNullOrEmpty(r.Password))
        {
            Require(r.Password?.Length is >= 10 and <= 128, "Mật khẩu cần từ 10 đến 128 ký tự.");
            entity.PasswordHash = new PasswordHasher<User>().HashPassword(entity, r.Password!);
        }

        if (!id.HasValue)
            db.Users.Add(entity);
        await db.SaveChangesAsync();
        db.UserBranches.RemoveRange(await db.UserBranches.Where(x => x.UserId == entity.Id).ToListAsync());
        await db.SaveChangesAsync();
        db.UserBranches.AddRange(branchIds.Select(x => new UserBranch { UserId = entity.Id, BranchId = x }));
        await Save("user.save", $"Tài khoản #{entity.Id}, {entity.Role}");
        return new
        {
            entity.Id,
            entity.Username,
            entity.Role
        };
    }

    public async Task ChangePassword(PasswordRequest r)
    {
        var user = await db.Users.FindAsync(UserId) ?? throw new BusinessError("Không tìm thấy tài khoản.", 401);
        var hasher = new PasswordHasher<User>();
        Require(hasher.VerifyHashedPassword(user, user.PasswordHash, r.CurrentPassword ?? "") != PasswordVerificationResult.Failed, "Mật khẩu hiện tại không đúng.");
        Require(r.NewPassword?.Length is >= 10 and <= 128, "Mật khẩu mới cần từ 10 đến 128 ký tự.");
        user.PasswordHash = hasher.HashPassword(user, r.NewPassword!);
        await Save("user.password", $"Tài khoản #{UserId}");
    }
}
