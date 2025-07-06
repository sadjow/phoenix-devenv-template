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
mv "$TEMP_DIR/phoenix_app"/* .
mv "$TEMP_DIR/phoenix_app"/.formatter.exs .
rm -rf "$TEMP_DIR"

# Apply our custom database configuration
echo ""
echo "Applying custom database configuration..."

# Update dev.exs with our custom configuration
cat > config/dev.exs << 'EOF'
import Config

# Configure your database
config :$APP_NAME, ${APP_NAME_MODULE}.Repo,
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "localhost",
  database: System.get_env("PGDATABASE") || "${APP_NAME}_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :$APP_NAME, ${APP_NAME_MODULE}Web.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "$(openssl rand -base64 48)",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:$APP_NAME, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:$APP_NAME, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :$APP_NAME, ${APP_NAME_MODULE}Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/${APP_NAME}_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :$APP_NAME, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[\$level] \$message\\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
EOF

# Also update test.exs to add password
sed -i.bak 's/username: "postgres",/username: "postgres",\n  password: "postgres",/' config/test.exs
rm -f config/test.exs.bak

echo ""
echo "Phoenix application recreated successfully!"
echo "Run 'mix deps.get' to install dependencies"