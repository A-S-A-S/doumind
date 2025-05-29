@echo off
echo This must be run as Administrator because starting/stopping a service requires admin privileges
set SERVICE_NAME=GoodbyeDPI

sc query %SERVICE_NAME% | find "RUNNING" >nul

if %errorlevel% == 0 (
    echo Service is running - stopping it...
    net stop %SERVICE_NAME%
) else (
    echo Service is not running - starting it...
    net start %SERVICE_NAME%
)

pause