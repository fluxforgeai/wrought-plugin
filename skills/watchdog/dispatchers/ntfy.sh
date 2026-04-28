#!/bin/bash
# ntfy.sh — ntfy.sh (or self-hosted ntfy) push dispatcher
# Contract: $1=category, $2=message, $3=severity
# Env: NTFY_TOPIC (required), NTFY_SERVER (default https://ntfy.sh),
#      WATCHDOG_DISPATCH_TIMEOUT (default 10)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

NTFY_TOPIC="${NTFY_TOPIC:-}"
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
TIMEOUT="${WATCHDOG_DISPATCH_TIMEOUT:-10}"

if [ -z "$NTFY_TOPIC" ]; then
    echo "[ntfy dispatcher] NTFY_TOPIC not set — permanent misconfiguration" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[ntfy dispatcher] curl binary not found on PATH" >&2
    exit 126
fi

case "$SEVERITY" in
    high)        PRIORITY=5 ;;
    medium)      PRIORITY=4 ;;
    low)         PRIORITY=3 ;;
    info|*)      PRIORITY=2 ;;
esac

TITLE="[watchdog/${CATEGORY}]"

HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
    --max-time "$TIMEOUT" \
    -H "Priority: $PRIORITY" \
    -H "Title: $TITLE" \
    -d "$MESSAGE" \
    "${NTFY_SERVER}/${NTFY_TOPIC}" 2>/dev/null || printf '000')

case "$HTTP_CODE" in
    2??) exit 0 ;;
    000) echo "[ntfy dispatcher] curl invocation failed (network, DNS, or timeout)" >&2; exit 1 ;;
    *)   echo "[ntfy dispatcher] non-2xx HTTP $HTTP_CODE from ${NTFY_SERVER}/${NTFY_TOPIC}" >&2; exit 1 ;;
esac
