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

for cmd in dnf flatpak git node python3 mokutil; do check_cmd "$cmd"; done

printf '\nDisplay manager: '
systemctl is-enabled gdm.service 2>/dev/null || true
printf 'Target padrão: '
systemctl get-default 2>/dev/null || true
printf 'GNOME: '
gnome-shell --version 2>/dev/null || true

printf '\nSecure Boot: '
mokutil --sb-state 2>/dev/null || true

printf 'NVIDIA driver: '
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || true
else
  echo 'nvidia-smi não encontrado'
  fail=1
fi

printf 'Assinatura do módulo NVIDIA: '
SIGNER="$(modinfo -F signer nvidia 2>/dev/null || true)"
if [[ -n "$SIGNER" ]]; then
  echo "$SIGNER"
else
  echo 'não detectada'
  fail=1
fi

if [[ -f /etc/pki/akmods/certs/public_key.der ]]; then
  printf 'Chave akmods no MOK: '
  if mokutil --test-key /etc/pki/akmods/certs/public_key.der >/dev/null 2>&1; then
    echo 'inscrita'
  else
    echo 'não inscrita / inscrição pendente'
  fi
fi

exit "$fail"
