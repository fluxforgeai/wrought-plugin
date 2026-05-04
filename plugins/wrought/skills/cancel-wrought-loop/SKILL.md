---
name: cancel-wrought-loop
description: "Cancel the active Wrought™ implementation/RCA loop"
disable-model-invocation: false
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - write_file
  platforms:
    claude-code:
      allowed-tools: "Read, Write"
      disable-model-invocation: false
  agent:
    role: "Loop Manager"
    expertise:
      - "loop state management"
    non_goals:
      - "implementation"
      - "investigation"
  execution:
    default_mode: react
    stop_conditions:
      - "Loop state set to inactive"
      - "User instructed to stop"
  output:
    format: markdown
    template: ".claude/wrought-loop-state.json"
    required_sections:
      - "Cancellation report"
  pipeline:
    track: standalone
    standalone: true
    prerequisites: []
    produces:
      - ".claude/wrought-loop-state.json"
---

# Cancel Wrought Loop

## Step 1: Read Loop State

Read `.claude/wrought-loop-state.json`.

- If the file does not exist: "No active loop found. Nothing to cancel."
- If `active` is `false`: "Loop is already inactive. Last run: {preset} with {current_iteration} iterations."

## Step 2: Deactivate

Set `active` to `false` in `.claude/wrought-loop-state.json`. Add a cancellation entry to `history`:
```json
{
  "iteration": {current_iteration},
  "result": "cancelled",
  "exit_code": null,
  "timestamp": "{ISO timestamp}"
}
```

## Step 3: Report

Report to the user:
- Preset: {preset}
- Iterations completed: {current_iteration} / {max_iterations}
- Last result: {last history entry result, or "none"}
- Capsule location: `docs/capsules/{finding_id}/`
- "Loop cancelled. You may resume work manually or start a new loop."
