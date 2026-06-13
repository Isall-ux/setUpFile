#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

TEMPLATES_DIR="$SCRIPT_DIR/templates"

write_if_missing() {
  local file="$1"
  shift
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

echo -e "  ${BOLD}Vanilla JS SPA Scaffold${RESET}"
echo ""

while true; do
  read -r -p "  Project name (kebab-case): " PROJECT_NAME || true
  if [[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    break
  fi
  print_error "Must be kebab-case (e.g. my-project)"
done

read -r -p "  GitHub Pages base path (blank for root, e.g. /my-repo): " BASE_PATH || true
BASE_PATH="${BASE_PATH:-}"

read -r -p "  Author name: " AUTHOR || true
AUTHOR="${AUTHOR:-}"

PROJECT_DIR="./$PROJECT_NAME"

echo ""
print_step 1 6 "Creating project structure..."
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/assets"
mkdir -p "$PROJECT_DIR/css"
mkdir -p "$PROJECT_DIR/dist"
mkdir -p "$PROJECT_DIR/data"
mkdir -p "$PROJECT_DIR/features"
mkdir -p "$PROJECT_DIR/components/layout"
mkdir -p "$PROJECT_DIR/components/ui"
mkdir -p "$PROJECT_DIR/components/shared"
mkdir -p "$PROJECT_DIR/js/core"
mkdir -p "$PROJECT_DIR/js/services"
mkdir -p "$PROJECT_DIR/js/data"
mkdir -p "$PROJECT_DIR/js/utils"
touch "$PROJECT_DIR/dist/.gitkeep"
touch "$PROJECT_DIR/data/.gitkeep"
touch "$PROJECT_DIR/features/.gitkeep"
touch "$PROJECT_DIR/components/layout/.gitkeep"
touch "$PROJECT_DIR/components/ui/.gitkeep"
touch "$PROJECT_DIR/components/shared/.gitkeep"
touch "$PROJECT_DIR/js/services/.gitkeep"
touch "$PROJECT_DIR/js/data/.gitkeep"
touch "$PROJECT_DIR/.nojekyll"
print_success "Project structure created"

print_step 2 6 "Installing core templates..."
deploy_template "$TEMPLATES_DIR/js/core/config.js"  "$PROJECT_DIR/js/core/config.js"
deploy_template "$TEMPLATES_DIR/js/core/main.js"    "$PROJECT_DIR/js/core/main.js"
deploy_template "$TEMPLATES_DIR/js/core/router.js"  "$PROJECT_DIR/js/core/router.js"
deploy_template "$TEMPLATES_DIR/js/core/theme.js"   "$PROJECT_DIR/js/core/theme.js"
print_success "Core files created"

print_step 3 6 "Installing utility templates..."
deploy_template "$TEMPLATES_DIR/js/utils/api.js"         "$PROJECT_DIR/js/utils/api.js"
deploy_template "$TEMPLATES_DIR/js/utils/dom.js"         "$PROJECT_DIR/js/utils/dom.js"
deploy_template "$TEMPLATES_DIR/js/utils/format.js"      "$PROJECT_DIR/js/utils/format.js"
deploy_template "$TEMPLATES_DIR/js/utils/styleLoader.js" "$PROJECT_DIR/js/utils/styleLoader.js"
deploy_template "$TEMPLATES_DIR/js/utils/url.js"         "$PROJECT_DIR/js/utils/url.js"
print_success "Utility files created"

print_step 4 6 "Installing HTML and CSS..."
deploy_template "$TEMPLATES_DIR/index.html" "$PROJECT_DIR/index.html"
sed -i "s|__BASE_PATH__|${BASE_PATH}|g" "$PROJECT_DIR/index.html"
deploy_template "$TEMPLATES_DIR/css/global.css" "$PROJECT_DIR/css/global.css"
print_success "HTML and CSS files created"

print_step 5 6 "Installing package.json..."
deploy_template "$TEMPLATES_DIR/package.json" "$PROJECT_DIR/package.json"
sed -i "s|__PROJECT_NAME__|${PROJECT_NAME}|g" "$PROJECT_DIR/package.json"
sed -i "s|__AUTHOR__|${AUTHOR}|g" "$PROJECT_DIR/package.json"
sed -i "s|__BASE_PATH__|${BASE_PATH}|g" "$PROJECT_DIR/js/core/config.js"
sed -i "s|__PROJECT_NAME__|${PROJECT_NAME}|g" "$PROJECT_DIR/js/core/config.js"
print_success "Package configuration created"

print_step 6 6 "Finalizing..."
print_success "All done!"

echo ""
echo -e "  ${GREEN}Vanilla JS SPA scaffolded successfully!${RESET}"
echo ""
echo -e "  ${CYAN}Next steps:${RESET}"
echo "    cd ${PROJECT_NAME}"
echo "    npm install"
echo "    npm run watch:css"
echo ""
