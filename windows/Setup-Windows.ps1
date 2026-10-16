# Setup-Windows.ps1 - run ELEVATED once. Mirrors the Linux setup:
#   XKB custom layout  -> native Windows layout CmkDHW (layout\Install-Layout.ps1)
#   kanata config.kbd  -> kanata winIOv2 at C:\Tools\kanata, started at logon
# Also retires the old EPKL setup (stops it and removes its Startup shortcut).
$ErrorActionPreference = 'Stop'
$Here      = Split-Path -Parent $MyInvocation.MyCommand.Path
$KanataDir = 'C:\Tools\kanata'

# 1. Keyboard layout (needs admin)
& (Join-Path $Here 'layout\Install-Layout.ps1')

# 2. Kanata
Get-Process kanata -ErrorAction SilentlyContinue | Stop-Process -Force
New-Item -ItemType Directory -Force -Path $KanataDir | Out-Null
Copy-Item (Join-Path $Here 'kanata\kanata.exe') (Join-Path $KanataDir 'kanata.exe') -Force
Copy-Item (Join-Path $Here 'kanata\config.kbd') (Join-Path $KanataDir 'config.kbd') -Force
Write-Host "Installed kanata + config.kbd to $KanataDir"

# 3. Retire EPKL and set up autostart
Get-Process EPKL -ErrorAction SilentlyContinue | Stop-Process -Force
& (Join-Path $Here 'Fix-Startup.ps1')

Start-Process (Join-Path $KanataDir 'kanata.exe') -ArgumentList '--cfg', "`"$KanataDir\config.kbd`"" -WorkingDirectory $KanataDir
Write-Host 'Started kanata. Sign out and back in (or reboot) so every app loads the new layout.'
