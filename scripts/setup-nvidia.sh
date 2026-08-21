#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root: sudo bash $0" >&2; exit 1; }

FEDORA_VERSION="$(rpm -E %fedora)"
RPMFUSION_FREE="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
RPMFUSION_NONFREE="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
AKMOD_CERT="/etc/pki/akmods/certs/public_key.der"

echo "== NVIDIA / RPM Fusion =="

# RPM Fusion fornece o driver NVIDIA empacotado para Fedora.
dnf install -y "$RPMFUSION_FREE" "$RPMFUSION_NONFREE"

echo "== Preparando assinatura de módulos para Secure Boot =="
# A chave precisa existir ANTES da primeira compilação do módulo NVIDIA.
dnf install -y akmods mokutil openssl kernel-devel kernel-headers

if [[ ! -f "$AKMOD_CERT" ]]; then
  kmodgenca -a
fi

if [[ ! -f "$AKMOD_CERT" ]]; then
  echo "ERRO: a chave pública do akmods não foi criada em $AKMOD_CERT" >&2
  exit 1
fi

echo "== Instalando driver NVIDIA =="
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# Força a construção/reconstrução com a chave já existente.
akmods --force --rebuild

if mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot enabled'; then
  echo
  echo "Secure Boot está ATIVADO."
  if mokutil --test-key "$AKMOD_CERT" >/dev/null 2>&1; then
    echo "A chave do akmods já está inscrita no firmware/MOK."
  else
    echo "A chave do akmods ainda precisa ser inscrita no MOK."
    echo "O comando a seguir solicitará uma senha temporária."
    echo "No próximo boot, confirme a inscrição no MokManager usando essa senha."
    mokutil --import "$AKMOD_CERT"
  fi
else
  echo "Secure Boot não está ativo; a chave foi criada mesmo assim para manter o fluxo reproduzível."
fi

echo
echo "Estado do módulo NVIDIA:"
modinfo -F signer nvidia 2>/dev/null || echo "Módulo ainda não disponível para consulta; verifique após a compilação/reboot."
echo
echo "NVIDIA preparada. Se houve inscrição MOK pendente, reinicie e conclua-a no MokManager."
