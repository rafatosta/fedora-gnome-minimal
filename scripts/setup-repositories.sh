#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }

echo "Configurando repositórios de terceiros..."

# Visual Studio Code
if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
  rpm --import https://packages.microsoft.com/keys/microsoft.asc
  cat >/etc/yum.repos.d/vscode.repo <<'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
fi

# Google Chrome
if [[ ! -f /etc/yum.repos.d/google-chrome.repo ]]; then
  cat >/etc/yum.repos.d/google-chrome.repo <<'REPO'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
REPO
fi

dnf makecache -y
