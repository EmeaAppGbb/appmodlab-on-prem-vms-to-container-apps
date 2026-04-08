using System;
using Microsoft.EntityFrameworkCore;
using PawsCare.Web.Models;

namespace PawsCare.Web.Data
{
    public class PawsCareDbContext : DbContext
    {
        public PawsCareDbContext(DbContextOptions<PawsCareDbContext> options)
            : base(options)
        {
        }

        public DbSet<Owner> Owners { get; set; }
        public DbSet<VetStaff> VetStaff { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Seed initial data
            SeedData(modelBuilder);
        }
        
        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed Owners
            modelBuilder.Entity<Owner>().HasData(
                new Owner { Id = 1, FirstName = "John", LastName = "Smith", Email = "john.smith@email.com", Phone = "555-0101", Address = "123 Main St, Seattle, WA" },
                new Owner { Id = 2, FirstName = "Sarah", LastName = "Johnson", Email = "sarah.j@email.com", Phone = "555-0102", Address = "456 Oak Ave, Portland, OR" },
                new Owner { Id = 3, FirstName = "Michael", LastName = "Brown", Email = "mbrown@email.com", Phone = "555-0103", Address = "789 Pine Rd, Spokane, WA" },
                new Owner { Id = 4, FirstName = "Emily", LastName = "Davis", Email = "emily.davis@email.com", Phone = "555-0104", Address = "321 Elm St, Tacoma, WA" },
                new Owner { Id = 5, FirstName = "David", LastName = "Wilson", Email = "dwilson@email.com", Phone = "555-0105", Address = "654 Maple Dr, Eugene, OR" },
                new Owner { Id = 6, FirstName = "Jennifer", LastName = "Martinez", Email = "jmartinez@email.com", Phone = "555-0106", Address = "987 Cedar Ln, Bellevue, WA" },
                new Owner { Id = 7, FirstName = "Robert", LastName = "Anderson", Email = "randerson@email.com", Phone = "555-0107", Address = "147 Birch Way, Olympia, WA" },
                new Owner { Id = 8, FirstName = "Lisa", LastName = "Taylor", Email = "ltaylor@email.com", Phone = "555-0108", Address = "258 Spruce Ct, Salem, OR" },
                new Owner { Id = 9, FirstName = "William", LastName = "Thomas", Email = "wthomas@email.com", Phone = "555-0109", Address = "369 Willow Ave, Redmond, WA" },
                new Owner { Id = 10, FirstName = "Amanda", LastName = "Garcia", Email = "agarcia@email.com", Phone = "555-0110", Address = "741 Aspen Blvd, Bend, OR" }
            );
            
            // Seed Vet Staff
            modelBuilder.Entity<VetStaff>().HasData(
                new VetStaff { Id = 1, FirstName = "Dr. Rebecca", LastName = "Foster", Specialization = "General Practice", Email = "rfoster@pawscare.vet", Phone = "555-0201", LicenseNumber = "VET-WA-1001" },
                new VetStaff { Id = 2, FirstName = "Dr. James", LastName = "Chen", Specialization = "Surgery", Email = "jchen@pawscare.vet", Phone = "555-0202", LicenseNumber = "VET-WA-1002" },
                new VetStaff { Id = 3, FirstName = "Dr. Maria", LastName = "Rodriguez", Specialization = "Exotic Animals", Email = "mrodriguez@pawscare.vet", Phone = "555-0203", LicenseNumber = "VET-OR-2001" },
                new VetStaff { Id = 4, FirstName = "Dr. Kevin", LastName = "Patel", Specialization = "Cardiology", Email = "kpatel@pawscare.vet", Phone = "555-0204", LicenseNumber = "VET-WA-1003" },
                new VetStaff { Id = 5, FirstName = "Dr. Linda", LastName = "Kim", Specialization = "Dermatology", Email = "lkim@pawscare.vet", Phone = "555-0205", LicenseNumber = "VET-WA-1004" }
            );
        }
    }
}
