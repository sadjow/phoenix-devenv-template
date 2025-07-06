#!/bin/bash
set -euo pipefail

echo "Cleaning Phoenix application files..."
echo "===================================="

# Get the app name from mix.exs before deletion (if it exists)
if [ -f "mix.exs" ]; then
  APP_NAME=$(grep "app:" mix.exs | head -1 | sed 's/.*app: ://' | tr -d ',')
  echo "App name: $APP_NAME"
  # Save the app name for the regeneration script
  echo "$APP_NAME" > .phoenix_app_name
else
  # Default app name if mix.exs doesn't exist
  echo "phoenix_devenv" > .phoenix_app_name
fi

# Remove all Phoenix-specific files
echo "Removing Phoenix files (preserving custom files)..."

# Remove specific Phoenix files
rm -f mix.exs mix.lock .formatter.exs

# Remove Phoenix directories
for dir in lib test config priv assets _build deps; do
  if [ -d "$dir" ]; then
    echo "Removing $dir/"
    rm -rf "$dir"
  fi
done

# Remove any remaining Phoenix-related files at root level
find . -maxdepth 1 -type f \
  -not -name ".git*" \
  -not -name "devenv*" \
  -not -name "README.md" \
  -not -name "LICENSE" \
  -not -name ".envrc" \
  -not -name ".phoenix_app_name" \
  -not -path "./scripts/*" \
  -not -path "./docs/*" \
  -not -path "./.github/*" \
  -delete 2>/dev/null || true

echo ""
echo "Phoenix files cleaned successfully!"
echo "Run 'git status' to see what was removed"
echo "Run './scripts/recreate-phoenix-app.sh' to regenerate the application"