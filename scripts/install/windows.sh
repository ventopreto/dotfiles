#!/bin/bash

set -euo pipefail

run_windows_bootstrap() {
    local project_dir="$1"

    if ! have_cmd powershell.exe; then
        warn "powershell.exe nao encontrado; pulando bootstrap do Windows"
        return 1
    fi

    local bootstrap_ps1="$project_dir/scripts/install/windows-bootstrap.ps1"
    local repo_source_windows
    repo_source_windows="$(to_windows_path "$project_dir")"

    msg "Chamando bootstrap do Windows..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$bootstrap_ps1" -RepoSource "$repo_source_windows"
}
