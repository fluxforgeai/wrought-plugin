#!/bin/bash
# local-file.sh — always-on file-based alert dispatcher
# Writes each alert as a JSON file under the session's incident directory.
# Contract: $1=category, $2=message, $3=severity
# Env: SESSION_ID (required; passed by watchdog_template.sh send_alert)

set -euo pipefail

CATEGORY="${1:-unknown}"
MESSAGE="${2:-}"
SEVERITY="${3:-info}"

SESSION_ID="${SESSION_ID:-unknown}"
ALERT_DIR="/tmp/watchdog_${SESSION_ID}_incidents"
mkdir -p "$ALERT_DIR"

TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
FILENAME="alert_${CATEGORY}_$(date -u '+%s')_$$.json"
FILEPATH="$ALERT_DIR/$FILENAME"

if command -v jq >/dev/null 2>&1; then
    ESCAPED_MSG=$(printf '%s' "$MESSAGE" | jq -Rs .)
elif command -v python3 >/dev/null 2>&1; then
    ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c 'import sys,json;print(json.dumps(sys.stdin.read()))')
else
    ESCAPED_MSG="\"$(printf '%s' "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')\""
fi

cat > "$FILEPATH" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "session_id": "$SESSION_ID",
  "category": "$CATEGORY",
  "severity": "$SEVERITY",
  "message": $ESCAPED_MSG
}
EOF

exit 0
