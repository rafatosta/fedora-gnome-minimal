#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo ./install.sh personalize"
  exit 1
fi

TARGET_USER="${SUDO_USER:-}"
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  echo "Não foi possível identificar o usuário da sessão GNOME. Execute via sudo a partir da sua conta de usuário." >&2
  exit 1
fi

TARGET_UID="$(id -u "$TARGET_USER")"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_RUNTIME="/run/user/$TARGET_UID"
TARGET_BUS="unix:path=$TARGET_RUNTIME/bus"

run_as_user() {
  runuser -u "$TARGET_USER" -- env \
    HOME="$TARGET_HOME" \
    USER="$TARGET_USER" \
    LOGNAME="$TARGET_USER" \
    XDG_RUNTIME_DIR="$TARGET_RUNTIME" \
    DBUS_SESSION_BUS_ADDRESS="$TARGET_BUS" \
    "$@"
}

install_icons() {
  local repo="https://github.com/rafatosta/LinuxMidnight-icon-theme.git"
  local tmp_dir

  command -v git >/dev/null 2>&1 || dnf install -y git

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf -- "$tmp_dir"' RETURN

  echo "Instalando tema de ícones LinuxMidnight para $TARGET_USER..."
  git clone --depth=1 "$repo" "$tmp_dir/LinuxMidnight-icon-theme"
  chmod -R a+rX "$tmp_dir/LinuxMidnight-icon-theme"
  run_as_user bash "$tmp_dir/LinuxMidnight-icon-theme/install.sh"

  if run_as_user gsettings list-schemas | grep -Fxq org.gnome.desktop.interface; then
    run_as_user gsettings set org.gnome.desktop.interface icon-theme 'LinuxMidnight'
  fi
}

configure_gnome() {
  if [[ ! -S "$TARGET_RUNTIME/bus" ]]; then
    echo "A sessão gráfica de $TARGET_USER não está ativa; não é possível aplicar gsettings agora." >&2
    exit 1
  fi

  echo "Aplicando preferências pessoais do GNOME..."

  run_as_user gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true

  run_as_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
  run_as_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0

  run_as_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
  run_as_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
}

case "${1:-all}" in
  icons)
    install_icons
    ;;
  settings)
    configure_gnome
    ;;
  all)
    install_icons
    configure_gnome
    ;;
  *)
    echo "Uso: $0 [icons|settings|all]" >&2
    exit 2
    ;;
esac
