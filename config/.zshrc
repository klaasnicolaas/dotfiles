export SHELL=/usr/bin/zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

ZSH_THEME="powerlevel10k/powerlevel10k"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(
  pyenv
  git
  npm
  sudo
  docker-compose
  laravel
  poetry
)

# Custom plugins
plugins+=(zsh-autosuggestions zsh-syntax-highlighting)

[ -f ~/.zshrc-local ] && source ~/.zshrc-local

source $ZSH/oh-my-zsh.sh
source ~/.nvm/nvm.sh

# Disable share history across consoles
unsetopt share_history

# Aliases - Remove what you don't need
alias gs="git status -sb"
alias zshreload="source $HOME/.zshrc"
alias zshconfig="mate $HOME/.zshrc"
alias ohmyzsh="mate $HOME/.oh-my-zsh"
alias diskspace="sudo du -shx * | sort -rh | head -10"

# Specific aliases for Home Assistant
alias ha_start="hass -c config"
alias ha_new="python3 -m script.scaffold integration"
alias ha_updatereq="python -m script.gen_requirements_all"
alias ha_hassfest="python -m script.hassfest"
alias ha_trans="python -m script.translations develop"
alias ha_installreq="pip install -r requirements_all.txt"
alias ha_installtest="pip install -r requirements_test.txt"
alias ha_installtest_all="pip install --use-deprecated=legacy-resolver -r requirements_test_all.txt -c homeassistant/package_constraints.txt"

# Venv
alias venv_enter="source venv/bin/activate"
alias venv_create="python3 -m venv venv"

# Pip
alias pip_freeze="pip freeze > requirements.txt"
alias pip_install="pip install -r requirements.txt"

# Php
alias pasip="php artisan serve --host 0.0.0.0 --port 8080"
alias php_modules="dpkg --get-selections | grep -i php"
alias sail="./vendor/bin/sail"

# Pyenv
alias pyenv_list='pyenv install --list | grep " 3\.[910]"'

# fzf
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# Automatically check venv and node modules for executables
export PATH="./venv/bin:./node_modules/.bin:~/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion