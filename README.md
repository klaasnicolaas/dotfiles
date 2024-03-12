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
pyenv install --list | grep " 3\.[91011]"
pyenv install 3.11.6
pyenv global 3.11.6
```

### Setup Github account

```bash
git config --global user.name "Klaas Schoute"
git config --global user.email "hello@example.com"
```

### Setup Node.JS/NPM

Version 20 is currently the LTS version.

```bash
nvm install 20
nvm use 20
nvm alias default 20
```

### Install Poetry

_Note: This can only after installing python._

```bash
bash components/poetry.sh
```

### Install PHP

Instal PHP 8.2 and all the extensions:

```bash
# 👇 install software-properties-common
sudo apt -y install software-properties-common

# 👇 use add-apt-repository command to install the PPA
sudo add-apt-repository ppa:ondrej/php

# 👇 refresh the package manager
sudo apt-get update

# 👇 install latest PHP version
sudo apt -y install php8.2

# 👇 install all the extensions
sudo apt install php8.2-{bcmath,xml,xmlrpc,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,common,mbstring,pgsql,opcache,soap,cgi,imagick,readline,sqlite3}
```

To remove the old packages:

```bash
sudo apt-get purge 'php8.1*'
```

## Links

https://realpython.com/intro-to-pyenv/ <br>
https://docs.docker.com/engine/install/ubuntu/
