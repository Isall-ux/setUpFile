#!/usr/bin/env bash
set -euo pipefail

REPO="aussenseiter-VsRB/setUpFile"
BRANCH="main"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.zip"
SCAFFOLD_DIR="${HOME}/.scaffold"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

print_success() { echo -e "  ${GREEN}✓${RESET} $*"; }
print_error()   { echo -e "  ${RED}✗${RESET} $*"; }
print_info()    { echo -e "  ${YELLOW}→${RESET} $*"; }

cleanup() {
  [ -n "${TMP_DIR-}" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

check_prereqs() {
  local missing=false

  if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required but not installed"
    missing=true
  fi

  if ! command -v unzip >/dev/null 2>&1; then
    print_error "unzip is required but not installed"
    missing=true
  fi

  if [ "$missing" = true ]; then
    echo ""
    echo "  Install missing dependencies and re-run the installer." >&2
    exit 1
  fi
}

register_alias() {
  local config_file="$1"
  local alias_line="alias scaffold='bash ${SCAFFOLD_DIR}/scaffold.sh'"

  if [ ! -f "$config_file" ]; then
    touch "$config_file"
  fi

  if grep -qF "alias scaffold=" "$config_file" 2>/dev/null; then
    print_info "Alias 'scaffold' already exists in ${config_file} — skipping"
    return
  fi

  printf '%s\n' "$alias_line" >> "$config_file"
  print_success "Registered alias in ${config_file}"
}

echo ""
echo -e "  ${BOLD}Scaffold Tool — Multi-Framework Installer${RESET}"
echo ""

check_prereqs

if [ -d "$SCAFFOLD_DIR" ]; then
  echo ""
  echo -e "  ${YELLOW}${SCAFFOLD_DIR} already exists.${RESET}"
  printf "  Update existing installation? [y/N] "
  read -r reply || true
  case "${reply:-n}" in
    y|Y) ;;
    *)
      echo "  Aborted."
      exit 0
      ;;
  esac
  rm -rf "$SCAFFOLD_DIR"
fi

print_info "Downloading ${REPO} (${BRANCH})..."
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d "/tmp/scaffold.XXXXXX")"
ZIP_FILE="${TMP_DIR}/repo.zip"
curl -fsSL "$ZIP_URL" -o "$ZIP_FILE"

print_info "Extracting..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
EXTRACTED_DIR="${TMP_DIR}/${REPO##*/}-${BRANCH}"

mkdir -p "$SCAFFOLD_DIR"

cp "$EXTRACTED_DIR/scaffold.sh" "$SCAFFOLD_DIR/"
[ -d "$EXTRACTED_DIR/lib" ]         && cp -r "$EXTRACTED_DIR/lib"          "$SCAFFOLD_DIR/"
[ -d "$EXTRACTED_DIR/node" ]        && cp -r "$EXTRACTED_DIR/node"         "$SCAFFOLD_DIR/"
[ -d "$EXTRACTED_DIR/vanilla-js" ]  && cp -r "$EXTRACTED_DIR/vanilla-js"   "$SCAFFOLD_DIR/"
[ -f "$EXTRACTED_DIR/CONTRIBUTING.md" ] && cp "$EXTRACTED_DIR/CONTRIBUTING.md" "$SCAFFOLD_DIR/"

print_info "Setting permissions..."
find "$SCAFFOLD_DIR" -name "*.sh" -exec chmod +x {} \;
print_success "Permissions set"

print_info "Registering shell alias..."
register_alias "${HOME}/.zshrc"
register_alias "${HOME}/.bashrc"

echo ""
print_success "Installation complete!"
echo ""
echo -e "  ${BOLD}Installed:${RESET}"
echo "    - Node.js / Express scaffold"
echo "    - Vanilla JS SPA scaffold"
echo "    - Generator tools (newFeature, newComponent, newService)"
echo ""
echo -e "  ${BOLD}Usage:${RESET}"
echo "    scaffold"
echo ""
echo -e "  ${YELLOW}Run the following to activate the alias in your current shell:${RESET}"
echo "    source ~/.zshrc"
echo "    (or source ~/.bashrc)"
echo ""
