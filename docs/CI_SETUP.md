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

## Automated Setup Scripts

### For Projects Using This Template

```bash
# Make sure you're authenticated with GitHub CLI
gh auth status

# Run the setup script for projects
./scripts/setup-for-projects.sh
```

This script will:
- Enable auto-merge and branch deletion
- Remove template-only files (Phoenix update workflow and template setup script)
- Guide you through manual configuration

### For Template Repository Maintainers

```bash
# Run the template repository setup
./scripts/setup-template-repo.sh
```

**Note:** Some settings (like GitHub Actions permissions) cannot be configured via API and must be set manually in the UI.

## Workflow Features

### For Projects Using This Template

- **Weekly devenv updates** (`update-devenv.yml`) - Automatically creates PRs to update the devenv lock file. This workflow is useful for any project using devenv to keep the development environment up-to-date.
- **Auto-merge** - Dependency update PRs are automatically merged if CI passes
- **Fast CI builds** - Uses Cachix binary cache to avoid compilation

### For The Template Repository Only

- **Phoenix template updates** (`update-phoenix.yml`) - This workflow is specifically designed for maintaining the template repository itself. It checks for new Phoenix versions and regenerates the entire Phoenix application, overwriting all files. **This workflow should be removed or disabled in projects created from this template** as it would destroy your project-specific code.

## Troubleshooting

### Workflows fail with "GitHub Actions is not permitted to create or approve pull requests"

- Ensure you've enabled the setting in **Settings** → **Actions** → **General**

### PRs are created but not auto-merged

- Verify auto-merge is enabled in **Settings** → **General** → **Pull Requests**
- Check that branch protection rules don't block auto-merge
- Ensure all required status checks are passing

### Branches aren't deleted after merge

- Enable **"Automatically delete head branches"** in **Settings** → **General** → **Pull Requests**