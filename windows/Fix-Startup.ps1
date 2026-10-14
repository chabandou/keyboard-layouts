$ErrorActionPreference = 'Stop'
$Startup = 'C:\Users\chabandou\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
New-Item -ItemType Directory -Force -Path $Startup | Out-Null
$Wsh = New-Object -ComObject WScript.Shell

$Lnk1 = $Wsh.CreateShortcut((Join-Path $Startup 'EPKL.lnk'))
$Lnk1.TargetPath = 'C:\Tools\EPKL\EPKL.exe'
$Lnk1.WorkingDirectory = 'C:\Tools\EPKL'
$Lnk1.Save()
Write-Host 'Created EPKL.lnk'

$Lnk2 = $Wsh.CreateShortcut((Join-Path $Startup 'Kanata.lnk'))
$Lnk2.TargetPath = 'C:\Tools\kanata\kanata.exe'
$Lnk2.Arguments = '-c "C:\Tools\kanata\config.kbd"'
$Lnk2.WorkingDirectory = 'C:\Tools\kanata'
$Lnk2.Save()
Write-Host 'Created Kanata.lnk'
Get-ChildItem $Startup/*.lnk | Select-Object Name, LastWriteTime
