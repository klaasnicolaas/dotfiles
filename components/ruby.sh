#!/bin/bash
set -euo pipefail

#----------------------------------------------------------------------------
# Ruby
# Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.
#----------------------------------------------------------------------------

# Source shared logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

log_header "Ruby Installation"

log_info "Installing rbenv and ruby-build"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

log_info "Installing ruby-build Ubuntu dependencies"
sudo apt install -y libyaml-dev libpq-dev

log_success "Ruby installation complete"