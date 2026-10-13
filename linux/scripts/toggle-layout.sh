#!/usr/bin/env bash
# Cycle keyboard layouts for all keyboards (EN Colemak-DH <-> AR)
hyprctl -j devices | jq -r '.keyboards[].name' | sort -u |
  while read -r dev; do
    hyprctl switchxkblayout "$dev" next >/dev/null 2>&1
  done

sleep 0.1
active=$(hyprctl -j devices | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)
notify-send -t 1500 -h string:x-canonical-private-synchronous:layout "$active"
