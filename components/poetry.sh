#!/bin/bash
set -euo pipefail

#----------------------------------------------------------------------------
# Poetry (installed via pipx)
# This script ensures pipx is present and uses it to install/upgrade poetry.
# You need python3 and pip available for pipx installation.
#----------------------------------------------------------------------------

# Source shared logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

log_header "Poetry Installation"

PYTHON_CMD=$(pyenv which python 2>/dev/null || true)
log_step "Using pyenv Python at: ${PYTHON_CMD:-<not found>}"

# Require that pipx is installed
if ! command -v pipx >/dev/null 2>&1; then
    error "pipx is not installed or not on PATH. Please install pipx before running this script."
fi

log_step "Using pipx from: $(command -v pipx)"

# Install or upgrade poetry using pipx (ensure poetry's venv uses the pyenv Python)
if pipx list 2>/dev/null | grep -q "poetry"; then
    log_info "Poetry already installed via pipx. Upgrading..."
    if ! pipx upgrade poetry; then
        log_warning "Upgrade failed, attempting fresh install (force)"
        log_step "Using interpreter: $PYTHON_CMD"
        pipx install --force --python "$PYTHON_CMD" poetry || error "Failed to install/upgrade poetry via pipx"
    fi
    log_success "Poetry upgraded successfully"
else
    log_info "Installing poetry with pipx"
    log_step "Using interpreter: $PYTHON_CMD"
    pipx install --python "$PYTHON_CMD" poetry || error "Failed to install poetry via pipx"
    log_success "Poetry installed successfully"
fi

# Ensure poetry is discoverable system-wide when necessary (for GUIs like VSCode)
# Many GUI apps don't inherit a login shell PATH, so ~/.local/bin may not be on PATH.
# Only create a system symlink when poetry isn't already found and the shim exists.
if ! command -v poetry >/dev/null 2>&1; then
    if [ -x "$HOME/.local/bin/poetry" ]; then
        if [ -e /usr/local/bin/poetry ]; then
            log_step "/usr/local/bin/poetry already exists; skipping symlink"
        elif command -v sudo >/dev/null 2>&1; then
            log_info "Creating system symlink for poetry (requires sudo)"
            sudo ln -sf "$HOME/.local/bin/poetry" /usr/local/bin/poetry
            log_success "System symlink created"
        else
            log_warning "poetry installed in $HOME/.local/bin but /usr/local/bin/poetry missing and sudo not available"
            log_step "Either add $HOME/.local/bin to PATH for GUI apps or run:"
            log_step "  sudo ln -s \"$HOME/.local/bin/poetry\" /usr/local/bin/poetry"
        fi
    else
        log_warning "poetry not found in PATH and no shim at $HOME/.local/bin/poetry"
    fi
fi