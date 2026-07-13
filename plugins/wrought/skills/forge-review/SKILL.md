---
name: forge-review
description: "Deep multi-agent code review with algorithmic complexity analysis, data structure review, paradigm enforcement, and efficiency analysis. Complements /simplify with deeper dimensions."
disable-model-invocation: false
argument-hint: "[--scope=diff|full] [file or directory]"
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
effort: xhigh
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - search_content
      - find_files
      - run_command
      - delegate
      - write_file
  platforms:
    claude-code:
      allowed-tools: "Read, Grep, Glob, Bash, Agent, Write"
      disable-model-invocation: false
  agent:
    role: "Code Review Orchestrator"
    expertise:
      - "code review orchestration"
      - "finding aggregation and deduplication"
      - "severity classification"
    non_goals:
      - "modifying source code"
      - "running tests"
      - "implementing fixes"
  execution:
    default_mode: self-refine
    max_iterations: 10
    max_refine: 1
    stop_conditions:
      - "Review report written to docs/reviews/"
      - "User instructed to stop"
  output:
    format: markdown
    template: "docs/reviews/{YYYY-MM-DD_HHMM}_{scope}.md"
    required_sections:
      - "Executive Summary"
      - "Critical Findings"
      - "Warnings"
      - "Suggestions"
      - "Subagent Reports"
  pipeline:
    track: proactive
    standalone: true
    prerequisites: []
    produces:
      - "docs/reviews/*.md"
    suggested_next:
      - finding
---

# Code Review Orchestrator

**Trigger**: `/forge-review [--scope=diff|full] [file or directory]`

**Purpose**: Deep multi-agent code review that orchestrates 4 specialized subagents in parallel. Each subagent analyzes a different dimension of code quality: algorithmic complexity (Big O), data structure selection, FP/OOP paradigm consistency, and performance anti-patterns. Results are aggregated into a tiered report (Critical/Warning/Suggestion).

**Complements /simplify**: This skill handles deep analysis dimensions. /simplify handles code reuse, readability, and basic efficiency. They do not overlap.

---

## Overview

You are the Code Review Orchestrator. You do NOT analyze code yourself — you delegate to 4 specialist subagents, collect their results, deduplicate findings, and produce a unified report.

Your subagents:
1. **Complexity Analyst** (`.claude/agents/complexity-analyst.md`) — Big O time/space, hot paths, call chains
2. **DS&A Reviewer** (`.claude/agents/ds-reviewer.md`) — Data structure selection vs access patterns
3. **Paradigm Enforcer** (`.claude/agents/paradigm-enforcer.md`) — FP/OOP consistency, auto-detection
4. **Efficiency Sentinel** (`.claude/agents/efficiency-sentinel.md`) — Performance anti-patterns, N+1, memory, concurrency
5. **Flow Integrator** (`.claude/agents/flow-integrator.md`) — End-to-end navigation-flow correctness (conditional spawn: only runs when diff touches navigation surfaces)

Note: Flow Integrator spawns conditionally. On non-frontend / non-navigation diffs, only the first 4 agents run.

---

## Step 1: Parse Arguments

Parse the user's invocation arguments:

- **`--scope=diff`** (DEFAULT if not specified): Review only changed files
- **`--scope=full`**: Review all source files in the project
- **`[file or directory]`** (optional): Narrow the review to a specific path

Examples:
```
/forge-review                           → diff scope, all changed files
/forge-review --scope=full              → full scope, entire project
/forge-review --scope=full src/engine/  → full scope, only src/engine/
/forge-review src/cli/commands.py       → diff scope, only this file (if changed)
```

---

## Step 1.5: Check Loop State

Read `.claude/wrought-loop-state.json` to determine if this review was triggered by a completed implementation loop.

1. If the file exists and `review_pending: true`:
   - Clear `review_pending` (set to `false`) by writing the updated state file
   - Extract `finding_id` and `tracker_path` from the state for lifecycle updates in Step 8
   - Note: this means the review is part of the implementation pipeline, not a standalone invocation
