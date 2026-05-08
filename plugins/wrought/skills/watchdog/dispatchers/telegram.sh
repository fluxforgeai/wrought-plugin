#!/bin/bash
# shellcheck disable=SC2034  # CATEGORY/SEVERITY are part of the dispatcher contract (positional args $1/$3); not all dispatchers use all parameters — telegram.sh only consumes MESSAGE.
# telegram.sh — Telegram Bot API push dispatcher
# Backward-compat anchor: reproduces byte-exact curl payload from pre-Stage-1
# send_telegram() (deployed template lines 51-59) so existing users see no
# change when WATCHDOG_BACKENDS is unset and CONTAINER_NAME is set (Decision #15).
#
# Contract: $1=category, $2=message (HTML-formatted; caller owns layout), $3=severity
# Env: TELEGRAM_BOT_TOKEN (required), TELEGRAM_CHAT_ID (required),
#      WATCHDOG_DISPATCH_TIMEOUT (default 10)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"
TIMEOUT="${WATCHDOG_DISPATCH_TIMEOUT:-10}"

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
    echo "[telegram dispatcher] TELEGRAM_BOT_TOKEN and/or TELEGRAM_CHAT_ID not set — permanent misconfiguration" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "[telegram dispatcher] curl binary not found on PATH" >&2
    exit 126
fi

# Byte-exact payload reproduction — matches pre-Stage-1 send_telegram() curl form:
#     curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
#         -d "chat_id=${CHAT_ID}" -d "text=${msg}" -d "parse_mode=HTML"
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
    --max-time "$TIMEOUT" \
    "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${MESSAGE}" \
    -d "parse_mode=HTML" 2>/dev/null || printf '000')

case "$HTTP_CODE" in
    2??) exit 0 ;;
    000) echo "[telegram dispatcher] curl invocation failed (network, DNS, or timeout)" >&2; exit 1 ;;
    *)   echo "[telegram dispatcher] non-2xx HTTP $HTTP_CODE from Telegram API" >&2; exit 1 ;;
esac
