# Setup-EPKL.ps1 - run ELEVATED once inside the Windows VM.
# Expands EPKL portable to C:\Tools\EPKL, installs layout override (Colemak-DH Wide),
# and creates Startup shortcuts for EPKL + Kanata (Kanata already at C:\Tools\kanata).
$ErrorActionPreference = 'Stop'
$Tools  = 'C:\Tools'
$EpklDir = Join-Path $Tools 'EPKL'
$Zip    = Join-Path $Tools 'EPKL_exe.zip'
$KanataExe = 'C:\Tools\kanata\kanata.exe'
$KanataCfg = 'C:\Tools\kanata\config.kbd'

if (!(Test-Path $Zip)) { throw "Missing $Zip - copy EPKL_exe.zip to C:\Tools first." }
if (!(Test-Path $KanataExe)) { Write-Warning "Kanata not found at $KanataExe (expected from step 2)." }

New-Item -ItemType Directory -Force -Path $EpklDir | Out-Null
Write-Host "Expanding EPKL to $EpklDir ..."
Expand-Archive -Path $Zip -DestinationPath $EpklDir -Force

# Install our layout override next to EPKL.exe
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Override = Join-Path $ScriptDir 'EPKL_Layouts_Override.ini'
if (Test-Path $Override) {
  Copy-Item $Override (Join-Path $EpklDir 'EPKL_Layouts_Override.ini') -Force
  Write-Host "Installed EPKL_Layouts_Override.ini (Colemak-DH-Wide CAW + QWERTY-AWide)."
} else {
  Write-Warning "Override ini not found next to script; select layout manually in EPKL tray menu."
}

# Startup shortcuts
$Startup = [Environment]::GetFolderPath('Startup')
$Wsh = New-Object -ComObject WScript.Shell

$Lnk1 = $Wsh.CreateShortcut((Join-Path $Startup 'EPKL.lnk'))
$Lnk1.TargetPath = (Join-Path $EpklDir 'EPKL.exe')
$Lnk1.WorkingDirectory = $EpklDir
$Lnk1.Save()
Write-Host "Created Startup EPKL.lnk"

if (Test-Path $KanataExe) {
  $Lnk2 = $Wsh.CreateShortcut((Join-Path $Startup 'Kanata.lnk'))
  $Lnk2.TargetPath = $KanataExe
  $Lnk2.Arguments = "-c `"$KanataCfg`""
  $Lnk2.WorkingDirectory = 'C:\Tools\kanata'
  $Lnk2.Save()
  Write-Host "Created Startup Kanata.lnk"
}

Write-Host "Done. Start EPKL.exe once, pick Colemak-DH-Wide if needed, then reboot to verify both autostart."
