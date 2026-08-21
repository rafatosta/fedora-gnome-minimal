#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }

SERVICES=(
  ModemManager.service
  avahi-daemon.service
  cups.service
  pcscd.service
  smartd.service
  NetworkManager-wait-online.service
)

for unit in "${SERVICES[@]}"; do
  if systemctl list-unit-files "$unit" --no-legend 2>/dev/null | grep -q .; then
    echo "Desabilitando $unit"
    systemctl disable --now "$unit" || true
  fi
done

# Serviços deliberadamente preservados:
# NetworkManager, firewalld, systemd-resolved, thermald, irqbalance,
# tuned/tuned-ppd quando presentes, upower, udisks2 e serviços NVIDIA.
