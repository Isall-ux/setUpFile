write_if_missing() {
  local file="$1"
  shift
  if [ ! -f "$file" ]; then
    mkdir -p "$(dirname "$file")"
    cat > "$file"
    echo "  Created: $file"
  else
    echo "  Skipped (exists): $file"
    cat > /dev/null
  fi
}

deploy_template() {
  local template="$1"
  local dest="$2"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$template" "$dest"
    echo "  Created: $dest"
  else
    echo "  Skipped (exists): $dest"
  fi
}
