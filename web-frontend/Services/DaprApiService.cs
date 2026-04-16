using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using PawsCare.Web.Models;

namespace PawsCare.Web.Services
{
    /// <summary>
    /// API service implementation that uses Dapr service invocation.
    /// Routes requests through the local Dapr sidecar instead of calling
    /// the API server directly, enabling service discovery and mTLS.
    /// </summary>
    public class DaprApiService : IApiService
    {
        private readonly HttpClient _httpClient;

        public DaprApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<Patient>> GetPatientsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("api/patients");
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<List<Patient>>(content);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error fetching patients: {ex.Message}");
                return new List<Patient>();
            }
        }

        public async Task<Patient> GetPatientByIdAsync(string id)
        {
            try
            {
                var response = await _httpClient.GetAsync($"api/patients/{id}");
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<Patient>(content);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error fetching patient: {ex.Message}");
                return null;
            }
        }

        public async Task<Patient> CreatePatientAsync(Patient patient)
        {
            try
            {
                var json = JsonConvert.SerializeObject(patient);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync("api/patients", content);
                response.EnsureSuccessStatusCode();
                var responseContent = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<Patient>(responseContent);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error creating patient: {ex.Message}");
                return null;
            }
        }

        public async Task<List<Appointment>> GetAppointmentsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("api/appointments");
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<List<Appointment>>(content);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error fetching appointments: {ex.Message}");
                return new List<Appointment>();
            }
        }

        public async Task<Appointment> GetAppointmentByIdAsync(string id)
        {
            try
            {
                var response = await _httpClient.GetAsync($"api/appointments/{id}");
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<Appointment>(content);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error fetching appointment: {ex.Message}");
                return null;
            }
        }

        public async Task<Appointment> CreateAppointmentAsync(Appointment appointment)
        {
            try
            {
                var json = JsonConvert.SerializeObject(appointment);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync("api/appointments", content);
                response.EnsureSuccessStatusCode();
                var responseContent = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<Appointment>(responseContent);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error creating appointment: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UploadLabResultAsync(string patientId, string fileName, byte[] fileData)
        {
            try
            {
                var content = new MultipartFormDataContent();
                var fileContent = new ByteArrayContent(fileData);
                fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
                content.Add(fileContent, "file", fileName);
                content.Add(new StringContent(patientId), "patientId");

                var response = await _httpClient.PostAsync("api/labresults/upload", content);
                return response.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dapr] Error uploading lab result: {ex.Message}");
                return false;
            }
        }
    }
}
