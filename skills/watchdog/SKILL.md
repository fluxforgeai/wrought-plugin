---
name: watchdog
description: "Passive monitoring with incident tagging. Creates autonomous bash monitoring scripts that watch logs after fixes, create incident files, and send alerts via your configured backend(s) on errors."
disable-model-invocation: false
argument-hint: "[target or log-path]"
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - search_content
      - find_files
      - write_file
  platforms:
    claude-code:
      disable-model-invocation: false
  agent:
    role: "Monitoring Script Generator"
    expertise:
      - "log monitoring"
      - "bash scripting"
      - "alerting configuration"
    non_goals:
      - "fixing issues"
      - "root cause analysis"
      - "modifying application code"
  execution:
    default_mode: react
    max_iterations: 8
    stop_conditions:
      - "Monitoring script generated and started"
      - "Monitoring report written to docs/monitoring/"
      - "User instructed to stop"
  output:
    format: markdown
    template: "docs/monitoring/{YYYY-MM-DD_HHMM}_{subject}.md"
    required_sections:
      - "What is being monitored"
      - "Alert conditions"
      - "Script location"
  pipeline:
    track: standalone
    standalone: true
    prerequisites: []
    produces:
      - "docs/monitoring/*.md"
      - "/tmp/watchdog_*.sh"
    suggested_next:
      - incident
---

# Watchdog - Passive Monitoring Skill

## Pre-flight Check

This skill is **standalone** — it can be invoked at any time without prerequisites.

If this invocation is part of an active workflow, check `docs/findings/*_FINDINGS_TRACKER.md`
for a relevant tracker and note it for context, but do not enforce stage requirements.

---

## Trigger

```
/watchdog {what to monitor - description of fix or process}
```

## Examples

```
/watchdog Monitor extraction after retry logic fix - watch for timeout errors
/watchdog Watch backend after GCS upload fix - look for upload failures
/watchdog Monitor batch job API after endpoint fix
```

---

## Description

A **fully autonomous bash script** that monitors logs after a fix is implemented. Runs independently without Claude — creates incident files and sends alerts via your configured backend(s) when errors occur.

### Key Behaviors

