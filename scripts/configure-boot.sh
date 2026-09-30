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

if rpm -q plymouth >/dev/null 2>&1; then
  desired_args=(quiet rhgb)
  echo "Plymouth detectado: mantendo splash gráfico com quiet + rhgb."
else
  desired_args=(quiet)
  echo "Plymouth não instalado: usando apenas quiet."
fi

if grep -q '^GRUB_CMDLINE_LINUX=' "$GRUB_DEFAULT_FILE"; then
  current_cmdline="$(sed -n 's/^GRUB_CMDLINE_LINUX="\(.*\)"/\1/p' "$GRUB_DEFAULT_FILE")"

  # Remove rhgb quando Plymouth não estiver instalado.
  if ! rpm -q plymouth >/dev/null 2>&1; then
    current_cmdline="$(printf '%s\n' "$current_cmdline" | sed -E 's/(^|[[:space:]])rhgb([[:space:]]|$)/ /g; s/[[:space:]]+/ /g; s/^ //; s/ $//')"
  fi

  for arg in "${desired_args[@]}"; do
    if [[ " $current_cmdline " != *" $arg "* ]]; then
      current_cmdline="${current_cmdline:+$current_cmdline }$arg"
    fi
  done

  sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$current_cmdline\"|" "$GRUB_DEFAULT_FILE"
else
  printf '\nGRUB_CMDLINE_LINUX="%s"\n' "${desired_args[*]}" >> "$GRUB_DEFAULT_FILE"
fi

echo "Regenerando a configuração do GRUB..."
grub2-mkconfig -o /boot/grub2/grub.cfg

echo
echo "Boot configurado:"
echo "  GRUB_TIMEOUT=0"
echo "  GRUB_TIMEOUT_STYLE=hidden"
if rpm -q plymouth >/dev/null 2>&1; then
  echo "  Plymouth detectado: quiet + rhgb"
else
  echo "  Plymouth ausente: quiet"
fi
