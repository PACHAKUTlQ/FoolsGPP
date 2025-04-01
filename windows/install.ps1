<#
.SYNOPSIS
    April Fools' G++ Prank Installer
.DESCRIPTION
    Installs a modified g++.exe that shows funny error messages while preserving the real compiler.
.NOTES
    Requires admin privileges to modify files in Program Files directories
#>

# Configuration
$ModifiedGppUrl = "https://41.jiers.me/g++.exe"
$ExpectedSHA256 = "443f1a5a4a425248a8d16b2d61af5a7a80d68a13b2008cbafd314b4e9cbfd82b" # Get this from: (Get-FileHash .\g++.exe -Algorithm SHA256).Hash
$TempDir = "$env:TEMP\gpp_prank"
$UninstallerPath = "$env:USERPROFILE\uninstallgpp.bat"

# Create temp directory
if (-not (Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
}

# Find real g++.exe
try {
    $GppPath = (Get-Command g++ -ErrorAction Stop).Source
} catch {
    Write-Host "Error: Could not find g++.exe in your PATH" -ForegroundColor Red
    exit 1
}

$GppDir = Split-Path -Parent $GppPath
$RealGppPath = Join-Path $GppDir "g++real.exe"

# Check if already installed
if (Test-Path $RealGppPath) {
    Write-Host "April Fools' g++ is already installed!" -ForegroundColor Yellow
    exit 0
}

# Download modified g++.exe
Write-Host "Downloading modified g++.exe..."
$ModifiedGppTempPath = "$TempDir\g++.exe"
try {
    Invoke-WebRequest -Uri $ModifiedGppUrl -OutFile $ModifiedGppTempPath -UseBasicParsing
} catch {
    Write-Host "Failed to download modified g++.exe: $_" -ForegroundColor Red
    exit 1
}

# Verify hash
$ActualHash = (Get-FileHash -Path $ModifiedGppTempPath -Algorithm SHA256).Hash
if ($ActualHash -ne $ExpectedSHA256) {
    Write-Host "Security Error: Downloaded file hash doesn't match!" -ForegroundColor Red
    Write-Host "Expected: $ExpectedSHA256"
    Write-Host "Actual:   $ActualHash"
    Remove-Item -Path $ModifiedGppTempPath -Force
    exit 1
}

# Install process
Write-Host "Installing April Fools' g++..."
try {
    # Rename original g++
    Rename-Item -Path $GppPath -NewName "g++real.exe" -Force
    
    # Copy modified g++
    Copy-Item -Path $ModifiedGppTempPath -Destination $GppDir -Force
    
    # Create proper uninstaller that works with the correct path
    $UninstallBatContent = @"
@echo off
setlocal enabledelayedexpansion

:: Uninstall script for April Fools' g++ prank
:: Finds the original g++real.exe location using PATH

for /f "delims=" %%I in ('where g++real.exe') do (
    set "real_gpp=%%I"
    goto :found_gpp
)

echo Error: Could not find g++real.exe in PATH
pause
exit /b 1

:found_gpp
set "gpp_dir=%~dp0"
set "gpp_dir=!real_gpp:\g++real.exe=!"

if not exist "!gpp_dir!\g++real.exe" (
    echo Error: g++real.exe not found in !gpp_dir!
    pause
    exit /b 1
)

if not exist "!gpp_dir!\g++.exe" (
    echo Error: Modified g++.exe not found in !gpp_dir!
    pause
    exit /b 1
)

echo Uninstalling April Fools' g++...
del "!gpp_dir!\g++.exe"
ren "!gpp_dir!\g++real.exe" "g++.exe"
echo Original g++ restored successfully.

:: Self-destruct
del "%~f0"
exit /b 0
"@

    $UninstallBatContent | Out-File -FilePath $UninstallerPath -Encoding ASCII

    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "Original g++ has been renamed to g++real.exe in $GppDir"
    Write-Host "To uninstall, run: $UninstallerPath"
} catch {
    Write-Host "Installation failed: $_" -ForegroundColor Red
    exit 1
}

# Clean up
Remove-Item -Path $ModifiedGppTempPath -Force -ErrorAction SilentlyContinue
