using Microsoft.AspNetCore.Mvc;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;

namespace Rental.Web.Controllers
{
    public class HomeController : Controller
    {
        private readonly IDashboardService _dashboardService;

        public HomeController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        public async Task<IActionResult> Index()
        {
            var stats = await _dashboardService.GetSummaryStatsAsync();
            return View(stats.Data);
        }
    }

    public class AccountController : Controller
    {
        private readonly IAuthService _authService;

        public AccountController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpGet]
        public IActionResult Login() => View();

        [HttpPost]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var result = await _authService.LoginAsync(request);
            if (result.IsSuccess)
            {
                HttpContext.Session.SetString("Token", result.Data.AccessToken);
                HttpContext.Session.SetString("UserName", result.Data.User.FullName);
                HttpContext.Session.SetString("RoleCode", result.Data.User.RoleCode);
                return RedirectToAction("Index", "Home");
            }
            ViewBag.Error = result.Message;
            return View();
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }
    }
}
