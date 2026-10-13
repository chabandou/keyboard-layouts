#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.config/xkb/backups"
SYMBOLS_DST="$HOME/.config/xkb/symbols/custom"
KEYMAP_DST="$HOME/.config/xkb/keymaps/cmk_ed_dh_wide_full.xkb"

mkdir -p "$(dirname "$SYMBOLS_DST")" "$(dirname "$KEYMAP_DST")"
cp "$BACKUP_DIR/custom.symbols.backup" "$SYMBOLS_DST"

XDG_CONFIG_HOME="$HOME/.config" xkbcli compile-keymap \
  --model pc104awide \
  --layout custom \
  --variant cmk_ed_dh_wide_full \
  --options lv3:ralt_switch \
  > "$KEYMAP_DST"

echo "Restored keymap files:"
echo "  $SYMBOLS_DST"
echo "  $KEYMAP_DST"
echo
echo "Apply in current session with:"
echo "  hyprctl keyword input:kb_file $KEYMAP_DST"
echo "  hyprctl reload"
