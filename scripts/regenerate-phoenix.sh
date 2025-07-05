#!/bin/bash
set -euo pipefail

echo "Regenerating Phoenix application..."
echo "==================================="

# Remove existing Phoenix files except for custom modifications
echo "Removing Phoenix files (preserving custom files)..."
find . -type f \
  -not -path "./.git/*" \
  -not -path "./devenv*" \
  -not -path "./.github/*" \
  -not -path "./scripts/*" \
  -not -path "./docs/*" \
  -not -name "README.md" \
  -not -name "LICENSE" \
  -not -name ".gitignore" \
  -not -name ".envrc" \
  -delete

# Also remove empty directories (except preserved ones)
find . -type d -empty \
  -not -path "./.git/*" \
  -not -path "./devenv*" \
  -not -path "./.github/*" \
  -not -path "./scripts/*" \
  -not -path "./docs/*" \
  -delete 2>/dev/null || true

# Generate new Phoenix application
echo "Generating new Phoenix application..."
mix phx.new . --module PhoenixDevenv --app phoenix_devenv --no-install

# Apply our custom database configuration
echo "Applying custom database configuration..."
# Add password to dev.exs
sed -i 's/username: "postgres",/username: "postgres",\n  password: "postgres",/' config/dev.exs
# Add password to test.exs
sed -i 's/username: "postgres",/username: "postgres",\n  password: "postgres",/' config/test.exs

# Install dependencies
echo "Installing dependencies..."
mix deps.get
mix deps.compile

echo "Phoenix template regenerated successfully!"