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
    public class BillingController : ControllerBase
    {
        private readonly IBillingService _billingService;

        public BillingController(IBillingService billingService)
        {
            _billingService = billingService;
        }

        [HttpPost("record-reading")]
        public async Task<IActionResult> RecordReading([FromBody] UtilityReadingDto readingDto)
        {
            var result = await _billingService.RecordReadingAsync(readingDto);
            return Ok(result);
        }

        [HttpPost("generate-invoice")]
        public async Task<IActionResult> GenerateInvoice(int contractId, int month, int year)
        {
            var result = await _billingService.GenerateMonthlyInvoiceAsync(contractId, month, year);
            return Ok(result);
        }

        [HttpGet("unpaid")]
        public async Task<IActionResult> GetUnpaid()
        {
            var result = await _billingService.GetUnpaidInvoicesAsync();
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var result = await _dashboardService.GetSummaryStatsAsync();
            return Ok(result);
        }
    }
}
