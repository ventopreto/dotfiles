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
PROJECT_DIR="$(pwd)"
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
sudo cp -r $PROJECT_DIR/fonts/* "$HOME_DIR/.fonts/" 2>/dev/null || exit 1
sudo chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.fonts" 2>/dev/null
fc-cache -f
}

msg "Instalando o TPM..."
{
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

msg "Instalando Tmux e cappicin..."
cp ./config/.tmux.conf "$HOME_DIR/.tmux.conf"

msg "Instalando o Nushell..."
curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg
echo "deb https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury.list > /dev/null
sudo apt update -qq > /dev/null 2>&1
sudo apt install -y -qq nushell > /dev/null 2>&1

msg "Instalando o Starship..."
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes > /dev/null

msg "Configurando Nushell..."
cp -r "$PROJECT_DIR/config/.config/" ~/ &> /dev/null

msg "Definindo o Nushell como shell padrão..."
chsh -s $(which nu)

msg "Instalando git-delta..."
DELTA_VERSION="0.18.2"
curl -s -LO https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb
sudo dpkg -i git-delta_${DELTA_VERSION}_amd64.deb
rm git-delta_${DELTA_VERSION}_amd64.deb

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

msg "Instalando asdf (versão binária)..."
ASDF_VERSION="v0.18.0"
ASDF_DIR="$HOME_DIR/.asdf-bin"
ARCHIVE_NAME="asdf-${ASDF_VERSION}-linux-amd64.tar.gz"

mkdir -p "$ASDF_DIR"
cd "$ASDF_DIR"
curl -sLO "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/${ARCHIVE_NAME}"
tar -xzf "$ARCHIVE_NAME"
rm "$ARCHIVE_NAME"

echo "export PATH=\"$ASDF_DIR:\$PATH\"" >> "$HOME_DIR/.bashrc"
export PATH="$ASDF_DIR:$PATH"

if ! command -v asdf >/dev/null; then
    msg "❌ asdf não foi adicionado ao PATH corretamente."
    exit 1
else
    msg "✅ asdf instalado com sucesso!"
fi

msg "Instalando zoxide via asdf..."
asdf plugin add zoxide https://github.com/nyrst/asdf-zoxide.git 2>&1
asdf install zoxide latest 2>&1
asdf set zoxide latest 2>&1

msg "Instalando Ruby via asdf..."
RUBY_VERSION="3.2.0"
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git || true
asdf install ruby $RUBY_VERSION
asdf set ruby $RUBY_VERSION

msg "Adicionando Ruby ao PATH (nova versão do asdf)..."
RUBY_BIN_PATH="$HOME_DIR/.asdf/installs/ruby/$RUBY_VERSION/bin"
export PATH="$RUBY_BIN_PATH:$PATH"
echo "export PATH=\"$RUBY_BIN_PATH:\$PATH\"" >> "$HOME_DIR/.bashrc"
echo ruby -v

msg "Instalando gems adicionais..."
gem install pry-theme amazing_print pry-byebug

mkdir -p "$HOME_DIR/.pry"
cp -r "$PROJECT_DIR/config/.pry/" "$HOME_DIR/.pry/"
cp "$PROJECT_DIR/config/.pryrc" "$HOME_DIR/.pryrc"
cp "$PROJECT_DIR/config/.irbrc" "$HOME_DIR/.irbrc" 
cp "$PROJECT_DIR/config/.aprc" "$HOME_DIR/.aprc"
sudo chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR"

msg "Instalação concluída com sucesso!"

nu
