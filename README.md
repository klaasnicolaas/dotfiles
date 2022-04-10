## What is this?

This is my dotfiles configuration files.

## How to install configuration?

```bash
git clone https://github.com/klaasnicolaas/dotfiles.git
cd dotfiles && bash install.sh
```

## Installed packages

The following platforms are installed and set up:

- GitHub CLI
- Oh My Zsh (with powerlevel10k)
- Pyenv
- Nvm
- Docker
- Docker Compose

## Manual things

After installation, there are still a few things I always do manually.

install a python version:

```bash
pyenv install --list | grep " 3\.[8910]"
pyenv install 3.10.4
pyenv global 3.10.4
```

Setup Github account:

```bash
git config --global user.name "Klaas Schoute"
git config --global user.email "hello@example.com"
```

Setup Node.JS/NPM:

```bash
nvm install 16
nvm use 16
```

Install Poetry:

_Note: This can only after installing python._

```bash
bash components/poetry.sh
```

## Links

https://realpython.com/intro-to-pyenv/
https://www.cloudbooklet.com/upgrade-php-version-to-php-7-4-on-ubuntu/
https://docs.docker.com/engine/install/ubuntu/