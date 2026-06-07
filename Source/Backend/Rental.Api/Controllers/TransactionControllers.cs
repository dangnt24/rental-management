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
    public class ContractController : ControllerBase
    {
        private readonly IContractService _contractService;

        public ContractController(IContractService contractService)
        {
            _contractService = contractService;
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? statusCode = null, int? roomId = null)
        {
            var result = await _contractService.GetPagedListAsync(pageNumber, pageSize, statusCode, roomId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _contractService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ContractDto dto)
        {
            var result = await _contractService.CreateContractAsync(dto);
            return Ok(result);
        }

        [HttpPost("{id}/terminate")]
        public async Task<IActionResult> Terminate(int id)
        {
            var result = await _contractService.TerminateContractAsync(id);
            return Ok(result);
        }

        [HttpGet("by-room/{roomId}")]
        public async Task<IActionResult> GetByRoom(int roomId)
        {
            var result = await _contractService.GetActiveContractByRoomAsync(roomId);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost]
        public async Task<IActionResult> ProcessPayment([FromBody] PaymentDto dto)
        {
            var result = await _paymentService.ProcessPaymentAsync(dto);
            return Ok(result);
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, int? invoiceId = null)
        {
            var result = await _paymentService.GetPagedListAsync(pageNumber, pageSize, invoiceId);
            return Ok(result);
        }
    }

    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class InvoiceController : ControllerBase
    {
        private readonly IBillingService _billingService;

        public InvoiceController(IBillingService billingService)
        {
            _billingService = billingService;
        }

        [HttpGet("unpaid")]
        public async Task<IActionResult> GetUnpaid()
        {
            var result = await _billingService.GetUnpaidInvoicesAsync();
            return Ok(result);
        }

        [HttpPost("generate")]
        public async Task<IActionResult> Generate(int contractId, int month, int year)
        {
            var result = await _billingService.GenerateMonthlyInvoiceAsync(contractId, month, year);
            return Ok(result);
        }

        [HttpGet("GetPagedList")]
        public async Task<IActionResult> GetPagedList(int pageNumber = 1, int pageSize = 10, string? statusCode = null, int? branchId = null)
        {
            var result = await _billingService.GetPagedUnpaidListAsync(pageNumber, pageSize, statusCode, branchId);
            return Ok(result);
        }
    }
}
