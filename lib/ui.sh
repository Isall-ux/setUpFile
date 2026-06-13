#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

prompt_choice() {
  local label="$1"
  shift
  local options=("$@")
  local i=1

  echo ""
  echo -e "  ${CYAN}${label}${RESET}"
  echo ""
  for opt in "${options[@]}"; do
    echo "    ${i}) ${opt}"
    ((i++))
  done
  echo ""

  local choice
  while true; do
    read -r -p "  Enter choice (1-${#options[@]}): " choice || true
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
      echo ""
      return $((choice - 1))
    fi
    echo -e "  ${RED}Invalid choice. Please enter 1-${#options[@]}.${RESET}"
  done
}

prompt_yn() {
  local question="$1"
  local reply

  echo ""
  read -r -p "  ${question} [y/N] " reply || true
  case "${reply,,}" in
    y|yes) return 0 ;;
    *)     return 1 ;;
  esac
}

print_step() {
  local n="$1"
  local total="$2"
  local message="$3"
  echo -e "  ${CYAN}[ ${n}/${total} ]${RESET} ${message}"
}

print_success() {
  echo -e "  ${GREEN}✓${RESET} $*"
}

print_error() {
  echo -e "  ${RED}✗${RESET} $*"
}

print_info() {
  echo -e "  ${YELLOW}→${RESET} $*"
}
