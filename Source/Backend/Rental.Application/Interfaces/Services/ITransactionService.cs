using Rental.Application.DTOs;
using Rental.Core;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface IContractService
    {
        Task<ApiResult<ContractDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<ContractDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId);
        Task<ApiResult<ContractDto>> CreateContractAsync(ContractDto contractDto);
        Task<ApiResult<bool>> TerminateContractAsync(int contractId);
        Task<ApiResult<ContractDto>> GetActiveContractByRoomAsync(int roomId);
    }

    public interface IBillingService
    {
        /// <summary>
        /// Nhập chỉ số điện nước và tự động tính tiêu thụ.
        /// </summary>
        Task<ApiResult<UtilityReadingDto>> RecordReadingAsync(UtilityReadingDto readingDto);

        /// <summary>
        /// Chốt tiền phòng hàng tháng (Billing Engine).
        /// </summary>
        Task<ApiResult<InvoiceDto>> GenerateMonthlyInvoiceAsync(int contractId, int month, int year);

        /// <summary>
        /// Lấy danh sách phòng chưa đóng tiền.
        /// </summary>
        Task<ApiResult<List<InvoiceDto>>> GetUnpaidInvoicesAsync();
        Task<ApiResult<PagedResult<InvoiceDto>>> GetPagedUnpaidListAsync(int pageNumber, int pageSize, string? statusCode, int? branchId);
    }

    public interface IPaymentService
    {
        Task<ApiResult<PaymentDto>> ProcessPaymentAsync(PaymentDto paymentDto);
        Task<ApiResult<PagedResult<PaymentDto>>> GetPagedListAsync(int pageNumber, int pageSize, int? invoiceId);
    }

    public interface IIncidentService
    {
        Task<ApiResult<IncidentDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<IncidentDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId);
        Task<ApiResult<IncidentDto>> CreateAsync(IncidentDto dto);
        Task<ApiResult<IncidentDto>> UpdateAsync(IncidentDto dto);
        Task<ApiResult<bool>> DeleteAsync(int id);
    }

    public interface IDashboardService
    {
        Task<ApiResult<DashboardStatsDto>> GetSummaryStatsAsync();
    }
}
