## What is this?

This is my dotfiles configuration files.

## How to install configuration?

```bash
git clone https://github.com/klaasnicolaas/dotfiles.git
cd dotfiles && bash install.sh
```

## Installed packages

The following platforms are installed and set up by default with the bash script:

- GitHub CLI
- Oh My Zsh (with powerlevel10k)
- Pyenv
- Nvm
- Docker
- Docker Compose
- Composer

## Manual installations

After installation, there are still a few things I always do manually.

This is the case for:

- Python
- GitHub
- Node.JS/NPM
- Poetry
- PHP

### Install a python version

```bash
pyenv install --list | grep " 3\.[8910]"
pyenv install 3.10.4
pyenv global 3.10.4
```

### Setup Github account

```bash
git config --global user.name "Klaas Schoute"
git config --global user.email "hello@example.com"
```

### Setup Node.JS/NPM

```bash
nvm install 16
nvm use 16
```

### Install Poetry

_Note: This can only after installing python._

```bash
bash components/poetry.sh
```

### Install PHP

Follow the instructions on this website: <br>
https://www.cloudbooklet.com/how-to-upgrade-php-version-to-php-8-0-on-ubuntu/

## Links

https://realpython.com/intro-to-pyenv/ <br>
https://docs.docker.com/engine/install/ubuntu/
