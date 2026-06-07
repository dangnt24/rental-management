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
    public class IncidentController : ControllerBase
    {
        private readonly IIncidentService _incidentService;

        public IncidentController(IIncidentService incidentService)
        {
            _incidentService = incidentService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? statusCode = null, int? roomId = null)
        {
            var result = await _incidentService.GetPagedListAsync(pageNumber, pageSize, statusCode, roomId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _incidentService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] IncidentDto dto)
        {
            var result = await _incidentService.CreateAsync(dto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] IncidentDto dto)
        {
            var result = await _incidentService.UpdateAsync(dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _incidentService.DeleteAsync(id);
            return Ok(result);
        }
    }

    [Authorize(Roles = "ADMIN")]
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? searchTerm = null)
        {
            var result = await _userService.GetPagedListAsync(pageNumber, pageSize, searchTerm);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _userService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] UserDto dto)
        {
            var result = await _userService.CreateAsync(dto);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UserDto dto)
        {
            var result = await _userService.UpdateAsync(dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _userService.DeleteAsync(id);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService _searchService;

        public SearchController(ISearchService searchService)
        {
            _searchService = searchService;
        }

        [HttpPost("contracts")]
        public async Task<IActionResult> SearchContracts([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchContractsAsync(request);
            return Ok(result);
        }

        [HttpPost("payments")]
        public async Task<IActionResult> SearchPayments([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchPaymentsAsync(request);
            return Ok(result);
        }

        [HttpPost("incidents")]
        public async Task<IActionResult> SearchIncidents([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchIncidentsAsync(request);
            return Ok(result);
        }

        [HttpPost("tenants")]
        public async Task<IActionResult> SearchTenants([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchTenantsAsync(request);
            return Ok(result);
        }

        [HttpPost("rooms")]
        public async Task<IActionResult> SearchRooms([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchRoomsAsync(request);
            return Ok(result);
        }

        [HttpPost("invoices")]
        public async Task<IActionResult> SearchInvoices([FromBody] SearchRequest request)
        {
            var result = await _searchService.SearchInvoicesAsync(request);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("revenue/{year}")]
        public async Task<IActionResult> GetRevenueReport(int year)
        {
            var result = await _reportService.GetRevenueReportAsync(year);
            return Ok(result);
        }

        [HttpGet("occupancy")]
        public async Task<IActionResult> GetOccupancyReport(int? branchId = null)
        {
            var result = await _reportService.GetOccupancyReportAsync(branchId);
            return Ok(result);
        }

        [HttpGet("overdue")]
        public async Task<IActionResult> GetOverdueReport(int? branchId = null)
        {
            var result = await _reportService.GetOverdueReportAsync(branchId);
            return Ok(result);
        }

        [HttpGet("incidents")]
        public async Task<IActionResult> GetIncidentSummary(int? branchId = null, int? month = null, int? year = null)
        {
            var result = await _reportService.GetIncidentSummaryAsync(branchId, month, year);
            return Ok(result);
        }
    }
}
