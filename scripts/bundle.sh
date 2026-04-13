#!/bin/bash
# Bundle Copilot Instructions
# Merges global standards with a personalized developer profile
#
# Usage: ./scripts/bundle.sh [profile_name] [output_file]
#
# Arguments:
#   profile_name   Profile in .github/profiles/ (default: $USER or developer-profile)
#   output_file    Destination path (default: ~/.copilot.md)
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

# Default arguments
PROFILE_NAME="${1:-${USER:-developer-profile}}"
OUTPUT_FILE="${2:-${HOME}/.copilot.md}"

# Paths
GLOBAL_FILE="${REPO_ROOT}/.github/copilot-instructions.md"
PROFILE_DIR="${REPO_ROOT}/.github/profiles"
PROFILE_FILE="${PROFILE_DIR}/${PROFILE_NAME}.md"

# 1. Validate Global Instructions (GitHub Org Limit)
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

# 2. Verify Profile
echo -e "${BLUE}👤 Merging profile:${NC} '$PROFILE_NAME'..."
if [[ ! -f "$PROFILE_FILE" ]]; then
    echo -e "${RED}❌ ERROR:${NC} Profile file not found: $PROFILE_FILE" >&2
    echo -e "   Please create your profile in .github/profiles/ or use 'developer-profile'." >&2
    exit 1
fi

# 3. Bundle
mkdir -p "$(dirname "$OUTPUT_FILE")"

{
    cat "$GLOBAL_FILE"
    echo -e "\n"
    if [[ -f "$PROFILE_FILE" ]]; then
        cat "$PROFILE_FILE"
    else
        echo -e "${RED}ERROR:${NC} Default profile template missing at $PROFILE_FILE" >&2
        exit 1
    fi
} > "$OUTPUT_FILE"

# 4. Final Metrics
TOTAL_CHARS=$(wc -m < "$OUTPUT_FILE")
echo -e "${GREEN}✨ Success:${NC} Personalized instructions bundled to $OUTPUT_FILE"

if [ "$TOTAL_CHARS" -gt 8000 ]; then
    echo -e "${YELLOW}⚠️  PERFORMANCE WARNING:${NC} Total size is $TOTAL_CHARS characters."
    echo -e "   Instructions > 8,000 characters may degrade Copilot's focus."
else
    echo -e "   Total size: $TOTAL_CHARS characters."
fi

# 5. Run detail metrics
if [[ -f "${SCRIPT_DIR}/metrics.sh" ]]; then
    echo ""
    bash "${SCRIPT_DIR}/metrics.sh" "$OUTPUT_FILE"
fi
