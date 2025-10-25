#!/usr/bin/env bash
# Shared logging library for dotfiles components
# Provides consistent, colorful logging across all scripts

# Color codes
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_RED='\033[1;31m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_CYAN='\033[1;36m'
readonly COLOR_GRAY='\033[0;90m'

# Icons/Symbols
readonly ICON_INFO="ℹ"
readonly ICON_SUCCESS="✓"
readonly ICON_WARNING="⚠"
readonly ICON_ERROR="✗"
readonly ICON_ARROW="→"
readonly ICON_PACKAGE="📦"

# Log info message
log_info() {
  printf "${COLOR_CYAN}${ICON_INFO} ${COLOR_BOLD}%s${COLOR_RESET}\n" "$*" >&2
}

# Log success message
log_success() {
  printf "${COLOR_GREEN}${ICON_SUCCESS} %s${COLOR_RESET}\n" "$*" >&2
}

# Log warning message
log_warning() {
  printf "${COLOR_YELLOW}${ICON_WARNING} %s${COLOR_RESET}\n" "$*" >&2
}

# Log error message
log_error() {
  printf "${COLOR_RED}${ICON_ERROR} %s${COLOR_RESET}\n" "$*" >&2
}

# Log a step/action (indented)
log_step() {
  printf "  ${COLOR_GRAY}${ICON_ARROW}${COLOR_RESET} %s\n" "$*" >&2
}

# Log package/component header
log_header() {
  printf "\n${COLOR_BLUE}${COLOR_BOLD}${ICON_PACKAGE} %s${COLOR_RESET}\n" "$*" >&2
}

# Legacy compatibility - maps to log_info
log() {
  log_info "$@"
}

# Error function that exits
error() {
  log_error "$@"
  exit 1
}
