#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root: sudo bash $0" >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "== Atualizando Fedora =="
dnf upgrade --refresh -y

echo "== Configurando repositórios =="
bash "$SCRIPT_DIR/setup-repositories.sh"

echo "== Preparando NVIDIA e Secure Boot =="
bash "$SCRIPT_DIR/setup-nvidia.sh"

echo "== Instalando pacotes RPM =="
bash "$SCRIPT_DIR/install-rpm-apps.sh"

echo "== Instalando Flatpaks =="
bash "$SCRIPT_DIR/install-flatpaks.sh"

echo "== Ajustando serviços =="
bash "$SCRIPT_DIR/disable-services.sh"

echo "== Limpeza =="
dnf autoremove -y || true
flatpak uninstall --system --unused -y || true

echo
if mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot enabled' && ! mokutil --test-key /etc/pki/akmods/certs/public_key.der >/dev/null 2>&1; then
  echo "Pós-instalação concluída. Reinicie e conclua a inscrição da chave NVIDIA no MokManager."
else
  echo "Pós-instalação concluída. Reinicie o sistema quando for conveniente."
fi