2. If the file does not exist, or `review_pending` is absent/false:
   - Continue normally — this is a standalone invocation
   - No lifecycle updates will be performed in Step 8

Store the loop context (if any) for use in Step 8.

---

## Step 2: Get File List

### For `--scope=diff` (default)

Run these commands to get the list of changed files:

```bash
# Get unstaged changes
git diff --name-only HEAD 2>/dev/null

# Get staged changes
git diff --name-only --cached 2>/dev/null

# Get untracked files
git ls-files --others --exclude-standard 2>/dev/null
```

Combine and deduplicate the results.

### For `--scope=full`

```bash
git ls-files 2>/dev/null
```

### Apply Filters

From whichever file list you obtained:

1. **Path filter**: If user specified a file or directory, filter to that path only
2. **Extension filter**: Keep only reviewable source files: `*.py`, `*.js`, `*.ts`, `*.jsx`, `*.tsx`, `*.go`, `*.rs`, `*.java`, `*.rb`, `*.sh`, `*.bash`
3. **Exclusion filter**: Remove these patterns:
   - `*.pyc`, `*.pyo`, `__pycache__/`
   - `node_modules/`, `vendor/`, `.venv/`, `venv/`, `env/`
   - `*.min.js`, `*.min.css`, `*.bundle.js`
   - `*.lock`, `package-lock.json`, `uv.lock`, `poetry.lock`
   - `.git/`, `.claude/`
   - Test fixtures: `tests/fixtures/`, `test_data/`, `testdata/`
   - Generated files: `*.generated.*`, `*_generated.*`, `*.pb.go`, `*_pb2.py`
   - Binary files (detected by extension): `*.png`, `*.jpg`, `*.gif`, `*.ico`, `*.woff`, `*.ttf`, `*.pdf`, `*.zip`, `*.tar`, `*.gz`

Store the final file list for passing to subagents.

---

## Step 3: Validate

If the file list is empty after filtering:

```
No reviewable files found for scope '{scope}'.

{If diff scope}: No changed files detected. Try --scope=full for a full codebase review.
{If full scope with path filter}: No source files found at '{path}'.
{If full scope}: No source files found in the project.
```

**STOP** — do not spawn subagents.

---

## Step 4: Spawn Subagents in Parallel (4 or 5 agents depending on diff)

### 4a. Detect Navigation-Surface Trigger

Before spawning, check if the diff touches navigation surfaces. Spawn `flow-integrator` as a 5th agent if **ANY** of the following match:

**File-path regex** (check each changed file path):
- `routes/` or `pages/` or `app/` as a directory segment
- `[^/]+Layout\.[jt]sx?` (layout files)
- `[^/]+Router\.[jt]sx?` (router files)
- `_app\.[jt]sx?` (Next.js _app)
- `middleware\.[jt]sx?`
- `[^/]+\.route\.[jt]sx?`

**Extension filter** (check for any changed file with):
- `.tsx`, `.jsx`, `.vue`, `.svelte`, `.html`

**Content regex** (run `git diff --unified=0` on changed files; check added/modified lines for):
- `<Route\b`, `<Link\b`, `<NavLink\b`, `<Navigate\b`
- `\brouter\.(push|replace|navigate)\b`, `\bhistory\.push\b`
- `\bredirect\(`, `\bnavigate\(`
- `\bhref=["']`, `\bto=["']`
- `\buseRouter\(`, `\buseNavigate\(`, `\buseHistory\(`
- `\bcreateBrowserRouter\(`, `\bcreateRoutesFromElements\(`

If ANY category matches → set `SPAWN_FLOW_INTEGRATOR = true` and `AGENT_COUNT = 5`. Otherwise → `SPAWN_FLOW_INTEGRATOR = false` and `AGENT_COUNT = 4`.

