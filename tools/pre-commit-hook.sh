#!/bin/bash
# Pre-commit hook to prevent common consistency issues
# 
# Installation:
#   cp tools/pre-commit-hook.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# This prevents commits with common issues that cause problems later

echo "🔍 Running pre-commit consistency checks..."

# Check for trailing whitespace
echo "Checking for trailing whitespace..."
if git diff --cached --check; then
    echo "✅ No trailing whitespace found"
else
    echo "❌ Found trailing whitespace in staged files"
    echo "Fix with: git diff --cached --check --name-only | xargs sed -i 's/[[:space:]]*$//'"
    exit 1
fi

# Check for uncommitted changes (other than what's staged)
echo "Checking for unstaged changes..."
if [ -n "$(git diff --name-only)" ]; then
    echo "⚠️  WARNING: You have unstaged changes"
    echo "Unstaged files:"
    git diff --name-only
    echo ""
    echo "Consider if these should be included in this commit"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Commit cancelled. Stage your changes or stash them."
        exit 1
    fi
fi

# Check commit message format (if committing)
if [ -t 1 ]; then  # Only if running in terminal
    echo "Checking commit message format..."
    # We can't check the message here since it's not written yet,
    # but we can remind the user
    echo "📝 Remember: Use conventional commit format (feat:, fix:, docs:, chore:)"
fi

# Check for large files
echo "Checking for large files..."
large_files=$(git diff --cached --name-only | xargs -I {} find {} -size +1M 2>/dev/null)
if [ -n "$large_files" ]; then
    echo "⚠️  Large files detected:"
    echo "$large_files"
    echo "Consider if these belong in git or should use Git LFS"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Commit cancelled."
        exit 1
    fi
fi

# Check for hardcoded personal paths in markdown files
echo "Checking for hardcoded personal paths..."
hardcoded_paths=$(git diff --cached --name-only "*.md" | xargs grep -l "/home/[^u][^s][^e]" 2>/dev/null || true)
if [ -n "$hardcoded_paths" ]; then
    echo "❌ Found possible hardcoded personal paths:"
    echo "$hardcoded_paths"
    echo "Replace with \$HOME or generic examples like /home/user/"
    exit 1
fi

# Validate YAML files if any are being committed
yaml_files=$(git diff --cached --name-only | grep -E '\.(yml|yaml)$' || true)
if [ -n "$yaml_files" ]; then
    echo "Validating YAML files..."
    for file in $yaml_files; do
        if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            echo "❌ Invalid YAML syntax in $file"
            exit 1
        fi
    done
    echo "✅ YAML files are valid"
fi

echo "✅ All pre-commit checks passed!"
echo ""
echo "💡 After committing, remember to:"
echo "   - Push changes: git push"
echo "   - Check git status to ensure clean working tree"
echo "   - Create PR if working on feature branch"
