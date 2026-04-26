#!/bin/bash
# ~/.hermes/scripts/disk-monitor.sh — 24/7 disk space watchdog
# Triggers cleanup when free space drops below thresholds.
# Part of low-resource optimization (2026-04-26).

set -uo pipefail

log() { echo "[$(date +%Y-%m-%dT%H:%M:%S)] $*"; }

# Thresholds (in GB)
THRESHOLD_5GB=5
THRESHOLD_3GB=3
THRESHOLD_2GB=2

# Paths
MONITOR_LOG="$HOME/.hermes/disk-monitor.log"
WRAPPER="$HOME/.hermes/scripts/disk_cleanup_wrapper.py"
LOCKFILE="/tmp/disk-monitor.lock"
TREND_WARN=""

# Ensure only one instance runs at a time
if [[ -e "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE" 2>/dev/null)" 2>/dev/null; then
    log "SKIP: Another instance is still running (PID $(cat $LOCKFILE))"
    exit 0
fi
echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"; exit' INT TERM EXIT

# Get free space on root partition in GB (integer)
FREE_GB=$(df / --output=avail -BG 2>/dev/null | tail -1 | tr -d ' G')
if [[ -z "$FREE_GB" ]]; then
    log "ERROR: Could not determine disk free space"
    exit 1
fi

log "Disk free: ${FREE_GB}GB${TREND_WARN}"

# Log every check (for trend analysis)
echo "$(date '+%s') $FREE_GB GB free" >> "$MONITOR_LOG"

# Simple trend detection: if current free < average of last 3 checks, flag
TREND_WARN=""
if [[ -s "$MONITOR_LOG" ]]; then
    # Get last 3 non-empty lines, extract free GB value (second field)
    mapfile -t last_three < <(tail -3 "$MONITOR_LOG" | awk '{print $2}' | grep -E '^[0-9]+$')
    if [[ ${#last_three[@]} -ge 3 ]]; then
        sum=0
        for v in "${last_three[@]}"; do ((sum += v)); done
        avg=$((sum / 3))
        if [[ "$FREE_GB" -lt $((avg - 1)) ]]; then
            TREND_WARN=" ↓${avg}GB avg (downward)"
        fi
    fi
fi

# Actions escalate with urgency

if [[ "$FREE_GB" -le "$THRESHOLD_2GB" ]]; then
    log "CRITICAL: ≤${THRESHOLD_2GB}GB remaining — running DEEP cleanup"
    python3 "$WRAPPER" deep 2>&1 | tee -a "$MONITOR_LOG"
    FREE_AFTER=$(df / --output=avail -BG 2>/dev/null | tail -1 | tr -d ' G')
    log "Post-deep free: ${FREE_AFTER}GB"
    # Send urgent alert via Telegram (if hermes-cli available)
    if command -v hermes &>/dev/null; then
        hermes telegram send "🚨 CRITICAL: Disk free dropped to ${FREE_GB}GB. Deep cleanup completed. Current free: ${FREE_AFTER}GB" 2>/dev/null || true
    fi

elif [[ "$FREE_GB" -le "$THRESHOLD_3GB" ]]; then
    log "WARNING: ≤${THRESHOLD_3GB}GB remaining — running QUICK cleanup"
    python3 "$WRAPPER" quick 2>&1 | tee -a "$MONITOR_LOG"
    FREE_AFTER=$(df / --output=avail -BG 2>/dev/null | tail -1 | tr -d ' G')
    log "Post-quick free: ${FREE_AFTER}GB"
    if command -v hermes &>/dev/null; then
        hermes telegram send "⚠️ WARNING: Disk free ${FREE_GB}GB. Quick cleanup completed. Current free: ${FREE_AFTER}GB" 2>/dev/null || true
    fi

elif [[ "$FREE_GB" -le "$THRESHOLD_5GB" ]]; then
    log "NOTICE: ≤${THRESHOLD_5GB}GB remaining — monitoring"
    if command -v hermes &>/dev/null; then
        hermes telegram send "ℹ️ NOTICE: Disk free at ${FREE_GB}GB. Monitoring." 2>/dev/null || true
    fi
else
    # All good — silent
    :
fi

exit 0
