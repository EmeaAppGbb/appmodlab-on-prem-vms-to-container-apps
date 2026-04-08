using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using PawsCare.Web.Services;
using PawsCare.Web.Models;
using System.Threading.Tasks;

namespace PawsCare.Web.Controllers
{
    public class AppointmentController : Controller
    {
        private readonly ILogger<AppointmentController> _logger;
        private readonly IApiService _apiService;

        public AppointmentController(ILogger<AppointmentController> logger, IApiService apiService)
        {
            _logger = logger;
            _apiService = apiService;
        }

        public async Task<IActionResult> Index()
        {
            var appointments = await _apiService.GetAppointmentsAsync();
            return View(appointments);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(Appointment appointment)
        {
            if (ModelState.IsValid)
            {
                var result = await _apiService.CreateAppointmentAsync(appointment);
                if (result != null)
                {
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Failed to create appointment");
            }
            return View(appointment);
        }

        public async Task<IActionResult> Details(string id)
        {
            var appointment = await _apiService.GetAppointmentByIdAsync(id);
            if (appointment == null)
            {
                return NotFound();
            }
            return View(appointment);
        }
    }
}
