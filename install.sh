#!/bin/bash
set -euo pipefail

#----------------------------------------
# PRE-FLIGHT CHECKS
#----------------------------------------
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Sudo is used where needed."
  exit 1
fi

log() {
  echo -e "\033[1;36m[INFO]\033[0m $1"
}

error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
  exit 1
}

trap 'error "An error occurred. Exiting."' ERR

DOTFILES="$HOME/dotfiles/config"
USER="$(whoami)"

#----------------------------------------
# LINK DOTFILES
#----------------------------------------
log "Symlinking dotfiles"
mkdir -p "$HOME"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.gitignore" "$HOME/.gitignore"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"

#----------------------------------------
# INTERACTIVE GIT CONFIGURATION
#----------------------------------------
log "Configuring Git user.name / user.email"

if ! git config --global user.name &>/dev/null; then
  read -p "Enter your Git user name: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi

if ! git config --global user.email &>/dev/null; then
  read -p "Enter your Git email address: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

log "Git global user.name/email configured."

#----------------------------------------
# GPG SIGNING
#----------------------------------------
read -p "Do you want to GPG-sign Git commits by default? (y/n) " SIGN_GPG

if [[ "$SIGN_GPG" =~ ^[Yy]$ ]]; then
  GIT_EMAIL=$(git config --global user.email)
  EXISTING_KEY=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2)

  if [ -z "$EXISTING_KEY" ]; then
    log "No existing GPG key found for $GIT_EMAIL. Generating new key......"
    gpg --full-generate-key
    EXISTING_KEY=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2)
  else
    log "GPG key found: $EXISTING_KEY"
  fi

  if [ -n "$EXISTING_KEY" ]; then
    git config --global user.signingkey "$EXISTING_KEY"
    git config --global commit.gpgsign true

    log "GPG signing enabled! Your GPG public key to share (for example GitHub):"
    echo "-------------------------------------------"
    gpg --armor --export "$EXISTING_KEY"
    echo "-------------------------------------------"
    echo "Add this key to GitHub > Settings > SSH and GPG keys > New GPG key."
  else
    error "GPG key generation failed. Signing is not enabled."
  fi
else
  log "GPG signing is not activated."
fi

#----------------------------------------
# UPDATE & BASE PACKAGES
#----------------------------------------
log "Installing apt packages"
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  zsh fzf vim jq unzip php-cli net-tools \
  build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

#----------------------------------------
# ZSH SHELL
#----------------------------------------
if [ "$(basename "$SHELL")" != "zsh" ]; then
  log "Switching default shell to Zsh"
  sudo chsh "$USER" -s "$(command -v zsh)"
  SHELL_CHANGED=1
else
  SHELL_CHANGED=0
fi

#----------------------------------------
# GH CLI
#----------------------------------------
log "Installing GitHub CLI"
if ! command -v gh &>/dev/null; then
  LATEST_DEB=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.assets[] | select(.name | endswith("_linux_amd64.deb")).browser_download_url')
  curl -LO "$LATEST_DEB"
  if [ -f ./gh_*.deb ]; then
    sudo dpkg -i ./gh_*.deb
    rm ./gh_*.deb
  else
    error "GitHub CLI .deb download failed!"
  fi
else
  log "GitHub CLI already installed."
fi

#----------------------------------------
# OH MY ZSH + PLUGINS/THEME
#----------------------------------------
log "Installing Oh My Zsh and plugins"
rm -rf "$HOME/.oh-my-zsh"
touch "$HOME/.z"  # Avoid warning on first use
CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Theme
[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
# Plugins
[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

#----------------------------------------
# PYENV
#----------------------------------------
log "Installing Pyenv"
if ! command -v pyenv &>/dev/null; then
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
else
  log "Pyenv already installed."
fi

#----------------------------------------
# UV
#----------------------------------------
log "Installing UV"
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  log "UV already installed."
fi

#----------------------------------------
# NVM (NodeJS)
#----------------------------------------
log "Installing NVM (NodeJS)"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
  log "NVM already installed."
fi

#----------------------------------------
# DOCKER
#----------------------------------------
log "Installing Docker"
if ! command -v docker &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker "$USER"
  log "Docker installed. You may need to log out and back in to use Docker without sudo."
else
  log "Docker already installed."
fi

#----------------------------------------
# COMPOSER
#----------------------------------------
log "Installing Composer"
if ! command -v composer &>/dev/null; then
  curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
  HASH=$(curl -sS https://composer.github.io/installer.sig)
  php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
  sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  rm /tmp/composer-setup.php
else
  log "Composer already installed."
fi

#----------------------------------------
# SYSTEM CLEANUP
#----------------------------------------
log "Cleaning up apt cache"
sudo apt-get autoremove -y
sudo apt-get clean

log "-- Done --"
if [ "${SHELL_CHANGED:-0}" = "1" ]; then
  echo "Log out and log in again to use ZSH as your default shell."
fi
echo "If you installed Docker: Log out and back in for group changes to take effect."
