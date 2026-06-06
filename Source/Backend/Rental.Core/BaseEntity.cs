using System;

namespace Rental.Core
{
    /// <summary>
    /// Lớp cơ sở cho tất cả các thực thể trong hệ thống.
    /// Bao gồm các trường kiểm tra (Audit Fields) và hỗ trợ Soft Delete.
    /// </summary>
    public abstract class BaseEntity
    {
        /// <summary>
        /// ID định danh duy nhất (Primary Key).
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Người tạo bản ghi.
        /// </summary>
        public string CreatedBy { get; set; }

        /// <summary>
        /// Thời điểm tạo bản ghi.
        /// </summary>
        public DateTime CreatedDate { get; set; } = DateTime.Now;

        /// <summary>
        /// Người cập nhật cuối cùng.
        /// </summary>
        public string UpdatedBy { get; set; }

        /// <summary>
        /// Thời điểm cập nhật cuối cùng.
        /// </summary>
        public DateTime? UpdatedDate { get; set; }

        /// <summary>
        /// Người thực hiện xóa (Soft Delete).
        /// </summary>
        public string DeletedBy { get; set; }

        /// <summary>
        /// Thời điểm thực hiện xóa (Soft Delete).
        /// </summary>
        public DateTime? DeletedDate { get; set; }

        /// <summary>
        /// Đánh dấu bản ghi đã bị xóa hay chưa.
        /// </summary>
        public bool IsDeleted { get; set; } = false;

        /// <summary>
        /// Phiên bản của bản ghi (Dùng để kiểm soát tranh chấp dữ liệu - Optimistic Concurrency).
        /// </summary>
        public int Version { get; set; } = 1;
    }

    /// <summary>
    /// Lớp cơ sở cho thực thể sử dụng Guid làm khóa chính.
    /// </summary>
    public abstract class BaseEntityGuid
    {
        /// <summary>
        /// ID định danh duy nhất (Guid).
        /// </summary>
        public Guid Id { get; set; } = Guid.NewGuid();

        public string CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public string UpdatedBy { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public string DeletedBy { get; set; }
        public DateTime? DeletedDate { get; set; }
        public bool IsDeleted { get; set; } = false;
        public int Version { get; set; } = 1;
    }
}
