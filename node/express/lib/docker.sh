do_docker() {
  write_if_missing "Dockerfile" <<'DOCKERFILE'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY prisma ./prisma
RUN npx prisma generate

COPY src ./src
COPY .env.example .env

EXPOSE 5000

CMD ["npm", "run", "dev"]
DOCKERFILE

  if [ "$ORM" = "mongoose" ]; then
    local db_service="mongo"
    local db_image="mongo:7"
    local db_port="27017"
    local db_volume="mongo_data:/data/db"
    local db_url_env="MONGO_URI=mongodb://mongo:27017/mydb"
  else
    local db_service="postgres"
    local db_image="postgres:16-alpine"
    local db_port="5432"
    local db_volume="postgres_data:/var/lib/postgresql/data"
    local db_url_env="DATABASE_URL=postgresql://user:password@postgres:5432/mydb"
  fi

  local compose_yml
  compose_yml="version: \"3.8\"

services:
  ${db_service}:
    image: ${db_image}
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    ports:
      - \"${db_port}:${db_port}\"
    volumes:
      - ${db_volume}

volumes:
  ${db_volume%%:*}:
"
  write_if_missing "docker-compose.yml" <<< "$compose_yml"

  write_if_missing ".dockerignore" <<'EOF'
node_modules
.env
.git
EOF
}
