#!/bin/bash

set -euo pipefail

msg() {
    local green="\033[1;32m"
    local cyan="\033[1;36m"
    local reset="\033[0m"
    local prefix="➜"

    if [[ "${1:-}" =~ conclu[ií]da ]]; then
        echo -e "${cyan}${prefix} $1${reset}"
    else
        echo -e "${green}${prefix} $1${reset}"
    fi
}

warn() {
    printf 'warning: %s\n' "$*" >&2
}

info() {
    printf 'info: %s\n' "$*"
}

is_windows() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_wsl() {
    [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

have_apt_package() {
    dpkg -s "$1" >/dev/null 2>&1
}

file_contains_line() {
    local line="$1"
    local file="$2"

    [ -f "$file" ] && grep -Fqx "$line" "$file"
}

ensure_directory() {
    mkdir -p "$1"
}

ensure_symlink_target_dir() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
}

copy_if_missing() {
    local source="$1"
    local target="$2"

    ensure_symlink_target_dir "$target"
    [ -e "$target" ] || cp -r "$source" "$target"
}

ensure_line() {
    local line="$1"
    local file="$2"

    touch "$file"
    grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

apply_chezmoi_from_source() {
    local source_dir="$1"

    if ! have_cmd chezmoi; then
        warn "chezmoi nao encontrado; pulando apply"
        return 1
    fi

    chezmoi apply -S "$source_dir"
}

project_dir_from_script() {
    local script_path="$1"
    cd "$(dirname "$script_path")/../.." && pwd
}

to_windows_path() {
    local path="$1"

    if have_cmd wslpath; then
        wslpath -w "$path"
        return
    fi

    if have_cmd cygpath; then
        cygpath -w "$path"
        return
    fi

    printf '%s\n' "$path"
}
