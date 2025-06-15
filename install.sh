#!/bin/bash

set -euo pipefail

msg() {
    local GREEN="\033[1;32m"
    local BLUE="\033[1;34m"
    local CYAN="\033[1;36m"
    local RESET="\033[0m"
    local PREFIX="➜"

    if [[ "$1" =~ "concluída" ]]; then
        echo -e "${CYAN}${PREFIX} ${1}${RESET}"
    else
        echo -e "${GREEN}${PREFIX} ${1}${RESET}"
    fi
}

if [ -n "${SUDO_USER:-}" ]; then
    USER_NAME="$SUDO_USER"
else
    USER_NAME="$(id -un)"
fi
HOME_DIR="/home/$USER_NAME"
[ "$USER_NAME" = "root" ] && HOME_DIR="/root"

msg "Atualizando pacotes e Instalando dependências..."
{
sudo apt update -qq >/dev/null 2>&1
sudo apt upgrade -y -qq >/dev/null 2>&1
sudo apt install -y -qq \
    fontconfig \
    curl \
    wget \
    git \
    zsh \
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
    apt-utils >/dev/null 2>&1
} >/dev/null 2>&1

msg "Instalando as fontes..."
{
mkdir -p "$HOME_DIR/.fonts"
sudo cp -r ./fonts/* "$HOME_DIR/.fonts/" 2>/dev/null || exit 1
sudo chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.fonts" 2>/dev/null
fc-cache -f
}

msg "Instalando o TPM..."
{
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >/dev/null 2>&1
}

msg "Instalando Tmux e cappicin..."
cp ./config/.tmux.conf "$HOME_DIR/.tmux.conf"

msg "Instalando zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- -q > /dev/null 2>&1

msg "Instalando o Nushell..."
curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg
echo "deb https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury.list > /dev/null
sudo apt update -qq > /dev/null 2>&1
sudo apt install -y -qq nushell > /dev/null 2>&1

msg "Instalando o Starship..."
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes > /dev/null

msg "Configurando Nushell..."
cp -r ./config/.config/ ~/ &> /dev/null

msg "Definindo o Nushell como shell padrão..."
chsh -s $(which nu)

msg "Configurando PATH para o asdf no Nushell..."
{
  echo '$env.PATH = ($env.PATH | append ($nu.home-path | path join ".asdf" "bin"))'
  echo '$env.PATH = ($env.PATH | append ($nu.home-path | path join ".asdf" "shims"))'
} >> ~/.config/nushell/env.nu

msg "Instalando git-delta..."
curl -s -LO https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.deb &> /dev/null
rm git-delta_0.16.5_amd64.deb

msg "Instalando o Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/ &> /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update -qq > /dev/null 2>&1
sudo apt install -y -qq code > /dev/null 2>&1

msg "Instalando o Docker..."
{
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release >/dev/null 2>&1

sudo install -m 0755 -d /etc/apt/keyrings >/dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>/dev/null | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >/dev/null 2>&1

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update -qq >/dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
    docker-ce-rootless-extras \
    docker-buildx-plugin >/dev/null 2>&1
} >/dev/null 2>&1

msg "Configurando permissões do Docker para $USER_NAME..."
{
sudo usermod -aG docker "$USER_NAME" >/dev/null 2>&1 || true
pidof systemd >/dev/null && sudo systemctl enable --now docker >/dev/null 2>&1 || sudo service docker start >/dev/null 2>&1
} >/dev/null 2>&1

docker --version
docker compose version

msg "Instalando o asdf..."
{
[ ! -d "$HOME_DIR/.asdf" ] && \
    git clone https://github.com/asdf-vm/asdf.git "$HOME_DIR/.asdf" --branch v0.18.0 >/dev/null 2>&1

export ASDF_DIR="$HOME_DIR/.asdf"
export PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"
. "$ASDF_DIR/asdf.sh" >/dev/null 2>&1
} >/dev/null 2>&1

msg "Instalando Ruby via asdf..."
{
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git >/dev/null 2>&1 || true
asdf install ruby latest >/dev/null 2>&1
asdf global ruby latest >/dev/null 2>&1
} >/dev/null 2>&1

msg "Instalando gems adicionais..."
{
gem install pry-theme amazing_print pry-byebug >/dev/null 2>&1

cp -r ./config/.pry/ "$HOME_DIR/.pry/" 2>/dev/null || true
cp ./config/.pryrc "$HOME_DIR/.pryrc" 2>/dev/null || true
cp ./config/.irbrc "$HOME_DIR/.irbrc" 2>/dev/null || true
cp ./config/.aprc "$HOME_DIR/.aprc" 2>/dev/null || true

sudo chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR" >/dev/null 2>&1
} >/dev/null 2>&1

docker --version
docker compose version
msg "Instalação concluída com sucesso!"

nu