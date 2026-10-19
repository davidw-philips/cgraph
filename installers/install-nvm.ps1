#!/usr/bin/env pwsh
# Install NVM for Windows (nvm-windows)
# Downloads and installs Node Version Manager for Windows

param(
    [switch]$SkipNodeInstall = $false
)

$NvmVersion = "1.1.12"
$NodeVersion = "22.5.0"
$DownloadUrl = "https://github.com/coreybutler/nvm-windows/releases/download/$NvmVersion/nvm-setup.exe"

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    $colors = @{
        "INFO"  = "Cyan"
        "OK"    = "Green"
        "WARN"  = "Yellow"
        "ERROR" = "Red"
    }
    Write-Host "[$Status] $Message" -ForegroundColor $colors[$Status]
}

function Test-AdminPrivileges {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Status "NVM for Windows Installer" "INFO"
Write-Host ""

# Check for admin privileges
if (-not (Test-AdminPrivileges)) {
    Write-Status "This script requires Administrator privileges" "ERROR"
    Write-Host ""
    Write-Host "Please run PowerShell as Administrator:" -ForegroundColor Yellow
    Write-Host "  1. Right-click PowerShell → Run as administrator" -ForegroundColor Cyan
    Write-Host "  2. Run: .\installers\install-nvm.ps1" -ForegroundColor Cyan
    exit 1
}

Write-Status "Installing NVM for Windows (v$NvmVersion)..." "INFO"
Write-Host ""

# Check if already installed
$nvmPath = "$env:LOCALAPPDATA\nvm"
if (Test-Path $nvmPath) {
    Write-Status "NVM is already installed at $nvmPath" "WARN"
    Write-Host ""
    Write-Host "To upgrade NVM, visit: https://github.com/coreybutler/nvm-windows/releases" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install Node.js:" -ForegroundColor Cyan
    Write-Host "  nvm install $NodeVersion" -ForegroundColor Green
    exit 0
}

# Download installer
$tempDir = $env:TEMP
$installerPath = "$tempDir\nvm-setup.exe"

Write-Status "Downloading NVM installer..." "INFO"
try {
    # Use TLS 1.2 for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Status "Download complete: $installerPath" "OK"
}
catch {
    Write-Status "Failed to download NVM installer" "ERROR"
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Status "Running NVM installer..." "INFO"
Write-Host "The installer will open. Follow the prompts to complete installation." -ForegroundColor Yellow
Write-Host ""

# Run installer
try {
    & $installerPath
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Status "NVM installation completed" "OK"
        
        # Refresh environment
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Try to verify installation
        $null = Get-Command nvm -ErrorAction SilentlyContinue
        if ($?) {
            Write-Status "NVM is now available" "OK"
            Write-Host ""
            
            if (-not $SkipNodeInstall) {
                Write-Host "Installing Node.js $NodeVersion..." -ForegroundColor Cyan
                & nvm install $NodeVersion
                & nvm use $NodeVersion
                
                Write-Host ""
                Write-Status "Node.js $NodeVersion installed and activated" "OK"
                Write-Host ""
                Write-Host "Verify installation:" -ForegroundColor Cyan
                Write-Host "  node --version" -ForegroundColor Green
                Write-Host "  npm --version" -ForegroundColor Green
            }
            else {
                Write-Host "To install Node.js, run:" -ForegroundColor Cyan
                Write-Host "  nvm install $NodeVersion" -ForegroundColor Green
                Write-Host "  nvm use $NodeVersion" -ForegroundColor Green
            }
        }
        else {
            Write-Status "NVM installed, but not yet available in current session" "WARN"
            Write-Host ""
            Write-Host "Open a NEW PowerShell window and run:" -ForegroundColor Yellow
            Write-Host "  nvm install $NodeVersion" -ForegroundColor Green
            Write-Host "  nvm use $NodeVersion" -ForegroundColor Green
        }
    }
    else {
        Write-Status "NVM installer exited with code $exitCode" "ERROR"
        exit $exitCode
    }
}
catch {
    Write-Status "Failed to run NVM installer" "ERROR"
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
finally {
    # Clean up
    if (Test-Path $installerPath) {
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    }
}
