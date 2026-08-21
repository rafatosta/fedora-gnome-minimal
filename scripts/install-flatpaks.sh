#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
LIST="$ROOT_DIR/packages/flatpak.txt"

flatpak remote-add --system --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

while IFS= read -r app; do
  [[ -z "$app" || "$app" =~ ^[[:space:]]*# ]] && continue
  echo "Instalando Flatpak: $app"
  flatpak install --system -y --noninteractive flathub "$app" || \
    echo "Aviso: não foi possível instalar $app" >&2
done < "$LIST"

flatpak update --system -y --noninteractive || true
