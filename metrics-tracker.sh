#!/bin/bash
# AI Instruction Complexity Analyzer
# Simple, focused analysis with actionable insights

set -euo pipefail

# Analysis thresholds
readonly WARNING_LINES=200
readonly EXCESSIVE_LINES=300
readonly WARNING_HEADERS=15
readonly EXCESSIVE_HEADERS=25

analyze_instructions() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi

    echo "📊 AI INSTRUCTION ANALYSIS: $file"
    echo "Generated: $(date)"
    echo ""

    # Get basic metrics
    local lines words headers
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    headers=$(grep -c '^##' "$file" 2>/dev/null || echo "0")

    # Display metrics
    echo "=== METRICS ==="
    echo "Lines: $lines"
    echo "Words: $words"
    echo "Sections: $headers"
    echo ""

    # Provide actionable insights
    echo "=== INSIGHTS ==="

    # Line count analysis
    if [[ "$lines" -gt "$EXCESSIVE_LINES" ]]; then
        echo "🚨 EXCESSIVE: $lines lines exceeds recommended limit of $EXCESSIVE_LINES"
        echo "   Consider breaking into smaller, focused instruction files"
    elif [[ "$lines" -gt "$WARNING_LINES" ]]; then
        echo "⚠️  WARNING: $lines lines approaching limit of $EXCESSIVE_LINES"
        echo "   Review for unnecessary content or consider reorganization"
    else
        echo "✅ GOOD: $lines lines is within recommended range"
    fi

    # Header analysis
    if [[ "$headers" -gt "$EXCESSIVE_HEADERS" ]]; then
        echo "🚨 EXCESSIVE: $headers sections may indicate over-organization"
        echo "   Consider consolidating related sections"
    elif [[ "$headers" -gt "$WARNING_HEADERS" ]]; then
        echo "⚠️  WARNING: $headers sections - review organization"
    else
        echo "✅ GOOD: $headers sections provides clear structure"
    fi

    # Decision complexity
    local decisions
    decisions=$(grep -c 'IF\|NEVER\|ALWAYS' "$file" 2>/dev/null || echo "0")
    # Clean up any newlines or extra output
    decisions=$(echo "$decisions" | tr -d '\n' | tr -d ' ')
    if [[ "$decisions" -gt 10 ]]; then
        echo "⚠️  WARNING: $decisions decision points may create rigid constraints"
        echo "   Consider if all rules are necessary"
    elif [[ "$decisions" -gt 0 ]]; then
        echo "✅ GOOD: $decisions decision points provide clear guidance"
    else
        echo "ℹ️  INFO: No hard decision points - flexible guidance"
    fi

    echo ""
    echo "=== RECOMMENDATIONS ==="

    if [[ "$lines" -gt "$WARNING_LINES" ]]; then
        echo "• Break large files into focused, topic-specific instructions"
        echo "• Remove outdated or redundant content"
        echo "• Consider if all sections are actively used"
    fi

    if [[ "$headers" -gt "$WARNING_HEADERS" ]]; then
        echo "• Consolidate related sections under broader categories"
        echo "• Use subsections (###) for detailed breakdowns"
        echo "• Ensure each section has clear, distinct purpose"
    fi

    if [[ "$decisions" -gt 5 ]]; then
        echo "• Review if all rules are still necessary"
        echo "• Consider converting rigid rules to flexible guidance"
        echo "• Focus on principles rather than specific constraints"
    fi

    echo ""
}

# Main execution
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <instruction-file>"
    echo "Example: $0 .github/copilot-upstream.md"
    exit 1
fi

analyze_instructions "$1"
