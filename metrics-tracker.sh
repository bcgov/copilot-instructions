#!/bin/bash
# AI Instruction Complexity Metrics Tracker

analyze_file() {
    local file="$1"
    echo "=== $file ==="
    echo "Lines: $(wc -l < "$file")"
    echo "Words: $(wc -w < "$file")"
    echo "Characters: $(wc -c < "$file")"
    echo "Headers (sections): $(grep -c '^##' "$file")"
    echo "Code blocks: $(grep -c '```' "$file" | awk '{print $1/2}')"
    echo "Decision points (IF/NEVER/ALWAYS): $(grep -c 'IF\|NEVER\|ALWAYS' "$file")"
    echo "Workflow patterns: $(grep -c 'Pattern\|Sequence\|Template' "$file")"
    echo ""
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file1> [file2] [file3]..."
    exit 1
fi

echo "📏 AI INSTRUCTION COMPLEXITY METRICS"
echo "Generated: $(date)"
echo ""

for file in "$@"; do
    if [ -f "$file" ]; then
        analyze_file "$file"
    else
        echo "File not found: $file"
    fi
done

# If comparing two files, show reduction percentages
if [ $# -eq 2 ]; then
    file1="$1"
    file2="$2"
    if [ -f "$file1" ] && [ -f "$file2" ]; then
        echo "=== REDUCTION ANALYSIS ($file1 → $file2) ==="
        echo "Lines: $(echo "scale=1; ($(wc -l < "$file1") - $(wc -l < "$file2")) / $(wc -l < "$file1") * 100" | bc)%"
        echo "Words: $(echo "scale=1; ($(wc -w < "$file1") - $(wc -w < "$file2")) / $(wc -w < "$file1") * 100" | bc)%"
        echo "Headers: $(echo "scale=1; ($(grep -c '^##' "$file1") - $(grep -c '^##' "$file2")) / $(grep -c '^##' "$file1") * 100" | bc)%"
        echo "Decision Points: $(echo "scale=1; ($(grep -c 'IF\|NEVER\|ALWAYS' "$file1") - $(grep -c 'IF\|NEVER\|ALWAYS' "$file2")) / $(grep -c 'IF\|NEVER\|ALWAYS' "$file1") * 100" | bc)%"
    fi
fi
