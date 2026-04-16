# test-local.ps1 - Test all PawsCare service endpoints locally
# Usage: .\scripts\test-local.ps1
param(
    [string]$BaseUrl = "http://localhost",
    [int]$ApiPort = 8381,
    [int]$WebPort = 8380
)

$ErrorActionPreference = "Continue"
$passed = 0
$failed = 0

function Write-Pass($msg) { $script:passed++; Write-Host "  ✅ PASS: $msg" -ForegroundColor Green }
function Write-Fail($msg, $detail) { $script:failed++; Write-Host "  ❌ FAIL: $msg - $detail" -ForegroundColor Red }

function Test-Endpoint {
    param([string]$Name, [string]$Url, [int]$Expected = 200)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq $Expected) {
            Write-Pass "$Name (HTTP $($response.StatusCode))"
        } else {
            Write-Fail $Name "expected HTTP $Expected, got $($response.StatusCode)"
        }
    } catch {
        $status = 0
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }
        Write-Fail $Name "expected HTTP $Expected, got $status ($($_.Exception.Message))"
    }
}

function Test-JsonField {
    param([string]$Name, [string]$Url, [string]$Field, [string]$Expected)
    try {
        $response = Invoke-RestMethod -Uri $Url -TimeoutSec 10 -ErrorAction Stop
        $value = $response.$Field
        if ($value -eq $Expected) {
            Write-Pass "$Name ($Field=$value)"
        } else {
            Write-Fail $Name "expected $Field='$Expected', got '$value'"
        }
    } catch {
        Write-Fail $Name "request failed: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "  PawsCare Local Container Test Suite"
Write-Host "=========================================="
Write-Host ""

# --- API Server Tests ---
Write-Host "🔹 API Server ($BaseUrl`:$ApiPort)" -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Test-Endpoint -Name "API health endpoint" -Url "$BaseUrl`:$ApiPort/health"
Test-JsonField -Name "API health status" -Url "$BaseUrl`:$ApiPort/health" -Field "status" -Expected "healthy"
Test-Endpoint -Name "API root endpoint" -Url "$BaseUrl`:$ApiPort/"
Test-Endpoint -Name "Patients API (GET)" -Url "$BaseUrl`:$ApiPort/api/patients"
Test-Endpoint -Name "Appointments API (GET)" -Url "$BaseUrl`:$ApiPort/api/appointments"
Test-Endpoint -Name "Prescriptions API (GET)" -Url "$BaseUrl`:$ApiPort/api/prescriptions"
Test-Endpoint -Name "Lab Results API (GET)" -Url "$BaseUrl`:$ApiPort/api/labresults"
Write-Host ""

# --- Web Frontend Tests ---
Write-Host "🔹 Web Frontend ($BaseUrl`:$WebPort)" -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Test-Endpoint -Name "Web frontend root" -Url "$BaseUrl`:$WebPort/"
Test-Endpoint -Name "Web frontend health" -Url "$BaseUrl`:$WebPort/health"
Write-Host ""

# --- Docker Health Status ---
Write-Host "🔹 Docker Container Health" -ForegroundColor Cyan
Write-Host "-------------------------------------------"
$services = @("api-server", "background-worker", "web-frontend")
foreach ($svc in $services) {
    try {
        $inspect = docker compose ps $svc --format json 2>$null | ConvertFrom-Json
        $health = $inspect.Health
        if ($health -eq "healthy") {
            Write-Pass "Container $svc is healthy"
        } else {
            Write-Fail "Container $svc" "health=$health"
        }
    } catch {
        Write-Fail "Container $svc" "could not inspect: $($_.Exception.Message)"
    }
}
Write-Host ""

# --- Summary ---
$total = $passed + $failed
Write-Host "=========================================="
Write-Host "  Results: $passed/$total passed, $failed failed"
Write-Host "=========================================="
Write-Host ""

if ($failed -gt 0) {
    exit 1
}
