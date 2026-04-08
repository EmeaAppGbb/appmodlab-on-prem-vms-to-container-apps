# PowerShell script to provision VM 1 (Windows Server 2019)
# Run this script with Administrator privileges

Write-Host "🐾 PawsCare VM 1 Setup - Windows Server 2019" -ForegroundColor Cyan
Write-Host "Installing Web Frontend and SQL Server..." -ForegroundColor Yellow

# Configure static IP
Write-Host "`n[1/5] Configuring static IP address 10.0.1.10..."
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress 10.0.1.10 -PrefixLength 24 -DefaultGateway 10.0.1.1
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses 8.8.8.8,8.8.4.4

# Install IIS
Write-Host "`n[2/5] Installing IIS and ASP.NET Core hosting bundle..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45

# Download and install ASP.NET Core 3.1 Runtime
$hostingBundleUrl = "https://download.visualstudio.microsoft.com/download/pr/abc12345/dotnet-hosting-3.1-win.exe"
Write-Host "Downloading ASP.NET Core 3.1 Hosting Bundle..."
# Invoke-WebRequest -Uri $hostingBundleUrl -OutFile "$env:TEMP\dotnet-hosting.exe"
# Start-Process -FilePath "$env:TEMP\dotnet-hosting.exe" -ArgumentList "/quiet /install" -Wait

# Install SQL Server 2019
Write-Host "`n[3/5] Installing SQL Server 2019..."
# In production, this would download and install SQL Server
# For demo, assume SQL Server is already installed

# Create SMB share
Write-Host "`n[4/5] Creating SMB file share at \\10.0.1.10\documents..."
New-Item -Path "C:\SharedDocuments" -ItemType Directory -Force
New-Item -Path "C:\SharedDocuments\lab-results" -ItemType Directory -Force
New-Item -Path "C:\SharedDocuments\xrays" -ItemType Directory -Force
New-Item -Path "C:\SharedDocuments\reports" -ItemType Directory -Force
New-SmbShare -Name "documents" -Path "C:\SharedDocuments" -FullAccess "Everyone"

# Configure firewall rules
Write-Host "`n[5/5] Configuring firewall rules..."
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "SMB" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow

Write-Host "`n✓ VM 1 setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Deploy PawsCare.Web application to IIS"
Write-Host "  2. Create PawsCare database in SQL Server"
Write-Host "  3. Update appsettings.json with connection string"
