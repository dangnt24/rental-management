using Rental.Core;
using System.Collections.Generic;

namespace Rental.Domain.Entities
{
    /// <summary>
    /// Thực thể Chi nhánh / Dãy trọ.
    /// </summary>
    public class Branch : BaseEntity
    {
        public string BranchName { get; set; }
        public string Address { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; } = true;

        public virtual ICollection<Room> Rooms { get; set; }
        public virtual ICollection<FeeType> FeeTypes { get; set; }
    }

    /// <summary>
    /// Thực thể Phòng trọ.
    /// </summary>
    public class Room : BaseEntity
    {
        public int BranchId { get; set; }
        public string RoomName { get; set; }
        public decimal Price { get; set; }
        public int MaxOccupants { get; set; }
        public string StatusCode { get; set; }
        public string Description { get; set; }

        public virtual Branch Branch { get; set; }
        public virtual ICollection<Contract> Contracts { get; set; }
    }

    /// <summary>
    /// Thực thể Người thuê.
    /// </summary>
    public class Tenant : BaseEntity
    {
        public int? UserId { get; set; }
        public string FullName { get; set; }
        public string IdentityNumber { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public System.DateTime? DateOfBirth { get; set; }
        public string GenderCode { get; set; }
        public string Hometown { get; set; }
        public string AddressTemporary { get; set; }
        public bool IsRepresentative { get; set; }
        public string StatusCode { get; set; }

        public virtual User User { get; set; }
        public virtual ICollection<ContractDetail> ContractDetails { get; set; }
    }
}
