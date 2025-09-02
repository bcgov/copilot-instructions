#!/bin/bash
# Performance Monitor for AI Instruction Scripts
# Tracks system resources, execution times, and optimization opportunities

set -euo pipefail

# Configuration
readonly MONITOR_INTERVAL=1  # seconds
readonly LOG_FILE="/tmp/performance-monitor.log"
readonly ALERT_THRESHOLD_CPU=80  # percentage
readonly ALERT_THRESHOLD_MEMORY=85  # percentage

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Performance tracking
declare -A script_performance
declare -A resource_usage

# Initialize logging
init_logging() {
    echo "=== PERFORMANCE MONITOR STARTED $(date) ===" > "$LOG_FILE"
    echo "Monitoring interval: ${MONITOR_INTERVAL}s" >> "$LOG_FILE"
    echo "Alert thresholds - CPU: ${ALERT_THRESHOLD_CPU}%, Memory: ${ALERT_THRESHOLD_MEMORY}%" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# Get system metrics efficiently
get_system_metrics() {
    # CPU usage (avoiding top for better performance)
    local cpu_usage
    cpu_usage=$(awk '{u=$2+$4; t=$2+$3+$4; if (NR==1){u1=u; t1=t;} else {printf "%.1f", ($2+$4-u1)*100/(t-t1);}}' <(grep '^cpu ' /proc/stat) <(sleep 1;grep '^cpu ' /proc/stat))
    
    # Memory usage
    local mem_info
    mem_info=$(free | grep Mem)
    local mem_total mem_used mem_available
    read mem_total mem_used mem_available <<< "$mem_info"
    local mem_percent
    mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc -l 2>/dev/null || echo "0")
    
    # Disk I/O
    local disk_io
    disk_io=$(iostat -d 1 1 | tail -n +4 | awk '{sum+=$2+$3} END {print sum}')
    
    # Network activity
    local net_rx net_tx
    net_rx=$(cat /proc/net/dev | grep -E '^(eth|en|wlan)' | awk '{sum+=$2} END {print sum}')
    net_tx=$(cat /proc/net/dev | grep -E '^(eth|en|wlan)' | awk '{sum+=$10} END {print sum}')
    
    echo "$cpu_usage:$mem_percent:$disk_io:$net_rx:$net_tx"
}

# Monitor script execution
monitor_script() {
    local script_name="$1"
    local start_time
    start_time=$(date +%s.%N)
    
    echo -e "${BLUE}🚀 Starting: $script_name${NC}"
    
    # Execute script with monitoring
    local output
    output=$(eval "$script_name" 2>&1)
    local exit_code=$?
    
    local end_time
    end_time=$(date +%s.%N)
    local execution_time
    execution_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "unknown")
    
    # Record performance
    script_performance["$script_name"]="$execution_time"
    
    echo -e "${GREEN}✅ Completed: $script_name (${execution_time}s)${NC}"
    
    # Log performance data
    echo "$(date): SCRIPT_EXECUTION: $script_name - ${execution_time}s - Exit: $exit_code" >> "$LOG_FILE"
    
    return $exit_code
}

