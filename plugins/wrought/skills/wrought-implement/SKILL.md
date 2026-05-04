---
name: wrought-implement
description: "Start an autonomous implementation loop with test verification"
disable-model-invocation: false
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
      allowed-tools: "Read, Grep, Glob, Write, Edit, Bash"
      disable-model-invocation: false
  agent:
    role: "Implementation Engineer"
    expertise:
      - "code implementation"
      - "test-driven development"
    non_goals:
      - "architectural design"
      - "investigation"
  execution:
    default_mode: react
    stop_conditions:
      - "Verifier passes (all tests green)"
      - "Max iterations reached"
      - "User instructed to stop"
  output:
    format: markdown
    template: "docs/capsules/{finding_id}/iter_{N}/run.log"
    required_sections:
      - "Implementation summary"
      - "Verifier result"
  pipeline:
    track: proactive
    standalone: false
    prerequisites:
      - "docs/plans/*.md"
    produces:
      - "docs/capsules/**/run.log"
      - ".claude/wrought-loop-state.json"
    suggested_next:
      - forge-review
---

# Wrought™ Implement — Autonomous Implementation Loop

You are starting a Ralph Wiggum inner loop for implementation. A Stop hook will automatically verify your work after each attempt to stop.

## Step 1: Check for Active Loop

Read `.claude/wrought-loop-state.json`. If it exists and `active` is `true`:
- **WARN**: "An active loop already exists. Run `/cancel-wrought-loop` first, or continue the existing loop."
- **STOP** — do not proceed.

## Step 2: Identify the Plan

The user should provide a plan path. If not provided:
1. Use Glob to find the most recent file in `docs/plans/*.md`
2. Read it and confirm with the user: "Found plan: {path}. Proceed?"

## Step 3: Read Verifier Config

Read the `.wrought` marker file and extract:
- `verifier_type` — if `none`, ask the user: "What verifier command should I use? (e.g., `uv run pytest tests/ -q`)"
- `verifier_test_path` — default test path
- `verifier_max_loops` — iteration budget
- `verifier_timeout` — per-run timeout in seconds

## Step 4: Initialize Loop State

Write `.claude/wrought-loop-state.json`:
```json
{
  "active": true,
  "preset": "wrought-implement",
  "finding_id": "{from plan or Findings Tracker}",
  "tracker_path": "{path to active FINDINGS_TRACKER.md}",
  "verifier_command": "{verifier command}",
  "max_iterations": {from marker},
  "current_iteration": 0,
  "started_at": "{ISO timestamp}",
  "history": []
}
```

## Step 4.5: Load Design Context (Frontend Work Only)

Read the implementation plan and check for frontend files. If the plan's "Files to modify" / "Files Likely Affected" section (or any file path mentioned in the plan body) contains any of these extensions: `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`, `.html` — proceed with this step. Otherwise, skip silently to Step 5 (no warning, no message).

1. Search for design context in this priority order, first match wins:
   - `docs/design-briefs/*.md` — use Glob; if multiple match, pick the most recent by filename date prefix (lexicographic sort = chronological for `YYYY-MM-DD_HHMM` naming convention)
   - `DESIGN_SYSTEM.md` at the repo root
   - `.wrought/design-system.md`
2. If a design context document is found:
   - Read it fully
   - Extract key sections: design tokens, typography, color, motion, anti-patterns
   - Use these as implementation context for Step 5 — produce frontend code that follows these conventions
3. If NO design context document is found on a frontend plan:
   - Print this exact warning: `No Design Brief found for frontend work. Consider running /ux-design first for better design quality. Proceeding without design context.`
   - Continue to Step 5 — this is a soft recommendation, not a hard gate

## Step 5: Implement

1. Read the implementation plan thoroughly
2. Implement changes step by step, following the plan's sequence
3. After implementing, the Stop hook will automatically run the verifier
4. If the verifier fails, you will be blocked — analyze the error output and fix
5. Continue until all tests pass

## Step 6: Completion

When the loop completes (verifier passes):
1. Read the final `.claude/wrought-loop-state.json` to summarize iterations
2. Report: "Implementation complete after {N} iterations. Capsule artifacts at `docs/capsules/{finding_id}/`"
3. Update the Findings Tracker with implementation status
4. Suggest: "Tests pass. Next: run `/forge-review --scope=diff` to verify code quality."
