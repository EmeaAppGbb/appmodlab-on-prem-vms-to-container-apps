<#
.SYNOPSIS
    Simulates load on the web-frontend and api-server endpoints to trigger KEDA auto-scaling.

.DESCRIPTION
    Sends concurrent HTTP requests to the specified endpoints and then queries
    Azure Container Apps to display current replica counts.

.PARAMETER WebFrontendUrl
    The FQDN or URL of the web-frontend Container App.

.PARAMETER ApiServerUrl
    The FQDN or URL of the api-server Container App (if externally reachable, or via ingress).

.PARAMETER ResourceGroup
    The Azure resource group containing the Container Apps.

.PARAMETER RequestCount
    Total number of requests to send per endpoint (default: 200).

.PARAMETER ConcurrentBatch
    Number of requests to send in each parallel batch (default: 20).

.EXAMPLE
    .\load-test.ps1 -WebFrontendUrl "https://pawscare-web-frontend.example.azurecontainerapps.io" `
                    -ResourceGroup "pawscare-rg"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$WebFrontendUrl,

    [Parameter()]
    [string]$ApiServerUrl = "",

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter()]
    [int]$RequestCount = 200,

    [Parameter()]
    [int]$ConcurrentBatch = 20
)

$ErrorActionPreference = "Continue"

function Send-LoadBatch {
    param(
        [string]$Url,
        [string]$Label,
        [int]$Total,
        [int]$BatchSize
    )

    Write-Host "`n=== Sending $Total requests to $Label ($Url) in batches of $BatchSize ===" -ForegroundColor Cyan

    $successCount = 0
    $failCount = 0

    for ($i = 0; $i -lt $Total; $i += $BatchSize) {
        $batchEnd = [Math]::Min($i + $BatchSize, $Total)
        $jobs = @()

        for ($j = $i; $j -lt $batchEnd; $j++) {
            $jobs += Start-Job -ScriptBlock {
                param($uri)
                try {
                    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 30
                    return $response.StatusCode
                } catch {
                    return 0
                }
            } -ArgumentList $Url
        }

        $results = $jobs | Wait-Job | Receive-Job
        $jobs | Remove-Job -Force

        foreach ($code in $results) {
            if ($code -ge 200 -and $code -lt 400) { $successCount++ } else { $failCount++ }
        }

        $completed = $batchEnd
        Write-Host "  Progress: $completed / $Total (Success: $successCount, Failed: $failCount)" -ForegroundColor Gray
    }

    Write-Host "  Completed: $successCount successful, $failCount failed" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
}

# --- Send load to web-frontend ---
Send-LoadBatch -Url "$WebFrontendUrl/health" -Label "web-frontend" -Total $RequestCount -BatchSize $ConcurrentBatch

# --- Send load to api-server (if provided) ---
if (-not [string]::IsNullOrEmpty($ApiServerUrl)) {
    Send-LoadBatch -Url "$ApiServerUrl/health" -Label "api-server" -Total $RequestCount -BatchSize $ConcurrentBatch
}

# --- Query replica counts ---
Write-Host "`n=== Waiting 30 seconds for scaling to take effect ===" -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host "`n=== Current Container App Replica Counts ===" -ForegroundColor Cyan

$apps = az containerapp list --resource-group $ResourceGroup --query "[].{Name:name, Replicas:properties.runningStatus.replicas}" --output json 2>$null | ConvertFrom-Json

if ($null -ne $apps) {
    foreach ($app in $apps) {
        $revision = az containerapp revision list --name $app.Name --resource-group $ResourceGroup --query "[0].{Revision:name, Replicas:properties.replicas, Active:properties.active}" --output json 2>$null | ConvertFrom-Json
        if ($null -ne $revision) {
            Write-Host "  $($app.Name): $($revision.Replicas) replica(s) [Revision: $($revision.Revision), Active: $($revision.Active)]" -ForegroundColor Green
        } else {
            Write-Host "  $($app.Name): (unable to query replicas)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  Could not query Container Apps. Ensure you are logged in with 'az login' and the resource group is correct." -ForegroundColor Red
}

Write-Host "`nLoad test complete." -ForegroundColor Cyan
