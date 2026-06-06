using System.Collections.Generic;
using System.Threading.Tasks;
using Rental.Application.DTOs;
using Rental.Core;

namespace Rental.Application.Interfaces.Services
{
    /// <summary>
    /// Giao diện dịch vụ xác thực và phân quyền.
    /// </summary>
    public interface IAuthService
    {
        /// <summary>
        /// Đăng nhập hệ thống.
        /// </summary>
        Task<ApiResult<LoginResponse>> LoginAsync(LoginRequest request);

        /// <summary>
        /// Làm mới Access Token bằng Refresh Token.
        /// </summary>
        Task<ApiResult<LoginResponse>> RefreshTokenAsync(string refreshToken);
        
        /// <summary>
        /// Đăng xuất.
        /// </summary>
        Task<ApiResult<bool>> LogoutAsync(int userId);
    }

    /// <summary>
    /// Giao diện dịch vụ quản lý Người dùng.
    /// </summary>
    public interface IUserService
    {
        Task<ApiResult<UserDto>> GetByIdAsync(int id);
        Task<ApiResult<PagedResult<UserDto>>> GetPagedListAsync(int pageNumber, int pageSize, string searchTerm);
    }
}
