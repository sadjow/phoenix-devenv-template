#!/bin/bash
set -euo pipefail

echo "Recreating Phoenix application..."
echo "================================"

# Get the app name from saved file or use default
if [ -f ".phoenix_app_name" ]; then
  APP_NAME=$(cat .phoenix_app_name)
  rm -f .phoenix_app_name
else
  APP_NAME="phoenix_devenv"
fi

echo "App name: $APP_NAME"

# Calculate module name from app name
APP_NAME_MODULE=$(echo "$APP_NAME" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')
echo "Module name: $APP_NAME_MODULE"

# Generate new Phoenix application in a temporary directory
echo ""
echo "Generating new Phoenix application in temporary directory..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
mix phx.new phoenix_app --module "$APP_NAME_MODULE" --app "$APP_NAME" --no-install

# Move generated files back to original directory
echo "Moving Phoenix files to project directory..."
cd - > /dev/null

# Don't overwrite README.md
rm -f "$TEMP_DIR/phoenix_app/README.md"

mv "$TEMP_DIR/phoenix_app"/* .
mv "$TEMP_DIR/phoenix_app"/.formatter.exs .
rm -rf "$TEMP_DIR"

# Now preserve existing salts and secrets
echo ""
echo "Preserving existing configuration values to avoid diff noise..."

# Extract existing values from the newly generated files
NEW_SIGNING_SALT=$(grep "signing_salt:" config/config.exs | head -1 | grep -o '"[^"]*"' | tr -d '"' || true)
NEW_LIVE_VIEW_SALT=$(grep "live_view:.*signing_salt:" config/config.exs | grep -o '"[^"]*"' | tr -d '"' || true)
NEW_SECRET_KEY_BASE=$(grep "secret_key_base:" config/dev.exs | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || true)
NEW_TEST_SECRET_KEY_BASE=$(grep "secret_key_base:" config/test.exs | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || true)
NEW_PUBSUB_SALT=$(grep "signing_salt:" lib/${APP_NAME}_web/endpoint.ex | grep -o '"[^"]*"' | tr -d '"' || true)

# Use git to check if these values existed before
if git show HEAD:config/config.exs &>/dev/null; then
  OLD_SIGNING_SALT=$(git show HEAD:config/config.exs | grep "signing_salt:" | head -1 | grep -o '"[^"]*"' | tr -d '"' || true)
  OLD_LIVE_VIEW_SALT=$(git show HEAD:config/config.exs | grep "live_view:.*signing_salt:" | grep -o '"[^"]*"' | tr -d '"' || true)
fi
if git show HEAD:config/dev.exs &>/dev/null; then
  OLD_SECRET_KEY_BASE=$(git show HEAD:config/dev.exs | grep "secret_key_base:" | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || true)
fi
if git show HEAD:config/test.exs &>/dev/null; then
  OLD_TEST_SECRET_KEY_BASE=$(git show HEAD:config/test.exs | grep "secret_key_base:" | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || true)
fi
if git show HEAD:lib/${APP_NAME}_web/endpoint.ex &>/dev/null; then
  OLD_PUBSUB_SALT=$(git show HEAD:lib/${APP_NAME}_web/endpoint.ex | grep "signing_salt:" | grep -o '"[^"]*"' | tr -d '"' || true)
fi

# Replace new salts with old ones if they existed
if [ -n "${OLD_SIGNING_SALT:-}" ] && [ -n "$NEW_SIGNING_SALT" ]; then
  echo "Preserving signing_salt..."
  sed -i.bak "s/signing_salt: \"$NEW_SIGNING_SALT\"/signing_salt: \"$OLD_SIGNING_SALT\"/" config/config.exs
fi
if [ -n "${OLD_LIVE_VIEW_SALT:-}" ] && [ -n "$NEW_LIVE_VIEW_SALT" ]; then
  echo "Preserving live_view signing_salt..."
  sed -i.bak "s/signing_salt: \"$NEW_LIVE_VIEW_SALT\"/signing_salt: \"$OLD_LIVE_VIEW_SALT\"/" config/config.exs
fi
if [ -n "${OLD_SECRET_KEY_BASE:-}" ] && [ -n "$NEW_SECRET_KEY_BASE" ]; then
  echo "Preserving dev secret_key_base..."
  sed -i.bak "s/secret_key_base: \"$NEW_SECRET_KEY_BASE\"/secret_key_base: \"$OLD_SECRET_KEY_BASE\"/" config/dev.exs
fi
if [ -n "${OLD_TEST_SECRET_KEY_BASE:-}" ] && [ -n "$NEW_TEST_SECRET_KEY_BASE" ]; then
  echo "Preserving test secret_key_base..."
  sed -i.bak "s/secret_key_base: \"$NEW_TEST_SECRET_KEY_BASE\"/secret_key_base: \"$OLD_TEST_SECRET_KEY_BASE\"/" config/test.exs
fi
if [ -n "${OLD_PUBSUB_SALT:-}" ] && [ -n "$NEW_PUBSUB_SALT" ]; then
  echo "Preserving pubsub signing_salt..."
  sed -i.bak "s/signing_salt: \"$NEW_PUBSUB_SALT\"/signing_salt: \"$OLD_PUBSUB_SALT\"/" lib/${APP_NAME}_web/endpoint.ex
fi

# Apply our custom database configuration
echo ""
echo "Applying custom database configuration..."

# Update dev.exs to add password field
sed -i.bak '/username: "postgres",/s/$/\n  password: "postgres",/' config/dev.exs

# Also update test.exs to add password
sed -i.bak '/username: "postgres",/s/$/\n  password: "postgres",/' config/test.exs

# Clean up backup files
find . -name "*.bak" -delete

echo ""
echo "Phoenix application recreated successfully!"
echo "Run 'mix deps.get' to install dependencies"