using Microsoft.AspNetCore.Mvc;
using Rental.Application.DTOs;
using Rental.Application.Interfaces.Services;
using Rental.Core;

namespace Rental.Web.Controllers
{
    public class RoomController : Controller
    {
        private readonly IRoomService _roomService;

        public RoomController(IRoomService roomService)
        {
            _roomService = roomService;
        }

        public async Task<IActionResult> Index(string? searchTerm = null, string? statusCode = null, int? branchId = null, int page = 1)
        {
            var result = await _roomService.GetPagedListAsync(page, 10, searchTerm, statusCode, branchId);
            ViewBag.SearchTerm = searchTerm;
            ViewBag.StatusCode = statusCode;
            ViewBag.BranchId = branchId;
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(RoomDto dto)
        {
            await _roomService.CreateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Edit(RoomDto dto)
        {
            await _roomService.UpdateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            await _roomService.DeleteAsync(id);
            return RedirectToAction("Index");
        }
    }

    public class TenantController : Controller
    {
        private readonly ITenantService _tenantService;

        public TenantController(ITenantService tenantService)
        {
            _tenantService = tenantService;
        }

        public async Task<IActionResult> Index(string? searchTerm = null, int page = 1)
        {
            var result = await _tenantService.GetPagedListAsync(page, 10, searchTerm);
            ViewBag.SearchTerm = searchTerm;
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(TenantDto dto)
        {
            await _tenantService.CreateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Edit(TenantDto dto)
        {
            await _tenantService.UpdateAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            await _tenantService.DeleteAsync(id);
            return RedirectToAction("Index");
        }
    }

    public class ContractController : Controller
    {
        private readonly IContractService _contractService;

        public ContractController(IContractService contractService)
        {
            _contractService = contractService;
        }

        public async Task<IActionResult> Index(string? statusCode = null, int? roomId = null, int page = 1)
        {
            var result = await _contractService.GetPagedListAsync(page, 10, statusCode, roomId);
            ViewBag.StatusCode = statusCode;
            ViewBag.RoomId = roomId;
            return View(result.Data);
        }

        public async Task<IActionResult> Details(int id)
        {
            var result = await _contractService.GetByIdAsync(id);
            return View(result.Data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(ContractDto dto)
        {
            await _contractService.CreateContractAsync(dto);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Terminate(int id)
        {
            await _contractService.TerminateContractAsync(id);
            return RedirectToAction("Index");
        }
    }
}