The reference implementation of this heuristic is `src/wrought/core/flow_trigger.py::should_spawn_flow_integrator()` — tested by `tests/claude/test_flow_integrator_trigger.py`.

### 4b. Launch Agents in Parallel

**CRITICAL**: All agents MUST be launched in a SINGLE message using the Agent tool. This ensures true parallel execution.

For each subagent, use:
- `subagent_type: "general-purpose"`
- `model`: the per-spawn model assigned to that specialist (see the launch list below) — Precheck-1-confirmed to take effect independent of `subagent_type`
- Include in the prompt: the file list, the scope description, and instruction to return structured findings

The prompt for each subagent should follow this template:

```
You are the {agent_name} subagent for /forge-review.

Your system prompt is defined in `.claude/agents/{agent_filename}.md` — read it first and follow all instructions.

## Review Scope

**Scope**: {diff|full}
**Files to review**:
{file_list — one file per line}

## Instructions

1. Read your system prompt at `.claude/agents/{agent_filename}.md`
2. Read your MEMORY.md for prior context about this codebase
3. Analyze each file in the list above according to your system prompt
4. Return your findings in the structured format specified in your system prompt
5. Update your MEMORY.md with new patterns discovered

Return ONLY your structured findings. Do not include explanatory prose.
```

Launch agents in parallel (4 always, plus Agent 5 if `SPAWN_FLOW_INTEGRATOR` is true). Each specialist is pinned to an explicit per-spawn `model` so the fan-out partially decorrelates (see the same-lab caveat below):
- **Agent 1**: Complexity Analyst → `.claude/agents/complexity-analyst.md` — `model: opus`
- **Agent 2**: DS&A Reviewer → `.claude/agents/ds-reviewer.md` — `model: sonnet` (deliberately differs from Complexity Analyst)
- **Agent 3**: Paradigm Enforcer → `.claude/agents/paradigm-enforcer.md` — `model: sonnet`
- **Agent 4**: Efficiency Sentinel → `.claude/agents/efficiency-sentinel.md` — `model: opus`
- **Agent 5** (conditional on `SPAWN_FLOW_INTEGRATOR`): Flow Integrator → `.claude/agents/flow-integrator.md` — `model: opus`

**Note (same-lab partial decorrelation):** pinning complexity-analyst / efficiency-sentinel / flow-integrator to Opus and ds-reviewer / paradigm-enforcer to Sonnet gives same-lab (Claude-tier) **partial** decorrelation — it catches some shared blind spots between differently-sized models from the same lab, but it is **not** a cross-lab hedge. A true cross-lab hedge requires manually pasting the diff into a different vendor's model (see `/design` Layer-3) — a distinct, human-driven mechanism this fan-out does not provide. This pin set is near-free / cost-neutral-to-lower when the main loop already runs Opus (today's common default), but is a real cost increase for the Opus-pinned specialists if the main loop runs on a cheaper model. (Fable stays holstered per CST-004 — never auto-pin/auto-select it as a specialist model.)

---

## Step 5: Collect Results

Wait for all agents to complete (4 or 5 depending on `AGENT_COUNT`). Each will return structured findings in their specified format:

- Complexity Analyst: `{severity} | {file}:{line} | {function} | {complexity} | {issue} | {suggested_approach}`
- DS&A Reviewer: `{severity} | {file}:{line} | {current_structure} | {access_pattern} | {recommended} | {rationale}`
- Paradigm Enforcer: `{severity} | {file}:{line} | {paradigm} | {violation_type} | {description} | {suggestion}`
- Efficiency Sentinel: `{severity} | {file}:{line} | {anti_pattern} | {impact} | {suggested_approach}`
- Flow Integrator (if spawned): `{severity} | {file}:{line} | {edge_description} | {flow_path} | {issue_description} | {suggested_fix}`

Parse each result set. If a subagent returned "No X findings." (or "No flow-integration findings." for Flow Integrator), record zero findings for that agent.

