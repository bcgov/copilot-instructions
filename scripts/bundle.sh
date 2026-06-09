#!/bin/bash
# Bundle Copilot Instructions
# Usage: ./scripts/bundle.sh [github_id]
#
# Arguments:
#   github_id      Optional. Profile in .github/profiles/ (defaults to gh api user or prompt)
#

set -euo pipefail

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 1. Capture Arguments
OUTPUT_FILE="$HOME/.config/Code/User/prompts/global.instructions.md"
GH_ID_FALLBACK=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    GH_ID_FALLBACK=$(gh api user --jq '.login' 2>/dev/null || true)
    GH_ID_FALLBACK=$(echo "$GH_ID_FALLBACK" | tr -d '"{}[] ')
fi

if [[ -z "${GH_ID_FALLBACK}" ]]; then
    if [[ -t 0 ]]; then
        read -r -p "Enter GitHub ID for profile: " GH_ID_FALLBACK
    fi
    GH_ID_FALLBACK="${GH_ID_FALLBACK:-DerekRoberts}"
fi
PROFILE_NAME="${1:-$GH_ID_FALLBACK}"

# Paths
GLOBAL_FILE="${REPO_ROOT}/.github/copilot-instructions.md"
PROFILE_DIR="${REPO_ROOT}/.github/profiles"
PROFILE_FILE="${PROFILE_DIR}/${PROFILE_NAME}.md"

# 2. Analyze Global Instructions (CI Limit Report)
if [[ ! -f "$GLOBAL_FILE" ]]; then
    echo -e "${RED}ERROR:${NC} Global instructions not found at $GLOBAL_FILE" >&2
    exit 1
fi

GLOBAL_CHARS=$(wc -m < "$GLOBAL_FILE")
echo -e "${BLUE}🔍 Analyzing shared standards...${NC}"
if [ "$GLOBAL_CHARS" -gt 4000 ]; then
    echo -e "   ${RED}⚠️  CI LIMIT WARNING:${NC} Global instructions are $GLOBAL_CHARS characters."
    echo -e "   (Note: The CI workflow will block merges exceeding 4,000 characters)"
else
    echo -e "   ${GREEN}✅ Shared instructions:${NC} $GLOBAL_CHARS characters (CI Limit: 4,000)"
fi

# 3. Verify Profile
echo -e "${BLUE}👤 Merging profile:${NC} '$PROFILE_NAME'..."
if [[ ! -f "$PROFILE_FILE" ]]; then
    echo -e "${RED}❌ ERROR:${NC} Profile file not found: $PROFILE_FILE" >&2
    echo -e "   Use 'DerekRoberts' as a template for your own profile." >&2
    exit 1
fi

# 4. Bundle
mkdir -p "$(dirname "$OUTPUT_FILE")"

{
    cat "$GLOBAL_FILE"
    echo -e "\n"
    cat "$PROFILE_FILE"
} > "$OUTPUT_FILE"

# 5. Result Summary
TOTAL_CHARS=$(wc -m < "$OUTPUT_FILE")
echo -e "${GREEN}✨ Success:${NC} Personalized instructions bundled and written directly to global VS Code prompts path:"
echo -e "           $OUTPUT_FILE"

if [ "$TOTAL_CHARS" -gt 8000 ]; then
    echo -e "${YELLOW}⚠️  PERFORMANCE WARNING:${NC} Total size is $TOTAL_CHARS characters."
    echo -e "   Instructions > 8,000 characters may degrade Copilot's focus."
else
    echo -e "   Total size: $TOTAL_CHARS characters."
fi

# 6. Run detail metrics
if [[ -f "${SCRIPT_DIR}/metrics.sh" ]]; then
    echo ""
    bash "${SCRIPT_DIR}/metrics.sh" "$OUTPUT_FILE"
fi
