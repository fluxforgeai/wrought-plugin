#!/bin/bash
# webhook.sh — generic HTTP POST dispatcher (structured JSON)
# Contract: $1=category, $2=message, $3=severity
# Env: WEBHOOK_URL (required),
#      WEBHOOK_HEADERS (optional; newline-separated "Key: Value" lines),
#      SESSION_ID (passed by watchdog_template.sh send_alert),
#      WATCHDOG_DISPATCH_TIMEOUT (default 10)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

URL="${WEBHOOK_URL:-}"
HEADERS="${WEBHOOK_HEADERS:-}"
SESSION_ID="${SESSION_ID:-unknown}"
TIMEOUT="${WATCHDOG_DISPATCH_TIMEOUT:-10}"

if [ -z "$URL" ]; then
    echo "[webhook dispatcher] WEBHOOK_URL not set — permanent misconfiguration" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[webhook dispatcher] curl binary not found on PATH" >&2
    exit 126
fi

TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

if command -v jq >/dev/null 2>&1; then
    PAYLOAD=$(jq -cn \
        --arg session_id "$SESSION_ID" \
        --arg timestamp "$TIMESTAMP" \
        --arg category "$CATEGORY" \
        --arg severity "$SEVERITY" \
        --arg message "$MESSAGE" \
        '{session_id:$session_id,timestamp:$timestamp,category:$category,severity:$severity,message:$message}')
elif command -v python3 >/dev/null 2>&1; then
    PAYLOAD=$(SESSION_ID="$SESSION_ID" TIMESTAMP="$TIMESTAMP" CATEGORY="$CATEGORY" SEVERITY="$SEVERITY" MESSAGE="$MESSAGE" python3 -c '
import json, os
print(json.dumps({k:os.environ[k.upper()] for k in ["session_id","timestamp","category","severity","message"]}))
')
else
    ESC_MSG=$(printf '%s' "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
    PAYLOAD="{\"session_id\":\"${SESSION_ID}\",\"timestamp\":\"${TIMESTAMP}\",\"category\":\"${CATEGORY}\",\"severity\":\"${SEVERITY}\",\"message\":\"${ESC_MSG}\"}"
fi

HEADER_ARGS=(-H 'Content-Type: application/json')
if [ -n "$HEADERS" ]; then
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        HEADER_ARGS+=(-H "$line")
    done <<< "$HEADERS"
fi

HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
    --max-time "$TIMEOUT" \
    "${HEADER_ARGS[@]}" \
    --data "$PAYLOAD" \
    "$URL" 2>/dev/null || printf '000')

case "$HTTP_CODE" in
    2??) exit 0 ;;
    000) echo "[webhook dispatcher] curl invocation failed (network, DNS, or timeout)" >&2; exit 1 ;;
    *)   echo "[webhook dispatcher] non-2xx HTTP $HTTP_CODE from ${URL}" >&2; exit 1 ;;
esac
