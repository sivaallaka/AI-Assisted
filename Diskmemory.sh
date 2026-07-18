#!/usr/bin/env bash
#
# Diskmemory.sh - Server resource utilization reporter
#
# Prints a snapshot of the server's resource utilization:
#   - Host / OS / uptime information
#   - CPU load and per-core usage
#   - Memory (RAM) and swap usage
#   - Disk usage per mounted filesystem
#   - Top processes by CPU and memory
#   - Network interface traffic
#
# Usage:
#   ./Diskmemory.sh            # human-readable report to stdout
#   ./Diskmemory.sh -h         # show help
#
# The script only relies on tools commonly available on Linux servers
# (coreutils, procps). Optional tools (lscpu, ip, ss) are used when present.

set -euo pipefail

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

print_header() {
    printf '\n===== %s =====\n' "$1"
}

have() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<'EOF'
Diskmemory.sh - Server resource utilization reporter

Usage:
  ./Diskmemory.sh        Show a full resource utilization report
  ./Diskmemory.sh -h     Show this help message

The report includes system info, CPU load, memory/swap usage,
disk usage, top processes, and network interface statistics.
EOF
}

# --------------------------------------------------------------------------
# Sections
# --------------------------------------------------------------------------

system_info() {
    print_header "SYSTEM INFORMATION"
    printf 'Hostname     : %s\n' "$(hostname 2>/dev/null || echo 'n/a')"
    printf 'Date/Time    : %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"

    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        printf 'OS           : %s\n' "${PRETTY_NAME:-unknown}"
    fi

    printf 'Kernel       : %s\n' "$(uname -sr 2>/dev/null || echo 'n/a')"
    printf 'Architecture : %s\n' "$(uname -m 2>/dev/null || echo 'n/a')"

    if have uptime; then
        printf 'Uptime       : %s\n' "$(uptime -p 2>/dev/null || uptime)"
    fi
}

cpu_info() {
    print_header "CPU"

    local cores
    cores=$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')
    printf 'Logical CPUs : %s\n' "$cores"

    if have lscpu; then
        lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); printf "Model        : %s\n", $2}'
    fi

    # Load averages from /proc/loadavg (1, 5, 15 min)
    if [ -r /proc/loadavg ]; then
        read -r l1 l5 l15 _ </proc/loadavg
        printf 'Load average : %s (1m)  %s (5m)  %s (15m)\n' "$l1" "$l5" "$l15"
    fi

    # Overall CPU utilization sampled from /proc/stat
    if [ -r /proc/stat ]; then
        read -r _ u1 n1 s1 i1 w1 irq1 sirq1 st1 _ < <(grep '^cpu ' /proc/stat)
        sleep 1
        read -r _ u2 n2 s2 i2 w2 irq2 sirq2 st2 _ < <(grep '^cpu ' /proc/stat)

        local idle1=$(( i1 + w1 ))
        local idle2=$(( i2 + w2 ))
        local nonidle1=$(( u1 + n1 + s1 + irq1 + sirq1 + st1 ))
        local nonidle2=$(( u2 + n2 + s2 + irq2 + sirq2 + st2 ))
        local total1=$(( idle1 + nonidle1 ))
        local total2=$(( idle2 + nonidle2 ))
        local totald=$(( total2 - total1 ))
        local idled=$(( idle2 - idle1 ))

        if [ "$totald" -gt 0 ]; then
            local usage=$(( (1000 * (totald - idled) / totald + 5) / 10 ))
            printf 'CPU usage    : %s%%\n' "$usage"
        fi
    fi
}

memory_info() {
    print_header "MEMORY"
    if have free; then
        free -h
    elif [ -r /proc/meminfo ]; then
        awk '/MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree/ \
            {printf "%-14s %s %s\n", $1, $2, $3}' /proc/meminfo
    else
        echo "Memory information not available"
    fi
}

disk_info() {
    print_header "DISK USAGE"
    # -h human readable, -T show fs type, exclude pseudo filesystems
    if have df; then
        df -hT -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null || df -h
    else
        echo "df not available"
    fi

    if have df; then
        print_header "INODE USAGE"
        df -hi -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null || df -i
    fi
}

top_processes() {
    print_header "TOP 5 PROCESSES BY CPU"
    if have ps; then
        ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -n 6
    fi

    print_header "TOP 5 PROCESSES BY MEMORY"
    if have ps; then
        ps -eo pid,comm,%cpu,%mem --sort=-%mem 2>/dev/null | head -n 6
    fi
}

network_info() {
    print_header "NETWORK INTERFACES"
    if have ip; then
        ip -brief address 2>/dev/null || ip address
    elif have ifconfig; then
        ifconfig -a
    else
        echo "No network tooling (ip/ifconfig) available"
    fi

    if [ -r /proc/net/dev ]; then
        print_header "NETWORK TRAFFIC (cumulative)"
        awk 'NR>2 {
            gsub(/:/, "", $1)
            printf "%-12s RX: %10.2f MB   TX: %10.2f MB\n", $1, $2/1024/1024, $10/1024/1024
        }' /proc/net/dev
    fi
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

main() {
    case "${1:-}" in
        -h|--help)
            usage
            exit 0
            ;;
    esac

    echo "############################################################"
    echo "#          SERVER RESOURCE UTILIZATION REPORT              #"
    echo "############################################################"

    system_info
    cpu_info
    memory_info
    disk_info
    top_processes
    network_info

    echo
    echo "Report generated at $(date '+%Y-%m-%d %H:%M:%S %Z')"
}

main "$@"
