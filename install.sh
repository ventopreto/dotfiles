#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

# shellcheck source=scripts/install/lib.sh
source "$PROJECT_DIR/scripts/install/lib.sh"
# shellcheck source=scripts/install/linux.sh
source "$PROJECT_DIR/scripts/install/linux.sh"
# shellcheck source=scripts/install/windows.sh
source "$PROJECT_DIR/scripts/install/windows.sh"
# shellcheck source=scripts/install/wsl.sh
source "$PROJECT_DIR/scripts/install/wsl.sh"

if [ -n "${SUDO_USER:-}" ]; then
    USER_NAME="$SUDO_USER"
else
    USER_NAME="$(id -un)"
fi

HOME_DIR="${HOME:-/home/$USER_NAME}"
[ "$USER_NAME" = "root" ] && HOME_DIR="/root"

if is_wsl; then
    msg "Ambiente WSL detectado"
    bootstrap_wsl_host "$PROJECT_DIR" "$HOME_DIR" "$USER_NAME"
elif is_linux; then
    msg "Ambiente Linux detectado"
    bootstrap_linux_host "$PROJECT_DIR" "$HOME_DIR" "$USER_NAME"
elif is_windows; then
    msg "Ambiente Windows detectado"
    run_windows_bootstrap "$PROJECT_DIR"
else
    warn "plataforma nao suportada por este bootstrap"
    exit 1
fi
