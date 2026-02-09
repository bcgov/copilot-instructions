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
    local lines words headers must_rules never_rules flexible_rules
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    headers=$(grep -c '^##' "$file" 2>/dev/null || echo "0")
    # MUST rules: Required practices
    must_rules=$(grep -c 'MUST\|ALWAYS' "$file" 2>/dev/null || echo "0")
    # NEVER rules: Prohibited actions
    never_rules=$(grep -c 'NEVER' "$file" 2>/dev/null || echo "0")
    # Flexible guidance: Principle-based guidance with flexibility
    flexible_rules=$(grep -c 'Should\|Consider\|Prefer\|Recommend\|Avoid' "$file" 2>/dev/null || echo "0")

    # Guidelines for a comprehensive shared instructions file
    local lines_target_min=150 lines_target_max=350
    local sections_target_min=10 sections_target_max=30
    local must_rules_target_max=20
    local never_rules_target_max=10
    local flexible_rules_target_min=10

    # Display metrics with context in three columns
    echo "CURRENT:"
    printf "  %-18s %-15s %s\n" "Metric" "Target" "Value"
    printf "  %-18s %-15s %s\n" "------" "------" "-----"
    printf "  %-18s %-15s %s\n" "Lines" "$lines_target_min-$lines_target_max" "$lines"
    printf "  %-18s %-15s %s\n" "Words" "-" "$words"
    printf "  %-18s %-15s %s\n" "Sections" "$sections_target_min-$sections_target_max" "$headers"
    printf "  %-18s %-15s %s\n" "MUST rules" "<$must_rules_target_max" "$must_rules"
    printf "  %-18s %-15s %s\n" "Flexible guidance" ">$flexible_rules_target_min" "$flexible_rules"
    printf "  %-18s %-15s %s\n" "NEVER rules" "<$never_rules_target_max" "$never_rules"
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

    if [[ $must_rules -lt $must_rules_target_max ]]; then
        echo "  ✅ MUST rules: Well-balanced required practices"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  MUST rules: Many required rules (consider reducing)"
    fi

    if [[ $flexible_rules -ge $flexible_rules_target_min ]]; then
        echo "  ✅ Flexible guidance: Principle-based and adaptable"
        status_good=$((status_good + 1))
    else
        echo "  ℹ️  Flexible guidance: Could include more principle-based guidance"
    fi

    if [[ $never_rules -lt $never_rules_target_max ]]; then
        echo "  ✅ NEVER rules: Few hard prohibitions (flexible guidance)"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  NEVER rules: Many hard rules (limited flexibility)"
    fi

    echo ""
    if [[ $status_good -eq 5 ]]; then
        echo "📈 Overall: Healthy file structure"
    elif [[ $status_good -ge 4 ]]; then
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
