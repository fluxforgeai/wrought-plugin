#!/usr/bin/env bash
# PreToolUse hook: Pipeline enforcement guard
#
# Blocks Edit/Write on source files when no active /wrought-implement or
# /wrought-rca-fix loop exists. Pipeline artifacts (docs/, .claude/, root
# *.md) are always allowed.
#
# Matcher: "Edit|Write" in hooks.json — fires before every Edit/Write call.
# Output: JSON with permissionDecision "deny" on stdout, or silent exit 0.

set -euo pipefail

# --- Read hook input from stdin ---
INPUT=$(cat)

# Parse file_path and cwd from input (single jq/python3 call)
if command -v jq &>/dev/null; then
    PARSED=$(echo "$INPUT" | jq -r '"\(.tool_input.file_path // "")\n\(.cwd // ".")"')
    FILE_PATH=$(echo "$PARSED" | sed -n '1p')
    CWD=$(echo "$PARSED" | sed -n '2p')
else
    PARSED=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
print(d.get('cwd', '.'))
")
    FILE_PATH=$(echo "$PARSED" | sed -n '1p')
    CWD=$(echo "$PARSED" | sed -n '2p')
fi
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

REL_PATH="${FILE_PATH#$CWD/}"

# File not under CWD — allow
if [ "$REL_PATH" = "$FILE_PATH" ]; then
    exit 0
fi

# --- Allowlist: pipeline artifacts always pass ---
if [[ "$REL_PATH" == docs/* ]]; then exit 0; fi
if [[ "$REL_PATH" == .claude/* ]]; then exit 0; fi
if [[ "$REL_PATH" == "CLAUDE.md" ]]; then exit 0; fi
if [[ "$REL_PATH" == NEXT_SESSION_PROMPT_*.md ]]; then exit 0; fi
if [[ "$REL_PATH" != */* && "$REL_PATH" == *.md ]]; then exit 0; fi
if [[ "$REL_PATH" == ".gitignore" ]]; then exit 0; fi

# --- Source file: check for active loop ---
STATE_FILE="$CWD/.claude/wrought-loop-state.json"

if [ -f "$STATE_FILE" ]; then
    if command -v jq &>/dev/null; then
        ACTIVE=$(jq -r '.active // false' "$STATE_FILE")
    else
        ACTIVE=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)
print(str(d.get('active', False)).lower())
")
    fi

    if [ "$ACTIVE" = "true" ]; then
        exit 0  # Loop active — allow
    fi
fi

# --- DENY: no active loop for source file ---
if command -v jq &>/dev/null; then
    jq -n \
        --arg reason "Pipeline guard: No active implementation loop. Source file '$REL_PATH' cannot be edited directly. Run /wrought-implement (proactive) or /wrought-rca-fix (reactive) first to start a loop." \
        '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "deny",
                permissionDecisionReason: $reason
            }
        }'
else
    python3 -c "
import json, sys
json.dump({
    'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'deny',
        'permissionDecisionReason': \"Pipeline guard: No active implementation loop. Source file '$REL_PATH' cannot be edited directly. Run /wrought-implement (proactive) or /wrought-rca-fix (reactive) first to start a loop.\"
    }
}, sys.stdout)
"
fi
