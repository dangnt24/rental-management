using Rental.Application.DTOs;
using Rental.Core;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface IReportService
    {
        Task<ApiResult<RevenueReportDto>> GetRevenueReportAsync(int year);
        Task<ApiResult<OccupancyReportDto>> GetOccupancyReportAsync(int? branchId);
        Task<ApiResult<OverdueReportDto>> GetOverdueReportAsync(int? branchId);
        Task<ApiResult<IncidentSummaryDto>> GetIncidentSummaryAsync(int? branchId, int? month, int? year);
    }
}
