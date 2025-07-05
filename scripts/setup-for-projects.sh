#!/bin/bash
set -euo pipefail

# Script to set up GitHub repository for projects using this template
# This configures settings for the devenv update workflow

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

if [ -z "$REPO" ]; then
    echo "Error: Not in a GitHub repository or gh CLI not authenticated"
    echo "Please run 'gh auth login' first"
    exit 1
fi

echo "Setting up repository for devenv updates: $REPO"
echo "================================================"

# Enable auto-merge for the repository
echo -n "Enabling auto-merge for dependency PRs... "
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

# Remove Phoenix update workflow if it exists
if [ -f ".github/workflows/update-phoenix.yml" ]; then
    echo ""
    echo "⚠️  Removing Phoenix update workflow (template-only workflow)..."
    rm .github/workflows/update-phoenix.yml
    echo "   ✓ Removed .github/workflows/update-phoenix.yml"
fi

# Remove template-specific script if it exists
if [ -f "scripts/setup-template-repo.sh" ]; then
    echo "⚠️  Removing template-specific setup script..."
    rm scripts/setup-template-repo.sh
    echo "   ✓ Removed scripts/setup-template-repo.sh"
fi

echo ""
echo "✅ Repository setup complete for devenv updates!"
echo ""
echo "⚠️  Manual step required:"
echo "========================"
echo "Allow GitHub Actions to create pull requests:"
echo "1. Go to: https://github.com/$REPO/settings/actions"
echo "2. Under 'Workflow permissions', select 'Read and write permissions'"
echo "3. Check 'Allow GitHub Actions to create and approve pull requests'"
echo ""
echo "This enables the weekly devenv update workflow to create PRs automatically."