---

## Step 6: Aggregate

### 6a. Deduplicate

If two or more agents flag the same `file:line` (within 5 lines tolerance):
- Merge into a single finding
- List all contributing agents in the **Agent** field (e.g., "Complexity Analyst, Efficiency Sentinel")
- Use the **highest severity** from any contributing agent
- Combine issue descriptions

**Note on flow-integrator overlap**: Flow Integrator's findings focus on behavioral navigation correctness. They may occasionally overlap with design-quality agent findings (once GitHub issue #134 ships) when both flag the same component file. The same dedup rules apply — merge and list both agents in the Agent field.

### 6b. Assign Severity Tiers

Group all findings (after deduplication) into three tiers:
- **Critical**: All findings with severity "Critical"
- **Warning**: All findings with severity "Warning"
- **Suggestion**: All findings with severity "Suggestion"

### 6c. Number Findings

Within each tier, number sequentially:
- Critical: C1, C2, C3...
- Warning: W1, W2, W3...
- Suggestion: S1, S2, S3...

### 6d. Count Totals

Record:
- Total critical count
- Total warning count
- Total suggestion count
- Total files reviewed
- Total files with findings

---

## Step 7: Write Report

Read the report template at `src/wrought/skills/forge-review/report_template.md`.

Generate the report by filling in the template. Determine the output filename:

```
docs/reviews/{YYYY-MM-DD_HHMM}_{scope}.md
```

Where:
- `{YYYY-MM-DD_HHMM}` is the current timestamp
- `{scope}` is `diff` or `full`

Example: `docs/reviews/2026-03-03_1400_diff.md`

Create the `docs/reviews/` directory if it doesn't exist.

Write the completed report using the Write tool.

---

## Step 8: Pipeline Handoff

### When loop context is present (from Step 1.5)

If `finding_id` and `tracker_path` were extracted from the loop state:

**If Critical findings > 0**:
- Set the finding's stage to "Reviewed" in the tracker (it stays at Reviewed — not Resolved)
- Output blocking message:
  ```
  BLOCKED: {N} critical findings detected. Fix critical issues and re-run `/forge-review --scope=diff`.
  Review report: {output_path}
  ```
- Do NOT advance to Resolved. The finding remains at "Reviewed" until criticals are fixed.

**If Critical == 0, but Warnings or Suggestions exist**:
- Auto-append each Warning as a new F-number in the tracker with type "Review Warning" and severity "Medium", recommended next step `/rca-bugfix`
- Auto-append each Suggestion as a new F-number in the tracker with type "Review Suggestion" and severity "Low", recommended next step `/simplify`
- Set the original finding's stage to "Reviewed", then immediately advance to "Resolved"
- Output:
  ```
  Review complete. Original finding {finding_id} → Resolved.

  ZERO CARRY-OVERS — {N} new review findings MUST be resolved before session end:
  {For each new F-number: "  F{N}: {severity} — {title} → {recommended action (/rca-bugfix or /simplify)}"}

  Address warnings via /rca-bugfix and suggestions via /simplify NOW.
  Do NOT proceed to /session-end until all review findings are Resolved.
  Review report: {output_path}
  ```

**If clean (0 critical, 0 warnings, 0 suggestions)**:
- Set the original finding's stage to "Reviewed", then immediately advance to "Resolved"
- Output:
  ```
  Clean review. Finding {finding_id} → Resolved.
  Review report: {output_path}
  ```

### When no loop context (standalone invocation)

If any **Critical** or **Warning** findings exist:

```
Findings detected ({N} critical, {N} warnings). Consider running `/finding` to create a Findings Tracker for remediation.
```

If any **Suggestion** findings exist:

```
{N} suggestions detected that may be auto-fixable. Consider running `/simplify` to address them.
```

