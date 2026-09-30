#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo ./scripts/install-nvidia.sh" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT="/etc/pki/akmods/certs/public_key.der"

log() {
  printf '\n==> %s\n' "$*"
}

log "Habilitando o repositório NVIDIA do Fedora Workstation"
bash "$ROOT_DIR/repositories/third-party/nvidia.sh"

log "Instalando ferramentas de assinatura e dependências"
dnf -y install mokutil openssl akmods kernel-devel-matched

if [[ ! -f "$CERT" ]]; then
  log "Gerando a chave de assinatura dos módulos akmods"
  kmodgenca -a
fi

if [[ ! -f "$CERT" ]]; then
  echo "ERRO: certificado MOK não encontrado em $CERT" >&2
  exit 1
fi

secure_boot=0
if mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot enabled'; then
  secure_boot=1
fi

if (( secure_boot )); then
  if mokutil --test-key "$CERT" >/dev/null 2>&1; then
    log "A chave akmods já está registrada no MOK"
  else
    log "Preparando o registro da chave MOK"

    MOK_PASSWORD="$(openssl rand -hex 4)"
    HASH_FILE="$(mktemp)"
    trap 'rm -f -- "$HASH_FILE"' EXIT

    mokutil --generate-hash="$MOK_PASSWORD" > "$HASH_FILE"
    mokutil --import "$CERT" --hash-file "$HASH_FILE"

    printf '\n============================================================\n'
    printf ' SENHA TEMPORÁRIA DO MOK: %s\n' "$MOK_PASSWORD"
    printf '============================================================\n'
    printf 'Anote essa senha. Ela será usada UMA VEZ no próximo boot.\n'
    printf 'No MOK Manager escolha: Enroll MOK -> Continue -> Yes.\n'
    printf 'Depois informe a senha acima e reinicie.\n'
    printf 'A senha não é salva pelo script.\n\n'

    read -r -p 'Pressione Enter depois de anotar a senha... ' _
  fi
else
  log "Secure Boot está desativado; registro MOK não é necessário"
fi

log "Instalando o driver NVIDIA"
dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda

log "Construindo os módulos NVIDIA para o kernel atual"
akmods --force

printf '\nInstalação NVIDIA concluída.\n'
if (( secure_boot )); then
  printf 'Reinicie o computador e conclua o registro no MOK Manager, se solicitado.\n'
else
  printf 'Reinicie o computador para carregar o driver NVIDIA.\n'
fi
