using Rental.Application.DTOs;
using Rental.Core;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface IMenuService
    {
        Task<ApiResult<List<MenuItemDto>>> GetMenusAsync(string roleCode);
    }
}
