#!/bin/bash

set -euo pipefail

install_linux_base_packages() {
    msg "Atualizando pacotes e instalando dependencias base..."
    sudo apt update -qq
    sudo apt install -y -qq \
        fontconfig \
        curl \
        wget \
        git \
        file \
        neovim \
        ripgrep \
        fd-find \
        xclip \
        lsb-release \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
        unzip \
        build-essential \
        libffi-dev \
        libyaml-dev \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev \
        autojump \
        tmux \
        chafa \
        ffmpeg \
        7zip \
        jq \
        poppler-utils \
        fzf \
        imagemagick \
        apt-utils
}

install_linux_fonts() {
    local project_dir="$1"
    local home_dir="$2"

    msg "Instalando as fontes..."
    ensure_directory "$home_dir/.fonts"
    for font_dir in "$project_dir"/fonts/*; do
        [ -e "$font_dir" ] || continue
        copy_if_missing "$font_dir" "$home_dir/.fonts/$(basename "$font_dir")"
    done
    fc-cache -f
}

install_tpm() {
    local home_dir="$1"
    local tpm_dir="$home_dir/.tmux/plugins/tpm"

    msg "Instalando TPM..."
    if [ -d "$tpm_dir/.git" ]; then
        info "TPM ja instalado; pulando clone"
        return
    fi

    ensure_directory "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

install_nushell() {
    local fury_keyring="/etc/apt/trusted.gpg.d/fury-nushell.gpg"
    local fury_list="/etc/apt/sources.list.d/fury.list"
    local fury_line="deb https://apt.fury.io/nushell/ /"

    msg "Instalando Nushell..."
    if ! [ -f "$fury_keyring" ]; then
        curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o "$fury_keyring"
    fi

    if ! file_contains_line "$fury_line" "$fury_list"; then
        echo "$fury_line" | sudo tee "$fury_list" >/dev/null
        sudo apt update -qq
    fi

    if have_apt_package nushell; then
        info "Nushell ja instalado; pulando apt install"
        return
    fi

    sudo apt install -y -qq nushell
}

install_starship() {
    msg "Instalando Starship..."
    if ! have_cmd starship; then
        sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes >/dev/null
    fi
}

install_git_delta() {
    msg "Instalando git-delta..."
    if ! have_cmd delta; then
        local delta_version="0.18.2"
        curl -s -LO "https://github.com/dandavison/delta/releases/download/${delta_version}/git-delta_${delta_version}_amd64.deb"
        sudo dpkg -i "git-delta_${delta_version}_amd64.deb"
        rm -f "git-delta_${delta_version}_amd64.deb"
    fi
}

install_docker() {
    local docker_keyring="/etc/apt/keyrings/docker.gpg"
    local docker_list="/etc/apt/sources.list.d/docker.list"
    local docker_line

    msg "Instalando Docker..."
    sudo apt-get install -y -qq ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    docker_line="deb [arch=$(dpkg --print-architecture) signed-by=${docker_keyring}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    if ! [ -f "$docker_keyring" ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$docker_keyring"
    fi

    if ! file_contains_line "$docker_line" "$docker_list"; then
        echo "$docker_line" | sudo tee "$docker_list" >/dev/null
        sudo apt-get update -qq
    fi

    if have_apt_package docker-ce && have_cmd docker; then
        info "Docker ja instalado; pulando apt install"
        return
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-compose-plugin \
        docker-ce-rootless-extras \
        docker-buildx-plugin
}

install_asdf_stack() {
    local project_dir="$1"
    local home_dir="$2"
    local asdf_bin_path=""

    msg "Instalando asdf..."
    if ! have_cmd asdf; then
        local asdf_version="v0.18.0"
        local asdf_dir="$home_dir/.asdf-bin"
        local archive_name="asdf-${asdf_version}-linux-amd64.tar.gz"

        mkdir -p "$asdf_dir"
        cd "$asdf_dir"
        curl -sLO "https://github.com/asdf-vm/asdf/releases/download/${asdf_version}/${archive_name}"
        tar -xzf "$archive_name"
        rm -f "$archive_name"
        ensure_line "export PATH=\"$asdf_dir:\$PATH\"" "$home_dir/.bashrc"
        export PATH="$asdf_dir:$PATH"
        asdf_bin_path="$asdf_dir/asdf"
        cd "$project_dir"
    fi

    if [ -z "$asdf_bin_path" ]; then
        asdf_bin_path="$(command -v asdf || true)"
    fi

    if [ -n "$asdf_bin_path" ]; then
        msg "Instalando zoxide via asdf..."
        if ! "$asdf_bin_path" plugin list 2>/dev/null | grep -Fxq zoxide; then
            "$asdf_bin_path" plugin add zoxide https://github.com/nyrst/asdf-zoxide.git
        fi
        "$asdf_bin_path" install zoxide latest
        "$asdf_bin_path" set zoxide latest

        msg "Instalando Ruby via asdf..."
        local ruby_version="3.2.0"
        if ! "$asdf_bin_path" plugin list 2>/dev/null | grep -Fxq ruby; then
            "$asdf_bin_path" plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
        fi
        "$asdf_bin_path" install ruby "$ruby_version"
        "$asdf_bin_path" set ruby "$ruby_version"
    fi
}

install_linux_chezmoi() {
    local home_dir="$1"

    if ! have_cmd chezmoi; then
        msg "Instalando chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$home_dir/.local/bin"
        export PATH="$home_dir/.local/bin:$PATH"
    fi
}

bootstrap_linux_host() {
    local project_dir="$1"
    local home_dir="$2"
    local user_name="$3"

    install_linux_base_packages
    install_linux_fonts "$project_dir" "$home_dir"
    install_tpm "$home_dir"
    install_nushell
    install_starship
    install_git_delta
    install_docker
    sudo usermod -aG docker "$user_name" >/dev/null 2>&1 || true
    install_asdf_stack "$project_dir" "$home_dir"
    install_linux_chezmoi "$home_dir"

    msg "Aplicando dotfiles Linux/WSL com chezmoi..."
    apply_chezmoi_from_source "$project_dir" || warn "chezmoi apply falhou"
}
