#!/bin/bash
set -euo pipefail

# This script regenerates the Phoenix application from scratch
# It calls the clean and recreate scripts in sequence

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Step 1: Cleaning Phoenix files..."
echo "================================="
"$SCRIPT_DIR/clean-phoenix-files.sh"

echo ""
echo "Step 2: Checking git status..."
echo "=============================="
git status --short

echo ""
echo "Step 3: Recreating Phoenix application..."
echo "========================================="
"$SCRIPT_DIR/recreate-phoenix-app.sh"

echo ""
echo "Phoenix regeneration complete!"