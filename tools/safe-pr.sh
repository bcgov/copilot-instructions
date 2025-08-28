#!/bin/bash
# Safe PR creation tool - handles common failure scenarios
# 
# Usage:
#   tools/safe-pr.sh "PR title" "PR body content"
#   tools/safe-pr.sh "feat: add new feature" "Description of changes"
#
# This script handles common PR creation failures and provides fallbacks

set -e  # Exit on error

PR_TITLE="$1"
PR_BODY="$2"

if [ -z "$PR_TITLE" ]; then
    echo "❌ Usage: $0 'PR title' 'PR body'"
    echo "Example: $0 'feat: add new feature' 'Description of the changes'"
    exit 1
fi

echo "🔍 Running pre-PR creation checks..."

# Check 1: Verify we're on a feature branch (not main)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
    echo "❌ Cannot create PR from main branch"
    echo "Create a feature branch first:"
    echo "  git checkout -b feat/your-feature-name"
    exit 1
fi
echo "✅ On feature branch: $CURRENT_BRANCH"

# Check 2: Verify branch has commits ahead of main
COMMITS_AHEAD=$(git rev-list --count main.."$CURRENT_BRANCH" 2>/dev/null || echo "0")
if [ "$COMMITS_AHEAD" = "0" ]; then
    echo "❌ Branch has no commits ahead of main"
    echo "Make some changes and commit them first"
    exit 1
fi
echo "✅ Branch has $COMMITS_AHEAD commits ahead of main"

# Check 3: Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  WARNING: Uncommitted changes detected!"
    git status --porcelain
    echo ""
    echo "These changes won't be included in the PR"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled. Commit your changes first."
        exit 1
    fi
fi

# Check 4: Verify remote branch exists or can be pushed
if ! git ls-remote --exit-code --heads origin "$CURRENT_BRANCH" >/dev/null 2>&1; then
    echo "📤 Branch doesn't exist remotely, pushing first..."
    if ! git push --set-upstream origin "$CURRENT_BRANCH"; then
        echo "❌ Failed to push branch to remote"
        echo "Check network connection and permissions"
        exit 1
    fi
else
    echo "✅ Remote branch exists"
    
    # Check if local is ahead/behind
    git fetch origin "$CURRENT_BRANCH"
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "@{u}" 2>/dev/null || echo "")
    
    if [ "$LOCAL" != "$REMOTE" ] && [ -n "$REMOTE" ]; then
        echo "📤 Local branch differs from remote, pushing updates..."
        git push
    fi
fi

# Check 5: Validate PR title format (conventional commits)
if ! echo "$PR_TITLE" | grep -E "^(feat|fix|docs|chore|refactor|test|ci|perf|build)(\(.+\))?: .+"; then
    echo "⚠️  PR title doesn't follow conventional commit format"
    echo "Current: $PR_TITLE"
    echo "Expected: type(scope): description"
    echo "Types: feat, fix, docs, chore, refactor, test, ci, perf, build"
    echo ""
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Fix title format and try again"
        exit 1
    fi
fi

# Check 6: Validate GitHub CLI and rate limits
echo "🔍 Checking GitHub CLI status..."
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) not found"
    echo "Install with: https://cli.github.com/"
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ GitHub CLI not authenticated"
    echo "Run: gh auth login"
    exit 1
fi

# Check rate limits if script exists
if [ -f ~/Documents/AI/scripts/check-github-rate-limit.sh ]; then
    if ! ~/Documents/AI/scripts/check-github-rate-limit.sh can-create-pr; then
        echo "❌ GitHub API rate limited"
        echo "Try again later or use manual PR creation"
        exit 1
    fi
fi

echo "✅ All pre-checks passed!"
echo ""

# Create temporary body file to handle multi-line content safely
BODY_FILE=$(mktemp)
cat >"$BODY_FILE" <<EOF
$PR_BODY
EOF

echo "🚀 Creating PR..."
echo "Title: $PR_TITLE"
echo "Body preview:"
echo "---"
head -5 "$BODY_FILE"
echo "---"
echo ""

# Attempt PR creation with error handling
if gh pr create --title "$PR_TITLE" --body-file "$BODY_FILE" --assignee DerekRoberts; then
    PR_URL=$(gh pr view --json url -q .url)
    echo "✅ PR created successfully!"
    echo "📎 URL: $PR_URL"
    
    # Clean up
    rm -f "$BODY_FILE"
    
    echo ""
    echo "📋 Next steps:"
    echo "- Review the PR: $PR_URL"
    echo "- Wait for checks to complete"
    echo "- Merge when ready"
    
else
    echo "❌ PR creation failed with gh CLI"
    echo ""
    echo "🔧 Fallback options:"
    echo ""
    echo "1. Manual PR creation:"
    echo "   URL: https://github.com/bcgov/copilot-instructions/compare/main...$CURRENT_BRANCH"
    echo ""
    echo "2. Manual gh command (copy and paste):"
    echo "   gh pr create \\"
    echo "     --title '$PR_TITLE' \\"
    echo "     --body-file '$BODY_FILE' \\"
    echo "     --assignee DerekRoberts"
    echo ""
    echo "3. Body content for manual creation:"
    echo "---"
    cat "$BODY_FILE"
    echo "---"
    
    # Don't clean up body file if PR creation failed
    echo ""
    echo "💾 Body content saved to: $BODY_FILE"
    echo "Clean up when done: rm $BODY_FILE"
    
    exit 1
fi
