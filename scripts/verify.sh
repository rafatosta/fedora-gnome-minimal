#!/usr/bin/env bash
set -u

fail=0
check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[OK]   %s\n' "$cmd"
  else
    printf '[MISS] %s\n' "$cmd"
    fail=1
  fi
}

for cmd in dnf flatpak git node python3; do check_cmd "$cmd"; done

printf '\nDisplay manager: '
systemctl is-enabled gdm.service 2>/dev/null || true
printf 'Target padrão: '
systemctl get-default 2>/dev/null || true
printf 'GNOME: '
gnome-shell --version 2>/dev/null || true

exit "$fail"
