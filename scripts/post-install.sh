#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root: sudo bash $0" >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "== Atualizando Fedora =="
dnf upgrade --refresh -y

echo "== Configurando repositórios =="
bash "$SCRIPT_DIR/setup-repositories.sh"

echo "== Instalando pacotes RPM =="
bash "$SCRIPT_DIR/install-rpm-apps.sh"

echo "== Instalando Flatpaks =="
bash "$SCRIPT_DIR/install-flatpaks.sh"

echo "== Ajustando serviços =="
bash "$SCRIPT_DIR/disable-services.sh"

echo "== Limpeza =="
dnf autoremove -y || true
flatpak uninstall --system --unused -y || true

echo "Pós-instalação concluída. Reinicie o sistema quando for conveniente."
