#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/ui.sh"

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

pascal_to_kebab() {
  echo "$1" | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//'
}

echo ""
echo -e "  ${BOLD}Component Generator${RESET}"
echo ""

while true; do
  read -r -p "  Component name (PascalCase, e.g. UserCard): " COMP_NAME || true
  if [[ "$COMP_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    break
  fi
  print_error "Must be PascalCase (e.g. UserCard)"
done

COMP_KEBAB=$(pascal_to_kebab "$COMP_NAME")

echo ""
prompt_choice "Category:" "layout" "ui" "shared" && cat_choice=$? || cat_choice=$?

case $cat_choice in
  0) CATEGORY="layout" ;;
  1) CATEGORY="ui" ;;
  2) CATEGORY="shared" ;;
esac

COMP_DIR="components/$CATEGORY/$COMP_KEBAB"

echo ""
echo -e "  ${CYAN}Generating component...${RESET}"
echo ""

mkdir -p "$COMP_DIR"

write_if_missing "$COMP_DIR/$COMP_KEBAB.js" << EOF
/**
 * ${COMP_NAME} component
 * @param {HTMLElement} main - mount target
 */
export function ${COMP_NAME}(main) {
  // TODO: implement ${COMP_NAME}
  main.innerHTML = '<div>${COMP_NAME} component</div>';
}
EOF

write_if_missing "$COMP_DIR/$COMP_KEBAB.css" << 'EOF'
/* ------------------------------------------------------------------ */
/*  Component: __COMP_NAME__  (__CATEGORY__)                            */
/* ------------------------------------------------------------------ */
EOF
sed -i "s|__COMP_NAME__|${COMP_NAME}|g" "$COMP_DIR/$COMP_KEBAB.css"
sed -i "s|__CATEGORY__|${CATEGORY}|g" "$COMP_DIR/$COMP_KEBAB.css"

echo ""
print_success "Component '${COMP_NAME}' created in ${COMP_DIR}/"
echo ""
