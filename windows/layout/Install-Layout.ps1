# Install-Layout.ps1 - run ELEVATED. Installs the Colemak-DH Wide (eD) keyboard layout
# built from linux/xkb (see gen-klc.py) as a native Windows layout under English (US),
# and makes it the default input method for the current user.
#   .\Install-Layout.ps1             install / update
#   .\Install-Layout.ps1 -Uninstall  remove it again
# Sign out and back in (or reboot) afterwards so every app loads the new layout DLL.
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'

$Dll      = 'CmkDHW.dll'
$Text     = 'Colemak-DH Wide (eD, Linux mirror)'
$KlRoot   = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts'
$Here     = Split-Path -Parent $MyInvocation.MyCommand.Path

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run this script from an elevated PowerShell (Run as administrator).'
}

# Reuse our existing registry entry if there is one, so re-running just updates the DLL.
$existing = Get-ChildItem $KlRoot | Where-Object { (Get-ItemProperty $_.PSPath).'Layout File' -eq $Dll } | Select-Object -First 1

if ($Uninstall) {
  if ($existing) {
    $klid = $existing.PSChildName
    $langs = Get-WinUserLanguageList
    foreach ($l in $langs) { [void]$l.InputMethodTips.Remove("0409:$($klid.ToUpper())") }
    Set-WinUserLanguageList $langs -Force
    Remove-Item $existing.PSPath -Recurse
    Write-Host "Removed layout $klid from the registry and language list."
  }
  foreach ($p in "$env:WINDIR\System32\$Dll", "$env:WINDIR\SysWOW64\$Dll") {
    if (Test-Path $p) { Remove-Item $p -Force; Write-Host "Removed $p" }
  }
  Write-Host 'Done. Sign out and back in to finish.'
  return
}

Copy-Item (Join-Path $Here "amd64\$Dll") "$env:WINDIR\System32\$Dll" -Force
Copy-Item (Join-Path $Here "wow64\$Dll") "$env:WINDIR\SysWOW64\$Dll" -Force
Write-Host "Copied $Dll to System32 and SysWOW64."

if ($existing) {
  $klid = $existing.PSChildName
} else {
  # Custom layouts use KLIDs a0000409, a1000409, ... and need a unique 'Layout Id'.
  $used = Get-ChildItem $KlRoot | ForEach-Object { $_.PSChildName.ToLower() }
  $klid = 0..15 | ForEach-Object { 'a{0:x}000409' -f $_ } | Where-Object { $used -notcontains $_ } | Select-Object -First 1
  $ids = Get-ChildItem $KlRoot | ForEach-Object { (Get-ItemProperty $_.PSPath).'Layout Id' } | Where-Object { $_ }
  $layoutId = 0xc0..0xfff | ForEach-Object { '{0:x4}' -f $_ } | Where-Object { $ids -notcontains $_ } | Select-Object -First 1
  $key = New-Item -Path (Join-Path $KlRoot $klid)
  New-ItemProperty $key.PSPath -Name 'Layout File' -Value $Dll | Out-Null
  New-ItemProperty $key.PSPath -Name 'Layout Text' -Value $Text | Out-Null
  New-ItemProperty $key.PSPath -Name 'Layout Display Name' -Value "@%SystemRoot%\system32\$Dll,-1000" -PropertyType ExpandString | Out-Null
  New-ItemProperty $key.PSPath -Name 'Layout Id' -Value $layoutId | Out-Null
  Write-Host "Registered layout $klid (Layout Id $layoutId)."
}

# Add it to English (US) for the current user and make it the default input method.
$tip = "0409:$($klid.ToUpper())"
$langs = Get-WinUserLanguageList
$en = $langs | Where-Object { $_.LanguageTag -eq 'en-US' } | Select-Object -First 1
if (-not $en) { $langs.Add('en-US'); $en = $langs | Where-Object { $_.LanguageTag -eq 'en-US' } }
if (-not $en.InputMethodTips.Contains($tip)) { $en.InputMethodTips.Insert(0, $tip) }
Set-WinUserLanguageList $langs -Force
Set-WinDefaultInputMethodOverride -InputTip $tip
Write-Host "Added $tip to English (US) and set it as the default input method."
Write-Host 'Done. Sign out and back in (or reboot) so all apps pick up the layout.'
