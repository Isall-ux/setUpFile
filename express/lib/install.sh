do_install() {
  local orm_deps
  case "$ORM" in
    prisma)    orm_deps="prisma @prisma/client" ;;
    sequelize) orm_deps="sequelize pg pg-hstore" ;;
    mongoose)  orm_deps="mongoose" ;;
  esac

  local env_content

  case "$ORM" in
    prisma)
      env_content="PORT=5000
DATABASE_URL=\"postgresql://user:password@localhost:5432/mydb\""
      ;;
    sequelize)
      env_content="PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=user
DB_PASS=password
DB_DIALECT=postgres"
      ;;
    mongoose)
      env_content="PORT=5000
MONGO_URI=mongodb://localhost:27017/mydb"
      ;;
  esac

  if [ ! -f "package.json" ]; then
    echo "  → npm init -y"
    npm init -y > /dev/null 2>&1
  else
    echo "  package.json exists — skipping npm init"
  fi

  if [ ! -d "node_modules" ]; then
    echo "  → npm install express dotenv $orm_deps"
    npm install express dotenv $orm_deps > /dev/null 2>&1
  else
    echo "  node_modules exist — skipping install"
  fi

  if [ "$DOCKER" = "y" ]; then
    local docker_flag="true"
  else
    local docker_flag="false"
  fi

  node -e "
const pkg = require('./package.json');
pkg.type = 'module';
pkg.scripts = {
  dev: 'node --watch src/server.js',
  module: 'node tools/createModule.js',
  delete: 'node tools/deleteModule.js'
};
if ($docker_flag) Object.assign(pkg.scripts, {
  docker: 'docker build -t myapp .',
  'docker:up': 'docker compose up -d',
  'docker:down': 'docker compose down'
});
require('fs').writeFileSync('./package.json', JSON.stringify(pkg, null, 2) + '\n');
"
  echo "  Updated package.json"

  local dirs=("src/config" "src/core/middleware" "src/core/utils" "src/features" "tools")
  local dir
  for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      echo "  Created folder: $dir/"
    fi
  done

  write_if_missing ".gitignore" <<'EOF'
node_modules
.env
EOF

  write_if_missing ".env" <<< "$env_content"
  write_if_missing ".env.example" <<< "$env_content"

  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local templates_dir="$lib_dir/../templates"

  deploy_template "$templates_dir/$ORM/db.js" "src/config/db.js"
  deploy_template "$templates_dir/$ORM/app.js" "src/app.js"
  deploy_template "$templates_dir/$ORM/createModule.js" "tools/createModule.js"

  write_if_missing "src/server.js" <<'EOF'
import dotenv from "dotenv"
dotenv.config()

import app from "./app.js"

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
EOF

  write_if_missing "tools/deleteModule.js" <<'EOF'
import fs from "fs"
import path from "path"

const name = process.argv[2]
if (!name) {
  console.error("Usage: npm run delete <name>")
  process.exit(1)
}

const featureDir = path.join(process.cwd(), "src", "features", name)
if (fs.existsSync(featureDir)) {
  fs.rmSync(featureDir, { recursive: true, force: true })
  console.log(`Deleted: src/features/${name}`)
} else {
  console.log(`Feature "${name}" not found.`)
}
EOF

  if [ "$ORM" = "prisma" ] && [ ! -d "prisma" ]; then
    echo "  → npx prisma init --datasource-provider postgresql"
    npx prisma init --datasource-provider postgresql > /dev/null 2>&1
  fi
}

print_summary() {
  local orm_upper
  orm_upper="$(echo "$ORM" | sed 's/.*/\u&/')"

  echo ""
  echo "✅ Setup complete with $orm_upper!"
  echo ""
  echo "  npm run dev             — start the server"
  echo "  npm run module <name>   — scaffold a feature module"
  echo "  npm run delete <name>   — remove a feature module"
  if [ "$ORM" = "prisma" ]; then
    echo "  npx prisma migrate dev  — run migrations after editing schema.prisma"
  fi
  if [ "$DOCKER" = "y" ]; then
    echo "  npm run docker          — build Docker image"
    echo "  npm run docker:up       — start Docker containers"
    echo "  npm run docker:down     — stop Docker containers"
  fi
  echo ""
}
