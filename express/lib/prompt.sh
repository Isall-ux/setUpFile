ask_orm() {
  echo ""
  echo "🔧 Express Project Setup"
  echo ""
  echo "Select an ORM:"
  echo "  1. Prisma"
  echo "  2. Sequelize"
  echo "  3. Mongoose"
  echo ""
  while true; do
    read -r -p "Enter choice (1-3): " choice || true
    case "$choice" in
      1) ORM="prisma"; break;;
      2) ORM="sequelize"; break;;
      3) ORM="mongoose"; break;;
      *) echo "Invalid choice. Please enter 1, 2, or 3.";;
    esac
  done
  echo ""
  echo "✓ Using ORM: $ORM"
}

ask_docker() {
  echo ""
  read -r -p "Do you want to include Docker support? (y/n): " include_docker || true
  DOCKER="$include_docker"
  if [ "$DOCKER" = "y" ]; then
    echo ""
    echo "✓ Docker support enabled"
  else
    echo ""
    echo "✗ Docker support skipped"
  fi
}
