using Rental.Application.DTOs;
using Rental.Core;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface ISearchService
    {
        Task<ApiResult<PagedResult<ContractSearchResult>>> SearchContractsAsync(SearchRequest request);
        Task<ApiResult<PagedResult<PaymentSearchResult>>> SearchPaymentsAsync(SearchRequest request);
        Task<ApiResult<PagedResult<IncidentSearchResult>>> SearchIncidentsAsync(SearchRequest request);
        Task<ApiResult<PagedResult<TenantSearchResult>>> SearchTenantsAsync(SearchRequest request);
        Task<ApiResult<PagedResult<RoomSearchResult>>> SearchRoomsAsync(SearchRequest request);
        Task<ApiResult<PagedResult<InvoiceSearchResult>>> SearchInvoicesAsync(SearchRequest request);
    }
}
