#!/bin/bash
# slack.sh — Slack incoming-webhook push dispatcher
# Contract: $1=category, $2=message, $3=severity
# Env: SLACK_WEBHOOK_URL (required),
#      WATCHDOG_DISPATCH_TIMEOUT (default 10)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
TIMEOUT="${WATCHDOG_DISPATCH_TIMEOUT:-10}"

if [ -z "$WEBHOOK_URL" ]; then
    echo "[slack dispatcher] SLACK_WEBHOOK_URL not set — permanent misconfiguration" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[slack dispatcher] curl binary not found on PATH" >&2
    exit 126
fi

case "$SEVERITY" in
    high)        COLOR="danger" ;;
    medium)      COLOR="warning" ;;
    low|info|*)  COLOR="good" ;;
esac

TITLE="[watchdog/${CATEGORY}]"

if command -v jq >/dev/null 2>&1; then
    PAYLOAD=$(jq -cn \
        --arg color "$COLOR" \
        --arg title "$TITLE" \
        --arg text "$MESSAGE" \
        '{attachments:[{color:$color,title:$title,text:$text}]}')
elif command -v python3 >/dev/null 2>&1; then
    PAYLOAD=$(COLOR="$COLOR" TITLE="$TITLE" TEXT="$MESSAGE" python3 -c '
import json, os
print(json.dumps({"attachments":[{"color":os.environ["COLOR"],"title":os.environ["TITLE"],"text":os.environ["TEXT"]}]}))
')
else
    ESC_MSG=$(printf '%s' "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
    PAYLOAD="{\"attachments\":[{\"color\":\"${COLOR}\",\"title\":\"${TITLE}\",\"text\":\"${ESC_MSG}\"}]}"
fi

HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
    --max-time "$TIMEOUT" \
    -H 'Content-Type: application/json' \
    --data "$PAYLOAD" \
    "$WEBHOOK_URL" 2>/dev/null || printf '000')

case "$HTTP_CODE" in
    2??) exit 0 ;;
    000) echo "[slack dispatcher] curl invocation failed (network, DNS, or timeout)" >&2; exit 1 ;;
    *)   echo "[slack dispatcher] non-2xx HTTP $HTTP_CODE from Slack webhook" >&2; exit 1 ;;
esac
