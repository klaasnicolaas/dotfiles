# Zsh configuration file
export SHELL=/usr/bin/zsh

# Increase FUNCNEST to prevent "maximum nested function level reached" errors
# This is needed for Oh My Posh + zsh-autosuggestions/zsh-syntax-highlighting
export FUNCNEST=1000

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Disable theme to use Oh My Posh instead
ZSH_THEME=""

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

plugins=(
  pyenv
  git
  npm
  sudo
  docker-compose
  laravel
  poetry
  rbenv
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
alias ha_install="uv pip install -e ."
alias ha_installreq="uv pip install -r requirements_all.txt -c homeassistant/package_constraints.txt"
alias ha_installtest="uv pip install -r requirements_test.txt"
alias ha_installpre="uv pip install -r requirements_test_pre_commit.txt"

# Mr.Green aliases
alias netos_start="bundle exec bin/dev"
alias netos_migrate="bundle exec bin/rails db:migrate"
alias netos_seed="bundle exec bin/rails db:seed"

# Venv
alias venv_enter="source .venv/bin/activate"
alias venv_create="python3 -m venv .venv"

# Pip
alias pip_freeze="pip freeze > requirements.txt"
alias pip_install="pip install -r requirements.txt"

# Uv
alias uv_install="uv pip install -r requirements.txt"
alias uv_venv="uv venv"
alias uvdate="uv self update"

# Php
alias pasip="php artisan serve --host 0.0.0.0 --port 8080"
alias php_modules="dpkg --get-selections | grep -i php"
alias laravel_clear="php artisan optimize:clear"
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias pint="vendor/bin/pint"
alias pest="vendor/bin/pest"
alias phpstan="vendor/bin/phpstan"

# Pyenv
alias pyenv_list='pyenv install --list | grep -E "^\s*3\.(11|12|13)(\..*|-dev.*)"'

# Django
alias django="python manage.py"

ha_install_package() {
  uv pip install -e ./../python-packages/python-$1
}

# Home Assistant tests
ha_test() {
    venv_enter
    pytest --timeout=10 --cov=homeassistant.components.$1 --cov-report term-missing tests/components/$1 -vv
}
ha_test_snapshot_update() {
  venv_enter
  pytest ./tests/components/$1/ --snapshot-update
}

# Git
alias gnext="fn_next_git_branch"

# Git worktree
alias gwta="git_worktree_add"
alias gwtr="git_worktree_remove"
alias gwtn="git_worktree_next"
alias gwtl="git worktree list"

# Git functions
git_rm_branches() {
  local branches=$(git branch | grep "$1")

  if [ -z "$branches" ]; then
    echo "No branches found matching pattern '$1'."
    return 1
  fi

  echo "Branches found matching pattern '$1':"
  echo "$branches"

  read -r "REPLY?Do you want to delete these branches? (y/n): "
  case "$REPLY" in
    [Yy])
      echo "$branches" | xargs git branch -D
      echo "Branches deleted successfully."
      ;;
    *)
      echo "Operation cancelled."
      ;;
  esac
}

function fn_get_next_branch_name() {
  local current_year=$(date +%Y)
  local last_branch=$(git branch --list "klaas-${current_year}-*" | sort -r | head -n 1)

  if [[ -n "$last_branch" ]]; then
    local last_number=${last_branch##*-}
    local new_number=$(printf "%03d" $((10#$last_number + 1)))
  else
    local new_number="001"
  fi

  echo "klaas-${current_year}-${new_number}"
}

function fn_next_git_branch() {
  local new_branch=$(fn_get_next_branch_name)
  git switch -c $new_branch
}

# Git worktree functions
function git_worktree_add() {
  if [ -z "$1" ]; then
    echo "Error: Branch name required"
    echo "Usage: gwta <branch-name> [location]"
    return 1
  fi

  local branch="$1"
  local location="${2:-../$1}"

  git worktree add -b "$branch" "$location"
}

function git_worktree_remove() {
  if [ -z "$1" ]; then
    echo "Error: Branch name required"
    echo "Usage: gwtr <branch-name> [location]"
    return 1
  fi

  local location="${2:-../$1}"

  git worktree remove "$location"
}

function git_worktree_next() {
  if [ -z "$1" ]; then
    echo "Error: Feature name required"
    echo "Usage: gwtn <feature-name>"
    return 1
  fi

  local feature_name="$1"
  local new_branch=$(fn_get_next_branch_name)
  local location="../${feature_name}"

  echo "Creating branch: $new_branch"
  echo "Creating worktree: $location"

  git worktree add -b "$new_branch" "$location"
}


# fzf
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# Automatically check venv and node modules for executables
export PATH="./venv/bin:./node_modules/.bin:~/bin:$PATH"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
export PATH="$HOME/.local/bin:$PATH"

# Pyenv
eval "$(pyenv init -)"
eval "$(command pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Uv
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

eval "$(uv generate-shell-completion zsh)"

# Oh My Posh with custom theme - MUST be loaded LAST after all other plugins
eval "$(oh-my-posh init zsh --config ~/.theme.omp.json)"
