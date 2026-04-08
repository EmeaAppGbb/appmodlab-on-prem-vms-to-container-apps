using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PawsCare.Web.Data;
using PawsCare.Web.Models;
using System.Threading.Tasks;

namespace PawsCare.Web.Controllers
{
    public class OwnerController : Controller
    {
        private readonly ILogger<OwnerController> _logger;
        private readonly PawsCareDbContext _dbContext;

        public OwnerController(ILogger<OwnerController> logger, PawsCareDbContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            var owners = await _dbContext.Owners.ToListAsync();
            return View(owners);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(Owner owner)
        {
            if (ModelState.IsValid)
            {
                _dbContext.Owners.Add(owner);
                await _dbContext.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(owner);
        }

        public async Task<IActionResult> Details(int id)
        {
            var owner = await _dbContext.Owners.FindAsync(id);
            if (owner == null)
            {
                return NotFound();
            }
            return View(owner);
        }
    }
}