**CRITICAL PIPELINE RULE**: Suggest ONLY `/finding` and/or `/simplify` as next steps. Do NOT offer to implement fixes. Do NOT offer to skip pipeline steps.

### Promote durable Rejected dispositions (Active Constraints)

When a Suggestion is intentionally **Rejected** with a *durable* rationale ("don't do X / don't re-propose Y because Z") — in addition to recording "Resolved: Rejected — {rationale}" in the tracker (rule 9) — promote it to the `## Active Constraints (in force)` section in `CLAUDE.md` (append under `### Durable invariants`):
```
- **[CST-NNN]** <don't-do-X> — clears: `SUPERSEDED-ONLY` · owner: S{session} · why: <rejection rationale> · ref: <review report>
```
so the rejected guidance is required-read and isn't re-surfaced in a future review. Text-persistence, not compliance (see CONVENTIONS.md). Skip transient/style rejections.

---

## Step 9: Display Summary

Output to the user:

```
Review complete: {N} critical, {N} warnings, {N} suggestions across {N} files ({AGENT_COUNT} agents run).
Report saved to {output_path}.

{If flow-integrator spawned}:
Flow-integration pass was performed (diff touched navigation surfaces).

{If critical > 0 or warnings > 0}:
Findings detected ({N} critical, {N} warnings). Consider running `/finding` to create a Findings Tracker for remediation.

{If suggestions > 0}:
{N} suggestions detected that may be auto-fixable. Consider running `/simplify` to address them.

{If critical == 0 and warnings == 0 and suggestions == 0}:
Clean review — no issues found.
```

**STOP** — await user instructions. Do NOT proceed with fixes or implementations.

---

## Read-Only Guarantee

This skill and its subagents are **read-only** with respect to the user's source code:

- **Subagents**: Have `tools: Read, Grep, Glob, Bash` — no Write/Edit. Memory writes go to each agent's declared scope — the review agents use `local` (`.claude/agent-memory-local/<name>/`); `decorrelation-critic` has no memory.
- **Orchestrator**: Uses Write ONLY to create the review report in `docs/reviews/`. Never modifies source code, configuration files, or any file outside `docs/reviews/`.

If you find yourself about to modify a source file — **STOP**. That is not your job. Report the finding in the review.

---

## Flags

```
--scope=diff     Review only changed files (default)
--scope=full     Review all project source files
```

No `--batch` mode — review is always non-interactive (subagents work autonomously).

---

## Example Invocations

```
/forge-review                              → Review changed files (diff scope)
/forge-review --scope=full                 → Review entire codebase
/forge-review --scope=full src/wrought/    → Review all files in src/wrought/
/forge-review src/wrought/cli/main.py      → Review specific changed file
```

---

## Findings Tracker Update Protocol

When loop context is present (Step 1.5 extracted `finding_id` and `tracker_path`), follow `_shared/tracker_update_checklist.md` with these parameters:

| Parameter | Value |
|-----------|-------|
| `{STAGE_NAME}` | Reviewed |
| `{TASK_DESCRIPTION}` | FN.5: Code review |
| `{ARTIFACT_TYPE}` | Review report |
| `{ARTIFACT_PATH_PATTERN}` | `docs/reviews/{YYYY-MM-DD_HHMM}_{scope}.md` |

### Lifecycle updates performed in Step 8:

1. Update overview table: Stage → "Reviewed", Status → "In Progress"
2. Append lifecycle row: `| Reviewed | {timestamp} | {session} | [Review report]({report_path}) |`
3. Check task: `[x] **FN.5**: Code review...`
4. Changelog: `FN stage → Reviewed. Review report: {report_path}`
5. If advancing to Resolved (clean or non-critical): also update Stage → "Resolved", Status → "Resolved", append second lifecycle row, check FN.5 task
6. Sync to GitHub Projects (NON-FATAL): Protocol B — Lifecycle Stage = Reviewed, Status = In Progress

When no loop context, skip all tracker updates.
