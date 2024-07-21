#!/bin/bash

# Log file
LOGFILE="system_health.log"

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Log message function
log_message() {
    local LEVEL=$1
    local MESSAGE=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$LEVEL] $MESSAGE" >> $LOGFILE
}

# Check CPU usage
check_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        log_message "WARNING" "High CPU usage detected: ${CPU_USAGE}%"
    else
        log_message "INFO" "CPU usage: ${CPU_USAGE}%"
    fi
}

# Check memory usage
check_memory_usage() {
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        log_message "WARNING" "High Memory usage detected: ${MEMORY_USAGE}%"
    else
        log_message "INFO" "Memory usage: ${MEMORY_USAGE}%"
    fi
}

# Check disk usage
check_disk_usage() {
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        log_message "WARNING" "High Disk usage detected: ${DISK_USAGE}%"
    else
        log_message "INFO" "Disk usage: ${DISK_USAGE}%"
    fi
}

# Check running processes
check_running_processes() {
    PROCESS_COUNT=$(ps aux | wc -l)
    log_message "INFO" "Running processes: ${PROCESS_COUNT}"
}

# Main function
main() {
    log_message "INFO" "System Health Check Started"
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_running_processes
    log_message "INFO" "System Health Check Completed"
}

main
