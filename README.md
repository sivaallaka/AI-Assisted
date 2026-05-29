
# VM Health Monitoring Script

A comprehensive shell script to monitor and analyze virtual machine health based on CPU, Memory, and Disk Space utilization.

## Overview

The `vm-health.sh` script provides real-time health monitoring for Linux virtual machines. It evaluates system parameters and determines overall health status based on a 60% utilization threshold:
- **HEALTHY**: All parameters ≤ 60%
- **NOT HEALTHY**: Any parameter > 60%

## Features

- ✅ Real-time CPU usage monitoring
- ✅ Memory utilization tracking
- ✅ Disk space analysis
- ✅ Detailed parameter explanation mode
- ✅ Color-coded output for easy visualization
- ✅ Simple and intuitive command-line interface

## Prerequisites

- Linux-based operating system (Ubuntu, CentOS, Debian, etc.)
- Bash shell
- Standard Linux utilities: `top`, `free`, `df`, `bc`
- Execute permissions on the script

## Step-by-Step Execution Guide

### Step 1: Download/Clone the Repository

```bash
git clone https://github.com/sivaallaka/AI-Assisted.git
cd AI-Assisted
```

### Step 2: Make the Script Executable

Grant execute permissions to the shell script:

```bash
chmod +x vm-health.sh
```

### Step 3: Run the Script - Quick Health Check

To display the overall VM health status with CPU, Memory, and Disk utilization:

```bash
./vm-health.sh
```

**Expected Output:**
```
==========================================
     VM HEALTH STATUS REPORT
==========================================

CPU Usage:       45.23% [HEALTHY]
Memory Usage:    52.10% [HEALTHY]
Disk Usage:      68.75% [NOT HEALTHY]

Overall Status: NOT HEALTHY

==========================================
Threshold: > 60% = NOT HEALTHY
Threshold: <= 60% = HEALTHY
==========================================
```

### Step 4: Run the Script - Detailed Explanation

To get detailed information about each parameter's utilization:

```bash
./vm-health.sh explain
```

**Expected Output:**
```
==========================================
  DETAILED PARAMETER UTILIZATION INFO
==========================================

1. CPU UTILIZATION
   -----------------
   Current Usage: 45.23%
   Status: HEALTHY

   Details:
   - Shows the percentage of CPU resources currently in use
   - Obtained from: top command - idle CPU percentage
   - High CPU usage may indicate:
     * Running heavy computational tasks
     * Multiple applications consuming resources
     * Potential performance bottlenecks

2. MEMORY UTILIZATION
   -------------------
   Current Usage: 52.10%
   Status: HEALTHY
   
   ... [detailed info]

3. DISK SPACE UTILIZATION
   ----------------------
   Current Usage: 68.75%
   Status: NOT HEALTHY
   
   ... [detailed info]
```

### Step 5: View Help Information

To display usage instructions and available options:

```bash
./vm-health.sh help
# or
./vm-health.sh -h
# or
./vm-health.sh --help
```

## Command Options

| Command | Description |
|---------|-------------|
| `./vm-health.sh` | Display overall VM health status with current resource utilization |
| `./vm-health.sh explain` | Show detailed parameter utilization information and explanations |
| `./vm-health.sh help` | Display help message with usage instructions |
| `./vm-health.sh -h` | Short form for help |
| `./vm-health.sh --help` | Long form for help |

## Output Interpretation

### Health Status Indicators

**Color Coding:**
- 🟢 **GREEN**: Parameter is HEALTHY (≤ 60%)
- 🔴 **RED**: Parameter is NOT HEALTHY (> 60%)

### Overall Status

- **HEALTHY**: All three parameters (CPU, Memory, Disk) are at or below 60%
- **NOT HEALTHY**: At least one parameter exceeds 60%

## Parameters Explained

### 1. CPU Usage
- **What it measures**: Percentage of CPU processing power currently in use
- **Source**: Derived from system idle percentage using `top` command
- **Concern threshold**: > 60% indicates potential performance issues
- **Action items**: Check running processes, optimize applications, or upgrade CPU resources

### 2. Memory Usage
- **What it measures**: Percentage of RAM currently allocated and in use
- **Source**: Calculated from `free` command (used memory / total memory)
- **Concern threshold**: > 60% indicates memory pressure
- **Action items**: Review running processes, check for memory leaks, or add more RAM

### 3. Disk Space Usage
- **What it measures**: Percentage of root partition (/) disk space in use
- **Source**: Obtained from `df` command (used space / total space)
- **Concern threshold**: > 60% indicates limited free space
- **Action items**: Clean up temporary files, archive old logs, or expand disk storage

## Troubleshooting

### Issue: "Permission denied" error

**Solution**: Make the script executable
```bash
chmod +x vm-health.sh
```

### Issue: "command not found: bc" error

**Solution**: Install the `bc` package
```bash
# Ubuntu/Debian
sudo apt-get install bc

# CentOS/RHEL
sudo yum install bc
```

### Issue: Inaccurate CPU readings

**Solution**: Run the script with elevated privileges for better accuracy
```bash
sudo ./vm-health.sh
```

## Examples

### Example 1: Check VM Health
```bash
$ ./vm-health.sh
```

### Example 2: Get Detailed Information
```bash
$ ./vm-health.sh explain
```

### Example 3: Schedule Regular Monitoring (Cron Job)

Monitor VM health every hour:

```bash
# Open crontab editor
crontab -e

# Add this line to run every hour
0 * * * * /path/to/AI-Assisted/vm-health.sh >> /var/log/vm-health.log 2>&1
```

## Best Practices

1. **Regular Monitoring**: Run the script periodically to track trends
2. **Log Analysis**: Redirect output to logs for historical analysis
3. **Proactive Action**: Address issues when metrics approach 60% threshold
4. **Resource Planning**: Use data to plan capacity upgrades
5. **Alerting Integration**: Combine with monitoring tools for automated alerts

## Author

Created as part of the AI-Assisted project

## License

This project is open source and available for modification and distribution.

---

**Last Updated**: 2026-05-29

For issues or improvements, please refer to the project repository.
