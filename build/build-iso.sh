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

# systemd-boot é UEFI-only. O build precisa usar firmware UEFI/OVMF.
if [[ ! -d /usr/share/edk2 ]]; then
  echo "Firmware UEFI/EDK2 não encontrado em /usr/share/edk2." >&2
  echo "Instale o pacote de firmware UEFI fornecido pela sua versão do Fedora." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INPUT_ISO="$(realpath "$1")"
RESULT_DIR="$ROOT_DIR/dist/lmc"
OUTPUT_ISO="$ROOT_DIR/dist/fedora-gnome-minimal.iso"
LOGFILE="$ROOT_DIR/dist/livemedia-creator.log"
KS="$ROOT_DIR/kickstart/fedora-gnome.ks"

# livemedia-creator exige que --resultdir NÃO exista ao iniciar.
# Crie apenas o diretório pai e deixe a própria ferramenta criar RESULT_DIR.
mkdir -p "$(dirname "$OUTPUT_ISO")"
rm -rf "$RESULT_DIR"
rm -f "$LOGFILE"

# O Kickstart descreve o conteúdo da imagem Live. Ele NÃO é usado para
# automatizar o particionamento do computador do usuário.
#
# --virt-uefi é obrigatório aqui porque a imagem é construída com
# systemd-boot e uma EFI System Partition (ESP).
livemedia-creator \
  --make-iso \
  --virt-uefi \
  --iso="$INPUT_ISO" \
  --ks="$KS" \
  --resultdir="$RESULT_DIR" \
  --logfile="$LOGFILE"

BUILT_ISO="$RESULT_DIR/images/boot.iso"
if [[ ! -f "$BUILT_ISO" ]]; then
  echo "ERRO: livemedia-creator terminou sem produzir $BUILT_ISO" >&2
  exit 1
fi

cp -f "$BUILT_ISO" "$OUTPUT_ISO"
echo "ISO Live criada em: $OUTPUT_ISO"
echo "Bootloader alvo: systemd-boot (UEFI)."
echo "A instalação final usa a WebUI do Anaconda e mantém o armazenamento interativo."
