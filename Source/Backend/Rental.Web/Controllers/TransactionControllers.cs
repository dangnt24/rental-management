using Microsoft.AspNetCore.Mvc;
using Rental.Application.DTOs;
using Rental.Application.Interfaces.Services;

namespace Rental.Web.Controllers
{
    public class BillingController : Controller
    {
        private readonly IBillingService _billingService;

        public BillingController(IBillingService billingService)
        {
            _billingService = billingService;
        }

        public async Task<IActionResult> Index(string? statusCode = null, int? branchId = null, int page = 1)
        {
            var result = await _billingService.GetPagedUnpaidListAsync(page, 10, statusCode, branchId);
            ViewBag.StatusCode = statusCode;
            ViewBag.BranchId = branchId;
            return View(result.Data);
        }

        public async Task<IActionResult> Unpaid()
        {
            var result = await _billingService.GetUnpaidInvoicesAsync();
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> GenerateInvoice(int contractId, int month, int year)
        {
            await _billingService.GenerateMonthlyInvoiceAsync(contractId, month, year);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> RecordReading(UtilityReadingDto dto)
        {
            await _billingService.RecordReadingAsync(dto);
            return RedirectToAction("Index");
        }
    }

    public class PaymentController : Controller
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        public async Task<IActionResult> Index(int? invoiceId = null, int page = 1)
        {
            var result = await _paymentService.GetPagedListAsync(page, 10, invoiceId);
            ViewBag.InvoiceId = invoiceId;
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> Process(PaymentDto dto)
        {
            await _paymentService.ProcessPaymentAsync(dto);
            return RedirectToAction("Index");
        }
    }

    public class IncidentController : Controller
    {
        private readonly IIncidentService _incidentService;

        public IncidentController(IIncidentService incidentService)
        {
            _incidentService = incidentService;
        }

        public async Task<IActionResult> Index(string? statusCode = null, int? roomId = null, int page = 1)
        {
            var result = await _incidentService.GetPagedListAsync(page, 10, statusCode, roomId);
            ViewBag.StatusCode = statusCode;
            ViewBag.RoomId = roomId;
            return View(result.Data);
        }

        public async Task<IActionResult> Details(int id)
        {
            var result = await _incidentService.GetByIdAsync(id);
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(IncidentDto dto)
        {
            await _incidentService.CreateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Update(IncidentDto dto)
        {
            await _incidentService.UpdateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            await _incidentService.DeleteAsync(id);
            return RedirectToAction("Index");
        }
    }
}
