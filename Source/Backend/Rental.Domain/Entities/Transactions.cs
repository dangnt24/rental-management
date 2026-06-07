using Rental.Core;
using System;
using System.Collections.Generic;

namespace Rental.Domain.Entities
{
    /// <summary>
    /// Thực thể Hợp đồng thuê phòng.
    /// </summary>
    public class Contract : BaseEntity
    {
        public string ContractCode { get; set; }
        public int RoomId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal ActualRentPrice { get; set; }
        public string StatusCode { get; set; }
        public string Remark { get; set; }

        public virtual Room Room { get; set; }
        public virtual ICollection<ContractDetail> ContractDetails { get; set; }
        public virtual ICollection<Invoice> Invoices { get; set; }
    }

    public class ContractDetail
    {
        public int ContractId { get; set; }
        public int TenantId { get; set; }
        public bool IsMain { get; set; }

        public virtual Contract Contract { get; set; }
        public virtual Tenant Tenant { get; set; }
    }

    public class Invoice : BaseEntity
    {
        public string InvoiceCode { get; set; }
        public int ContractId { get; set; }
        public int BranchId { get; set; }
        public int BillingMonth { get; set; }
        public int BillingYear { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public string StatusCode { get; set; }
        public DateTime? DueDate { get; set; }

        public virtual Contract Contract { get; set; }
        public virtual ICollection<InvoiceItem> InvoiceItems { get; set; }
        public virtual ICollection<Payment> Payments { get; set; }
    }

    public class InvoiceItem : BaseEntity
    {
        public int InvoiceId { get; set; }
        public int? FeeTypeId { get; set; }
        public string Description { get; set; }
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Amount { get; set; }

        public virtual Invoice Invoice { get; set; }
        public virtual FeeType? FeeType { get; set; }
    }

    public class FeeType : BaseEntity
    {
        public int? BranchId { get; set; }
        public string FeeName { get; set; }
        public decimal UnitPrice { get; set; }
        public string CalcMethod { get; set; }
        public bool IsSystem { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class Payment : BaseEntity
    {
        public int InvoiceId { get; set; }
        public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
        public decimal Amount { get; set; }
        public string MethodCode { get; set; }
        public Guid? EvidenceId { get; set; }
        public string Remark { get; set; }

        public virtual Invoice Invoice { get; set; }
    }

    /// <summary>
    /// Thực thể Chốt chỉ số điện nước.
    /// </summary>
    public class UtilityReading : BaseEntity
    {
        public int RoomId { get; set; }
        public DateTime ReadingDate { get; set; }
        public decimal ElecIndexOld { get; set; }
        public decimal ElecIndexNew { get; set; }
        public decimal WaterIndexOld { get; set; }
        public decimal WaterIndexNew { get; set; }

        public virtual Room Room { get; set; }
    }

    /// <summary>
    /// Thực thể Quản lý sự cố.
    /// </summary>
    public class Incident : BaseEntity
    {
        public int RoomId { get; set; }
        public int TenantId { get; set; }
        public string Description { get; set; }
        public string PriorityCode { get; set; }
        public string StatusCode { get; set; }
        public decimal RepairCost { get; set; }
        public DateTime ReportedDate { get; set; }
        public DateTime? ResolvedDate { get; set; }

        public virtual Room Room { get; set; }
        public virtual Tenant Tenant { get; set; }
    }
}
