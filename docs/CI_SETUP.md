# CI/CD Setup Guide

This guide explains how to configure your repository for the automated CI/CD workflows.

## Required Repository Settings

The following settings must be configured for the automated workflows to function properly:

### 1. GitHub Actions Permissions

Allow GitHub Actions to create and approve pull requests:

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**:
   - Select **"Read and write permissions"**
   - Check **"Allow GitHub Actions to create and approve pull requests"**

### 2. Auto-merge Settings

Enable auto-merge for automated dependency updates:

1. Go to **Settings** → **General**
2. Under **Pull Requests**:
   - Check **"Allow auto-merge"**
   - Check **"Automatically delete head branches"** (recommended)

### 3. Branch Protection Rules (Recommended)

Protect your main branch with required status checks:

1. Go to **Settings** → **Branches**
2. Add a branch protection rule for `main`
3. Configure:
   - **Require status checks to pass before merging**
   - Select required checks: `CI` and/or `Elixir Tests`
   - **Require branches to be up to date before merging**

## Automated Setup Script

You can use the provided script to configure some settings automatically:

```bash
# Make sure you're authenticated with GitHub CLI
gh auth status

# Run the configuration script
./scripts/configure-repo-settings.sh
```

**Note:** Some settings (like GitHub Actions permissions) cannot be configured via API and must be set manually in the UI.

## Workflow Features

Once configured, the repository will have:

- **Weekly dependency updates** - Automatically creates PRs for outdated devenv dependencies
- **Phoenix template updates** - Checks for new Phoenix versions and updates the template
- **Auto-merge** - Dependency update PRs are automatically merged if CI passes
- **Fast CI builds** - Uses Cachix binary cache to avoid compilation

## Troubleshooting

### Workflows fail with "GitHub Actions is not permitted to create or approve pull requests"

- Ensure you've enabled the setting in **Settings** → **Actions** → **General**

### PRs are created but not auto-merged

- Verify auto-merge is enabled in **Settings** → **General** → **Pull Requests**
- Check that branch protection rules don't block auto-merge
- Ensure all required status checks are passing

### Branches aren't deleted after merge

- Enable **"Automatically delete head branches"** in **Settings** → **General** → **Pull Requests**