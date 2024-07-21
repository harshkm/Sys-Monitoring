#!/bin/bash

# Log file path
LOGFILE="/var/log/nginx/access.log"

# Patterns
PATTERN_404="404"
PATTERN_REQUEST="GET|POST|PUT|DELETE|PATCH"
PATTERN_IP="([0-9]{1,3}\.){3}[0-9]{1,3}"

# Analyze log file
analyze_log() {
    echo "Analyzing log file: $LOGFILE"

    # Count 404 errors
    COUNT_404=$(grep -c "$PATTERN_404" $LOGFILE)
    echo "Total 404 errors: $COUNT_404"

    # Most requested pages
    echo "Most requested pages:"
    grep -Eo "\"$PATTERN_REQUEST [^\"]+ HTTP" $LOGFILE | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

    # Most active IPs
    echo "Most active IPs:"
    grep -Eo "$PATTERN_IP" $LOGFILE | sort | uniq -c | sort -rn | head -10
}

analyze_log
