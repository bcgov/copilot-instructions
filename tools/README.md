# Tools for Maintaining BCGov AI Coding Standards

This directory contains tools to help maintain consistency and quality in the BCGov AI coding standards repository.

## Pre-commit Hook

### `pre-commit-hook.sh`

A pre-commit hook that prevents common consistency issues from being committed.

## PR Creation Tools

### `safe-pr.sh`

A robust PR creation tool that handles common failure scenarios.

**Usage:**
```bash
tools/safe-pr.sh "feat: add new feature" "Description of changes"
```

**What it handles:**
- ❌ Creating PR from main branch
- ❌ No commits ahead of main  
- ⚠️  Uncommitted changes warnings
- ❌ Remote branch doesn't exist
- ❌ Non-conventional commit titles
- ❌ GitHub CLI authentication issues
- ❌ API rate limiting
- 🔧 Provides manual fallbacks when automation fails

### `pr-templates.sh`

Generates consistent PR titles and bodies following conventional commit format.

**Usage:**
```bash
tools/pr-templates.sh feature "add user authentication"
tools/pr-templates.sh bugfix "fix memory leak in data processing"  
tools/pr-templates.sh docs "improve setup instructions"
```

**Benefits:**
- Consistent PR format across all repositories
- Conventional commit compliance  
- Built-in checklists and templates
- Integration with safe-pr.sh for one-command PR creation

**Installation:**
```bash
cp tools/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**What it checks:**
- ❌ Trailing whitespace in staged files
- ⚠️  Unstaged changes (warns you might have forgotten something)
- ⚠️  Large files that might need Git LFS
- ❌ Hardcoded personal paths in markdown files
- ❌ Invalid YAML syntax in workflow files

**Benefits:**
- Prevents the "uncommitted changes" problem we experienced
- Catches formatting issues before they reach CI
- Encourages clean commit practices
- Validates changes before they're committed

## Automated Workflows

The repository includes GitHub Actions workflows for consistency:

### `standards-check.yml`
Runs on every PR to validate:
- Trailing whitespace
- Line endings consistency
- YAML syntax validation
- Hardcoded personal paths
- Markdown formatting
- Required sections in copilot-upstream.md

### `pr-quality-check.yml` 
Runs on PR creation to check:
- Conventional commit message format
- Indicators of uncommitted changes in PR description
- Large file additions
- Provides helpful next steps

### `pr-creation-helper.yml`
Manual workflow to create PRs when local tools fail:
- Triggered via GitHub Actions web interface
- Generates proper conventional commit titles and template bodies
- Attempts automated PR creation with fallbacks
- Provides manual alternatives when automation fails

### `maintenance.yml`
Runs monthly to:
- Check for GitHub Actions version updates
- Analyze template completeness
- Generate maintenance reports
- Track standards evolution over time

## Usage Philosophy

These tools embody the **"prevent problems before they happen"** approach:

1. **Pre-commit hook** catches issues before they're committed
2. **CI workflows** catch issues before they're merged
3. **Maintenance workflows** catch issues before they become systemic

The goal is to automate away the consistency problems that cause friction and rework.

## Contributing

If you encounter new consistency issues that could be automated away, please:
1. Add detection to the appropriate tool
2. Include helpful error messages that explain how to fix the issue
3. Test the automation to ensure it's not overly restrictive

Remember: These tools should help developers, not hinder them. Good automation makes the right thing the easy thing.
