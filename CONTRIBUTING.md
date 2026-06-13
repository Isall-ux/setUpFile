# Contributor Guide — Adding a New Framework Scaffold

## Contract

Every framework scaffold **must** follow these rules:

### 1. Location

```
~/.scaffold/<lang>/<framework>/scaffold.sh
```

- `<lang>` is the language/ecosystem folder (e.g., `node`, `python`)
- `<framework>` is the framework folder (e.g., `express`, `fastify`)

### 2. Source shared UI

The first two lines of `scaffold.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Source the shared UI library at the top:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/ui.sh"
```

This gives you access to:

| Function | Purpose |
|---|---|
| `prompt_choice "Label" "opt1" "opt2" ...` | Numbered menu, returns index via `$?` |
| `prompt_yn "Question?"` | Yes/no prompt, returns 0/1 |
| `print_step n total "msg"` | Progress indicator |
| `print_success "msg"` | Green checkmark |
| `print_error "msg"` | Red X |
| `print_info "msg"` | Yellow arrow |

And color variables: `$GREEN`, `$YELLOW`, `$RED`, `$CYAN`, `$BOLD`, `$RESET`.

### 3. File writing

You **must** use `write_if_missing()` — either from your own `lib/files.sh` or from a shared `lib/files.sh`:

```bash
write_if_missing "path/to/file" <<'EOF'
file content here
EOF
```

`write_if_missing()` must:
- Create parent directories automatically
- Skip and print a message if the file already exists
- Print a success message when the file is created

### 4. Idempotency

Every operation must be safe to re-run. All of these must be idempotent:
- File creation — use `write_if_missing()` or `deploy_template()`
- Directory creation — skip if exists
- `npm install` — skip if `node_modules` exists
- `npm init` — skip if `package.json` exists
- Alias registration — skip if already present

### 5. The top-level router (`scaffold.sh`) delegates to your framework

Your scaffold runs as a subprocess (`bash .../scaffold.sh`), so it must be self-contained:
- Set `SCRIPT_DIR` from `BASH_SOURCE[0]`
- Source all needed libs relative to `SCRIPT_DIR`
- Prompt the user for inputs directly (no parameters passed from router)

### 6. Templates

Store reusable template files under:

```
<script-dir>/templates/
```

Use `deploy_template()` to copy them:

```bash
deploy_template() {
  local template="$1"
  local dest="$2"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$template" "$dest"
    print_success "Created: $dest"
  else
    print_info "Skipped (exists): $dest"
  fi
}
```

---

## Step-by-Step: Adding a New Framework

```
scaffold/
├── lib/ui.sh          ← shared (do not edit)
├── scaffold.sh         ← top-level router (edit to add your entry)
├── <lang>/
│   └── <framework>/
│       ├── scaffold.sh  ← your entry point
│       ├── lib/          ← optional, for your helpers
│       └── templates/    ← optional, for reusable files
```

### Step 1 — Create the directory

```bash
mkdir -p ~/.scaffold/<lang>/<framework>/{lib,templates}
```

### Step 2 — Write scaffold.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/ui.sh"

# Your code here
```

### Step 3 — Add your entry to the top-level router

Edit `~/.scaffold/scaffold.sh`:

```bash
# In the language menu, add your language if new
# In the framework submenu, add your framework
# Delegate with:
bash "$SCRIPT_DIR/<lang>/<framework>/scaffold.sh"
```

### Step 4 — Make it idempotent

Wrap every write in `write_if_missing()`. Check `node_modules` before `npm install`. Check `package.json` before `npm init`.

### Step 5 — Test

```bash
# Remove and re-install
rm -rf ~/.scaffold
bash install.sh

# Run it
cd /tmp/test-project
scaffold
```

Run it twice — the second run should skip everything with "exists" messages and never error.

### Step 6 — Commit

Open a PR with your `<lang>/<framework>/` directory, any changes to `scaffold.sh`, and this entry in `install.sh`.
