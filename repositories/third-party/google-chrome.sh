#!/usr/bin/env bash
set -euo pipefail

arch="$(uname -m)"
if [[ "$arch" != "x86_64" ]]; then
  echo "Google Chrome RPM oficial suportado apenas em x86_64 neste script: $arch" >&2
  exit 1
fi

cat > /etc/yum.repos.d/google-chrome.repo <<'EOF'
[google-chrome]
name=Google Chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

echo "Repositório oficial do Google Chrome configurado."
