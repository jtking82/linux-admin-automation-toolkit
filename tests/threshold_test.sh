#!/bin/bash
# Simulation of threshold evaluation
check_threshold() {
    local usage="$1" resource="$2"
    if [ "$usage" -ge 90 ]; then
        echo "CRITICAL: $resource utilization is ${usage}%."
    elif [ "$usage" -ge 80 ]; then
        echo "WARNING: $resource utilization is ${usage}%."
    else
        echo "OK: $resource utilization is ${usage}%."
    fi
}
echo "===== DISK THRESHOLD TESTS ====="
check_threshold 65 DISK
check_threshold 85 DISK
check_threshold 95 DISK
echo
echo "===== MEMORY THRESHOLD TESTS ====="
check_threshold 65 MEMORY
check_threshold 85 MEMORY
check_threshold 95 MEMORY
