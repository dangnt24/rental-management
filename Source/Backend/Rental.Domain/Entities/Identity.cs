using Rental.Core;
using System;
using System.Collections.Generic;

namespace Rental.Domain.Entities
{
    /// <summary>
    /// Thực thể Người dùng hệ thống.
    /// </summary>
    public class User : BaseEntity
    {
        /// <summary>
        /// Tên đăng nhập.
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        /// Mật khẩu đã mã hóa.
        /// </summary>
        public string PasswordHash { get; set; }

        /// <summary>
        /// Họ và tên đầy đủ.
        /// </summary>
        public string FullName { get; set; }

        /// <summary>
        /// Địa chỉ Email.
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// Số điện thoại.
        /// </summary>
        public string Phone { get; set; }

        /// <summary>
        /// Mã vai trò (Role Code).
        /// </summary>
        public string RoleCode { get; set; }

        /// <summary>
        /// Trạng thái hoạt động.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Thời điểm đăng nhập cuối cùng.
        /// </summary>
        public DateTime? LastLogin { get; set; }

        /// <summary>
        /// Token để làm mới Access Token.
        /// </summary>
        public string RefreshToken { get; set; }

        /// <summary>
        /// Thời hạn của Refresh Token.
        /// </summary>
        public DateTime? RefreshTokenExpiry { get; set; }

        // Navigation properties
        public virtual Role Role { get; set; }
    }

    /// <summary>
    /// Thực thể Vai trò.
    /// </summary>
    public class Role : BaseEntity
    {
        /// <summary>
        /// Mã vai trò.
        /// </summary>
        public string RoleCode { get; set; }

        /// <summary>
        /// Tên vai trò.
        /// </summary>
        public string RoleName { get; set; }

        /// <summary>
        /// Đánh dấu là vai trò mặc định của hệ thống.
        /// </summary>
        public bool IsSystem { get; set; }

        public virtual ICollection<User> Users { get; set; }
        public virtual ICollection<RolePermission> RolePermissions { get; set; }
    }

    /// <summary>
    /// Thực thể Quyền hạn.
    /// </summary>
    public class Permission : BaseEntity
    {
        /// <summary>
        /// Mã quyền.
        /// </summary>
        public string PermissionCode { get; set; }

        /// <summary>
        /// Tên quyền.
        /// </summary>
        public string PermissionName { get; set; }

        /// <summary>
        /// Module thuộc về.
        /// </summary>
        public string Module { get; set; }

        public virtual ICollection<RolePermission> RolePermissions { get; set; }
    }

    /// <summary>
    /// Bảng trung gian Vai trò - Quyền hạn.
    /// </summary>
    public class RolePermission
    {
        public string RoleCode { get; set; }
        public string PermissionCode { get; set; }

        public virtual Role Role { get; set; }
        public virtual Permission Permission { get; set; }
    }
}
