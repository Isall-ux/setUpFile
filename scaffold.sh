#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/ui.sh"

clear

while true; do
  prompt_choice "Select a language / ecosystem:" "Node.js" "Vanilla JS" "Python (coming soon)" "PHP (coming soon)" && lang_choice=$? || lang_choice=$?

  case $lang_choice in
    0)
      clear
      echo -e "  ${BOLD}Node.js${RESET}"
      prompt_choice "Select a framework:" "Express" "Fastify (coming soon)" "NestJS (coming soon)" && fw_choice=$? || fw_choice=$?
      case $fw_choice in
        0)
          clear
          echo -e "  ${BOLD}Node.js > Express${RESET}"
          echo ""
          bash "$SCRIPT_DIR/node/express/scaffold.sh"
          exit 0
          ;;
        1)
          clear
          print_info "Fastify scaffold coming soon!"
          ;;
        2)
          clear
          print_info "NestJS scaffold coming soon!"
          ;;
      esac
      ;;
    1)
      clear
      echo -e "  ${BOLD}Vanilla JS${RESET}"
      echo ""
      bash "$SCRIPT_DIR/vanilla-js/scaffold.sh"
      exit 0
      ;;
    2)
      clear
      print_info "Python scaffold coming soon!"
      ;;
    3)
      clear
      print_info "PHP scaffold coming soon!"
      ;;
  esac

  echo ""
  read -r -p "  Press Enter to continue..." || true
  clear
done
