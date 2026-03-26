---
name: rca-bugfix
description: "Root cause analysis and bug fix procedure. Investigates bugs, documents the RCA, and creates an implementation prompt for the fix. Use after /investigate or /finding."
disable-model-invocation: true
argument-hint: "[finding-ref or description]"
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - search_content
      - find_files
      - write_file
      - edit_file
      - run_command
  platforms:
    claude-code:
      disable-model-invocation: true
  agent:
    role: "RCA Engineer"
    expertise:
      - "root cause analysis"
      - "bug fixing"
      - "implementation planning"
    non_goals:
      - "architectural redesign"
      - "feature development"
  execution:
    default_mode: hypothesis-rca
    optional_modes:
      - self-refine
    max_iterations: 12
    max_refine: 1
    stop_conditions:
      - "RCA document written to docs/RCAs/"
      - "Implementation prompt written to docs/prompts/"
      - "User instructed to stop"
  output:
    format: markdown
    template: "docs/RCAs/{YYYY-MM-DD_HHMM}_{name}.md"
    required_sections:
      - "Summary"
      - "Root Cause"
      - "Evidence"
      - "Fix"
      - "Verification"
    prohibited_content:
      - "credentials"
      - "secrets"
  pipeline:
    track: reactive
    standalone: false
    prerequisites:
      - "docs/investigations/*.md"
      - "docs/findings/*.md"
    produces:
      - "docs/RCAs/*.md"
      - "docs/prompts/*.md"
    suggested_next:
      - plan
---

# RCA Bug Fix Procedure

**Trigger**: Use `/rca-bugfix {issue description}` when investigating and fixing bugs that require root cause analysis.

**Examples**:
- `/rca-bugfix health check timeout causing gray indicators on monitor page`
- `/rca-bugfix rate limiting still happening despite batch processing implementation`
- `/rca-bugfix extractions stuck at 0 records during streaming`

## Prerequisites

Before executing this skill, verify ALL of the following:
1. **Use Glob** to check for: `docs/investigations/*.md`
   - If NO match -> **STOP**: "Run /investigate first to create an investigation report."
   - If user says `--force`, proceed without validation.
2. **Read** the most recent Findings Tracker matching `*_FINDINGS_TRACKER.md`
   - Identify the relevant finding (ask user if ambiguous)

## Pre-flight Check

1. Verify artifact prerequisites (above)
2. Identify which finding/workflow this is for
3. Load finding report and related artifacts for context
4. Proceed to main skill instructions

---

## Instructions

The user has provided an issue to investigate. Reason thoroughly about this issue — trace the root cause through evidence before proposing a fix.

**Issue to investigate**: The argument passed after `/rca-bugfix`

---

## Input Sources

Before starting, check for upstream artifacts: `docs/investigations/*.md` (from `/investigate`), `docs/findings/*.md` (from `/finding`), or work from the user-provided description. When a finding report provides a known cause, focus on confirming it, defining the fix, and writing the implementation prompt.

---

## CRITICAL: File Naming Convention

**ALL files MUST use this exact format**: `{YYYY-MM-DD_HHMM}_{issue_name}.md`

Yes: `2026-01-22_1700_stream_download_timeout.md`
No: `RCA_STREAM_DOWNLOAD_TIMEOUT_2026-01-22.md` — no prefix, date comes FIRST

---

### Context Check

## Step 1: Initial Context Check

Ask the user to run `/context` and share the output.

Based on the context usage:

### If context > 80% (not enough room):
1. Perform an expert-level RCA of the issue
2. Write the RCA to `docs/RCAs/{YYYY-MM-DD_HHMM}_{name}.md`
3. Tell the user: "Context is high. RCA saved. Please run `/session-end` and start a new session."
4. **STOP** - Do not proceed further

### If context <= 80% (enough room):
1. Perform an expert-level RCA of the issue
2. Write the RCA to `docs/RCAs/{YYYY-MM-DD_HHMM}_{name}.md`
3. Using the RCA, write an expert-level prompt for `/plan` mode
4. Write the prompt to `docs/prompts/{YYYY-MM-DD_HHMM}_{name}.md`
5. Proceed to Step 2

## Step 2: Pre-Planning Context Check

Ask the user to run `/context` again and share the output.

### If context > 85% (not enough room for planning):
1. Tell the user: "Context too high for planning. Please run `/session-end` and start a new session."
2. Tell the user: "In the next session, run `/plan` with the prompt saved at `docs/prompts/{YYYY-MM-DD_HHMM}_{name}.md`"
3. **STOP**

### If context <= 85% (enough room):
1. Tell the user: "Ready for planning. Please run `/plan`"
2. When in plan mode, use the expert-level prompt you wrote to guide the implementation plan

---

## Findings Tracker Update Protocol

## At the START of work

Check if this work relates to a tracked finding:

1. If input contains `F{N}` (e.g., "F1", "F3"), search `docs/findings/*_FINDINGS_TRACKER.md` for that finding
2. If input is topic-based, search active trackers for a matching finding title
3. If a match is found:
   a. Read the tracker and any linked artifacts (finding report, investigation, design analysis)
   b. Use these as context for the current work

