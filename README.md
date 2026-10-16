# keyboard-layouts

Personal keyboard layout setups, per OS.

- `windows/` — native Colemak-DH Wide layout + Kanata (mirror of the Linux setup).
- `linux/` — Arch/Omarchy + Hyprland custom XKB (Colemak-DH Wide + Arabic).

## linux/

Exact mirror of the Linux keyboard setup on `omarchy`
(Arch Linux, Hyprland 0.56.1, Wayland), captured 2026-10-13.
See `linux/README.md`.

- Active Hyprland input: `kb_layout = custom,ara`,
  `kb_variant = cmk_ed_dh_wide_full,`, `kb_model = pc104awide`,
  `kb_options = lv3:ralt_switch` (symbols in `linux/xkb/symbols/custom`,
  includes DreymaR `us(colemak_dh_wide)` BigBag base + eD layer).
- `linux/Setup-linux.sh` — restores xkb/hypr/kanata/scripts, recompiles the
  keymap with `xkbcli`, applies system `fr` TTY/Xorg keymap with sudo.

### Restore on a fresh Linux machine

1. Install DreymaR BigBag first if `us(colemak_dh_wide)` is missing.
2. Run `linux/Setup-linux.sh`, then `hyprctl reload`.
3. `systemctl --user start kanata.service` for Space-Extend/home-row mods.

## windows/

Same split as Linux: the OS layout does the letters and AltGr symbols,
Kanata does Space-Extend, home-row mods and Caps=Shift.

| Linux | Windows |
|---|---|
| XKB `custom(cmk_ed_dh_wide_full)` + `pc104awide` | native layout `CmkDHW` (`windows/layout/`) |
| `kanata.service` + `linux/kanata/config.kbd` | `C:\Tools\kanata\kanata.exe` + `windows/kanata/config.kbd` |
| `switchxkblayout` EN/AR | Win+Space between English (CmkDHW) and Arabic |

- `windows/layout/gen-klc.py` generates `CmkDHW.klc` from
  `linux/xkb/keymaps/cmk_ed_dh_wide_full.xkb` (levels 1-4 become
  Base/Shift/AltGr/Shift+AltGr; XKB dead keys become Windows dead keys).
  `amd64/` and `wow64/` hold the DLLs built from it with MSKLC's `kbdutool`.
- `windows/layout/Install-Layout.ps1` (elevated) copies the DLLs to
  System32/SysWOW64, registers the layout and makes it the default
  under English (US). `-Uninstall` reverses it.
- `windows/kanata/kanata.exe` is the kanata v1.11.0 `gui_winIOv2_x64` build.
  Not v1.12.0: that release turned on a Windows key-state sync that checks
  keys by their US QWERTY virtual-key code, so under Colemak/AZERTY it logs
  "Unexpected keycode is pressed in kanata but not in Windows" and can eat
  repeated presses (jtroo/kanata#2115). v1.13+ adds
  `windows-sync-keystates none` to switch it off; until then stay on v1.11.0.
  winIOv2 sends scancodes, so its output goes through the Windows layout the
  same way Linux kanata output goes through XKB. (The default LLHOOK build
  doesn't follow OS-level layouts reliably; see kanata issue #152.)
- `windows/kanata/config.kbd` is `linux/kanata/config.kbd` plus
  `windows-altgr add-lctl-release`, with the Extend Ctrl shortcuts keyed by the
  physical key that carries each letter in Colemak-DH Wide (so Ctrl+F is
  really Ctrl+F) and Omarchy's Super+X/C cut/copy as Ctrl+X/C.
- `windows/Setup-Windows.ps1` (elevated) runs the layout installer, installs
  kanata to `C:\Tools\kanata`, stops EPKL and swaps the Startup shortcut.
  `windows/Fix-Startup.ps1` just recreates the `Kanata.lnk` Startup shortcut.

EPKL was used until 2026-10-16; it was dropped because its tap-or-mod keys
only switch to hold on a timer and send interrupted taps out of order. The old
EPKL tree is in git history (commit `610d289`).

### Rebuild the layout after changing the Linux XKB keymap

1. `python windows/layout/gen-klc.py`
2. Build with MSKLC's `kbdutool` (from the MSKLC 1.4 package, `bin\i386`):
   `kbdutool -u -m CmkDHW.klc` (amd64) and `kbdutool -u -o CmkDHW.klc` (wow64),
   then copy each `CmkDHW.dll` into `windows/layout/amd64` and `wow64`.
3. Re-run `windows/layout/Install-Layout.ps1` elevated and sign out/in.

### Restore on a fresh Windows machine

1. Run `windows/Setup-Windows.ps1` from an elevated PowerShell.
2. Sign out and back in (or reboot).
3. Check that the input switcher shows English with
   "Colemak-DH Wide (eD, Linux mirror)" and that kanata's tray icon is present.

Note: kanata only remaps keys going into non-elevated windows unless it is
itself run as administrator (Windows UIPI).
