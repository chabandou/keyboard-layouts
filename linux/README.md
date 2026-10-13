# linux/

Exact mirror of the Linux keyboard setup on `omarchy`
(Arch Linux, Omarchy/Hyprland 0.56.1, Wayland), captured 2026-10-13.

Active Hyprland input (`hypr/input.conf`, `hypr/lua/input.lua`):

- `kb_layout = custom,ara`
- `kb_variant = cmk_ed_dh_wide_full,`
- `kb_model = pc104awide`
- `kb_options = lv3:ralt_switch`
- `resolve_binds_by_sym = true`, repeat 40/600, toggle EN/AR via `switchxkblayout next`
- Symbols source: `~/.config/xkb/symbols/custom` (`xkb_symbols "cmk_ed_dh_wide_full"`,
  includes `us(colemak_dh_wide)` = DreymaR BigBag Wide + eD symbol layer)

Upstream dependency: DreymaR BigBag (`us(colemak_dh_wide)` base).
Local copy of the upstream checkout lives at `~/BigBagKbdTrixXKB` on the source
machine (not vendored here — 11M). To reinstall from upstream, use
`~/dotfiles/scripts/install-bigbag-xkb.sh` (clones
`https://github.com/DreymaR/BigBagKbdTrixXKB.git`).

## Contents (verbatim copies, `diff -q` clean at capture)

- `xkb/symbols/custom` ← `~/.config/xkb/symbols/custom` (source of truth, 2.8K)
- `xkb/keymaps/cmk_ed_dh_wide_full.xkb` ← `~/.config/xkb/keymaps/cmk_ed_dh_wide_full.xkb`
  (compiled via `xkbcli compile-keymap --model pc104awide --layout custom
  --variant cmk_ed_dh_wide_full --options lv3:ralt_switch`, 71,744 bytes)
- `xkb/backups/` ← `~/.config/xkb/backups/` (`custom.symbols.backup`,
  `cmk_ed_dh_wide_full.xkb.backup`, `restore-cmk-ed-dh-wide.sh`)
- `hypr/input.conf` ← `~/.config/hypr/input.conf`
- `hypr/lua/input.lua` ← `~/.config/hypr/lua/input.lua`
- `kanata/config.kbd` ← `~/.config/kanata/config.kbd`
  (Space-Extend + home-row mods: Space→Extend layer, A→RAlt, F/K→LCtrl, `'`
  →RShift; Caps counts as Shift in EPKL terms because Kanata owns it here too)
- `scripts/toggle-layout.sh` ← `~/user_scripts/keyboard/toggle-layout.sh`
  (cycles EN Colemak-DH ↔ AR on all keyboards)
- `scripts/kanata-toggle.sh` ← `~/user_scripts/keyboard/kanata-toggle.sh`
  (pauses/resumes `kanata.service` = gaming vs typing mode)
- `system/vconsole.conf` ← `/etc/vconsole.conf`
  (`KEYMAP=fr`, `XKBLAYOUT=fr`, `XKBMODEL=pc105`, `XKBOPTIONS=terminate:ctrl_alt_bksp`)
- `system/00-keyboard.conf` ← `/etc/X11/xorg.conf.d/00-keyboard.conf` (same X11 values)
- `system/localectl-status.txt` ← `localectl status`
  (`VC Keymap: fr`, `X11 Layout: fr`, `Model: pc105`, `Options: terminate:ctrl_alt_bksp`)

Note: system-wide `fr` only governs TTY/Xorg. The live Wayland session uses the
`custom,ara` Hyprland config above. `setxkbmap -query` under Xwayland may report
`us` — expected, ignore it.

## Restore on a fresh Linux machine

1. (If the `us(colemak_dh_wide)` base is missing) install DreymaR BigBag first —
   see `~/dotfiles/scripts/install-bigbag-xkb.sh` or the BigBag repo.
2. Run `./Setup-linux.sh` (copies xkb/hypr/kanata/scripts, recompiles the keymap
   if `xkbcli` exists, applies system `fr` keymap with sudo).
3. `hyprctl reload`, then verify:
   `hyprctl -j devices | jq '.keyboards[] | {name, active_keymap}'`
4. Kanata: `systemctl --user start kanata.service`
   (toggle with `~/user_scripts/keyboard/kanata-toggle.sh`, bound to SUPER ALT + F10).
