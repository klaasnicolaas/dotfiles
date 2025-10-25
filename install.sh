#!/bin/bash
set -euo pipefail

#----------------------------------------
# PRE-FLIGHT CHECKS
#----------------------------------------
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Sudo is used where needed."
  exit 1
fi

# Source shared logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logger.sh"

trap 'error "An error occurred. Exiting."' ERR

DOTFILES="$HOME/dotfiles/config"
USER="$(whoami)"

#----------------------------------------
# LINK DOTFILES
#----------------------------------------
log_header "Dotfiles Configuration"
log_info "Symlinking dotfiles"
mkdir -p "$HOME"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.gitignore" "$HOME/.gitignore"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"

#----------------------------------------
# INTERACTIVE GIT CONFIGURATION
#----------------------------------------
log_header "Git Configuration"
log_info "Configuring Git user.name / user.email"

if ! git config --global user.name &>/dev/null; then
  read -p "Enter your Git user name: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi

if ! git config --global user.email &>/dev/null; then
  read -p "Enter your Git email address: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

log_success "Git global user.name/email configured"

#----------------------------------------
# GPG SIGNING
#----------------------------------------
read -p "Do you want to GPG-sign Git commits by default? (y/n) " SIGN_GPG

if [[ "$SIGN_GPG" =~ ^[Yy]$ ]]; then
  if ! command -v gpg &>/dev/null; then
    error "GPG is not installed! Install it first."
  fi

  GIT_EMAIL=$(git config --global user.email)
  if [ -z "$GIT_EMAIL" ]; then
    error "No Git user.email set! Set it first (run the Git config step again)."
  fi

  EXISTING_KEY=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2 || true)

  if [ -z "$EXISTING_KEY" ]; then
    log_info "No existing GPG key found for $GIT_EMAIL"
    echo "Let's generate a key... (follow the prompts!)"
    gpg --full-generate-key

    EXISTING_KEY=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2 || true)
  else
    log_success "GPG key found: $EXISTING_KEY"
  fi

  if [ -n "$EXISTING_KEY" ]; then
    git config --global user.signingkey "$EXISTING_KEY"
    git config --global commit.gpgsign true

    EXPORT_FILE="$HOME/public-gpg-key.txt"
    gpg --armor --export "$EXISTING_KEY" > "$EXPORT_FILE"

    log_success "GPG signing enabled!"
    log_step "Your GPG public key is saved to: $EXPORT_FILE"
    log_step "Open this file in a text editor and copy/paste it to GitHub:"
    echo "    GitHub > Settings > SSH and GPG keys > New GPG key"
    echo "-------------------------------------------"
    head -n 3 "$EXPORT_FILE"
    echo "..."
    tail -n 3 "$EXPORT_FILE"
    echo "-------------------------------------------"
  else
    error "GPG key generation failed, or no key found for $GIT_EMAIL. Signing is not enabled."
  fi
else
  log_info "GPG signing is not activated"
fi

#----------------------------------------
# UPDATE & BASE PACKAGES
#----------------------------------------
log_header "System Packages"
log_info "Installing apt packages"
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  zsh fzf vim jq unzip php-cli net-tools \
  build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

#----------------------------------------
# ZSH SHELL
#----------------------------------------
log_header "Shell Configuration"
if [ "$(basename "$SHELL")" != "zsh" ]; then
  log_info "Switching default shell to Zsh"
  sudo chsh "$USER" -s "$(command -v zsh)"
  SHELL_CHANGED=1
else
  log_success "Zsh is already the default shell"
  SHELL_CHANGED=0
fi

#----------------------------------------
# GH CLI
#----------------------------------------
log_header "GitHub CLI"
if ! command -v gh &>/dev/null; then
  log_info "Installing GitHub CLI"
  LATEST_DEB=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.assets[] | select(.name | endswith("_linux_amd64.deb")).browser_download_url')
  curl -LO "$LATEST_DEB"
  if [ -f ./gh_*.deb ]; then
    sudo dpkg -i ./gh_*.deb
    rm ./gh_*.deb
    log_success "GitHub CLI installed"
  else
    error "GitHub CLI .deb download failed!"
  fi
else
  log_success "GitHub CLI already installed"
fi

#----------------------------------------
# OH MY ZSH + PLUGINS/THEME
#----------------------------------------
log_header "Oh My Zsh"
log_info "Installing Oh My Zsh and plugins"
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
log_header "Pyenv"
PYENV_ROOT="$HOME/.pyenv"

if command -v pyenv &>/dev/null; then
  log_success "Pyenv is already installed and available"
else
  if [ -d "$PYENV_ROOT" ]; then
    log_warning "Pyenv directory exists, but command not found. Removing possibly broken install..."
    rm -rf "$PYENV_ROOT"
  fi

  log_info "Installing fresh Pyenv"
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"

  if command -v pyenv &>/dev/null; then
    log_success "Pyenv installed successfully"
  else
    error "Pyenv installation failed"
  fi
fi

#----------------------------------------
# UV
#----------------------------------------
log_header "UV Python Package Manager"
if ! command -v uv &>/dev/null; then
  log_info "Installing UV"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  log_success "UV installed"
else
  log_success "UV already installed"
fi

#----------------------------------------
# UV SHELL COMPLETION
#----------------------------------------
log_info "Setting up UV shell completion"

if [ -f "$HOME/.zshrc" ] && ! grep -q 'uv generate-shell-completion zsh' "$HOME/.zshrc"; then
  echo 'eval "$(uv generate-shell-completion zsh)"' >> "$HOME/.zshrc"
  log_success "UV shell completion added to .zshrc"
else
  log_step "UV shell completion already configured"
fi

#----------------------------------------
# NVM (NodeJS)
#----------------------------------------
log_header "NVM (Node Version Manager)"
if [ ! -d "$HOME/.nvm" ]; then
  log_info "Installing NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  log_success "NVM installed"
else
  log_success "NVM already installed"
fi

#----------------------------------------
# DOCKER
#----------------------------------------
log_header "Docker"
if ! command -v docker &>/dev/null; then
  log_info "Installing Docker"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker "$USER"
  log_success "Docker installed"
  log_warning "You may need to log out and back in to use Docker without sudo"
else
  log_success "Docker already installed"
fi

#----------------------------------------
# COMPOSER
#----------------------------------------
log_header "Composer (PHP)"
if ! command -v composer &>/dev/null; then
  log_info "Installing Composer"
  curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
  HASH=$(curl -sS https://composer.github.io/installer.sig)
  php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
  sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  rm /tmp/composer-setup.php

  log_info "Installing Laravel Installer globally"
  composer global require laravel/installer
  log_success "Composer and Laravel Installer installed"
else
  log_success "Composer already installed"
fi

#----------------------------------------
# SYSTEM CLEANUP
#----------------------------------------
log_header "Cleanup"
log_info "Cleaning up apt cache"
sudo apt-get autoremove -y
sudo apt-get clean
log_success "System cleanup complete"

echo ""
log_success "Installation complete!"
if [ "${SHELL_CHANGED:-0}" = "1" ]; then
  log_warning "Log out and log in again to use ZSH as your default shell"
fi
echo "If you installed Docker: Log out and back in for group changes to take effect."
