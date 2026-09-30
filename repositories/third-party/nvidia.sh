#!/usr/bin/env bash
set -euo pipefail

# Fedora Workstation disponibiliza o repositório do driver NVIDIA
# por meio do pacote fedora-workstation-repositories.

dnf -y install fedora-workstation-repositories

# Habilita somente o repositório NVIDIA usado pelo Workstation.
dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=1

echo "Repositório NVIDIA do Fedora Workstation habilitado: rpmfusion-nonfree-nvidia-driver"
