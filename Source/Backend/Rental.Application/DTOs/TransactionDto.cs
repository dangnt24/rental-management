using System;
using System.Collections.Generic;

namespace Rental.Application.DTOs
{
    public class ContractDto : BaseDto
    {
        public string ContractCode { get; set; }
        public int RoomId { get; set; }
        public string RoomName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal ActualRentPrice { get; set; }
        public string StatusCode { get; set; }
        public string Remark { get; set; }
        public List<TenantDto> Tenants { get; set; } = new List<TenantDto>();
    }

    public class UtilityReadingDto : BaseDto
    {
        public int RoomId { get; set; }
        public string RoomName { get; set; }
        public DateTime ReadingDate { get; set; }
        public decimal ElecIndexOld { get; set; }
        public decimal ElecIndexNew { get; set; }
        public decimal WaterIndexOld { get; set; }
        public decimal WaterIndexNew { get; set; }
        public decimal ElecConsumption => ElecIndexNew - ElecIndexOld;
        public decimal WaterConsumption => WaterIndexNew - WaterIndexOld;
    }

    public class InvoiceDto : BaseDto
    {
        public string InvoiceCode { get; set; }
        public int ContractId { get; set; }
        public string RoomName { get; set; }
        public int BillingMonth { get; set; }
        public int BillingYear { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal RemainingAmount => TotalAmount - PaidAmount;
        public string StatusCode { get; set; }
        public DateTime? DueDate { get; set; }
        public List<InvoiceItemDto> Items { get; set; } = new List<InvoiceItemDto>();
    }

    public class InvoiceItemDto
    {
        public int Id { get; set; }
        public int FeeTypeId { get; set; }
        public string FeeName { get; set; }
        public string Description { get; set; }
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Amount { get; set; }
    }

    public class PaymentDto : BaseDto
    {
        public int InvoiceId { get; set; }
        public string InvoiceCode { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string MethodCode { get; set; }
        public string Remark { get; set; }
    }

    public class IncidentDto : BaseDto
    {
        public int RoomId { get; set; }
        public string RoomName { get; set; }
        public int TenantId { get; set; }
        public string TenantName { get; set; }
        public string Description { get; set; }
        public string PriorityCode { get; set; }
        public string StatusCode { get; set; }
        public decimal RepairCost { get; set; }
        public DateTime ReportedDate { get; set; }
        public DateTime? ResolvedDate { get; set; }
    }

    public class DashboardStatsDto
    {
        public int TotalRooms { get; set; }
        public int RentedRooms { get; set; }
        public int EmptyRooms { get; set; }
        public decimal MonthlyRevenue { get; set; }
    }
}
