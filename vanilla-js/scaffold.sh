#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

TEMPLATES_DIR="$SCRIPT_DIR/templates"

write_if_missing() {
  local file="$1"; shift
  if [ ! -f "$file" ]; then
    mkdir -p "$(dirname "$file")"
    cat > "$file"
    print_success "Created: $file"
  else
    print_info "Skipped (exists): $file"
    cat > /dev/null
  fi
}

deploy_template() {
  local template="$1"
  local dest="$2"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$template" "$dest"
  fi
}

# ── Prompts (2 questions only) ─────────────────────────────────────────────
echo ""
echo -e "  ${BOLD}Vanilla JS SPA Scaffold${RESET}"
echo ""

while true; do
  read -r -p "  Project name (kebab-case): " PROJECT_NAME || true
  [[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]] && break
  print_error "Must be kebab-case (e.g. my-project)"
done

read -r -p "  GitHub Pages base path (blank for root, e.g. /my-repo): " BASE_PATH || true
BASE_PATH="${BASE_PATH:-}"

# ── Everything below runs silently ─────────────────────────────────────────
PROJECT_DIR="./$PROJECT_NAME"

main() {
  do_structure
  do_core
  do_utils
  do_html_css
  do_package
  do_tools
  print_summary
}

do_structure() {
  print_step 1 6 "Creating project structure..."
  mkdir -p "$PROJECT_DIR"/{assets,css,dist,data,features}
  mkdir -p "$PROJECT_DIR"/components/{layout,ui,shared}
  mkdir -p "$PROJECT_DIR"/js/{core,services,data,utils}
  touch "$PROJECT_DIR"/dist/.gitkeep
  touch "$PROJECT_DIR"/data/.gitkeep
  touch "$PROJECT_DIR"/features/.gitkeep
  touch "$PROJECT_DIR"/components/{layout,ui,shared}/.gitkeep
  touch "$PROJECT_DIR"/js/{services,data}/.gitkeep
  touch "$PROJECT_DIR"/.nojekyll
}

do_core() {
  print_step 2 6 "Installing core files..."
  for f in config.js main.js router.js theme.js; do
    deploy_template "$TEMPLATES_DIR/js/core/$f" "$PROJECT_DIR/js/core/$f"
  done
}

do_utils() {
  print_step 3 6 "Installing utilities..."
  for f in api.js dom.js format.js styleLoader.js url.js; do
    deploy_template "$TEMPLATES_DIR/js/utils/$f" "$PROJECT_DIR/js/utils/$f"
  done
}

do_html_css() {
  print_step 4 6 "Installing HTML and CSS..."
  deploy_template "$TEMPLATES_DIR/index.html"     "$PROJECT_DIR/index.html"
  deploy_template "$TEMPLATES_DIR/css/global.css" "$PROJECT_DIR/css/global.css"
  sed -i "s|__BASE_PATH__|${BASE_PATH}|g"         "$PROJECT_DIR/index.html"
  sed -i "s|__BASE_PATH__|${BASE_PATH}|g"         "$PROJECT_DIR/js/core/config.js"
}

do_package() {
  print_step 5 6 "Installing package.json..."
  deploy_template "$TEMPLATES_DIR/package.json" "$PROJECT_DIR/package.json"
  sed -i "s|__PROJECT_NAME__|${PROJECT_NAME}|g" "$PROJECT_DIR/package.json"
  sed -i "s|__PROJECT_NAME__|${PROJECT_NAME}|g" "$PROJECT_DIR/js/core/config.js"
}

do_tools() {
  print_step 6 6 "Copying generator tools..."
  mkdir -p "$PROJECT_DIR/tools"
  cp -r "$SCRIPT_DIR/tools/"* "$PROJECT_DIR/tools/"
}

print_summary() {
  echo ""
  echo -e "  ${GREEN}${BOLD}${PROJECT_NAME}${RESET}${GREEN} scaffolded successfully!${RESET}"
  echo ""
  echo -e "  ${CYAN}Next steps:${RESET}"
  echo "    cd ${PROJECT_NAME}"
  echo "    npm install"
  echo "    npm run watch:css"
  echo ""
  echo -e "  ${CYAN}Generators (run from project root):${RESET}"
  echo "    npm run new:feature      # Scaffold a new feature"
  echo "    npm run new:component    # Scaffold a new component"
  echo "    npm run new:service      # Scaffold a new service"
  echo ""
}

main