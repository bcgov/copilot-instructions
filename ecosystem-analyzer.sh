#!/bin/bash
# AI Instruction Ecosystem Analyzer
# Measures complexity across ALL instruction layers

echo "🌐 AI INSTRUCTION ECOSYSTEM ANALYSIS"
echo "Generated: $(date)"
echo ""

# Function to safely analyze a file if it exists
analyze_layer() {
    local layer_name="$1"
    local file_path="$2"
    local description="$3"

    echo "## $layer_name"
    echo "Path: $file_path"
    echo "Purpose: $description"

    if [ -f "$file_path" ]; then
        echo "Status: ✅ EXISTS"
        lines=$(wc -l < "$file_path")
        words=$(wc -w < "$file_path")
        headers=$(grep -c '^##' "$file_path" 2>/dev/null || echo "0")
        decisions=$(grep -c 'IF\|NEVER\|ALWAYS' "$file_path" 2>/dev/null || echo "0")
        echo "Lines: $lines"
        echo "Words: $words"
        echo "Headers: $headers"
        echo "Decision Points: $decisions"
    else
        echo "Status: ❌ NOT FOUND"
        lines=0
        words=0
        headers=0
        decisions=0
    fi
    echo ""

    # Return values for totaling
    echo "$lines $words $headers $decisions"
}

echo "=== LAYER-BY-LAYER ANALYSIS ==="
echo ""

# Layer 1: Personal (Derek's cursor rules)
personal_stats=$(analyze_layer "1. PERSONAL LAYER" "$HOME/Documents/1-Personal/Linux/cursorrules" "Derek's personal AI preferences (loaded globally)")

# Layer 2: Shared (BCGov standards)
shared_stats=$(analyze_layer "2. SHARED LAYER" ".github/copilot-upstream.md" "BCGov distributed standards (hundreds of developers)")

# Layer 3: Repository-specific (this repo)
repo_stats=$(analyze_layer "3. REPOSITORY LAYER" ".github/copilot-instructions.md" "Repository-specific guidance")

# Layer 4: Mystery AI folder
mystery_stats=$(analyze_layer "4. MYSTERY LAYER" "$HOME/Documents/AI" "Unknown purpose folder")

echo "=== ECOSYSTEM TOTALS ==="
echo ""

# Calculate totals (this is complex in bash, but doable)
total_lines=0
total_words=0
total_headers=0
total_decisions=0

for stats in "$personal_stats" "$shared_stats" "$repo_stats" "$mystery_stats"; do
    if [ -n "$stats" ]; then
        read lines words headers decisions <<< "$stats"
        total_lines=$((total_lines + lines))
        total_words=$((total_words + words))
        total_headers=$((total_headers + headers))
        total_decisions=$((total_decisions + decisions))
    fi
done

echo "TOTAL INSTRUCTION COMPLEXITY:"
echo "Lines: $total_lines"
echo "Words: $total_words"
echo "Headers: $total_headers"
echo "Decision Points: $total_decisions"
echo ""

# Quality assessment
echo "=== QUALITY ASSESSMENT ==="
if [ $total_lines -lt 200 ]; then
    echo "✅ EXCELLENT: Total complexity within optimal range"
elif [ $total_lines -lt 400 ]; then
    echo "⚠️  CAUTION: Moderate complexity, monitor for bloat"
else
    echo "🚨 OVERLOAD: High complexity, simplification needed"
fi

if [ $total_decisions -lt 10 ]; then
    echo "✅ EXCELLENT: Low decision complexity"
elif [ $total_decisions -lt 25 ]; then
    echo "⚠️  CAUTION: Moderate decision complexity"
else
    echo "🚨 OVERLOAD: High decision complexity, AI confusion likely"
fi

echo ""
echo "=== MYSTERY FOLDER ANALYSIS ==="
if [ -d "$HOME/Documents/AI" ]; then
    echo "📁 ~/Documents/AI folder contents:"
    find "$HOME/Documents/AI" -name "*.md" 2>/dev/null | head -10
    echo ""
    echo "Total .md files: $(find "$HOME/Documents/AI" -name "*.md" 2>/dev/null | wc -l)"
    echo "Total files: $(find "$HOME/Documents/AI" -type f 2>/dev/null | wc -l)"
else
    echo "❓ ~/Documents/AI folder not found or not accessible"
fi
