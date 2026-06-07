using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;

        public DashboardService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResult<DashboardStatsDto>> GetSummaryStatsAsync()
        {
            var totalRooms = await _unitOfWork.Rooms.Find(r => !r.IsDeleted).CountAsync();
            var rentedRooms = await _unitOfWork.Rooms.Find(r => !r.IsDeleted && r.StatusCode == "RENTED").CountAsync();
            var emptyRooms = totalRooms - rentedRooms;
            
            var currentMonth = System.DateTime.Now.Month;
            var currentYear = System.DateTime.Now.Year;
            
            var monthlyRevenue = await _unitOfWork.Invoices
                .Find(i => i.BillingMonth == currentMonth && i.BillingYear == currentYear)
                .SumAsync(i => i.PaidAmount);

            return ApiResult<DashboardStatsDto>.Success(new DashboardStatsDto
            {
                TotalRooms = totalRooms,
                RentedRooms = rentedRooms,
                EmptyRooms = emptyRooms,
                MonthlyRevenue = monthlyRevenue
            });
        }
    }
}
