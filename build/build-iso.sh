#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }
command -v pungi-koji >/dev/null 2>&1 || {
  echo "pungi-koji não encontrado. Instale pungi." >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONF="$ROOT_DIR/compose/fedora-gnome-minimal.conf"
TARGET_DIR="$ROOT_DIR/dist/pungi"
OUTPUT_ISO="$ROOT_DIR/dist/fedora-gnome-minimal.iso"
LOGFILE="$ROOT_DIR/dist/pungi.log"

[[ -f "$CONF" ]] || { echo "Configuração Pungi não encontrada: $CONF" >&2; exit 1; }

mkdir -p "$ROOT_DIR/dist" "$TARGET_DIR"
rm -rf "$TARGET_DIR"/*
rm -f "$OUTPUT_ISO" "$LOGFILE"

# Pungi executa o fluxo de compose documentado para mídia package-based:
# pkgset -> gather -> createrepo -> buildinstall/Lorax -> createiso.
# A ISO final contém os RPMs selecionados e o runtime do Anaconda.
{
  echo "Criando Fedora GNOME Minimal com Pungi + Lorax"
  echo "Configuração: $CONF"
  pungi-koji \
    --config "$CONF" \
    --target-dir "$TARGET_DIR" \
    --test \
    --no-latest-link
} 2>&1 | tee "$LOGFILE"

mapfile -t iso_candidates < <(find "$TARGET_DIR" -type f -path '*/compose/Minimal/x86_64/iso/*.iso' -print | sort)

if [[ ${#iso_candidates[@]} -ne 1 ]]; then
  echo "ERRO: esperado exatamente 1 ISO binária em compose/Minimal/x86_64/iso; encontradas ${#iso_candidates[@]}." >&2
  printf '  %s\n' "${iso_candidates[@]:-}" >&2
  exit 1
fi

cp -f "${iso_candidates[0]}" "$OUTPUT_ISO"
sha256sum "$OUTPUT_ISO" > "$OUTPUT_ISO.sha256"

echo "ISO criada em: $OUTPUT_ISO"
echo "Modo: package-based completo (Pungi + Lorax + repositório RPM embutido)."
echo "Instalador: Anaconda clássico, com armazenamento interativo."
echo "Bootloader alvo do sistema final: systemd-boot."
echo "Primeiro usuário: GNOME Initial Setup no primeiro boot gráfico."
