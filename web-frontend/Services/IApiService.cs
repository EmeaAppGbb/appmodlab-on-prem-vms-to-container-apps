using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PawsCare.Web.Models;

namespace PawsCare.Web.Services
{
    public interface IApiService
    {
        Task<List<Patient>> GetPatientsAsync();
        Task<Patient> GetPatientByIdAsync(string id);
        Task<Patient> CreatePatientAsync(Patient patient);
        Task<List<Appointment>> GetAppointmentsAsync();
        Task<Appointment> GetAppointmentByIdAsync(string id);
        Task<Appointment> CreateAppointmentAsync(Appointment appointment);
        Task<bool> UploadLabResultAsync(string patientId, string fileName, byte[] fileData);
    }
}
