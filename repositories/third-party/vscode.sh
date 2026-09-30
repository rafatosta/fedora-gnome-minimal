#!/usr/bin/env bash
set -euo pipefail

repo_file="/etc/yum.repos.d/vscode.repo"
key_url="https://packages.microsoft.com/keys/microsoft.asc"

rpm --import "$key_url"

cat > "$repo_file" <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

echo "Repositório do Visual Studio Code configurado."
