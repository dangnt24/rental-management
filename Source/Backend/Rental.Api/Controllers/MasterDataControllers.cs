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
    public class RoomController : ControllerBase
    {
        private readonly IRoomService _roomService;

        public RoomController(IRoomService roomService)
        {
            _roomService = roomService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? searchTerm = null, string? statusCode = null, int? branchId = null)
        {
            var result = await _roomService.GetPagedListAsync(pageNumber, pageSize, searchTerm, statusCode, branchId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _roomService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] RoomDto roomDto)
        {
            var result = await _roomService.CreateAsync(roomDto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] RoomDto roomDto)
        {
            var result = await _roomService.UpdateAsync(roomDto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _roomService.DeleteAsync(id);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TenantController : ControllerBase
    {
        private readonly ITenantService _tenantService;

        public TenantController(ITenantService tenantService)
        {
            _tenantService = tenantService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? searchTerm = null)
        {
            var result = await _tenantService.GetPagedListAsync(pageNumber, pageSize, searchTerm);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _tenantService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] TenantDto tenantDto)
        {
            var result = await _tenantService.CreateAsync(tenantDto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] TenantDto tenantDto)
        {
            var result = await _tenantService.UpdateAsync(tenantDto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _tenantService.DeleteAsync(id);
            return Ok(result);
        }
    }
}
