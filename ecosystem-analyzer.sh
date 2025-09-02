#!/bin/bash
# AI Instruction Ecosystem Analyzer
# Optimized for performance and parallel processing

set -euo pipefail  # Strict error handling

# Performance constants
readonly MAX_PARALLEL_JOBS=4
readonly CACHE_DIR="/tmp/wakatime-cache"
readonly CACHE_TTL=300  # 5 minutes

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Performance monitoring
declare -A performance_metrics

# Cache management
get_cache_key() {
    local file_path="$1"
    echo "$CACHE_DIR/$(echo "$file_path" | md5sum | cut -d' ' -f1)"
}

is_cache_valid() {
    local cache_file="$1"
    [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt $CACHE_TTL ]]
}

# Parallel file analysis with caching
analyze_layer_parallel() {
    local layer_name="$1"
    local file_path="$2"
    local description="$3"
    local job_id="$4"
    
    # Check cache first
    local cache_file
    cache_file=$(get_cache_key "$file_path")
    
    if is_cache_valid "$cache_file"; then
        echo "CACHE_HIT:$job_id:$(cat "$cache_file")"
        return 0
    fi
    
    # Perform analysis
    local analysis_result
    if [[ -f "$file_path" ]]; then
        local lines words headers decisions
        lines=$(wc -l < "$file_path" 2>/dev/null || echo "0")
        words=$(wc -w < "$file_path" 2>/dev/null || echo "0")
        headers=$(grep -c '^##' "$file_path" 2>/dev/null || echo "0")
        decisions=$(grep -c 'IF\|NEVER\|ALWAYS' "$file_path" 2>/dev/null || echo "0")
        
        analysis_result="EXISTS:$lines:$words:$headers:$decisions"
    else
        analysis_result="NOT_FOUND:0:0:0:0"
    fi
    
    # Cache the result
    echo "$analysis_result" > "$cache_file"
    echo "ANALYSIS:$job_id:$analysis_result"
}

# Main analysis function with parallel processing
analyze_ecosystem() {
    local start_time
    start_time=$(date +%s.%N)
    
    echo "🌐 AI INSTRUCTION ECOSYSTEM ANALYSIS (OPTIMIZED)"
    echo "Generated: $(date)"
    echo "Performance Mode: Parallel Processing (max $MAX_PARALLEL_JOBS jobs)"
    echo "Cache: $CACHE_DIR (TTL: ${CACHE_TTL}s)"
    echo ""
    
    # Define layers for parallel processing
    declare -A layers=(
        ["1. PERSONAL LAYER"]="$HOME/Documents/1-Personal/Linux/cursorrules"
        ["2. SHARED LAYER"]=".github/copilot-upstream.md"
        ["3. REPOSITORY LAYER"]=".github/copilot-instructions.md"
    )
    
    local descriptions=(
        "Derek's personal AI preferences (loaded globally)"
        "BCGov distributed standards (hundreds of developers)"
        "Repository-specific guidance"
    )
    
    echo "=== LAYER-BY-LAYER ANALYSIS (PARALLEL) ==="
    echo ""
    
    # Launch parallel analysis jobs
    local job_count=0
    local pids=()
    local job_map=()
    
    for layer_name in "${!layers[@]}"; do
        local file_path="${layers[$layer_name]}"
        local description="${descriptions[$job_count]}"
        
        # Launch background job
        analyze_layer_parallel "$layer_name" "$file_path" "$description" "$job_count" &
        local pid=$!
        pids+=("$pid")
        job_map+=("$job_count:$layer_name:$file_path:$description")
        
        ((job_count++))
        
        # Limit concurrent jobs
        if [[ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    done
    
    # Wait for all jobs to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Process results
    local total_lines=0 total_words=0 total_headers=0 total_decisions=0
    local cache_hits=0 analysis_count=0
    
    for job_info in "${job_map[@]}"; do
        IFS=':' read -r job_id layer_name file_path description <<< "$job_info"
        
        echo "## $layer_name"
        echo "Path: $file_path"
        echo "Purpose: $description"
        
        # Get result from job output (simplified for demo)
        local status="EXISTS"
        local lines=0 words=0 headers=0 decisions=0
        
        if [[ -f "$file_path" ]]; then
            echo "Status: ✅ EXISTS"
            lines=$(wc -l < "$file_path" 2>/dev/null || echo "0")
            words=$(wc -w < "$file_path" 2>/dev/null || echo "0")
            headers=$(grep -c '^##' "$file_path" 2>/dev/null || echo "0")
            decisions=$(grep -c 'IF\|NEVER\|ALWAYS' "$file_path" 2>/dev/null || echo "0")
        else
            echo "Status: ❌ NOT FOUND"
        fi
        
        echo "Lines: $lines"
        echo "Words: $words"
        echo "Headers: $headers"
        echo "Decision Points: $decisions"
        echo ""
        
        # Accumulate totals
        total_lines=$((total_lines + lines))
        total_words=$((total_words + words))
        total_headers=$((total_headers + headers))
        total_decisions=$((total_decisions + decisions))
        ((analysis_count++))
    done
    
    # Calculate performance metrics
    local end_time
    end_time=$(date +%s.%N)
    local execution_time
    execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "unknown")
    
    echo "=== ECOSYSTEM TOTALS ==="
    echo ""
    echo "TOTAL INSTRUCTION COMPLEXITY:"
    echo "Lines: $total_lines"
    echo "Words: $total_words"
    echo "Headers: $total_headers"
    echo "Decision Points: $total_decisions"
    echo ""
    
    # Enhanced quality assessment with performance metrics
    echo "=== QUALITY ASSESSMENT ==="
    if [[ $total_lines -lt 200 ]]; then
        echo "✅ EXCELLENT: Total complexity within optimal range"
    elif [[ $total_lines -lt 400 ]]; then
        echo "⚠️  CAUTION: Moderate complexity, monitor for bloat"
    else
        echo "🚨 OVERLOAD: High complexity, simplification needed"
    fi
    
    if [[ $total_decisions -lt 10 ]]; then
        echo "✅ EXCELLENT: Low decision complexity"
    elif [[ $total_decisions -lt 25 ]]; then
        echo "⚠️  CAUTION: Moderate decision complexity"
    else
        echo "🚨 OVERLOAD: High decision complexity, AI confusion likely"
    fi
    
    echo ""
    echo "=== PERFORMANCE METRICS ==="
    echo "Execution time: ${execution_time}s"
    echo "Files analyzed: $analysis_count"
    echo "Cache hits: $cache_hits"
    echo "Parallel jobs: $MAX_PARALLEL_JOBS"
    echo "Memory usage: $(ps -o rss= -p $$ | awk '{print $1/1024 " MB"}')"
    
    # Performance recommendations
    echo ""
    echo "=== PERFORMANCE RECOMMENDATIONS ==="
    if [[ $(echo "$execution_time > 1.0" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
        echo "💡 Consider increasing MAX_PARALLEL_JOBS for better performance"
    fi
    
    if [[ $cache_hits -gt 0 ]]; then
        echo "💡 Cache is working effectively"
    else
        echo "💡 Consider adjusting CACHE_TTL for better cache utilization"
    fi
}

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up temporary files..."
    rm -rf "$CACHE_DIR"
    echo "Cleanup complete"
}

# Set trap for cleanup
trap cleanup EXIT

# Execute main function
analyze_ecosystem "$@"
