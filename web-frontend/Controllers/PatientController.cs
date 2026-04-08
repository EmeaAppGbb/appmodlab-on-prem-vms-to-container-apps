using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using PawsCare.Web.Services;
using PawsCare.Web.Models;
using System.Threading.Tasks;

namespace PawsCare.Web.Controllers
{
    public class PatientController : Controller
    {
        private readonly ILogger<PatientController> _logger;
        private readonly IApiService _apiService;

        public PatientController(ILogger<PatientController> logger, IApiService apiService)
        {
            _logger = logger;
            _apiService = apiService;
        }

        public async Task<IActionResult> Index()
        {
            var patients = await _apiService.GetPatientsAsync();
            return View(patients);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(Patient patient)
        {
            if (ModelState.IsValid)
            {
                var result = await _apiService.CreatePatientAsync(patient);
                if (result != null)
                {
                    return RedirectToAction(nameof(Index));
                }
                ModelState.AddModelError("", "Failed to create patient");
            }
            return View(patient);
        }

        public async Task<IActionResult> Details(string id)
        {
            var patient = await _apiService.GetPatientByIdAsync(id);
            if (patient == null)
            {
                return NotFound();
            }
            return View(patient);
        }
    }
}
