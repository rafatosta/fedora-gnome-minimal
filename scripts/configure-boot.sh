#!/usr/bin/env bash
set -euo pipefail

GRUB_DEFAULT_FILE="/etc/default/grub"

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo ./install.sh boot"
  exit 1
fi

if [[ ! -f "$GRUB_DEFAULT_FILE" ]]; then
  echo "Arquivo não encontrado: $GRUB_DEFAULT_FILE" >&2
  exit 1
fi

set_grub_value() {
  local key="$1"
  local value="$2"

  if grep -qE "^${key}=" "$GRUB_DEFAULT_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$GRUB_DEFAULT_FILE"
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$GRUB_DEFAULT_FILE"
  fi
}

echo "Configurando GRUB para boot imediato e menu oculto..."
set_grub_value "GRUB_TIMEOUT" "0"
set_grub_value "GRUB_TIMEOUT_STYLE" "hidden"

# Mantém o Plymouth/splash gráfico do Fedora.
if grep -q '^GRUB_CMDLINE_LINUX=' "$GRUB_DEFAULT_FILE"; then
  current_cmdline="$(sed -n 's/^GRUB_CMDLINE_LINUX="\(.*\)"/\1/p' "$GRUB_DEFAULT_FILE")"

  for arg in quiet rhgb; do
    if [[ " $current_cmdline " != *" $arg "* ]]; then
      current_cmdline="${current_cmdline:+$current_cmdline }$arg"
    fi
  done

  sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$current_cmdline\"|" "$GRUB_DEFAULT_FILE"
else
  printf '\nGRUB_CMDLINE_LINUX="quiet rhgb"\n' >> "$GRUB_DEFAULT_FILE"
fi

echo "Regenerando a configuração do GRUB..."
grub2-mkconfig -o /boot/grub2/grub.cfg

echo
echo "Boot configurado:"
echo "  GRUB_TIMEOUT=0"
echo "  GRUB_TIMEOUT_STYLE=hidden"
echo "  Plymouth mantido por quiet + rhgb"
