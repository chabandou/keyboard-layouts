$ErrorActionPreference = 'Stop'
$Startup = [Environment]::GetFolderPath('Startup')
New-Item -ItemType Directory -Force -Path $Startup | Out-Null
$Wsh = New-Object -ComObject WScript.Shell

# EPKL is retired: kanata + the native CmkDHW layout replace it.
$OldEpkl = Join-Path $Startup 'EPKL.lnk'
if (Test-Path $OldEpkl) { Remove-Item $OldEpkl -Force; Write-Host 'Removed EPKL.lnk' }

$Lnk = $Wsh.CreateShortcut((Join-Path $Startup 'Kanata.lnk'))
$Lnk.TargetPath = 'C:\Tools\kanata\kanata.exe'
$Lnk.Arguments = '--cfg "C:\Tools\kanata\config.kbd"'
$Lnk.WorkingDirectory = 'C:\Tools\kanata'
$Lnk.Save()
Write-Host 'Created Kanata.lnk'
Get-ChildItem $Startup/*.lnk | Select-Object Name, LastWriteTime
