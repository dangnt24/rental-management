using Microsoft.EntityFrameworkCore;
using Rental.Application.DTOs;
using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Core;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class MenuService : IMenuService
    {
        private readonly IUnitOfWork _unitOfWork;

        public MenuService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResult<List<MenuItemDto>>> GetMenusAsync(string roleCode)
        {
            var menus = await _unitOfWork.Commons
                .Find(m => m.Type == "MENU_ITEM" && m.IsActive)
                .OrderBy(m => m.SortOrder)
                .ToListAsync();

            var userPermissions = await _unitOfWork.RolePermissions
                .Find(rp => rp.RoleCode == roleCode)
                .Select(rp => rp.PermissionCode)
                .ToListAsync();

            var result = menus.Select(m => new MenuItemDto
            {
                Code = m.Code,
                Name = m.NameVi,
                Icon = m.Remark ?? "Circle",
                Route = "/" + m.Code.ToLower(),
                SortOrder = m.SortOrder
            }).ToList();

            return ApiResult<List<MenuItemDto>>.Success(result);
        }
    }
}
