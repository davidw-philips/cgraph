#!/usr/bin/env pwsh
# cgraph Node.js Runtime Checker (PowerShell)
#
# NOTE: The codegraph CLI/MCP server (the standalone installer) bundles its own
# runtime and needs NO Node.js at all. This script is only relevant if you plan
# to install via `npm i -g @colbymchenry/codegraph` (needs Node) or embed
# CodeGraph's library API in your own app (needs Node 22.5+ for node:sqlite).

param(
    [switch]$Verbose = $false,
    [switch]$Install = $false
)

$MinNodeVersion = [version]"18.0.0"
$TargetNodeVersion = "22.5.0"

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

function Get-NodeInfo {
    try {
        $output = & node --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $version = $output -replace '^v', ''
            return @{
                Installed = $true
                Version   = [version]$version
                Raw       = $output
                Path      = (Get-Command node).Source
            }
        }
    }
    catch {
        # Node not found
    }
    return @{
        Installed = $false
        Version   = $null
        Raw       = $null
        Path      = $null
    }
}

function Get-NvmInfo {
    $nvmPath = if ($env:NVM_HOME) { $env:NVM_HOME } else { "$env:LOCALAPPDATA\nvm" }
    return @{
        Installed = Test-Path $nvmPath
        Path      = $nvmPath
    }
}

function Test-Compatibility {
    param([version]$Version)
    return $Version -ge $MinNodeVersion
}

# Main execution
Write-Status "Checking Node.js runtime compatibility for cgraph..." "INFO"
Write-Host ""

$nodeInfo = Get-NodeInfo
$nvmInfo = Get-NvmInfo

if ($Verbose) {
    Write-Host "DEBUG: Node.js Info:" -ForegroundColor DarkGray
    $nodeInfo | Format-Table | Out-String | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
    Write-Host "DEBUG: NVM Info:" -ForegroundColor DarkGray
    $nvmInfo | Format-Table | Out-String | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
    Write-Host ""
}

if ($nodeInfo.Installed) {
    Write-Status "Node.js found: $($nodeInfo.Raw)" "OK"
    Write-Status "Location: $($nodeInfo.Path)" "INFO"
    
    if (Test-Compatibility $nodeInfo.Version) {
        Write-Status "Version $($nodeInfo.Version) is compatible (requires v$MinNodeVersion+)" "OK"
        Write-Host ""
        Write-Host "Node.js runtime is ready for npm install / library embedding" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Status "Version $($nodeInfo.Version) is TOO OLD (requires v$MinNodeVersion+)" "WARN"
        Write-Status "Upgrade with: nvm install $TargetNodeVersion" "INFO"
        
        if ($nvmInfo.Installed) {
            Write-Host ""
            Write-Host "NVM is installed. Run:" -ForegroundColor Yellow
            Write-Host "  nvm install $TargetNodeVersion" -ForegroundColor Green
            Write-Host "  nvm use $TargetNodeVersion" -ForegroundColor Green
        }
        else {
            Write-Host ""
            Write-Host "NVM is NOT installed. Run the installer:" -ForegroundColor Yellow
            Write-Host "  .\installers\install-nvm.ps1" -ForegroundColor Green
        }
        exit 1
    }
}
else {
    Write-Status "Node.js is NOT installed" "WARN"
    Write-Host ""
    
    if ($nvmInfo.Installed) {
        Write-Status "NVM is already installed at $($nvmInfo.Path)" "OK"
        Write-Host ""
        Write-Host "Install Node.js with NVM:" -ForegroundColor Yellow
        Write-Host "  nvm install $TargetNodeVersion" -ForegroundColor Green
        Write-Host "  nvm use $TargetNodeVersion" -ForegroundColor Green
        exit 1
    }
    else {
        Write-Status "NVM is NOT installed" "WARN"
        
        if ($Install) {
            Write-Host ""
            Write-Host "Running NVM installer..." -ForegroundColor Cyan
            & "$PSScriptRoot\install-nvm.ps1"
            exit $LASTEXITCODE
        }
        else {
            Write-Host ""
            Write-Host "To install Node.js, run the NVM installer:" -ForegroundColor Yellow
            Write-Host "  .\installers\install-nvm.ps1" -ForegroundColor Green
            Write-Host ""
            Write-Host "Then install Node:" -ForegroundColor Yellow
            Write-Host "  nvm install $TargetNodeVersion" -ForegroundColor Green
            exit 1
        }
    }
}
