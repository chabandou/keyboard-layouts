#!/usr/bin/env bash
set -euo pipefail
# Restore Linux keyboard layout from this repo onto a fresh Arch/Omarchy + Hyprland machine.
# Source machine: omarchy (Arch Linux, Hyprland 0.56.1), captured 2026-10-13.
# Active setup: custom Colemak-DH Wide + Arabic, model pc104awide, lv3:ralt_switch.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XKB_SYMBOLS_SRC="$REPO_DIR/xkb/symbols/custom"
XKB_KEYMAP_SRC="$REPO_DIR/xkb/keymaps/cmk_ed_dh_wide_full.xkb"
HYPR_INPUT_SRC="$REPO_DIR/hypr/input.conf"
HYPR_LUA_SRC="$REPO_DIR/hypr/lua/input.lua"
KANATA_SRC="$REPO_DIR/kanata/config.kbd"

XKB_SYMBOLS_DST="$HOME/.config/xkb/symbols/custom"
XKB_KEYMAP_DST="$HOME/.config/xkb/keymaps/cmk_ed_dh_wide_full.xkb"
HYPR_INPUT_DST="$HOME/.config/hypr/input.conf"
HYPR_LUA_DST="$HOME/.config/hypr/lua/input.lua"
KANATA_DST="$HOME/.config/kanata/config.kbd"

mkdir -p "$(dirname "$XKB_SYMBOLS_DST")" "$(dirname "$XKB_KEYMAP_DST")" \
         "$(dirname "$HYPR_INPUT_DST")" "$(dirname "$HYPR_LUA_DST")" \
         "$(dirname "$KANATA_DST")" "$HOME/user_scripts/keyboard"

backup_if_exists() {
  if [[ -e "$1" ]]; then
    cp -a "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up $1"
  fi
}

echo "== xkb symbols (verbatim source of truth) =="
backup_if_exists "$XKB_SYMBOLS_DST"
cp -a "$XKB_SYMBOLS_SRC" "$XKB_SYMBOLS_DST"
echo "  $XKB_SYMBOLS_SRC -> $XKB_SYMBOLS_DST"

echo "== xkb compiled keymap (verbatim, optional — recompiled below) =="
backup_if_exists "$XKB_KEYMAP_DST"
cp -a "$XKB_KEYMAP_SRC" "$XKB_KEYMAP_DST"
echo "  $XKB_KEYMAP_SRC -> $XKB_KEYMAP_DST"

if command -v xkbcli >/dev/null 2>&1; then
  echo "== recompile keymap with xkbcli =="
  XDG_CONFIG_HOME="$HOME/.config" xkbcli compile-keymap \
    --model pc104awide \
    --layout custom \
    --variant cmk_ed_dh_wide_full \
    --options lv3:ralt_switch \
    > "$XKB_KEYMAP_DST"
  echo "  recompiled $XKB_KEYMAP_DST"
else
  echo "!! xkbcli not found, kept verbatim keymap copy"
fi

echo "== hyprland input =="
backup_if_exists "$HYPR_INPUT_DST"
cp -a "$HYPR_INPUT_SRC" "$HYPR_INPUT_DST"
backup_if_exists "$HYPR_LUA_DST"
cp -a "$HYPR_LUA_SRC" "$HYPR_LUA_DST"
echo "  hypr/input.conf + hypr/lua/input.lua installed"

echo "== kanata =="
backup_if_exists "$KANATA_DST"
cp -a "$KANATA_SRC" "$KANATA_DST"
cp -a "$REPO_DIR/scripts/toggle-layout.sh" "$REPO_DIR/scripts/kanata-toggle.sh" "$HOME/user_scripts/keyboard/"
chmod +x "$HOME/user_scripts/keyboard/"*.sh
echo "  kanata/config.kbd + helper scripts installed"

echo "== system keyboard (requires sudo) =="
echo "  Tracked values (see system/): VC KEYMAP=fr, X11 fr/pc105/terminate:ctrl_alt_bksp"
echo "  This Hyprland setup overrides them per-compositor (custom,ara / cmk_ed_dh_wide_full). System values only matter for TTY/Xorg."
if command -v sudo >/dev/null 2>&1 && command -v localectl >/dev/null 2>&1; then
  sudo localectl set-keymap fr || true
  sudo localectl set-x11-keymap fr pc105 '' terminate:ctrl_alt_bksp || true
  echo "  system keymap applied"
else
  echo "!! sudo/localectl unavailable, skipped. Apply manually:"
  echo "   sudo localectl set-keymap fr"
  echo "   sudo localectl set-x11-keymap fr pc105 '' terminate:ctrl_alt_bksp"
fi

echo
echo "Apply in current Hyprland session with:"
echo "  hyprctl reload"
echo "Verify with: hyprctl -j devices | jq '.keyboards[] | {name, active_keymap}'"
