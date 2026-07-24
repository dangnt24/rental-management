using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Constants;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICommonService _commonService;

        public DashboardService(IUnitOfWork unitOfWork, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _commonService = commonService;
        }

        public async Task<ApiResult<DashboardStatsDto>> GetSummaryStatsAsync()
        {
            var totalRooms = await _unitOfWork.Rooms.Find(r => true).CountAsync();
            var rentedRooms = await _unitOfWork.Rooms.Find(r => r.StatusCode == RoomStatus.Rented).CountAsync();
            var emptyRooms = await _unitOfWork.Rooms.Find(r => r.StatusCode == RoomStatus.Empty).CountAsync();

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
