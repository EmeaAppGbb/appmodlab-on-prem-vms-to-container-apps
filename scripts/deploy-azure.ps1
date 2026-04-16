<#
.SYNOPSIS
    Builds Docker images, pushes to ACR, and deploys PawsCare to Azure Container Apps.
.DESCRIPTION
    This script deploys the PawsCare application to Azure Container Apps using Bicep templates.
    It builds and pushes Docker images to ACR, then deploys all three services with Dapr sidecars.
.PARAMETER SubscriptionId
    Azure subscription ID. Defaults to AZURE_SUBSCRIPTION_ID env var.
.PARAMETER ResourceGroup
    Azure resource group name. Defaults to AZURE_RESOURCE_GROUP env var.
.PARAMETER Location
    Azure region. Defaults to eastus.
.PARAMETER Environment
    Deployment environment (dev, staging, prod). Defaults to dev.
.PARAMETER BaseName
    Base name for all resources. Defaults to pawscare.
.PARAMETER ImageTag
    Docker image tag. Defaults to short git SHA or 'latest'.
#>

param(
    [string]$SubscriptionId = ($env:AZURE_SUBSCRIPTION_ID ?? '<your-subscription-id>'),
    [string]$ResourceGroup  = ($env:AZURE_RESOURCE_GROUP ?? '<your-resource-group>'),
    [string]$Location        = ($env:AZURE_LOCATION ?? 'eastus'),
    [string]$Environment     = ($env:DEPLOY_ENVIRONMENT ?? 'dev'),
    [string]$BaseName        = ($env:BASE_NAME ?? 'pawscare'),
    [string]$ImageTag        = ($env:IMAGE_TAG ?? '')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }

# Resolve image tag
if ([string]::IsNullOrEmpty($ImageTag)) {
    try {
        $ImageTag = (git rev-parse --short HEAD 2>$null)
    } catch {
        $ImageTag = 'latest'
    }
    if ([string]::IsNullOrEmpty($ImageTag)) { $ImageTag = 'latest' }
}

function Write-Info  { param([string]$Message) Write-Host "[INFO]  $Message" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Message) Write-Host "[OK]    $Message" -ForegroundColor Green }
function Write-Err   { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# --- Pre-flight checks ---
foreach ($cmd in @('az', 'docker')) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Err "'$cmd' is required but not found. Please install it first."
        exit 1
    }
}

Write-Info "Setting Azure subscription to $SubscriptionId"
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) { Write-Err "Failed to set subscription."; exit 1 }

# --- Step 1: Create resource group ---
Write-Info "Ensuring resource group '$ResourceGroup' exists in '$Location'..."
az group create --name $ResourceGroup --location $Location --output none
if ($LASTEXITCODE -ne 0) { Write-Err "Failed to create resource group."; exit 1 }
Write-Ok "Resource group ready."

# --- Step 2: Deploy infrastructure ---
Write-Info "Deploying base infrastructure (ACR, Log Analytics, Container Apps Environment)..."
$infraOutput = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "$RepoRoot\infrastructure\main.bicep" `
    --parameters environment=$Environment baseName=$BaseName `
    --query "properties.outputs" `
    --output json | ConvertFrom-Json

$acrLoginServer = $infraOutput.acrLoginServer.value
$acrName = $infraOutput.acrName.value
Write-Ok "Infrastructure deployed. ACR: $acrLoginServer"

# --- Step 3: Log in to ACR ---
Write-Info "Logging in to Azure Container Registry '$acrName'..."
az acr login --name $acrName
if ($LASTEXITCODE -ne 0) { Write-Err "Failed to log in to ACR."; exit 1 }
Write-Ok "Logged in to ACR."

# --- Step 4: Build and push Docker images ---
$services = @('web-frontend', 'api-server', 'background-worker')

foreach ($service in $services) {
    $imageName = "$acrLoginServer/pawscare/${service}:$ImageTag"
    Write-Info "Building image for $service..."
    docker build -t $imageName "$RepoRoot\$service"
    if ($LASTEXITCODE -ne 0) { Write-Err "Failed to build $service."; exit 1 }

    Write-Info "Pushing $imageName..."
    docker push $imageName
    if ($LASTEXITCODE -ne 0) { Write-Err "Failed to push $service."; exit 1 }
    Write-Ok "$service image pushed."
}

# --- Step 5: Deploy Container Apps ---
Write-Info "Deploying Container Apps with Dapr sidecars..."
$deployOutput = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "$RepoRoot\infrastructure\deploy.bicep" `
    --parameters environment=$Environment baseName=$BaseName imageTag=$ImageTag `
    --query "properties.outputs" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) { Write-Err "Deployment failed."; exit 1 }
Write-Ok "Deployment complete!"

# --- Step 6: Output results ---
Write-Host ""
Write-Host "============================================="
Write-Host "  PawsCare Deployment Summary"
Write-Host "============================================="
Write-Host ""
Write-Host "  ACR Login Server:    $acrLoginServer"
Write-Host "  Image Tag:           $ImageTag"
Write-Host "  Environment:         $Environment"
Write-Host ""
Write-Host "  Web Frontend URL:    $($deployOutput.webFrontendUrl.value)"
Write-Host "  API Server FQDN:     $($deployOutput.apiServerFqdn.value)"
Write-Host "  Worker:              $($deployOutput.backgroundWorkerName.value)"
Write-Host ""
Write-Host "============================================="
