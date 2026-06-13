#!/usr/bin/env bash
set -euo pipefail

REPO="aussenseiter-VsRB/setUpFile"
BRANCH="main"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.zip"
SCAFFOLD_DIR="${HOME}/.scaffold"

warn()  { printf "  ! %s\n" "$*" >&2; }
info()  { printf "  \xe2\x86\x92 %s\n" "$*"; }
ok()    { printf "  \xe2\x9c\x93 %s\n" "$*"; }

cleanup() {
  [ -n "${TMP_DIR-}" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

check_prereqs() {
  local missing=false

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl is required but not installed"
    missing=true
  fi

  if ! command -v unzip >/dev/null 2>&1; then
    warn "unzip is required but not installed"
    missing=true
  fi

  if [ "$missing" = true ]; then
    echo ""
    echo "  Install missing dependencies and re-run the installer." >&2
    exit 1
  fi
}

detect_shell_config() {
  local shell_name
  shell_name="$(basename "${SHELL:-bash}")"

  case "$shell_name" in
    zsh)  echo "${HOME}/.zshrc" ;;
    bash) echo "${HOME}/.bashrc" ;;
    fish) echo "${HOME}/.config/fish/config.fish" ;;
    *)
      warn "Unsupported shell: $shell_name (defaulting to ~/.bashrc)"
      echo "${HOME}/.bashrc"
      ;;
  esac
}

add_alias() {
  local config_file="$1"
  local alias_line="alias scaffold='${SCAFFOLD_DIR}/scaffold.sh'"

  if grep -qF "alias scaffold=" "$config_file" 2>/dev/null; then
    warn "Alias 'scaffold' already exists in ${config_file} — skipping"
    return
  fi

  printf '%s\n' "$alias_line" >> "$config_file"
  ok "Registered alias in ${config_file}"
}

print_source_hint() {
  local shell_name
  shell_name="$(basename "${SHELL:-bash}")"

  case "$shell_name" in
    zsh)  echo "  source ~/.zshrc" ;;
    bash) echo "  source ~/.bashrc" ;;
    fish) echo "  source ~/.config/fish/config.fish" ;;
    *)    echo "  source your shell's config file" ;;
  esac
}

echo "  Express scaffold installer"
echo ""

check_prereqs

if [ -d "$SCAFFOLD_DIR" ]; then
  echo "  ${SCAFFOLD_DIR} already exists."
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

info "Downloading ${REPO} (${BRANCH})…"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d "/tmp/scaffold.XXXXXX")"
ZIP_FILE="${TMP_DIR}/repo.zip"
curl -fsSL "$ZIP_URL" -o "$ZIP_FILE"

info "Extracting…"
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
EXTRACTED_DIR="${TMP_DIR}/${REPO##*/}-${BRANCH}"

mkdir -p "$SCAFFOLD_DIR"
if [ -d "$EXTRACTED_DIR/express" ]; then
  mv "$EXTRACTED_DIR/express"/* "$SCAFFOLD_DIR/"
else
  warn "Unexpected archive structure — could not find express/"
  exit 1
fi

info "Setting permissions…"
chmod +x "$SCAFFOLD_DIR/scaffold.sh"
chmod +x "$SCAFFOLD_DIR/lib/"*.sh
ok "Permissions set"

info "Registering shell alias…"
CONFIG_FILE="$(detect_shell_config)"
add_alias "$CONFIG_FILE"

echo ""
ok "Installation complete!"
echo ""
echo "  scaffold can now be run from any project directory."
echo "  Run the following to activate the alias in your current shell:"
echo "    $(print_source_hint)"
echo ""
