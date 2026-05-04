#!/bin/bash
# email.sh — sendmail-based email alert dispatcher
# Contract: $1=category, $2=message, $3=severity
# Env: EMAIL_TO (required), EMAIL_FROM (default watchdog@localhost)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

TO="${EMAIL_TO:-}"
FROM="${EMAIL_FROM:-watchdog@localhost}"

if [ -z "$TO" ]; then
    echo "[email dispatcher] EMAIL_TO not set — permanent misconfiguration" >&2
    exit 2
fi

if ! command -v sendmail >/dev/null 2>&1; then
    echo "[email dispatcher] sendmail binary not found on PATH" >&2
    exit 126
fi

FIRST_LINE="${MESSAGE%%$'\n'*}"
TRUNCATED="${FIRST_LINE:0:50}"
SUBJECT="[watchdog/${SEVERITY}] ${CATEGORY}: ${TRUNCATED}"

{
    printf 'From: %s\n' "$FROM"
    printf 'To: %s\n' "$TO"
    printf 'Subject: %s\n' "$SUBJECT"
    printf 'Content-Type: text/plain; charset=UTF-8\n'
    printf '\n'
    printf '%s\n' "$MESSAGE"
} | sendmail -t 2>/dev/null || {
    echo "[email dispatcher] sendmail invocation failed" >&2
    exit 1
}

exit 0
