#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo ./install.sh [ação]"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read_manifest() {
  grep -Ev '^[[:space:]]*(#|$)' "$1"
}

install_manifest() {
  local file="$1"
  local -a packages=()

  [[ -f "$file" ]] || {
    echo "Arquivo não encontrado: $file" >&2
    exit 1
  }

  mapfile -t packages < <(read_manifest "$file")
  ((${#packages[@]})) || return 0
  dnf -y install "${packages[@]}"
}

install_gnome() {
  echo "Atualizando metadados do DNF..."
  dnf -y makecache --refresh

  echo "Instalando GNOME mínimo..."
  install_manifest "$REPO_DIR/packages/gnome-minimal.txt"

  echo "Ativando NetworkManager e GDM..."
  systemctl enable NetworkManager.service
  systemctl enable gdm.service
  systemctl set-default graphical.target
}

setup_repositories() {
  echo "Configurando repositórios de terceiros..."
  bash "$REPO_DIR/repositories/third-party/google-chrome.sh"
  bash "$REPO_DIR/repositories/third-party/vscode.sh"
  bash "$REPO_DIR/repositories/third-party/chatgpt.sh"
  dnf -y makecache --refresh
}

install_third_party_rpm() {
  setup_repositories
  echo "Instalando aplicativos RPM de terceiros..."
  install_manifest "$REPO_DIR/packages/rpm/third-party-apps.txt"
}

setup_flathub() {
  command -v flatpak >/dev/null 2>&1 || dnf install -y flatpak
  flatpak remote-add --system --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
}

install_flatpak_manifest() {
  local file="$1"
  local app

  [[ -f "$file" ]] || {
    echo "Arquivo não encontrado: $file" >&2
    exit 1
  }

  while IFS= read -r app; do
    [[ -n "$app" ]] || continue
    echo "Instalando Flatpak: $app"
    flatpak install --system -y --noninteractive flathub "$app"
  done < <(read_manifest "$file")
}

install_flatpaks() {
  setup_flathub
  install_flatpak_manifest "$REPO_DIR/packages/flatpak/gnome-apps.txt"
  install_flatpak_manifest "$REPO_DIR/packages/flatpak/third-party-apps.txt"
}

show_help() {
  cat <<'EOF'
Uso:
  sudo ./install.sh [ação]

Ações:
  gnome      Instala somente o GNOME mínimo
  repos      Configura os repositórios de terceiros
  apps       Instala Chrome, VS Code e ChatGPT via RPM
  flatpaks   Instala Calculadora/Agenda GNOME e aplicativos conhecidos via Flathub
  all        Instala GNOME mínimo + aplicativos de terceiros
  help       Exibe esta ajuda

Sem argumentos, instala somente o GNOME mínimo.
EOF
}

action="${1:-gnome}"

case "$action" in
  gnome) install_gnome ;;
  repos) setup_repositories ;;
  apps) install_third_party_rpm ;;
  flatpaks) install_flatpaks ;;
  all)
    install_gnome
    install_third_party_rpm
    install_flatpaks
    ;;
  help|-h|--help) show_help ;;
  *)
    echo "Ação desconhecida: $action" >&2
    show_help >&2
    exit 2
    ;;
esac
