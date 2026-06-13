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

camel_to_pascal() {
  echo "$1" | sed 's/\b\(.\)/\u\1/g' | sed 's/ //g'
}

echo ""
echo -e "  ${BOLD}Service Generator${RESET}"
echo ""

while true; do
  read -r -p "  Service name (camelCase, e.g. bookmarks): " SERVICE_NAME || true
  if [[ "$SERVICE_NAME" =~ ^[a-z][a-zA-Z0-9]*$ ]]; then
    break
  fi
  print_error "Must be camelCase (e.g. bookmarks)"
done

SERVICE_PASCAL=$(camel_to_pascal "$SERVICE_NAME")

SERVICE_DIR="js/services"

echo ""
echo -e "  ${CYAN}Generating service...${RESET}"
echo ""

mkdir -p "$SERVICE_DIR"

write_if_missing "$SERVICE_DIR/${SERVICE_NAME}.js" << EOF
/**
 * ${SERVICE_PASCAL}Service — singleton
 *
 * Import convention:
 *   import { ${SERVICE_NAME}Service } from '../services/${SERVICE_NAME}.js';
 */
class ${SERVICE_PASCAL}Service {
  init() {
    // TODO: initialize service state
  }

  /**
   * Get all items
   * @returns {Promise<Array>}
   */
  async getAll() {
    // TODO: implement
    return [];
  }

  /**
   * Create a new item
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    // TODO: implement
    return data;
  }
}

export const ${SERVICE_NAME}Service = new ${SERVICE_PASCAL}Service();
EOF

echo ""
print_success "Service '${SERVICE_NAME}Service' created in ${SERVICE_DIR}/${SERVICE_NAME}.js"
echo ""
