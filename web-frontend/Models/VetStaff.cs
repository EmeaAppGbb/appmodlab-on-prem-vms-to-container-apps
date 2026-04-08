using System.ComponentModel.DataAnnotations;

namespace PawsCare.Web.Models
{
    public class VetStaff
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [StringLength(100)]
        public string FirstName { get; set; }
        
        [Required]
        [StringLength(100)]
        public string LastName { get; set; }
        
        [Required]
        public string Specialization { get; set; }
        
        [Required]
        [EmailAddress]
        public string Email { get; set; }
        
        [Phone]
        public string Phone { get; set; }
        
        [Required]
        public string LicenseNumber { get; set; }
    }
}
