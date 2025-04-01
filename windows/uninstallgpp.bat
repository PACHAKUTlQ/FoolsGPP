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

