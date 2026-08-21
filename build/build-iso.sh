#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uso: sudo bash $0 /caminho/Fedora-netinst.iso" >&2
  exit 2
fi

[[ ${EUID} -eq 0 ]] || { echo "Execute como root para compatibilidade UEFI completa." >&2; exit 1; }
command -v mkksiso >/dev/null 2>&1 || {
  echo "mkksiso não encontrado. Instale o pacote lorax." >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INPUT_ISO="$(realpath "$1")"
OUT_DIR="$ROOT_DIR/dist"
OUTPUT_ISO="$OUT_DIR/fedora-gnome-minimal.iso"

mkdir -p "$OUT_DIR"

mkksiso \
  --ks "$ROOT_DIR/kickstart/fedora-gnome.ks" \
  -V "Fedora GNOME Minimal" \
  "$INPUT_ISO" \
  "$OUTPUT_ISO"

echo "ISO criada em: $OUTPUT_ISO"
