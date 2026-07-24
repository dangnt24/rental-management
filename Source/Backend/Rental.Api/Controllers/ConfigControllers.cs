using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rental.Application.DTOs;
using Rental.Application.Interfaces.Services;
using System.Threading.Tasks;

namespace Rental.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class BranchController : ControllerBase
    {
        private readonly IBranchService _branchService;

        public BranchController(IBranchService branchService)
        {
            _branchService = branchService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _branchService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _branchService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] BranchDto dto)
        {
            var result = await _branchService.CreateAsync(dto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] BranchDto dto)
        {
            var result = await _branchService.UpdateAsync(dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _branchService.DeleteAsync(id);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class FeeTypeController : ControllerBase
    {
        private readonly IFeeTypeService _feeTypeService;

        public FeeTypeController(IFeeTypeService feeTypeService)
        {
            _feeTypeService = feeTypeService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, int? branchId = null)
        {
            var result = await _feeTypeService.GetPagedListAsync(pageNumber, pageSize, branchId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _feeTypeService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] FeeTypeDto dto)
        {
            var result = await _feeTypeService.CreateAsync(dto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] FeeTypeDto dto)
        {
            var result = await _feeTypeService.UpdateAsync(dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _feeTypeService.DeleteAsync(id);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MenuController : ControllerBase
    {
        private readonly IMenuService _menuService;

        public MenuController(IMenuService menuService)
        {
            _menuService = menuService;
        }

        [HttpGet]
        public async Task<IActionResult> GetMenus()
        {
            var roleCode = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value ?? "STAFF";
            var result = await _menuService.GetMenusAsync(roleCode);
            return Ok(result);
        }
    }
}
