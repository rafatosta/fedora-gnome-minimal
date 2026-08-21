#!/usr/bin/env bash
set -euo pipefail

[[ ${EUID} -eq 0 ]] || { echo "Execute como root." >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
LIST="$ROOT_DIR/packages/rpm.txt"

mapfile -t PACKAGES < <(grep -Ev '^\s*(#|$)' "$LIST")
((${#PACKAGES[@]})) || exit 0

dnf install -y "${PACKAGES[@]}"
