#!/bin/bash
# Metrics Tracker - Analyze copilot-instructions.md complexity
# Reports metrics with context and guidelines

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

    # Guidelines for a comprehensive shared instructions file
    local lines_target_min=150 lines_target_max=350
    local sections_target_min=10 sections_target_max=30
    local decisions_target_max=15

    # Display metrics with context in three columns
    echo "CURRENT:"
    printf "  %-18s %-15s %s\n" "Metric" "Target" "Value"
    printf "  %-18s %-15s %s\n" "------" "------" "-----"
    printf "  %-18s %-15s %s\n" "Lines" "$lines_target_min-$lines_target_max" "$lines"
    printf "  %-18s %-15s %s\n" "Words" "-" "$words"
    printf "  %-18s %-15s %s\n" "Sections" "$sections_target_min-$sections_target_max" "$headers"
    printf "  %-18s %-15s %s\n" "Decision points" "<$decisions_target_max" "$decisions"
    echo ""

    # Assessment
    echo "ASSESSMENT:"
    local status_good=0
    
    if [[ $lines -ge $lines_target_min && $lines -le $lines_target_max ]]; then
        echo "  ✅ Lines: Within healthy range"
        status_good=$((status_good + 1))
    elif [[ $lines -lt $lines_target_min ]]; then
        echo "  ℹ️  Lines: Below target (more detail may be needed)"
    else
        echo "  ⚠️  Lines: Above target (consider breaking into narrower focus)"
    fi

    if [[ $headers -ge $sections_target_min && $headers -le $sections_target_max ]]; then
        echo "  ✅ Sections: Well-organized"
        status_good=$((status_good + 1))
    elif [[ $headers -lt $sections_target_min ]]; then
        echo "  ℹ️  Sections: Few sections (may need better organization)"
    else
        echo "  ⚠️  Sections: Many sections (consider consolidation or splitting)"
    fi

    if [[ $decisions -lt $decisions_target_max ]]; then
        echo "  ✅ Decision points: Flexible guidance (not overly rigid)"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  Decision points: Many hard rules (consider softening to principles)"
    fi

    echo ""
    if [[ $status_good -eq 3 ]]; then
        echo "📈 Overall: Healthy file structure"
    elif [[ $status_good -eq 2 ]]; then
        echo "📈 Overall: Good structure with room for improvement"
    else
        echo "📈 Overall: Review metric(s) above for potential improvements"
    fi
    echo ""
}

# Main execution
readonly DEFAULT_INSTRUCTIONS=".github/copilot-instructions.md"
local_file="${1:-$DEFAULT_INSTRUCTIONS}"

analyze_instructions "$local_file"
