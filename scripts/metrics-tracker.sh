#!/bin/bash
# Metrics Tracker - Analyze copilot-instructions.md complexity
# Reports basic metrics: lines, words, sections

set -euo pipefail

analyze_instructions() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi

    echo "📊 METRICS: $file"
    echo "Generated: $(date)"
    echo ""

    # Get basic metrics
    local lines words headers decisions
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    headers=$(grep -c '^##' "$file" 2>/dev/null || echo "0")
    decisions=$(grep -c 'IF\|NEVER\|ALWAYS' "$file" 2>/dev/null || echo "0")

    # Display metrics
    echo "Lines:                 $lines"
    echo "Words:                 $words"
    echo "Sections (##):         $headers"
    echo "Decision points:       $decisions"
    echo ""
}

# Main execution
readonly DEFAULT_INSTRUCTIONS=".github/copilot-instructions.md"
local_file="${1:-$DEFAULT_INSTRUCTIONS}"

analyze_instructions "$local_file"
