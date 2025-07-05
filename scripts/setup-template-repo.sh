#!/bin/bash
set -euo pipefail

# Script to configure the phoenix-devenv-template repository
# This is ONLY for maintainers of the template repository itself
# Projects using this template should use setup-for-projects.sh instead

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

if [ -z "$REPO" ]; then
    echo "Error: Not in a GitHub repository or gh CLI not authenticated"
    echo "Please run 'gh auth login' first"
    exit 1
fi

# Verify this is the template repository
if [[ "$REPO" != *"phoenix-devenv-template"* ]]; then
    echo "⚠️  Warning: This script is intended for the phoenix-devenv-template repository."
    echo "   Current repo: $REPO"
    echo "   For projects using the template, run: ./scripts/setup-for-projects.sh"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Configuring template repository: $REPO"
echo "======================================="

# Enable auto-merge for the repository
echo -n "Enabling auto-merge for all workflows... "
if gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$REPO \
  -f allow_auto_merge=true >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ (requires admin permissions)"
fi

# Enable automatic deletion of head branches after merge
echo -n "Enabling automatic branch deletion... "
if gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$REPO \
  -f delete_branch_on_merge=true >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗ (requires admin permissions)"
fi

# Verify both workflows exist
echo ""
echo "Checking required workflows:"
if [ -f ".github/workflows/update-devenv.yml" ]; then
    echo "✓ update-devenv.yml found"
else
    echo "✗ update-devenv.yml missing!"
fi

if [ -f ".github/workflows/update-phoenix.yml" ]; then
    echo "✓ update-phoenix.yml found"
else
    echo "✗ update-phoenix.yml missing!"
fi

# Verify settings
echo ""
echo "Current repository settings:"
echo "============================"
gh api /repos/$REPO --jq '{
  "Auto-merge enabled": .allow_auto_merge,
  "Auto-delete branches": .delete_branch_on_merge,
  "Default branch": .default_branch
}' 2>/dev/null || echo "Unable to fetch settings"

echo ""
echo "⚠️  Manual configuration required:"
echo "================================="
echo ""
echo "Allow GitHub Actions to create and approve pull requests:"
echo "1. Go to: https://github.com/$REPO/settings/actions"
echo "2. Under 'Workflow permissions', select 'Read and write permissions'"
echo "3. Check 'Allow GitHub Actions to create and approve pull requests'"
echo ""
echo "This enables both workflows:"
echo "- Weekly devenv updates"
echo "- Weekly Phoenix template updates"
echo ""
echo "For detailed instructions, see: docs/CI_SETUP.md"