using Rental.Application.DTOs;
using Rental.Core;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    /// <summary>
    /// Giao diện dịch vụ quản lý Phòng.
    /// </summary>
    public interface IRoomService
    {
        Task<ApiResult<RoomDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<RoomDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm, string? statusCode, int? branchId);
        Task<ApiResult<RoomDto>> CreateAsync(RoomDto roomDto);
        Task<ApiResult<RoomDto>> UpdateAsync(RoomDto roomDto);
        Task<ApiResult<bool>> DeleteAsync(int id);
    }

    /// <summary>
    /// Giao diện dịch vụ quản lý Người thuê.
    /// </summary>
    public interface ITenantService
    {
        Task<ApiResult<TenantDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<TenantDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm);
        Task<ApiResult<TenantDto>> CreateAsync(TenantDto tenantDto);
        Task<ApiResult<TenantDto>> UpdateAsync(TenantDto tenantDto);
        Task<ApiResult<bool>> DeleteAsync(int id);
    }

    public interface IBranchService
    {
        Task<ApiResult<BranchDto>> GetByIdAsync(int id);
        Task<ApiResult<List<BranchDto>>> GetAllAsync();
        Task<ApiResult<BranchDto>> CreateAsync(BranchDto dto);
        Task<ApiResult<BranchDto>> UpdateAsync(BranchDto dto);
        Task<ApiResult<bool>> DeleteAsync(int id);
    }

    public interface IFeeTypeService
    {
        Task<ApiResult<FeeTypeDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<FeeTypeDto>>> GetPagedListAsync(int pageNumber, int pageSize, int? branchId);
        Task<ApiResult<FeeTypeDto>> CreateAsync(FeeTypeDto dto);
        Task<ApiResult<FeeTypeDto>> UpdateAsync(FeeTypeDto dto);
        Task<ApiResult<bool>> DeleteAsync(int id);
    }

}
