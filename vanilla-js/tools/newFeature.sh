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

kebab_to_pascal() {
  echo "$1" | sed 's/[-]/ /g' | sed 's/\b\(.\)/\u\1/g' | sed 's/ //g'
}

echo ""
echo -e "  ${BOLD}Feature Generator${RESET}"
echo ""

while true; do
  read -r -p "  Feature path (kebab-case, nested with /, e.g. blog or blog/post/comments): " FEATURE_PATH || true
  if [[ "$FEATURE_PATH" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*(/[a-z][a-z0-9]*(-[a-z0-9]+)*)*$ ]]; then
    break
  fi
  print_error "Must be kebab-case segments separated by / (e.g. blog or blog/post/comments)"
done

FEATURE_NAME="${FEATURE_PATH##*/}"
FEATURE_PASCAL=$(kebab_to_pascal "$FEATURE_NAME")
FEATURE_DIR="features/$FEATURE_PATH"
DEPTH=$(($(tr -dc '/' <<< "$FEATURE_PATH" | wc -c) + 1))

echo ""
prompt_choice "Data scope:" "New feature-specific JSON" "Use existing shared JSON" && data_choice=$? || data_choice=$?

JSON_PATH=""
if [ $data_choice -eq 0 ]; then
  JSON_PATH="$FEATURE_DIR/$FEATURE_NAME.json"
else
  read -r -p "  Path to existing JSON (relative to project root): " JSON_PATH || true
fi

echo ""
prompt_yn "Generate sub-helpers (_cards.js, _render.js, _handlers.js, _utils.js)?" && gen_helpers=$? || gen_helpers=$?

echo ""
echo -e "  ${CYAN}Generating feature: ${BOLD}$FEATURE_NAME${RESET}${CYAN}...${RESET}"
echo ""

mkdir -p "$FEATURE_DIR/js"
mkdir -p "$FEATURE_DIR/css"

UP="$(printf '../%.0s' $(seq 1 $DEPTH))"

DATA_IMPORT=""
FETCH_LINE=""
if [ $data_choice -eq 0 ]; then
  DATA_IMPORT="import { fetchData } from '${UP}js/utils/api.js';"
  FETCH_LINE="const data = await fetchData('/${FEATURE_DIR}/${FEATURE_NAME}.json');"
else
  FETCH_LINE="// Data from: ${JSON_PATH}"
fi

write_if_missing "$FEATURE_DIR/$FEATURE_NAME.js" << EOF
${DATA_IMPORT}
import { injectStyle } from '${UP}js/utils/styleLoader.js';

export async function ${FEATURE_PASCAL}(main) {
  injectStyle('/${FEATURE_DIR}/css/${FEATURE_NAME}.css');

  try {
    ${FETCH_LINE}
    const isMobile = window.innerWidth <= 900;
    if (isMobile) {
      renderMobile(main, data);
    } else {
      renderDesktop(main, data);
    }
  } catch (err) {
    main.innerHTML = \`<div class="error">Failed to load ${FEATURE_NAME}: \${err.message}</div>\`;
  }
}

function renderMobile(main, data) {
  main.innerHTML = '<div class="loading">Mobile view — not yet implemented</div>';
}

function renderDesktop(main, data) {
  main.innerHTML = '<div class="loading">Desktop view — not yet implemented</div>';
}
EOF

write_if_missing "$FEATURE_DIR/css/$FEATURE_NAME.css" << 'EOF'
/* ------------------------------------------------------------------ */
/*  Feature: __FEATURE_NAME__                                           */
/* ------------------------------------------------------------------ */
EOF
sed -i "s|__FEATURE_NAME__|${FEATURE_NAME}|g" "$FEATURE_DIR/css/$FEATURE_NAME.css"

if [ $gen_helpers -eq 0 ]; then
  for helper in _cards _render _handlers _utils; do
    write_if_missing "$FEATURE_DIR/js/${helper}.js" << EOF
// ${helper}.js — stub for ${FEATURE_NAME}
// Import this from ${FEATURE_NAME}.js when needed
EOF
  done
fi

if [ $data_choice -eq 0 ]; then
  write_if_missing "$JSON_PATH" << 'JSON_EOF'
{}
JSON_EOF
fi

echo ""
print_success "Feature '${FEATURE_PATH}' created!"
echo ""
echo -e "  ${YELLOW}Next steps:${RESET}"
echo "    Add to router.js:"
echo "      import { ${FEATURE_PASCAL} } from '$(printf '../%.0s' $(seq 1 $((DEPTH + 1))))features/${FEATURE_PATH}/${FEATURE_NAME}.js';"
echo "    Then add to routes object:"
echo "      '/${FEATURE_PATH}': ${FEATURE_PASCAL},"
echo ""
