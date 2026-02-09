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
    local lines words headers must_rules never_rules unclear_rules
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    headers=$(grep -c '^##' "$file" 2>/dev/null || true)
    # MUST rules: Clear required practices
    must_rules=$(grep -c 'MUST\|ALWAYS' "$file" 2>/dev/null || true)
    # NEVER rules: Clear prohibited actions
    never_rules=$(grep -c 'NEVER' "$file" 2>/dev/null || true)
    # UNCLEAR rules: Ambiguous guidance that needs clarification
    unclear_rules=$(grep -c 'Should\|Consider\|Prefer\|Try' "$file" 2>/dev/null || true)

    # Ensure all counts are numeric (grep -c outputs 0 when no matches, but exits with code 1)
    headers=${headers:-0}
    must_rules=${must_rules:-0}
    never_rules=${never_rules:-0}
    unclear_rules=${unclear_rules:-0}

    # Guidelines for a comprehensive shared instructions file
    local lines_target_min=150 lines_target_max=350
    local sections_target_min=10 sections_target_max=30
    local must_rules_target_max=20
    local never_rules_target_max=10
    local unclear_rules_target_max=0

    # Display metrics with context in three columns
    echo "CURRENT:"
    printf "  %-18s %-15s %s\n" "Metric" "Target" "Value"
    printf "  %-18s %-15s %s\n" "------" "------" "-----"
    printf "  %-18s %-15s %s\n" "Lines" "$lines_target_min-$lines_target_max" "$lines"
    printf "  %-18s %-15s %s\n" "Words" "-" "$words"
    printf "  %-18s %-15s %s\n" "Sections" "$sections_target_min-$sections_target_max" "$headers"
    printf "  %-18s %-15s %s\n" "MUST rules" "<$must_rules_target_max" "$must_rules"
    printf "  %-18s %-15s %s\n" "NEVER rules" "<$never_rules_target_max" "$never_rules"
    printf "  %-18s %-15s %s\n" "UNCLEAR rules" "<=$unclear_rules_target_max" "$unclear_rules"
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
        echo "  ✅ MUST rules: Essential practices clearly required"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  MUST rules: Many required rules (ensure each is essential)"
    fi

    if [[ $never_rules -lt $never_rules_target_max ]]; then
        echo "  ✅ NEVER rules: Critical boundaries enforced"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  NEVER rules: Many prohibitions (clarify priorities)"
    fi

    if [[ $unclear_rules -le $unclear_rules_target_max ]]; then
        echo "  ✅ UNCLEAR rules: None found (guardrails are clear)"
        status_good=$((status_good + 1))
    else
        echo "  ⚠️  UNCLEAR rules: $unclear_rules found (reword for clarity: use MUST or NEVER)"
    fi

    echo ""
    if [[ $status_good -eq 5 ]]; then
        echo "📈 Overall: Clear, enforceable guardrails"
    elif [[ $status_good -ge 4 ]]; then
        echo "📈 Overall: Mostly clear guardrails with minor issues"
    else
        echo "📈 Overall: Review guideline wording for clarity"
    fi
    echo ""
}

# Main execution
readonly DEFAULT_INSTRUCTIONS=".github/copilot-instructions.md"

# Handle help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [file]"
    echo ""
    echo "Analyze copilot instructions for guardrails clarity."
    echo ""
    echo "Arguments:"
    echo "  file    Path to instructions file (default: $DEFAULT_INSTRUCTIONS)"
    echo ""
    echo "Examples:"
    echo "  $0                          # Analyze default file"
    echo "  $0 custom/instructions.md   # Analyze custom file"
    exit 0
fi

# Validate argument count
if [[ $# -gt 1 ]]; then
    echo "Error: Too many arguments. Expected 0 or 1, got $#" >&2
    echo "Run '$0 --help' for usage information." >&2
    exit 1
fi

local_file="${1:-$DEFAULT_INSTRUCTIONS}"

analyze_instructions "$local_file"