# Resource monitoring loop
monitor_resources() {
    echo -e "${BLUE}📊 Starting resource monitoring...${NC}"
    echo "Press Ctrl+C to stop monitoring"
    
    local iteration=0
    while true; do
        ((iteration++))
        
        # Get current metrics
        local metrics
        metrics=$(get_system_metrics)
        IFS=':' read -r cpu mem disk net_rx net_tx <<< "$metrics"
        
        # Store for trending
        resource_usage["$iteration"]="$cpu:$mem:$disk:$net_rx:$net_tx"
        
        # Display current status
        echo -e "\n${BLUE}=== ITERATION $iteration $(date) ===${NC}"
        echo -e "CPU: ${cpu}% ${cpu%.* -gt $ALERT_THRESHOLD_CPU && echo -e "${RED}⚠️  HIGH${NC}" || echo -e "${GREEN}✅ OK${NC}"}"
        echo -e "Memory: ${mem}% ${mem%.* -gt $ALERT_THRESHOLD_MEMORY && echo -e "${RED}⚠️  HIGH${NC}" || echo -e "${GREEN}✅ OK${NC}"}"
        echo -e "Disk I/O: ${disk} ops/s"
        echo -e "Network: RX ${net_rx} bytes, TX ${net_tx} bytes"
        
        # Check for alerts
        if [[ $(echo "$cpu > $ALERT_THRESHOLD_CPU" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
            echo -e "${RED}🚨 ALERT: High CPU usage detected!${NC}"
            echo "$(date): ALERT: High CPU usage - ${cpu}%" >> "$LOG_FILE"
        fi
        
        if [[ $(echo "$mem > $ALERT_THRESHOLD_MEMORY" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
            echo -e "${RED}🚨 ALERT: High memory usage detected!${NC}"
            echo "$(date): ALERT: High memory usage - ${mem}%" >> "$LOG_FILE"
        fi
        
        # Log metrics
        echo "$(date): METRICS: CPU:${cpu}% MEM:${mem}% DISK:${disk} NET_RX:${net_rx} NET_TX:${net_tx}" >> "$LOG_FILE"
        
        sleep "$MONITOR_INTERVAL"
    done
}

# Performance analysis and recommendations
analyze_performance() {
    echo -e "\n${BLUE}📈 PERFORMANCE ANALYSIS${NC}"
    echo "================================"
    
    # Script performance summary
    if [[ ${#script_performance[@]} -gt 0 ]]; then
        echo -e "\n${GREEN}Script Performance:${NC}"
        for script in "${!script_performance[@]}"; do
            echo "  $script: ${script_performance[$script]}s"
        done
        
        # Find fastest and slowest
        local fastest_script slowest_script fastest_time slowest_time
        fastest_time=999999
        slowest_time=0
        
        for script in "${!script_performance[@]}"; do
            local time="${script_performance[$script]}"
            if [[ $(echo "$time < $fastest_time" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
                fastest_time="$time"
                fastest_script="$script"
            fi
            if [[ $(echo "$time > $slowest_time" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
                slowest_time="$time"
                slowest_script="$script"
            fi
        done
        
        echo -e "\n🏆 Fastest: $fastest_script (${fastest_time}s)"
        echo -e "🐌 Slowest: $slowest_script (${slowest_time}s)"
    fi
    
    # Resource usage trends
    if [[ ${#resource_usage[@]} -gt 1 ]]; then
        echo -e "\n${GREEN}Resource Usage Trends:${NC}"
        
        # Calculate averages
        local total_cpu=0 total_mem=0 count=0
        for iteration in "${!resource_usage[@]}"; do
            local metrics="${resource_usage[$iteration]}"
            IFS=':' read -r cpu mem <<< "$metrics"
            total_cpu=$(echo "$total_cpu + $cpu" | bc -l 2>/dev/null || echo "$total_cpu")
            total_mem=$(echo "$total_mem + $mem" | bc -l 2>/dev/null || echo "$total_mem")
            ((count++))
        done
        
        local avg_cpu avg_mem
        avg_cpu=$(echo "scale=1; $total_cpu / $count" | bc -l 2>/dev/null || echo "0")
        avg_mem=$(echo "scale=1; $total_mem / $count" | bc -l 2>/dev/null || echo "0")
        
        echo "  Average CPU: ${avg_cpu}%"
        echo "  Average Memory: ${avg_mem}%"
        echo "  Samples collected: $count"
    fi
    
    # Optimization recommendations
    echo -e "\n${GREEN}Optimization Recommendations:${NC}"
    if [[ ${#script_performance[@]} -gt 1 ]]; then
        echo "  💡 Consider parallelizing slow scripts"
        echo "  💡 Implement caching for repeated operations"
    fi
    
    if [[ $(echo "$avg_cpu > 70" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
        echo "  💡 High CPU usage - consider reducing concurrent processes"
    fi
    
    if [[ $(echo "$avg_mem > 80" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
        echo "  💡 High memory usage - consider optimizing data structures"
    fi
}

# Main function
main() {
    echo -e "${BLUE}🚀 PERFORMANCE MONITOR FOR AI INSTRUCTION SCRIPTS${NC}"
    echo "=================================================="
    
    # Initialize
    init_logging
    
    # Parse command line arguments
    case "${1:-}" in
        "monitor")
            monitor_resources
            ;;
        "analyze")
            analyze_performance
            ;;
        "test")
            echo -e "${GREEN}🧪 Running performance tests...${NC}"
            monitor_script "./metrics-tracker.sh metrics-tracker.sh"
            monitor_script "./ecosystem-analyzer.sh"
            analyze_performance
            ;;
        *)
            echo "Usage: $0 {monitor|analyze|test}"
            echo "  monitor: Start continuous resource monitoring"
            echo "  analyze: Show performance analysis"
            echo "  test: Run scripts and analyze performance"
            exit 1
            ;;
    esac
}

# Cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
    echo "$(date): MONITOR_STOPPED" >> "$LOG_FILE"
    echo "Performance log saved to: $LOG_FILE"
}

trap cleanup EXIT

# Execute main function
main "$@"
