using System;

namespace PawsCare.Web.Models
{
    public class Patient
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Species { get; set; }
        public string Breed { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string OwnerId { get; set; }
        public string OwnerName { get; set; }
        public string MicrochipNumber { get; set; }
        public string Notes { get; set; }
    }
}
