#!/bin/bash
# Simulate status/exit-code behavior for a single utilization value.
usage="$1"
if [ -z "$usage" ] || ! [[ "$usage" =~ ^[0-9]+$ ]] || [ "$usage" -gt 100 ]; then
    echo "ERROR: Provide a utilization value between 0 and 100."
    exit 2
fi
if [ "$usage" -ge 90 ]; then
    echo "CRITICAL: Utilization is ${usage}%."
    exit 2
elif [ "$usage" -ge 80 ]; then
    echo "WARNING: Utilization is ${usage}%."
    exit 1
else
    echo "OK: Utilization is ${usage}%."
    exit 0
fi
