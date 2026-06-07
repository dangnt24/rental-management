using Rental.Core;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rental.Domain.Entities
{
    /// <summary>
    /// Thực thể Người dùng hệ thống.
    /// </summary>
    public class User : BaseEntity
    {
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        
        /// <summary>
        /// Khóa ngoại liên kết với bảng Vai trò.
        /// </summary>
        public string RoleCode { get; set; }

        public bool IsActive { get; set; } = true;
        public DateTime? LastLogin { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiry { get; set; }

        // Navigation properties
        [ForeignKey("RoleCode")]
        public virtual Role Role { get; set; }
    }

    /// <summary>
    /// Thực thể Vai trò.
    /// Sử dụng RoleCode làm khóa chính.
    /// </summary>
    public class Role
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string RoleCode { get; set; }
        public string RoleName { get; set; }
        public bool IsSystem { get; set; }

        public string? CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public string? UpdatedBy { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public string? DeletedBy { get; set; }
        public DateTime? DeletedDate { get; set; }
        public bool IsDeleted { get; set; } = false;
        public int Version { get; set; } = 1;

        public virtual ICollection<User> Users { get; set; }
        public virtual ICollection<RolePermission> RolePermissions { get; set; }
    }

    /// <summary>
    /// Thực thể Quyền hạn.
    /// </summary>
    public class Permission
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string PermissionCode { get; set; }
        public string PermissionName { get; set; }
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

        [ForeignKey("RoleCode")]
        public virtual Role Role { get; set; }
        
        [ForeignKey("PermissionCode")]
        public virtual Permission Permission { get; set; }
    }
}
