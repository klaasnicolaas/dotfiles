## What is this?

This is my dotfiles configuration files.

## How to install configuration?

```bash
git clone https://github.com/klaasnicolaas/dotfiles.git
cd dotfiles && bash install.sh
```

## Manual things

After installation, there are still a few things I always do manually.

install a python version:

```bash
pyenv install python 3.9.10
pyenv global 3.9.10
```

Setup Github account:

```bash
git config --global user.name "Klaas Schoute"
git config --global user.email hello@example.com
```

## Links

https://realpython.com/intro-to-pyenv/
https://www.cloudbooklet.com/upgrade-php-version-to-php-7-4-on-ubuntu/
https://docs.docker.com/engine/install/ubuntu/