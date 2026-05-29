#!/bin/bash

# VM Health Monitoring Script
# Analyzes virtual machine health based on CPU, Memory, and Disk Space
# Threshold: > 60% is NOT HEALTHY, <= 60% is HEALTHY

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  (no argument)  - Display overall VM health status"
    echo "  explain        - Display detailed parameter utilization information"
    echo "  help           - Show this help message"
}

# Function to get CPU utilization
get_cpu_usage() {
    # Get CPU usage percentage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$cpu_usage"
}

# Function to get Memory utilization
get_memory_usage() {
    # Get memory usage percentage
    mem_usage=$(free | grep Mem | awk '{printf("%.2f", ($3/$2) * 100)}')
    echo "$mem_usage"
}

# Function to get Disk utilization
get_disk_usage() {
    # Get disk usage percentage of root partition
    disk_usage=$(df / | awk 'NR==2 {printf("%.2f", ($3/$2) * 100)}')
    echo "$disk_usage"
}

# Function to check health status
check_health_status() {
    local value=$1
    if (( $(echo "$value > 60" | bc -l) )); then
        echo "NOT HEALTHY"
    else
        echo "HEALTHY"
    fi
}

# Function to get color based on health
get_color() {
    local value=$1
    if (( $(echo "$value > 60" | bc -l) )); then
        echo -e "${RED}"
    else
        echo -e "${GREEN}"
    fi
}

# Function to display overall health status
display_health_status() {
    echo ""
    echo "=========================================="
    echo "     VM HEALTH STATUS REPORT"
    echo "=========================================="
    echo ""

    cpu=$(get_cpu_usage)
    memory=$(get_memory_usage)
    disk=$(get_disk_usage)

    cpu_status=$(check_health_status "$cpu")
    memory_status=$(check_health_status "$memory")
    disk_status=$(check_health_status "$disk")

    echo -e "CPU Usage:       $(get_color "$cpu")$cpu%${NC} [$cpu_status]"
    echo -e "Memory Usage:    $(get_color "$memory")$memory%${NC} [$memory_status]"
    echo -e "Disk Usage:      $(get_color "$disk")$disk%${NC} [$disk_status]"
    echo ""

    # Overall health determination
    if (( $(echo "$cpu <= 60 && $memory <= 60 && $disk <= 60" | bc -l) )); then
        echo -e "Overall Status: ${GREEN}HEALTHY${NC}"
    else
        echo -e "Overall Status: ${RED}NOT HEALTHY${NC}"
    fi

    echo ""
    echo "=========================================="
    echo "Threshold: > 60% = NOT HEALTHY"
    echo "Threshold: <= 60% = HEALTHY"
    echo "=========================================="
    echo ""
}

# Function to display detailed explanation
display_detailed_explanation() {
    echo ""
    echo "=========================================="
    echo "  DETAILED PARAMETER UTILIZATION INFO"
    echo "=========================================="
    echo ""

    cpu=$(get_cpu_usage)
    memory=$(get_memory_usage)
    disk=$(get_disk_usage)

    echo "1. CPU UTILIZATION"
    echo "   -----------------"
    echo "   Current Usage: $cpu%"
    echo "   Status: $(check_health_status "$cpu")"
    echo ""
    echo "   Details:"
    echo "   - Shows the percentage of CPU resources currently in use"
    echo "   - Obtained from: top command - idle CPU percentage"
    echo "   - High CPU usage may indicate:"
    echo "     * Running heavy computational tasks"
    echo "     * Multiple applications consuming resources"
    echo "     * Potential performance bottlenecks"
    echo ""

    echo "2. MEMORY UTILIZATION"
    echo "   -------------------"
    echo "   Current Usage: $memory%"
    echo "   Status: $(check_health_status "$memory")"
    echo ""
    echo "   Details:"
    echo "   - Shows the percentage of RAM currently in use"
    echo "   - Obtained from: free command - used memory / total memory"
    echo "   - High memory usage may indicate:"
    echo "     * Too many applications running simultaneously"
    echo "     * Memory leaks in running processes"
    echo "     * Need for additional RAM or process optimization"
    echo ""

    echo "3. DISK SPACE UTILIZATION"
    echo "   ----------------------"
    echo "   Current Usage: $disk%"
    echo "   Status: $(check_health_status "$disk")"
    echo ""
    echo "   Details:"
    echo "   - Shows the percentage of root partition (/) disk space in use"
    echo "   - Obtained from: df command - used space / total space"
    echo "   - High disk usage may indicate:"
    echo "     * Accumulation of log files or temporary files"
    echo "     * Large application installations"
    echo "     * Need for disk cleanup or archiving old data"
    echo ""

    echo "=========================================="
    echo ""
}

# Main script logic
case "${1}" in
    "explain")
        display_detailed_explanation
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    "")
        display_health_status
        ;;
    *)
        echo "Unknown option: $1"
        echo ""
        usage
        exit 1
        ;;
esac
