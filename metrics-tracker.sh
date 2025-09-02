#!/bin/bash
# AI Instruction Complexity Metrics Tracker
# Optimized for performance and efficiency

set -euo pipefail  # Strict error handling

# Performance optimization: Cache grep patterns
readonly DECISION_PATTERN='IF|NEVER|ALWAYS'
readonly WORKFLOW_PATTERN='Pattern|Sequence|Template'
readonly HEADER_PATTERN='^##'

# Cache for file analysis to avoid repeated processing
declare -A file_cache

analyze_file() {
    local file="$1"
    
    # Check cache first for performance
    if [[ -n "${file_cache[$file]:-}" ]]; then
        echo "${file_cache[$file]}"
        return 0
    fi
    
    # Validate file exists and is readable
    if [[ ! -r "$file" ]]; then
        echo "❌ ERROR: Cannot read file: $file"
        return 1
    fi
    
    # Use efficient single-pass processing
    local analysis_output
    analysis_output=$(cat <<EOF
=== $file ===
Lines: $(wc -l < "$file")
Words: $(wc -w < "$file")
Characters: $(wc -c < "$file")
Headers (sections): $(grep -c "$HEADER_PATTERN" "$file" 2>/dev/null || echo "0")
Code blocks: $(awk '/```/{count++} END{print int(count/2)}' "$file" 2>/dev/null || echo "0")
Decision points (IF/NEVER/ALWAYS): $(grep -c "$DECISION_PATTERN" "$file" 2>/dev/null || echo "0")
Workflow patterns: $(grep -c "$WORKFLOW_PATTERN" "$file" 2>/dev/null || echo "0")

EOF
)
    
    # Cache the result
    file_cache[$file]="$analysis_output"
    echo "$analysis_output"
}

# Optimized reduction calculation using awk for better performance
calculate_reduction() {
    local file1="$1"
    local file2="$2"
    
    if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
        echo "❌ ERROR: One or both files not found"
        return 1
    fi
    
    echo "=== REDUCTION ANALYSIS ($file1 → $file2) ==="
    
    # Single-pass analysis using awk for efficiency
    awk -v file1="$file1" -v file2="$file2" '
    BEGIN {
        # Process file1
        cmd1 = "wc -l < \"" file1 "\""
        cmd1 | getline lines1
        close(cmd1)
        
        cmd1 = "wc -w < \"" file1 "\""
        cmd1 | getline words1
        close(cmd1)
        
        cmd1 = "grep -c \"^##\" \"" file1 "\" 2>/dev/null || echo 0"
        cmd1 | getline headers1
        close(cmd1)
        
        cmd1 = "grep -c \"IF|NEVER|ALWAYS\" \"" file1 "\" 2>/dev/null || echo 0"
        cmd1 | getline decisions1
        close(cmd1)
        
        # Process file2
        cmd2 = "wc -l < \"" file2 "\""
        cmd2 | getline lines2
        close(cmd2)
        
        cmd2 = "wc -w < \"" file2 "\""
        cmd2 | getline words2
        close(cmd2)
        
        cmd2 = "grep -c \"^##\" \"" file2 "\" 2>/dev/null || echo 0"
        cmd2 | getline headers2
        close(cmd2)
        
        cmd2 = "grep -c \"IF|NEVER|ALWAYS\" \"" file2 "\" 2>/dev/null || echo 0"
        cmd2 | getline decisions2
        close(cmd2)
        
        # Calculate reductions
        if (lines1 > 0) printf "Lines: %.1f%%\n", (lines1 - lines2) / lines1 * 100
        else print "Lines: N/A (file1 has zero lines)"
        
        if (words1 > 0) printf "Words: %.1f%%\n", (words1 - words2) / words1 * 100
        else print "Words: N/A (file1 has zero words)"
        
        if (headers1 > 0) printf "Headers: %.1f%%\n", (headers1 - headers2) / headers1 * 100
        else print "Headers: N/A (file1 has zero headers)"
        
        if (decisions1 > 0) printf "Decision Points: %.1f%%\n", (decisions1 - decisions2) / decisions1 * 100
        else print "Decision Points: N/A (file1 has zero decision points)"
    }'
}

# Main execution with performance monitoring
main() {
    local start_time
    start_time=$(date +%s.%N)
    
    echo "📏 AI INSTRUCTION COMPLEXITY METRICS (OPTIMIZED)"
    echo "Generated: $(date)"
    echo "Performance Mode: Enabled"
    echo ""
    
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <file1> [file2] [file3]..."
        echo "Performance: Use multiple files for batch processing efficiency"
        exit 1
    fi
    
    # Batch process files for better performance
    local processed_files=0
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            analyze_file "$file"
            ((processed_files++))
        else
            echo "❌ File not found: $file"
        fi
    done
    
    # Show reduction analysis if exactly two files
    if [[ $# -eq 2 ]]; then
        echo ""
        calculate_reduction "$1" "$2"
    fi
    
    # Performance summary
    local end_time
    end_time=$(date +%s.%N)
    local execution_time
    execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "unknown")
    
    echo ""
    echo "=== PERFORMANCE SUMMARY ==="
    echo "Files processed: $processed_files"
    echo "Cache hits: ${#file_cache[@]}"
    echo "Execution time: ${execution_time}s"
    echo "Memory usage: $(ps -o rss= -p $$ | awk '{print $1/1024 " MB"}')"
}

# Execute main function
main "$@"
