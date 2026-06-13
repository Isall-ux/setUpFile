#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/prompt.sh"
source "$SCRIPT_DIR/lib/files.sh"
source "$SCRIPT_DIR/lib/install.sh"
source "$SCRIPT_DIR/lib/docker.sh"

main() {
  ask_orm
  ask_docker
  do_install
  if [ "$DOCKER" = "y" ]; then
    do_docker
  fi
  print_summary
}

main
