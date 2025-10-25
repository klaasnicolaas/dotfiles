#!/usr/bin/env bash
set -euo pipefail

#----------------------------------------------------------------------------
# Pipx
# Install pipx using pyenv-managed Python shim
# Assumptions: pyenv is already bootstrapped earlier in the install flow.
#----------------------------------------------------------------------------

# Source shared logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

log_header "Pipx Installation"

if command -v pipx &>/dev/null; then
  log_success "pipx already installed; skipping"
  exit 0
fi

PYENV_PYTHON=$(pyenv which python 2>/dev/null || true)
if [ -n "$PYENV_PYTHON" ]; then
  log_info "Installing pipx using pyenv-managed Python"
  log_step "Python path: $PYENV_PYTHON"

  "$PYENV_PYTHON" -m pip install --upgrade --user pipx
  "$PYENV_PYTHON" -m pipx ensurepath || true

  log_success "pipx installed successfully"
  log_warning "You may need to restart your shell: exec \$SHELL"
  exit 0
else
  log_error "pyenv python shim not found"
  log_step "Please install a Python version with pyenv and set it:"
  log_step "  pyenv install 3.14"
  log_step "  pyenv global 3.14"
  log_step "Then re-run this component"
  exit 1
fi
