#!/bin/bash
set -euo pipefail

# Script to configure GitHub repository settings for automated workflows
# Requires: gh (GitHub CLI) authenticated with appropriate permissions

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

if [ -z "$REPO" ]; then
    echo "Error: Not in a GitHub repository or gh CLI not authenticated"
    echo "Please run 'gh auth login' first"
    exit 1
fi

echo "Configuring repository settings for: $REPO"
echo "================================================"

# Enable auto-merge for the repository
echo -n "Enabling auto-merge... "
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
echo -n "Enabling automatic branch deletion after merge... "
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

# Verify settings
echo ""
echo "Current repository settings:"
echo "============================"
gh api /repos/$REPO --jq '{
  "Auto-merge enabled": .allow_auto_merge,
  "Auto-delete branches": .delete_branch_on_merge,
  "Default branch": .default_branch,
  "Visibility": .visibility
}' 2>/dev/null || echo "Unable to fetch settings"

echo ""
echo "⚠️  Manual configuration required:"
echo "================================="
echo ""
echo "The following settings must be configured manually in the GitHub UI:"
echo ""
echo "1. Go to: https://github.com/$REPO/settings/actions"
echo "   - Under 'Workflow permissions', select 'Read and write permissions'"
echo "   - Check 'Allow GitHub Actions to create and approve pull requests'"
echo ""
echo "For detailed instructions, see: docs/CI_SETUP.md"