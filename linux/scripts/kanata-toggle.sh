#!/usr/bin/env bash
set -euo pipefail

unit="kanata.service"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Kanata" "$1"
  fi
}

if systemctl --user is-active --quiet "$unit"; then
  systemctl --user stop "$unit"
  notify "Gaming mode: remaps paused"
else
  systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
  systemctl --user start "$unit"
  notify "Typing mode: remaps enabled"
fi
