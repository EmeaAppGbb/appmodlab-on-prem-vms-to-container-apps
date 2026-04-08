using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PawsCare.Web.Data;
using PawsCare.Web.Services;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace PawsCare.Web.Controllers
{
    public class DashboardController : Controller
    {
        private readonly ILogger<DashboardController> _logger;
        private readonly PawsCareDbContext _dbContext;
        private readonly IApiService _apiService;

        public DashboardController(
            ILogger<DashboardController> logger,
            PawsCareDbContext dbContext,
            IApiService apiService)
        {
            _logger = logger;
            _dbContext = dbContext;
            _apiService = apiService;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                ViewBag.TotalOwners = await _dbContext.Owners.CountAsync();
                ViewBag.TotalVets = await _dbContext.VetStaff.CountAsync();
                
                var patients = await _apiService.GetPatientsAsync();
                ViewBag.TotalPatients = patients?.Count ?? 0;
                
                var appointments = await _apiService.GetAppointmentsAsync();
                var today = DateTime.Today;
                ViewBag.TodayAppointments = appointments?.Count(a => 
                    DateTime.Parse(a.AppointmentDate.ToString()).Date == today) ?? 0;
                
                ViewBag.RecentAppointments = appointments?
                    .OrderByDescending(a => a.AppointmentDate)
                    .Take(5)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading dashboard");
                ViewBag.Error = "Unable to load dashboard data. Please check if all services are running.";
            }

            return View();
        }
    }
}
