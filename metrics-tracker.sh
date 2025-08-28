#!/bin/bash
# AI Instruction Complexity Metrics Tracker

analyze_file() {
    local file="$1"
    echo "=== $file ==="
    echo "Lines: $(wc -l < "$file")"
    echo "Words: $(wc -w < "$file")"
    echo "Characters: $(wc -c < "$file")"
    echo "Headers (sections): $(grep -c '^##' "$file")"
    local code_block_ticks
    code_block_ticks=$(grep -c '```' "$file")
    if (( code_block_ticks % 2 == 0 )); then
        echo "Code blocks: $((code_block_ticks / 2))"
    else
        echo "Code blocks: $((code_block_ticks / 2)) (Warning: Odd number of triple backticks, possible unclosed code block)"
    fi
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
        lines1=$(wc -l < "$file1")
        lines2=$(wc -l < "$file2")
        words1=$(wc -w < "$file1")
        words2=$(wc -w < "$file2")
        headers1=$(grep -c '^##' "$file1")
        headers2=$(grep -c '^##' "$file2")
        decisions1=$(grep -c 'IF\|NEVER\|ALWAYS' "$file1")
        decisions2=$(grep -c 'IF\|NEVER\|ALWAYS' "$file2")
        
        if [ "$lines1" -eq 0 ]; then
            echo "Lines: N/A (file1 has zero lines)"
        else
            echo "Lines: $(echo "scale=1; ($lines1 - $lines2) / $lines1 * 100" | bc)%"
        fi
        if [ "$words1" -eq 0 ]; then
            echo "Words: N/A (file1 has zero words)"
        else
            echo "Words: $(echo "scale=1; ($words1 - $words2) / $words1 * 100" | bc)%"
        fi
        if [ "$headers1" -eq 0 ]; then
            echo "Headers: N/A (file1 has zero headers)"
        else
            echo "Headers: $(echo "scale=1; ($headers1 - $headers2) / $headers1 * 100" | bc)%"
        fi
        if [ "$decisions1" -eq 0 ]; then
            echo "Decision Points: N/A (file1 has zero decision points)"
        else
            echo "Decision Points: $(echo "scale=1; ($decisions1 - $decisions2) / $decisions1 * 100" | bc)%"
        fi
    fi
fi
