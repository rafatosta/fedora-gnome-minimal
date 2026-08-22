#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uso: sudo bash $0 /caminho/Fedora-Everything-netinst.iso" >&2
  exit 2
fi

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }
command -v mkksiso >/dev/null 2>&1 || {
  echo "mkksiso não encontrado. Instale o pacote lorax." >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INPUT_ISO="$(realpath "$1")"
OUTPUT_ISO="$ROOT_DIR/dist/fedora-gnome-minimal.iso"
LOGFILE="$ROOT_DIR/dist/mkksiso.log"
KS="$ROOT_DIR/kickstart/fedora-gnome.ks"
FEDORA_RELEASE="${FEDORA_RELEASE:-44}"
INSTALL_REPO_URL="${INSTALL_REPO_URL:-https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_RELEASE}/Everything/x86_64/os/}"

[[ -f "$INPUT_ISO" ]] || { echo "ISO fonte não encontrada: $INPUT_ISO" >&2; exit 1; }
[[ -f "$KS" ]] || { echo "Kickstart não encontrado: $KS" >&2; exit 1; }

mkdir -p "$(dirname "$OUTPUT_ISO")"
rm -f "$OUTPUT_ISO" "$LOGFILE"

# Arquitetura package-based:
# - a Fedora Everything netinstall fornece o runtime oficial do Anaconda;
# - mkksiso incorpora o Kickstart sem criar/clonar uma imagem Live;
# - inst.sdboot seleciona systemd-boot na instalação FINAL;
# - inst.profile=fedora-workstation mantém o perfil/experiência Workstation;
# - inst.pauseatsummary impede início automático antes da confirmação do usuário;
# - o repositório de pacotes vem da árvore oficial Fedora Everything.
#
# O Kickstart não contém comandos de particionamento. A WebUI continua
# responsável pela configuração de armazenamento no computador de destino.
BOOT_ARGS="inst.sdboot inst.profile=fedora-workstation inst.pauseatsummary inst.repo=${INSTALL_REPO_URL}"

{
  echo "Criando mídia package-based com mkksiso"
  echo "Fedora: $FEDORA_RELEASE"
  echo "Fonte de pacotes: $INSTALL_REPO_URL"
  echo "Argumentos Anaconda: $BOOT_ARGS"

  mkksiso \
    --cmdline "$BOOT_ARGS" \
    --ks "$KS" \
    "$INPUT_ISO" \
    "$OUTPUT_ISO"
} 2>&1 | tee "$LOGFILE"

if [[ ! -f "$OUTPUT_ISO" ]]; then
  echo "ERRO: mkksiso terminou sem produzir $OUTPUT_ISO" >&2
  exit 1
fi

echo "ISO de instalação criada em: $OUTPUT_ISO"
echo "Modo: package-based (Fedora Everything netinstall + Kickstart)."
echo "Bootloader alvo da instalação final: systemd-boot (UEFI)."
echo "Armazenamento final: interativo pela WebUI do Anaconda."
