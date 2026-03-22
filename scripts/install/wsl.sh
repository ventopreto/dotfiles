#!/bin/bash

set -euo pipefail

bootstrap_wsl_host() {
    local project_dir="$1"
    local home_dir="$2"
    local user_name="$3"

    bootstrap_linux_host "$project_dir" "$home_dir" "$user_name"

    if have_cmd powershell.exe; then
        msg "Tentando bootstrap do host Windows via WSL..."
        if ! run_windows_bootstrap "$project_dir"; then
            warn "falha ao executar o bootstrap do Windows a partir da WSL; rode o script tambem no Windows"
        fi
    else
        warn "powershell.exe nao disponivel; bootstrap do Windows foi ignorado"
    fi
}
