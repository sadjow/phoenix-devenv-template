#!/bin/bash
set -euo pipefail

echo "Updating Phoenix dependencies..."
echo "================================"

# Get the app name from mix.exs
APP_NAME=$(grep "app:" mix.exs | head -1 | sed 's/.*app: ://' | tr -d ',')
echo "App name: $APP_NAME"

# Calculate module name from app name
APP_NAME_MODULE=$(echo "$APP_NAME" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')
echo "Module name: $APP_NAME_MODULE"

# Save current configuration values we want to preserve
echo "Preserving current configuration..."
CURRENT_SIGNING_SALT=$(grep "signing_salt:" config/config.exs | grep -o '"[^"]*"' | tr -d '"')
CURRENT_SECRET_KEY_BASE=$(grep "secret_key_base:" config/dev.exs | grep -o '"[^"]*"' | head -1 | tr -d '"')
CURRENT_LIVE_VIEW_SALT=$(grep "live_view:.*signing_salt:" config/config.exs | grep -o '"[^"]*"' | tr -d '"')

# Generate new Phoenix app in temp directory to get latest mix.exs
echo ""
echo "Getting latest Phoenix dependencies..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
mix phx.new phoenix_app --module "$APP_NAME_MODULE" --app "$APP_NAME" --no-install

# Copy only the files we need
echo "Updating dependency files..."
cd - > /dev/null

# Backup and update mix.exs
cp mix.exs mix.exs.bak
cp "$TEMP_DIR/phoenix_app/mix.exs" mix.exs

# Preserve our README
if [ -f "$TEMP_DIR/phoenix_app/README.md" ]; then
  rm "$TEMP_DIR/phoenix_app/README.md"
fi

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Update mix.lock by fetching dependencies
echo ""
echo "Fetching updated dependencies..."
mix deps.get

# Restore configuration values to avoid diff noise
echo ""
echo "Restoring configuration values..."
if [ -n "$CURRENT_SIGNING_SALT" ]; then
  sed -i.bak "s/signing_salt: \"[^\"]*\"/signing_salt: \"$CURRENT_SIGNING_SALT\"/" config/config.exs
fi
if [ -n "$CURRENT_LIVE_VIEW_SALT" ]; then
  sed -i.bak "s/live_view:.*signing_salt: \"[^\"]*\"/live_view: [signing_salt: \"$CURRENT_LIVE_VIEW_SALT\"]/" config/config.exs
fi
if [ -n "$CURRENT_SECRET_KEY_BASE" ]; then
  sed -i.bak "s/secret_key_base: \"[^\"]*\"/secret_key_base: \"$CURRENT_SECRET_KEY_BASE\"/" config/dev.exs
fi

# Clean up backup files
find config -name "*.bak" -delete
rm -f mix.exs.bak

echo ""
echo "Phoenix dependencies updated successfully!"
echo "Changes made:"
echo "- Updated mix.exs with latest Phoenix dependencies"
echo "- Updated mix.lock with new dependency versions"
echo "- Preserved existing configuration values"
echo "- Preserved README.md"