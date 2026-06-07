using Rental.Core;
using System;

namespace Rental.Domain.Entities
{
    /// <summary>
    /// Bảng quản lý danh mục chung (Trạng thái, Giới tính...).
    /// </summary>
    public class Common : BaseEntity
    {
        public string Type { get; set; }
        public string Code { get; set; }
        public string NameVi { get; set; }
        public string NameEn { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
        public string Remark { get; set; }
    }

    /// <summary>
    /// Quản lý cấu hình sinh mã tự động.
    /// </summary>
    public class DocumentSetting
    {
        public int Id { get; set; }
        public string TransactionType { get; set; }
        public string Prefix { get; set; }
        public string DateFormat { get; set; }
        public int NumberDigits { get; set; }
        public int CurrentNumber { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int Version { get; set; } = 1;
    }

    /// <summary>
    /// Quản lý file đính kèm.
    /// </summary>
    public class FileAttachment : BaseEntityGuid
    {
        public string TableName { get; set; }
        public int RefId { get; set; }
        public string FileName { get; set; }
        public string FilePath { get; set; }
        public string FileType { get; set; }
        public long FileSize { get; set; }
    }
}
