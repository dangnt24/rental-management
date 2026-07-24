using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Constants;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace Rental.Application.Services
{
    public class ReportService : IReportService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommonService _commonService;

        public ReportService(IUnitOfWork unitOfWork, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _commonService = commonService;
        }

        public async Task<ApiResult<RevenueReportDto>> GetRevenueReportAsync(int year)
        {
            var invoices = await _unitOfWork.Invoices
                .Find(i => i.BillingYear == year && i.StatusCode == InvoiceStatus.Paid)
                .Include(i => i.InvoiceItems)
                .ToListAsync();

            var systemFees = await _unitOfWork.FeeTypes
                .Find(f => f.IsSystem)
                .ToListAsync();

            var rentFeeIds = systemFees
                .Where(f => f.FeeName == SystemFeeNames.Rent)
                .Select(f => f.Id)
                .ToHashSet();

            var utilityFeeNames = new HashSet<string> { SystemFeeNames.Electricity, SystemFeeNames.Water };

            var monthlyRevenues = new List<MonthlyRevenue>();

            for (int m = 1; m <= 12; m++)
            {
                var monthInvoices = invoices.Where(i => i.BillingMonth == m).ToList();
                var allItems = monthInvoices.SelectMany(i => i.InvoiceItems ?? new List<Domain.Entities.InvoiceItem>()).ToList();

                monthlyRevenues.Add(new MonthlyRevenue
                {
                    Month = m,
                    RentRevenue = allItems
                        .Where(item => item.FeeTypeId.HasValue && rentFeeIds.Contains(item.FeeTypeId.Value))
                        .Sum(item => item.Amount),
                    UtilityRevenue = allItems
                        .Where(item => item.FeeTypeId.HasValue && systemFees.Any(sf => sf.Id == item.FeeTypeId && utilityFeeNames.Contains(sf.FeeName)))
                        .Sum(item => item.Amount),
                    OtherRevenue = allItems
                        .Where(item => !item.FeeTypeId.HasValue ||
                            !rentFeeIds.Contains(item.FeeTypeId.Value) &&
                            !systemFees.Any(sf => sf.Id == item.FeeTypeId && utilityFeeNames.Contains(sf.FeeName)))
                        .Sum(item => item.Amount)
                });
            }

            var dto = new RevenueReportDto
            {
                Year = year,
                MonthlyRevenues = monthlyRevenues,
                TotalRentRevenue = monthlyRevenues.Sum(m => m.RentRevenue),
                TotalUtilityRevenue = monthlyRevenues.Sum(m => m.UtilityRevenue),
                TotalOtherRevenue = monthlyRevenues.Sum(m => m.OtherRevenue)
            };

            return ApiResult<RevenueReportDto>.Success(dto);
        }

        public async Task<ApiResult<OccupancyReportDto>> GetOccupancyReportAsync(int? branchId)
        {
            var roomsQuery = _unitOfWork.Rooms.Find(r => true).Include(r => r.Branch).AsQueryable();
            if (branchId.HasValue)
                roomsQuery = roomsQuery.Where(r => r.BranchId == branchId.Value);

            var rooms = await roomsQuery.ToListAsync();

            var branchGroups = rooms.GroupBy(r => r.Branch?.BranchName ?? "N/A");
            var branchDetails = branchGroups.Select(g => new BranchOccupancy
            {
                BranchName = g.Key,
                TotalRooms = g.Count(),
                RentedRooms = g.Count(r => r.StatusCode == RoomStatus.Rented)
            }).ToList();

            var dto = new OccupancyReportDto
            {
                TotalRooms = rooms.Count,
                RentedRooms = rooms.Count(r => r.StatusCode == RoomStatus.Rented),
                EmptyRooms = rooms.Count(r => r.StatusCode == RoomStatus.Empty),
                MaintenanceRooms = rooms.Count(r => r.StatusCode == RoomStatus.Maintenance),
                BranchDetails = branchDetails
            };

            return ApiResult<OccupancyReportDto>.Success(dto);
        }

        public async Task<ApiResult<OverdueReportDto>> GetOverdueReportAsync(int? branchId)
        {
            var now = DateTime.UtcNow;
            var query = _unitOfWork.Invoices
                .Find(i => i.StatusCode != InvoiceStatus.Paid && i.DueDate < now)
                .Include(i => i.Contract).ThenInclude(c => c.Room)
                .Include(i => i.Contract).ThenInclude(c => c.ContractDetails).ThenInclude(cd => cd.Tenant)
                .AsQueryable();

            if (branchId.HasValue)
                query = query.Where(i => i.BranchId == branchId.Value);

            var invoices = await query.ToListAsync();

            var dto = new OverdueReportDto
            {
                TotalOverdue = invoices.Count,
                TotalOverdueAmount = invoices.Sum(i => i.TotalAmount - i.PaidAmount),
                Items = invoices.Select(i => new OverdueInvoiceItem
                {
                    InvoiceId = i.Id,
                    InvoiceCode = i.InvoiceCode,
                    RoomName = i.Contract?.Room?.RoomName ?? "",
                    TenantName = i.Contract?.ContractDetails?.FirstOrDefault()?.Tenant?.FullName ?? "",
                    TotalAmount = i.TotalAmount,
                    PaidAmount = i.PaidAmount,
                    DueDate = i.DueDate ?? now
                }).OrderByDescending(x => x.OverdueDays).ToList()
            };

            return ApiResult<OverdueReportDto>.Success(dto);
        }

        public async Task<ApiResult<IncidentSummaryDto>> GetIncidentSummaryAsync(int? branchId, int? month, int? year)
        {
            var query = _unitOfWork.Incidents
                .Find(i => true)
                .Include(i => i.Room)
                .AsQueryable();

            if (branchId.HasValue)
                query = query.Where(i => i.Room.BranchId == branchId.Value);
            if (month.HasValue)
                query = query.Where(i => i.ReportedDate.Month == month.Value);
            if (year.HasValue)
                query = query.Where(i => i.ReportedDate.Year == year.Value);

            var incidents = await query.ToListAsync();

            var dto = new IncidentSummaryDto
            {
                TotalIncidents = incidents.Count,
                ResolvedCount = incidents.Count(i => i.StatusCode == IncidentStatus.Resolved),
                PendingCount = incidents.Count(i => i.StatusCode == IncidentStatus.Pending),
                TotalRepairCost = incidents.Sum(i => i.RepairCost),
                ByPriority = incidents
                    .GroupBy(i => i.PriorityCode)
                    .Select(g => new IncidentByPriority { PriorityCode = g.Key, Count = g.Count() })
                    .ToList()
            };

            return ApiResult<IncidentSummaryDto>.Success(dto);
        }
    }
}
