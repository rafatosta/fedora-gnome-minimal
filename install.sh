#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo ./install.sh"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$REPO_DIR/packages/gnome-minimal.txt"

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Arquivo de pacotes não encontrado: $PACKAGE_FILE"
  exit 1
fi

mapfile -t PACKAGES < <(grep -Ev '^[[:space:]]*(#|$)' "$PACKAGE_FILE")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "Nenhum pacote definido em $PACKAGE_FILE"
  exit 1
fi

echo "Atualizando metadados do DNF..."
dnf -y makecache --refresh

echo "Instalando GNOME mínimo..."
dnf -y install "${PACKAGES[@]}"

echo "Ativando NetworkManager e GDM..."
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl set-default graphical.target

echo
echo "GNOME mínimo instalado."
echo "Reinicie quando estiver pronto: sudo reboot"