## At the END of work

After writing the output artifact(s):

1. Update the tracker's overview table: set `Stage` to `RCA Complete`, set `Status` to `In Progress`
2. Update the per-finding **Lifecycle** table — append row:
   ```
   | RCA Complete | {YYYY-MM-DD HH:MM} UTC | {session} | [RCA + Prompt]({rca_path} + {prompt_path}) |
   ```
3. Check the resolution task: `[x] **FN.2: RCA + fix design**...`
4. Add changelog entry:
   ```
   | {YYYY-MM-DD HH:MM} UTC | {session} | FN stage -> RCA Complete. RCA + Prompt: {rca_path} + {prompt_path} |
   ```
5. Update `Last Updated` timestamp at top of tracker
6. Sync to GitHub Projects (NON-FATAL) — read `docs/reference/github_projects_sync_protocol.md`, follow Protocol B: Lifecycle Stage = RCA Complete (`3e226861`), Status = In Progress (`47fc9ee4`), Evidence = artifact path(s). If `**Project Item ID**:` is missing or `—`, skip sync with a note.

## HANDOFF UPDATE

After the standard handoff message to the user, add:

```
Tracker updated: {tracker_path} — FN stage -> RCA Complete

After /plan completes, update the tracker:
- Stage -> Planned
- Lifecycle row: `| Planned | {timestamp} | {session} | [Plan]({plan_path}) |`
- Check task: `[x] **FN.3**: Implementation plan...`
- Changelog: `FN stage -> Planned. Plan: {plan_path}`
- GitHub sync (NON-FATAL): Protocol B — Lifecycle Stage = Planned (`a66cfac9`), Status = In Progress (`47fc9ee4`)
```

If no matching finding exists, proceed normally — not all work originates from findings.

---

## RCA Template

When writing RCAs, use this structure:

```markdown
# Root Cause Analysis: {Issue Title}

**Date**: {YYYY-MM-DD}
**Severity**: {Critical/High/Medium/Low}
**Status**: {Investigating/Identified/Resolved}

## Problem Statement
{Clear description of the issue}

## Symptoms
- {Observable symptom 1}
- {Observable symptom 2}

## Root Cause
{The actual underlying cause}

## Evidence
{Code snippets, logs, or data supporting the root cause}

## Impact
{What was affected and how}

## Resolution
{How to fix it}

## Prevention
{How to prevent this in the future}

## Debug Strategy (optional — include when fix involves testable code)
- **Self-debug**: enabled | disabled
- **Verifier**: {command} (e.g., `uv run pytest tests/ -q`)
- **Max iterations**: {N}
- **Completion criteria**: {what "done" means — e.g., "bug no longer reproducible, all tests pass"}
- **Escape hatch**: After {N} iterations, document blockers and request human review
- **Invoke with**: `/wrought-rca-fix` (activates Stop hook verifier loop)
```

---

## Prompt Template

When writing prompts for `/plan` mode, use this structure:

```markdown
# Implementation Prompt: {Issue Title}

**RCA Reference**: docs/RCAs/{YYYY-MM-DD_HHMM}_{issue_name}.md

## Context
{Brief summary of the root cause}

## Goal
{What needs to be implemented/fixed}

## Requirements
1. {Requirement 1}
2. {Requirement 2}

## Files Likely Affected
- {file1.py}
- {file2.tsx}

## Constraints
- {Any constraints or considerations}

## Acceptance Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

---

## Plan Output Instructions

**IMPORTANT**: Before creating the implementation plan, you MUST enter plan mode:

1. Call `EnterPlanMode` to enter plan mode (compresses context and enables read-only exploration)
2. Explore the codebase and design your implementation approach using read-only tools (Read, Grep, Glob)
3. Write the plan to `docs/plans/{YYYY-MM-DD_HHMM}_{issue_name}.md` including:
   - Summary of the approach
   - Step-by-step implementation tasks
   - Files to modify with specific changes
   - Testing strategy
   - Rollback plan (if applicable)
4. Call `ExitPlanMode` to present the plan for user approval
5. **Wait for user approval** before proceeding to implementation
6. After plan approval, invoke `/wrought-rca-fix` to start the autonomous bugfix loop with test verification.
```

---

## Completion

After writing the RCA and implementation prompt:

1. Update the Findings Tracker (per protocol above)
2. Tell the user what was produced:
   - RCA saved to `docs/RCAs/{name}.md`
   - Implementation prompt saved to `docs/prompts/{name}.md`
3. If context is high (>85%), note: "Context is high. Consider `/session-end`, then `/plan` in the next session."

**CRITICAL PIPELINE RULE**: Suggest ONLY the next pipeline step below. Do NOT offer to implement. Do NOT offer to skip `/plan`. Do NOT offer alternatives to the pipeline sequence.

Next step: Run `/plan` with the prompt at `docs/prompts/{name}.md` to create the implementation plan.

4. **STOP** — do NOT proceed to implementation, do NOT offer to implement. Do NOT add commentary suggesting any pipeline step could be skipped or is unnecessary. Await user instructions.
