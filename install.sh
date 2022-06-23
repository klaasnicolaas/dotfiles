#!/bin/bash

# Git
ln -sf ~/dotfiles/config/.gitconfig ~
ln -sf ~/dotfiles/config/.gitignore ~

# APT
echo
echo "** Installing apt packages"
sudo apt-get update
sudo apt-get install -y --no-install-recommends zsh fzf vim jq

USER=`whoami`
sudo -n chsh $USER -s $(which zsh)

#----------------------------------------------------------------------------
# GH CLI
#----------------------------------------------------------------------------
echo
echo "** Downloading GitHub CLI"
curl -s https://api.github.com/repos/cli/cli/releases/latest \
  | jq '.assets[] | select(.name | endswith("_linux_amd64.deb")).browser_download_url' \
  | xargs curl -O -L

sudo -n dpkg -i ./gh_*.deb
rm ./gh_*.deb

# ZSH
ln -sf ~/dotfiles/config/.zshrc ~/.zshrc

#----------------------------------------------------------------------------
# Oh My ZSH
#----------------------------------------------------------------------------
echo
echo "** Installing Oh My Zsh"
rm -rf ~/.oh-my-zsh
touch ~/.z  # So it doesn't complain on very first usage
CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh my ZSH theme
git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k --depth 1
ln -sf ~/dotfiles/config/.p10k.zsh ~/.p10k.zsh

# Oh my ZSH plugin
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions --depth 1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting --depth 1

#----------------------------------------------------------------------------
# pyenv
#----------------------------------------------------------------------------
echo
echo "** Installing Pyenv"
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

#----------------------------------------------------------------------------
# nvm (nodejs)
#----------------------------------------------------------------------------
echo
echo "** Installing NVM (nodejs)"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

#----------------------------------------------------------------------------
# Docker
#----------------------------------------------------------------------------
echo
echo "** Installing Docker"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER

#----------------------------------------------------------------------------
# Docker-compose
#----------------------------------------------------------------------------
echo
echo "** Installing Docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo
echo "-- Done --"