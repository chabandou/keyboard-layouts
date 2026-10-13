# keyboard-layouts

Personal keyboard layout setups, per OS.

- `windows/` — EPKL portable install (Colemak-DH Wide ANS eD).
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

## windows/EPKL

Exact mirror of the EPKL portable install on the source machine
(`C:\Tools\EPKL`), captured 2026-10-13.

- Upstream: EPKL (EPiKaL Portable Keyboard Layout) by DreymaR,
  based on PKL by Farkas Máté. See `windows/EPKL/README.md` and
  `windows/EPKL/LICENSE.md`.
- Active layout (from `EPKL_Layouts_Override.ini`):
  **Colemak-DH Wide ANS eD** (`Colemak\Cmk-eD\Cmk-eD_ANS_CurlAWide`),
  plus `QWERTY\QWE-VK_ANS_AWide` as layout 2.
  Caps is mapped to plain Shift (`QWCLK = LShift`) because Kanata
  owns Caps/Space-Extend/home-row mods on the host.
- Program settings override: only `showHelpImage = no`
  (see `windows/EPKL/EPKL_Settings_Override.ini`).

### Layout

- `windows/EPKL/` — verbatim copy of `C:\Tools\EPKL`
  (2899 files, incl. `EPKL.exe`, stock layouts, images, docs).
- `windows/Setup-EPKL.ps1` — elevated one-time installer:
  expands the portable zip, installs the layout override,
  creates Startup shortcuts for EPKL + Kanata.
- `windows/Fix-Startup.ps1` — recreates the Startup
  `EPKL.lnk` + `Kanata.lnk` shortcuts.
- `windows/EPKL_Layouts_Override.ini.source` — source copy of the
  layout override installed as `EPKL_Layouts_Override.ini`
  (identical to `windows/EPKL/EPKL_Layouts_Override.ini`).

### Restore on a fresh Windows machine

1. Copy `windows/EPKL` to `C:\Tools\EPKL`.
2. (Option A) Run `windows/Setup-EPKL.ps1` elevated.
   (Option B) Manually create Startup shortcuts pointing at
   `C:\Tools\EPKL\EPKL.exe` (workdir `C:\Tools\EPKL`).
3. Start `EPKL.exe` once and verify the tray menu shows
   `Colemak-DH-Wide(eD) CAW`.

### Notes

- Binaries (`EPKL.exe`, `*.png`, `*.ico`, `*.zip`, `*.lnk`) are
  committed intentionally so a clone is fully self-contained.
- `Other/Startup_Shortcut.lnk` is a template shortcut, not the
  live Startup entry (live entries live in the Windows Startup folder).