| Setting | Value |
|---------|-------|
| Monitoring style | **Passive** — watch logs/messages |
| Check interval | **60 seconds** |
| On error detected | **Create incident file + fan out alerts via all configured backends** |
| Error de-duplication | **Don't repeat same/similar errors** |
| After incident | **Continue monitoring** (don't stop) |
| Manual stop | **Run until user stops it** |
| Alerts | **Log + configured backends** (different messages for system vs fix-related) |
| Incident tagging | **"system" vs "fix-related"** based on pattern matched |
| Status surfacing | **Every 60 seconds** to status file |
| **Autonomy** | **Runs independently** — no Claude session required |

### Autonomous Operation

**IMPORTANT**: Once started, the watchdog runs as a standalone bash script:

1. **Does NOT require Claude** to be running
2. **Does NOT require user to be awake**
3. **Sends alerts via configured backends** (default: local-file + ntfy.sh; optional: Telegram, Slack, webhook, email)
4. **Creates incident JSON files** for later review

**Workflow when you're asleep:**
```
1. You start watchdog and go to sleep
2. Watchdog detects error at 3am
3. Creates incident file: /tmp/watchdog_{id}_incidents/fix-related_20260122_030000.json
4. Fans out to all WATCHDOG_BACKENDS dispatchers (e.g. ntfy push → your phone, Slack channel, Telegram bot)
5. You wake up, see the push notification
6. Start Claude, run: /incident {error summary}
   OR read incident files: cat /tmp/watchdog_{id}_incidents/*.json
```

**What the script can do autonomously:**
- Fetch recent text from the configured monitor source (default: `docker logs ${CONTAINER_NAME}`)
- Detect errors using pattern matching
- Tag incidents as "system" or "fix-related"
- Create JSON incident files with full stack traces
- Fan out alerts to every configured backend (independent failure isolation)
- Update status file for later review
- De-duplicate repeated errors

**What requires Claude (when you're back):**
- Running `/incident` to create formal incident report
- Investigating the root cause
- Implementing fixes

---

## Prerequisites

- **Zero** for the zero-config default (`local-file` + `ntfy`) — no accounts, no credentials
- **Telegram**: bot created via `@BotFather` + chat ID looked up via `getUpdates`
- **Slack**: incoming-webhook URL from a Slack workspace admin
- **webhook**: any HTTP endpoint that accepts POST JSON; optional auth via `WEBHOOK_HEADERS`
- **email**: `sendmail` binary on PATH (or an SMTP forwarder configured to accept sendmail input)
- **Docker-logs monitor source**: a running container named in `CONTAINER_NAME`
- **Network dispatchers** (`ntfy`, `telegram`, `slack`, `webhook`): `curl` on PATH
- **JSON-heavy backends** (`slack`, `webhook`, `local-file` with non-ASCII messages): `jq` or `python3` on PATH for robust escaping (falls back to sed if neither is available)

See `docs/setup/watchdog.md` for step-by-step per-backend setup.

---

## Backends

Dispatcher scripts live in `.claude/skills/watchdog/dispatchers/*.sh` and share one interface:

```
dispatcher.sh {category} {message} {severity}
```

Each reads its own env vars, writes to stdout/stderr (captured by the template's log), and returns an exit code (`0`=success, `1`=transient/retry, `2`=permanent misconfig, `126`=required binary missing). The template fans out to every backend listed in `WATCHDOG_BACKENDS` with failure isolation — one backend's misconfig cannot stop another from firing.

### local-file (default; always-on audit trail)

- **Purpose**: JSON incident record per alert on local disk; first-line defence even when network is down
- **Required env**: none (`SESSION_ID` passed by the template)
- **Output**: `/tmp/watchdog_${SESSION_ID}_incidents/alert_{category}_{unix_ts}_{pid}.json`
- **Config example**: `WATCHDOG_BACKENDS=local-file`

### ntfy (default; free push notifications)

- **Purpose**: no-signup push to phone/desktop via ntfy.sh or a self-hosted ntfy server
- **Required env**: `NTFY_TOPIC`
- **Optional env**: `NTFY_SERVER` (default `https://ntfy.sh`)
- **Severity → priority**: `high=5`, `medium=4`, `low=3`, `info=2`
- **Config example**: `WATCHDOG_BACKENDS=local-file,ntfy; NTFY_TOPIC=my-watchdog-topic`

### telegram (legacy default when CONTAINER_NAME is set)

- **Purpose**: Telegram bot message; byte-exact replica of pre-Stage-1 behaviour
- **Required env**: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`
- **Format**: `parse_mode=HTML` with category-specific emojis (`🎯🔴` fix-related, `⚠️` system, `🐕` info)
- **Config example**: `WATCHDOG_BACKENDS=telegram; TELEGRAM_BOT_TOKEN=...; TELEGRAM_CHAT_ID=...`

### slack

- **Purpose**: Slack channel post via incoming webhook
- **Required env**: `SLACK_WEBHOOK_URL`
- **Severity → color**: `high=danger`, `medium=warning`, `low|info=good`
- **Config example**: `WATCHDOG_BACKENDS=local-file,slack; SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...`

### webhook (generic HTTP POST)

- **Purpose**: structured JSON POST to any endpoint; use for PagerDuty Events v2, Discord webhooks, custom APIs
- **Required env**: `WEBHOOK_URL`
- **Optional env**: `WEBHOOK_HEADERS` (newline-separated `Key: Value` lines — e.g. for `Authorization: Bearer …`)
- **Payload**: `{"session_id", "timestamp", "category", "severity", "message"}`
- **Config example**: `WATCHDOG_BACKENDS=webhook; WEBHOOK_URL=https://api.example.com/alerts`

### email

- **Purpose**: plaintext email via local sendmail (or any sendmail-compatible forwarder)
- **Required env**: `EMAIL_TO`
- **Optional env**: `EMAIL_FROM` (default `watchdog@localhost`)
- **Required binary**: `sendmail` on PATH (`exit 126` if missing)
- **Subject format**: `[watchdog/{severity}] {category}: {first-line-truncated-to-50-chars}`
- **Config example**: `WATCHDOG_BACKENDS=local-file,email; EMAIL_TO=ops@example.com`

---

## Environment Variables

| Variable | Purpose | Consumed by | Default |
|---|---|---|---|
| `WATCHDOG_BACKENDS` | CSV list of dispatchers to fan out to | template (router) | `local-file,ntfy` — or `telegram` if `CONTAINER_NAME` set (Decision #15) |
| `WATCHDOG_MONITOR_CMD` | Shell command producing log text on stdout | template (source) | `docker logs ${CONTAINER_NAME} --since ${INTERVAL}s` |
| `WATCHDOG_DISPATCH_TIMEOUT` | Per-dispatcher HTTP/exec timeout in seconds | network dispatchers | `10` |
| `WATCHDOG_DISPATCHER_DIR` | Absolute path to dispatchers directory | template (router) | `$(dirname $0)/dispatchers` |
| `CONTAINER_NAME` | Docker container for legacy monitor source + legacy cred-fallback | template | unset |
| `NTFY_TOPIC` | ntfy.sh topic | ntfy | unset |
| `NTFY_SERVER` | ntfy server URL | ntfy | `https://ntfy.sh` |
| `TELEGRAM_BOT_TOKEN` | Bot token from `@BotFather` | telegram | unset |
| `TELEGRAM_CHAT_ID` | Target chat ID (use `/getUpdates` to discover) | telegram | unset |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL | slack | unset |
| `WEBHOOK_URL` | Generic POST endpoint | webhook | unset |
| `WEBHOOK_HEADERS` | Newline-separated auth headers (`Key: Value`) | webhook | unset |
| `EMAIL_TO` | Recipient address | email | unset |
| `EMAIL_FROM` | Sender address | email | `watchdog@localhost` |

Full reference + setup walkthroughs: `docs/setup/watchdog.md`. Sample env file: `.env.watchdog.example` at repo root.

### Credential priority (highest wins)

1. **Host environment** — already exported when watchdog is launched
2. `./.env.watchdog` then `../.env.watchdog` — per-project watchdog config
3. `./.env` then `../.env` — project-wide env
4. `docker exec ${CONTAINER_NAME} printenv VAR` — legacy Docker+Telegram fallback (only when `CONTAINER_NAME` is set and `docker` is on PATH)

Once a variable is resolved at a given tier, lower tiers are skipped for it. This makes host-env overrides safe in any shell session — no file edits required.

---

## Instructions

### Step 1: Parse Input and Understand Context

1. **Parse the user's input** to understand:
   - What was fixed
   - What process to monitor
   - What errors to watch for

2. **Read recent context documents** (if relevant):
   - Recent `docs/RCAs/*.md` files
   - Recent `docs/plans/*.md` files
   - Recent `docs/investigations/*.md` files

3. **Identify FIX-SPECIFIC error patterns** based on the fix context. These are CRITICAL for tagging incidents correctly.

   Examples:
   - If fix was for "retry logic for timeouts" → fix patterns: `ReadTimeout|ConnectTimeout|timed out`
   - If fix was for "GCS upload" → fix patterns: `GCS|upload.*fail|storage`
   - If fix was for "URL refresh" → fix patterns: `refresh|_fetch_all_export_files|URLExpired`

4. **Store patterns in two categories**:
   - `SYSTEM_PATTERNS`: General errors (always the same)
   - `FIX_PATTERNS`: Specific to what was fixed (varies per session)

5. **Determine the monitor source and backend selection**:
   - **Monitor source**: if the target is a Docker container, the default `docker logs ${CONTAINER_NAME} --since ${INTERVAL}s` works. For other sources (pytest output, tail of a file, SSH command, shell pipeline), set `WATCHDOG_MONITOR_CMD` to any shell command that produces log text on stdout.
   - **Backend selection**: if `WATCHDOG_BACKENDS` is unset, the template picks the default per Decision #15 (`telegram` if `CONTAINER_NAME` is set; otherwise `local-file,ntfy`). Users can override via env, `.env.watchdog`, or by editing the startup snippet before launching.

### Step 2: Create Monitoring Session

1. **Generate a unique session ID**:
   ```bash
   SESSION_ID=$(date -u '+%Y%m%d_%H%M%S')_$(head -c 4 /dev/urandom | xxd -p)
   ```

2. **Identify log sources** to monitor:
   - Docker container: `docker logs {container_name} --since 1m` (default)
   - Pytest / CI output: `uv run pytest tests/ --tb=no -q 2>&1 | tail -30`
   - File tail: `tail -n 200 /var/log/app.log`
   - Any other shell pipeline producing text on stdout

3. **Create the monitoring report** at `docs/monitoring/{YYYY-MM-DD_HHMM}_{name}.md`

4. **Define the fix-specific patterns** based on Step 1 analysis

### Step 3: Write Monitoring Report

Create a report at: `docs/monitoring/{YYYY-MM-DD_HHMM}_{name}.md`

Read the template from `watchdog_report_template.md` (in this skill's directory). Copy it, replace all `{placeholders}` with actual values from the session context, and write it to the report path.

### Step 4: Start Background Monitoring Script

Use the Bash tool with `run_in_background: true` to start the monitoring script.

**IMPORTANT**: The script must:
1. Run in an infinite loop
2. Check the configured monitor source every 60 seconds
3. De-duplicate errors using MD5 hashes
4. **Tag incidents as "system" or "fix-related"**
5. Create incident files with category tag
6. **Fan out to every backend** in `WATCHDOG_BACKENDS` via `send_alert` (distinct messages per category)
7. **Write status file every 60 seconds** for Claude to read
8. Continue monitoring after incidents (don't exit)

Read the script template from `watchdog_template.sh` (in this skill's directory). Replace all `{placeholders}` with actual values:
- `{session_id}` — the generated session ID
- `{fix_patterns_pipe_separated}` — pipe-separated regex patterns for the fix (e.g., `ReadTimeout|ConnectTimeout|timed out`)
- `{fix_description}` — human-readable description of what was fixed

Backend selection (`WATCHDOG_BACKENDS`) and monitor source (`WATCHDOG_MONITOR_CMD`) are read from the environment at runtime — set them before launching or via `.env.watchdog` / `.env`. The template resolves Decision #15 defaults if unset.

### Step 5: Execute Background Script

**CRITICAL**: Before executing, you MUST replace these placeholders:
- `{session_id}` — The generated session ID
- `{fix_patterns_pipe_separated}` — Pipe-separated regex patterns for the fix (e.g., `ReadTimeout|ConnectTimeout|timed out`)
- `{fix_description}` — Human-readable description of what was fixed

Use the Bash tool with these parameters:

```
command: <the script above with placeholders replaced>
run_in_background: true
description: "Watchdog monitoring - passive log watcher with incident tagging"
```

### Step 6: Confirm to User (Keep It Simple!)

After starting the background process, respond with a **simple, clean confirmation**:

```
Watchdog started. Session: {session_id}

Watching for: {brief description of fix patterns}
Monitor source: {summary of WATCHDOG_MONITOR_CMD}
Backends: {list of WATCHDOG_BACKENDS}
Interval: 60 seconds

Safe to sleep - I'll alert you via {the first push-capable backend} if errors occur.

To check status: "check watchdog"
To stop: "stop watchdog"
```

**DO NOT include:**
- Complex tables
- Long file paths
- Redundant information
- Technical details about patterns

Keep it short and actionable.

### Step 7: STOP and Await

**IMPORTANT**: After confirming to the user, **STOP** your response. The monitoring is running in the background.

- Do NOT continuously check the logs
- Do NOT poll the background process
- The status file is updated every 60 seconds
- Configured push backends provide immediate notifications; local-file provides the audit trail

The user can:
- Ask you to check watchdog status (you'll read the status file)
- Ask you to read incident files
- Ask you to stop the watchdog
- Continue with other work while watchdog runs

---

## When User Asks to Check Watchdog

If the user asks "check watchdog" or similar:

1. **Read the status file and incident files**:
   ```bash
   cat /tmp/watchdog_{session_id}_status.json
   cat /tmp/watchdog_{session_id}_incidents/*.json 2>/dev/null
   ```

2. **Present a SIMPLE status report showing ACTUAL ERRORS**:

   ```
   **Watchdog Status**

   Running: Yes | Checks: {count} | Since: {start_time}

   **Incidents: {total_count}** ({fix_count} fix-related, {system_count} system)

   {IF incidents exist, show them directly:}

   ---
   🎯 **Fix-Related Error** (high priority)
   Time: {timestamp}
   Error: {actual error message from JSON}
   Stack: {first 3 lines of stack trace}
   ---

   ⚠️ **System Error**
   Time: {timestamp}
   Error: {actual error message}
   ---

   {IF no incidents:}
   No errors detected so far.
   ```

3. **SHOW THE ACTUAL ERRORS** - do not just list file paths!
   - Extract `summary` and `stack_trace` from each incident JSON
   - Display the error message directly
   - Show first few lines of stack trace
   - User should NOT need to run any commands to see errors

---

## When User Asks to Stop Watchdog

If the user asks "stop watchdog" or similar:

1. **Stop the process**:
   ```bash
   kill $(cat /tmp/watchdog_{session_id}.pid) 2>/dev/null && echo "Stopped" || echo "Not running"
   ```

2. **Read final status and any incidents**:
   ```bash
   cat /tmp/watchdog_{session_id}_status.json
   cat /tmp/watchdog_{session_id}_incidents/*.json 2>/dev/null
   ```

3. **Present final summary WITH any errors shown directly**:

   ```
   **Watchdog Stopped**

   Session: {session_id}
   Runtime: {duration}
   Total checks: {count}

   **Final Incident Summary:**
   - Fix-related: {count}
   - System: {count}

   {IF incidents exist, list each error summary directly}

   {IF no incidents:}
   No errors detected during monitoring.
   ```

---

## Error Patterns Reference

### System-Wide Patterns (Category: "system")

These patterns use **smart matching** to avoid false positives from field names:

| Pattern | Regex | Indicates |
|---------|-------|-----------|
| Error-level logs | `"level":\s*"error"` | Actual error log entries |
| Warning-level logs | `"level":\s*"warning"` | Warning log entries |
| Python tracebacks | `Traceback` | Stack traces |
| Error events | `_error"\|_failed"` | Event names like `download_error` |
| Exception text | `Exception:\|Error:` | Exception messages |
| Critical logs | `CRITICAL\|FATAL` | Severe errors |

**Note**: Does NOT match field names like `"parse_errors": 0`

### Fix-Specific Patterns (Category: "fix-related")

These are determined per-session based on what was fixed. Examples:

| Fix Context | Patterns |
|-------------|----------|
| Retry logic for timeouts | `ReadTimeout\|ConnectTimeout\|timed out` |
| GCS upload fix | `GCS\|upload.*fail\|storage\|bucket` |
| URL refresh fix | `refresh\|_fetch_all_export_files\|URLExpired` |
| Batch job fix | `batch.*fail\|job.*fail\|initiate_export` |
| Stream download fix | `stream.*download\|StreamingChunk\|iter_bytes` |

---

## Notes

### Autonomous Operation
- **Runs as standalone bash script** — does NOT need Claude running
- **Safe to start and go to sleep** — push backends deliver immediate alerts
- **Survives Claude session end** — keeps running until manually stopped
- **Creates incident files** — review them when you wake up

### Monitoring Behavior
- Status file updated every 60 seconds
- Fix-related incidents use severity `high` — red alerts via push backends (🎯🔴 on Telegram, Priority=5 on ntfy, `color=danger` on Slack)
- System incidents use severity `medium` — warnings (⚠️ on Telegram, Priority=4 on ntfy, `color=warning` on Slack)
- De-duplication prevents spam for repeated errors
- Backend failures are isolated — one misconfig doesn't stop another backend from firing

### Cleanup
- Always stop watchdog when no longer needed: `kill $(cat /tmp/watchdog_{id}.pid)`
- Incident files persist in `/tmp/` until system reboot or manual cleanup
- Incident JSON files can be used with `/incident` skill for formal reports
