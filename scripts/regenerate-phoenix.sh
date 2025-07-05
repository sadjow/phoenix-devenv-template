#!/bin/bash
set -euo pipefail

echo "Regenerating Phoenix application..."
echo "==================================="

# Backup config files that might be customized
echo "Backing up config files..."
mkdir -p backup
[ -f "config/dev.exs" ] && cp config/dev.exs backup/
[ -f "config/test.exs" ] && cp config/test.exs backup/

# Remove existing Phoenix files except for custom modifications
echo "Removing Phoenix files (preserving custom files)..."
find . -type f \
  -not -path "./.git/*" \
  -not -path "./devenv*" \
  -not -path "./.github/*" \
  -not -path "./backup/*" \
  -not -path "./scripts/*" \
  -not -path "./docs/*" \
  -not -name "README.md" \
  -not -name "LICENSE" \
  -not -name ".gitignore" \
  -not -name ".envrc" \
  -delete

# Generate new Phoenix application
echo "Generating new Phoenix application..."
echo Y | mix phx.new . --module PhoenixDevenv --app phoenix_devenv --no-install

# Restore backed up config files
echo "Restoring config files..."
[ -f "backup/dev.exs" ] && cp backup/dev.exs config/
[ -f "backup/test.exs" ] && cp backup/test.exs config/

# Clean up backup directory
rm -rf backup

# Update database configuration
echo "Updating database configuration..."
sed -i 's/username: "postgres",/username: "postgres",\n  password: "postgres",/' config/dev.exs
sed -i 's/username: "postgres",/username: "postgres",\n  password: "postgres",/' config/test.exs

# Install dependencies
echo "Installing dependencies..."
mix deps.get
mix deps.compile

echo "Phoenix template regenerated successfully!"