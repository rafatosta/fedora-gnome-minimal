#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uso: sudo bash $0 /caminho/Fedora-Everything-netinst.iso" >&2
  exit 2
fi

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }
command -v livemedia-creator >/dev/null 2>&1 || {
  echo "livemedia-creator não encontrado. Instale lorax e lorax-lmc-virt." >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INPUT_ISO="$(realpath "$1")"
RESULT_DIR="$ROOT_DIR/dist/lmc"
OUTPUT_ISO="$ROOT_DIR/dist/fedora-gnome-minimal.iso"
KS="$ROOT_DIR/kickstart/fedora-gnome.ks"

rm -rf "$RESULT_DIR"
mkdir -p "$RESULT_DIR" "$(dirname "$OUTPUT_ISO")"

# O Kickstart aqui descreve o conteúdo da imagem Live. Ele NÃO é usado para
# automatizar o particionamento do computador do usuário.
livemedia-creator \
  --make-iso \
  --iso="$INPUT_ISO" \
  --ks="$KS" \
  --resultdir="$RESULT_DIR" \
  --logfile="$RESULT_DIR/livemedia-creator.log"

BUILT_ISO="$RESULT_DIR/images/boot.iso"
if [[ ! -f "$BUILT_ISO" ]]; then
  echo "ERRO: livemedia-creator terminou sem produzir $BUILT_ISO" >&2
  exit 1
fi

cp -f "$BUILT_ISO" "$OUTPUT_ISO"
echo "ISO Live criada em: $OUTPUT_ISO"
echo "A instalação final usa a WebUI do Anaconda e mantém o armazenamento interativo."
