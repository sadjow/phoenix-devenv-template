#!/bin/bash
set -euo pipefail

echo "Preserving existing Phoenix salts and secrets..."

# Create a temporary file to store the values
SALTS_FILE=".phoenix_salts_temp"

# Extract existing values if files exist
if [ -f "config/config.exs" ]; then
  SIGNING_SALT=$(grep "signing_salt:" config/config.exs | head -1 | grep -o '"[^"]*"' | tr -d '"' || echo "")
  LIVE_VIEW_SALT=$(grep "live_view:.*signing_salt:" config/config.exs | grep -o '"[^"]*"' | tr -d '"' || echo "")
  echo "OLD_SIGNING_SALT='$SIGNING_SALT'" > "$SALTS_FILE"
  echo "OLD_LIVE_VIEW_SALT='$LIVE_VIEW_SALT'" >> "$SALTS_FILE"
fi

if [ -f "config/dev.exs" ]; then
  SECRET_KEY_BASE=$(grep "secret_key_base:" config/dev.exs | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || echo "")
  echo "OLD_SECRET_KEY_BASE='$SECRET_KEY_BASE'" >> "$SALTS_FILE"
fi

if [ -f "config/test.exs" ]; then
  TEST_SECRET_KEY_BASE=$(grep "secret_key_base:" config/test.exs | head -1 | grep -o '"[^"]*"' | head -1 | tr -d '"' || echo "")
  echo "OLD_TEST_SECRET_KEY_BASE='$TEST_SECRET_KEY_BASE'" >> "$SALTS_FILE"
fi

if [ -f "lib/phoenix_devenv_web/endpoint.ex" ]; then
  PUBSUB_SALT=$(grep "signing_salt:" lib/phoenix_devenv_web/endpoint.ex | grep -o '"[^"]*"' | tr -d '"' || echo "")
  echo "OLD_PUBSUB_SALT='$PUBSUB_SALT'" >> "$SALTS_FILE"
fi

echo "Salts preserved in $SALTS_FILE"