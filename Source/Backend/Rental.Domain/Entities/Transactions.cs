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

    /// <summary>
    /// Chi tiết người thuê trong hợp đồng.
    /// </summary>
    public class ContractDetail
    {
        public int ContractId { get; set; }
        public int TenantId { get; set; }
        public bool IsMain { get; set; }

        public virtual Contract Contract { get; set; }
        public virtual Tenant Tenant { get; set; }
    }

    /// <summary>
    /// Thực thể Hóa đơn hàng tháng.
    /// </summary>
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

    /// <summary>
    /// Chi tiết các khoản phí trong hóa đơn.
    /// </summary>
    public class InvoiceItem : BaseEntity
    {
        public int InvoiceId { get; set; }
        public int FeeTypeId { get; set; }
        public string Description { get; set; }
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Amount { get; set; }

        public virtual Invoice Invoice { get; set; }
        public virtual FeeType FeeType { get; set; }
    }

    /// <summary>
    /// Thực thể Loại phí.
    /// </summary>
    public class FeeType : BaseEntity
    {
        public int? BranchId { get; set; }
        public string FeeName { get; set; }
        public decimal UnitPrice { get; set; }
        public string CalcMethod { get; set; }
        public bool IsSystem { get; set; }
        public bool IsActive { get; set; } = true;

        public virtual Branch Branch { get; set; }
    }

    /// <summary>
    /// Lịch sử thanh toán.
    /// </summary>
    public class Payment : BaseEntity
    {
        public int InvoiceId { get; set; }
        public DateTime PaymentDate { get; set; } = DateTime.Now;
        public decimal Amount { get; set; }
        public string MethodCode { get; set; }
        public Guid? EvidenceId { get; set; }
        public string Remark { get; set; }

        public virtual Invoice Invoice { get; set; }
    }
}
