using System;

namespace Rental.Application.DTOs
{
    /// <summary>
    /// DTO thông tin Phòng.
    /// </summary>
    public class RoomDto : BaseDto
    {
        public int BranchId { get; set; }
        public string RoomName { get; set; }
        public decimal Price { get; set; }
        public int MaxOccupants { get; set; }
        public string StatusCode { get; set; }
        public string Description { get; set; }
        public string? ImageUrl { get; set; }
    }

    /// <summary>
    /// DTO thông tin Người thuê.
    /// </summary>
    public class TenantDto : BaseDto
    {
        public int? UserId { get; set; }
        public string FullName { get; set; }
        public string IdentityNumber { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string GenderCode { get; set; }
        public string Hometown { get; set; }
        public string AddressTemporary { get; set; }
        public bool IsRepresentative { get; set; }
        public string StatusCode { get; set; }
        public string? AvatarUrl { get; set; }
        public string? IdCardImageUrl { get; set; }
    }

    /// <summary>
    /// DTO thông tin Chi nhánh/Dãy trọ.
    /// </summary>
    public class BranchDto : BaseDto
    {
        public string BranchName { get; set; }
        public string Address { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }

    public class FeeTypeDto : BaseDto
    {
        public int? BranchId { get; set; }
        public string FeeName { get; set; }
        public decimal UnitPrice { get; set; }
        public string CalcMethod { get; set; }
        public bool IsSystem { get; set; }
        public bool IsActive { get; set; }
    }
}
