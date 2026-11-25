#!/bin/bash
# Simulate overall status using disk and memory percentage values.
disk="$1"
memory="$2"
if ! [[ "$disk" =~ ^[0-9]+$ ]] || ! [[ "$memory" =~ ^[0-9]+$ ]] || [ "$disk" -gt 100 ] || [ "$memory" -gt 100 ]; then
    echo "ERROR: Disk and memory values must be integers between 0 and 100."
    exit 2
fi
status=0
if [ "$disk" -ge 90 ] || [ "$memory" -ge 90 ]; then
    status=2
elif [ "$disk" -ge 80 ] || [ "$memory" -ge 80 ]; then
    status=1
fi
case "$status" in
    0) echo "HEALTHY: Disk ${disk}% | Memory ${memory}%" ;;
    1) echo "WARNING: Disk ${disk}% | Memory ${memory}%" ;;
    2) echo "CRITICAL: Disk ${disk}% | Memory ${memory}%" ;;
esac
exit "$status"
