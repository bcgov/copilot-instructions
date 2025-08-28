#!/bin/bash
# PR template generator - provides consistent PR formats
# 
# Usage:
#   tools/pr-templates.sh feature "Brief description"
#   tools/pr-templates.sh bugfix "What was broken and how it's fixed"
#   tools/pr-templates.sh docs "Documentation improvements"
#
# Generates properly formatted PR titles and bodies

PR_TYPE="$1"
DESCRIPTION="$2"

if [ -z "$PR_TYPE" ] || [ -z "$DESCRIPTION" ]; then
    echo "❌ Usage: $0 <type> 'description'"
    echo ""
    echo "Available types:"
    echo "  feature   - New functionality"
    echo "  bugfix    - Bug fixes"  
    echo "  docs      - Documentation changes"
    echo "  chore     - Maintenance tasks"
    echo "  refactor  - Code improvements"
    echo "  ci        - CI/CD changes"
    echo ""
    echo "Examples:"
    echo "  $0 feature 'add user authentication'"
    echo "  $0 bugfix 'fix memory leak in data processing'"
    echo "  $0 docs 'improve setup instructions'"
    exit 1
fi

# Generate conventional commit title based on type
case "$PR_TYPE" in
    "feature")
        TITLE="feat: $DESCRIPTION"
        TYPE_DESC="New Feature"
        ;;
    "bugfix")
        TITLE="fix: $DESCRIPTION"
        TYPE_DESC="Bug Fix"
        ;;
    "docs")
        TITLE="docs: $DESCRIPTION"
        TYPE_DESC="Documentation"
        ;;
    "chore")
        TITLE="chore: $DESCRIPTION"
        TYPE_DESC="Maintenance"
        ;;
    "refactor")
        TITLE="refactor: $DESCRIPTION"
        TYPE_DESC="Code Improvement"
        ;;
    "ci")
        TITLE="ci: $DESCRIPTION"
        TYPE_DESC="CI/CD"
        ;;
    *)
        echo "❌ Unknown PR type: $PR_TYPE"
        echo "Use: feature, bugfix, docs, chore, refactor, or ci"
        exit 1
        ;;
esac

# Generate PR body template
BODY="## Summary

$TYPE_DESC: $DESCRIPTION

## What This Changes

- [ ] TODO: List specific changes made
- [ ] TODO: Mention any new features or capabilities  
- [ ] TODO: Note any breaking changes

## How to Test

- [ ] TODO: Describe how to test these changes
- [ ] TODO: Include any setup requirements
- [ ] TODO: Mention test cases covered

## Checklist

- [ ] Code follows project standards
- [ ] Tests added/updated where appropriate
- [ ] Documentation updated if needed
- [ ] No hardcoded personal paths or secrets
- [ ] Conventional commit format used

## Additional Notes

TODO: Add any additional context, screenshots, or notes for reviewers"

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

echo "📋 Generated PR Template"
echo "======================="
echo ""
echo "Title: $TITLE"
echo ""
echo "Body:"
echo "$BODY"
echo ""
echo "======================="
echo ""
echo "🚀 Options:"
echo ""
echo "1. Create PR with safe-pr script:"
echo "   tools/safe-pr.sh '$TITLE' '$BODY'"
echo ""
echo "2. Copy title and body for manual creation"
echo ""
echo "3. Create PR now? (y/N)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    if [ -f "tools/safe-pr.sh" ]; then
        chmod +x tools/safe-pr.sh
        tools/safe-pr.sh "$TITLE" "$BODY"
    else
        echo "❌ safe-pr.sh not found"
        echo "Create PR manually with the template above"
    fi
fi
