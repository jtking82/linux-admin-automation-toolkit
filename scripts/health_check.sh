#!/bin/bash
# Linux Admin Toolkit - System Health Check
# Collects basic diagnostics and evaluates root filesystem and memory thresholds.

set -u

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$TOOLKIT_DIR/logs"
REPORT_DIR="$TOOLKIT_DIR/reports"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="$REPORT_DIR/health_report_$TIMESTAMP.txt"

mkdir -p "$LOG_DIR" "$REPORT_DIR"
exec > >(tee -a "$LOG_DIR/health_check.log") 2>&1

report() { echo "$1" | tee -a "$REPORT_FILE"; }

report "======================================"
report "       SYSTEM HEALTH CHECK"
report "======================================"
report "Hostname: $(hostname)"
report "Date: $(date)"
report ""

report "========== CPU HEALTH =========="
report "CPU cores: $(nproc)"
report "Load average: $(awk '{print $1, $2, $3}' /proc/loadavg)"
report ""

report "========== MEMORY HEALTH =========="
free -h | tee -a "$REPORT_FILE"
report ""

report "========== DISK HEALTH =========="
df -hP | tee -a "$REPORT_FILE"
report ""

report "========== SERVICE HEALTH =========="
FAILED_SERVICES=$(systemctl --failed --no-legend 2>/dev/null || true)
if [ -z "$FAILED_SERVICES" ]; then
    report "Status: No failed system services detected."
else
    report "WARNING: Failed services detected!"
    echo "$FAILED_SERVICES" | tee -a "$REPORT_FILE"
fi
report ""

report "========== NETWORK HEALTH =========="
report "Network interfaces:"
ip -br addr | tee -a "$REPORT_FILE"
report ""
report "Default route:"
ip route | tee -a "$REPORT_FILE"
report ""

GATEWAY=$(ip route | awk '/default/ {print $3; exit}')
report "Gateway connectivity test:"
if [ -n "$GATEWAY" ]; then
    if ping -c 3 -W 2 "$GATEWAY" >/dev/null 2>&1; then
        report "PASS: Gateway $GATEWAY reachable."
    else
        report "WARNING: Gateway $GATEWAY unreachable."
    fi
else
    report "WARNING: No default gateway detected."
fi
report ""

report "External IP connectivity test:"
if ping -c 3 -W 2 1.1.1.1 >/dev/null 2>&1; then
    report "PASS: External IP connectivity confirmed."
else
    report "WARNING: External IP connectivity failed."
fi
report ""

report "DNS resolution test:"
if getent hosts google.com >/dev/null 2>&1; then
    report "PASS: DNS resolution working."
else
    report "WARNING: DNS resolution failed."
fi
report ""

report "========== DISK THRESHOLD MONITORING =========="
while read -r filesystem usage mountpoint; do
    if [[ "$usage" =~ ^[0-9]+$ ]]; then
        if [ "$usage" -ge 90 ]; then
            report "CRITICAL: $mountpoint is at ${usage}% utilization."
        elif [ "$usage" -ge 80 ]; then
            report "WARNING: $mountpoint is at ${usage}% utilization."
        else
            report "OK: $mountpoint is at ${usage}% utilization."
        fi
    fi
done < <(df -P | awk 'NR>1 {gsub("%","",$5); print $1, $5, $6}')
report ""

MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
MEM_USED_PERCENT=$(( (MEM_TOTAL - MEM_AVAILABLE) * 100 / MEM_TOTAL ))
report "========== MEMORY THRESHOLD MONITORING =========="
if [ "$MEM_USED_PERCENT" -ge 90 ]; then
    report "CRITICAL: Memory utilization is ${MEM_USED_PERCENT}% ."
elif [ "$MEM_USED_PERCENT" -ge 80 ]; then
    report "WARNING: Memory utilization is ${MEM_USED_PERCENT}% ."
else
    report "OK: Memory utilization is ${MEM_USED_PERCENT}% ."
fi
report ""

ROOT_DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
OVERALL_STATUS=0
if [ "$ROOT_DISK_USAGE" -ge 90 ] || [ "$MEM_USED_PERCENT" -ge 90 ]; then
    OVERALL_STATUS=2
elif [ "$ROOT_DISK_USAGE" -ge 80 ] || [ "$MEM_USED_PERCENT" -ge 80 ]; then
    OVERALL_STATUS=1
fi

report "========== OVERALL SYSTEM STATUS =========="
case "$OVERALL_STATUS" in
    2) report "OVERALL RESULT: CRITICAL" ;;
    1) report "OVERALL RESULT: WARNING" ;;
    0) report "OVERALL RESULT: HEALTHY" ;;
esac
report "Root filesystem utilization: ${ROOT_DISK_USAGE}%"
report "Memory utilization: ${MEM_USED_PERCENT}%"
report "Toolkit exit code: $OVERALL_STATUS"
report "Report location: $REPORT_FILE"
report "Execution log: $LOG_DIR/health_check.log"
report "========== AUDIT COMPLETE =========="
exit "$OVERALL_STATUS"
