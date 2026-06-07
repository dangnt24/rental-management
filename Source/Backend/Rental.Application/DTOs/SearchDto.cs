using System;
using System.Collections.Generic;

namespace Rental.Application.DTOs
{
    public class SearchRequest
    {
        public string? Keyword { get; set; }
        public string? StatusCode { get; set; }
        public int? BranchId { get; set; }
        public int? RoomId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public decimal? MinAmount { get; set; }
        public decimal? MaxAmount { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }

    public class ContractSearchResult
    {
        public int Id { get; set; }
        public string ContractCode { get; set; }
        public string RoomName { get; set; }
        public string TenantName { get; set; }
        public string TenantPhone { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public decimal ActualRentPrice { get; set; }
        public string StatusCode { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    public class PaymentSearchResult
    {
        public int Id { get; set; }
        public string InvoiceCode { get; set; }
        public string RoomName { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public string MethodCode { get; set; }
        public string Remark { get; set; }
    }

    public class IncidentSearchResult
    {
        public int Id { get; set; }
        public string RoomName { get; set; }
        public string Description { get; set; }
        public string PriorityCode { get; set; }
        public string StatusCode { get; set; }
        public decimal RepairCost { get; set; }
        public DateTime ReportedDate { get; set; }
        public DateTime? ResolvedDate { get; set; }
        public string TenantName { get; set; }
    }

    public class TenantSearchResult
    {
        public int Id { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string IdentityNumber { get; set; }
        public string Email { get; set; }
        public string StatusCode { get; set; }
        public string RoomName { get; set; }
    }

    public class RoomSearchResult
    {
        public int Id { get; set; }
        public string RoomName { get; set; }
        public string BranchName { get; set; }
        public decimal Price { get; set; }
        public int MaxOccupants { get; set; }
        public string StatusCode { get; set; }
    }

    public class InvoiceSearchResult
    {
        public int Id { get; set; }
        public string InvoiceCode { get; set; }
        public string RoomName { get; set; }
        public int BillingMonth { get; set; }
        public int BillingYear { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal Remaining => TotalAmount - PaidAmount;
        public string StatusCode { get; set; }
        public DateTime? DueDate { get; set; }
    }

    public class RevenueReportDto
    {
        public int Year { get; set; }
        public List<MonthlyRevenue> MonthlyRevenues { get; set; } = new();
        public decimal TotalRevenue => TotalRentRevenue + TotalUtilityRevenue + TotalOtherRevenue;
        public decimal TotalRentRevenue { get; set; }
        public decimal TotalUtilityRevenue { get; set; }
        public decimal TotalOtherRevenue { get; set; }
    }

    public class MonthlyRevenue
    {
        public int Month { get; set; }
        public decimal RentRevenue { get; set; }
        public decimal UtilityRevenue { get; set; }
        public decimal OtherRevenue { get; set; }
        public decimal Total => RentRevenue + UtilityRevenue + OtherRevenue;
    }

    public class OccupancyReportDto
    {
        public int TotalRooms { get; set; }
        public int RentedRooms { get; set; }
        public int EmptyRooms { get; set; }
        public int MaintenanceRooms { get; set; }
        public double OccupancyRate => TotalRooms > 0 ? Math.Round((double)RentedRooms / TotalRooms * 100, 2) : 0;
        public List<BranchOccupancy> BranchDetails { get; set; } = new();
    }

    public class BranchOccupancy
    {
        public string BranchName { get; set; }
        public int TotalRooms { get; set; }
        public int RentedRooms { get; set; }
        public double OccupancyRate => TotalRooms > 0 ? Math.Round((double)RentedRooms / TotalRooms * 100, 2) : 0;
    }

    public class OverdueReportDto
    {
        public int TotalOverdue { get; set; }
        public decimal TotalOverdueAmount { get; set; }
        public List<OverdueInvoiceItem> Items { get; set; } = new();
    }

    public class OverdueInvoiceItem
    {
        public int InvoiceId { get; set; }
        public string InvoiceCode { get; set; }
        public string RoomName { get; set; }
        public string TenantName { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal Remaining => TotalAmount - PaidAmount;
        public DateTime DueDate { get; set; }
        public int OverdueDays => (DateTime.UtcNow - DueDate).Days;
    }

    public class IncidentSummaryDto
    {
        public int TotalIncidents { get; set; }
        public int ResolvedCount { get; set; }
        public int PendingCount { get; set; }
        public decimal TotalRepairCost { get; set; }
        public List<IncidentByPriority> ByPriority { get; set; } = new();
    }

    public class IncidentByPriority
    {
        public string PriorityCode { get; set; }
        public int Count { get; set; }
    }
}
