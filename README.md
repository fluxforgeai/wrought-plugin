# Wrought™ -- Structured Engineering Methodology for Claude Code

A disciplined, pipeline-driven approach to software engineering that replaces ad-hoc coding with structured investigation, design, and implementation workflows.

## Quick Start

Install inside a Claude Code session:

```
/plugin marketplace add fluxforgeai/wrought-plugin
/plugin install wrought@wrought-plugin
/reload-plugins
```

The first command registers this repo as a Claude Code plugin marketplace; the second installs the `wrought` plugin from it; the third activates the skills, agents, and slash commands. Restart your Claude Code session if it prompts you to.

### Slash command namespacing

Claude Code namespaces plugin-provided slash commands under the plugin name. After installing, all Wrought commands are invoked as **`/wrought:<name>`** — for example, `/wrought:finding`, not `/finding`. Plain unprefixed forms will return `Unknown command`.

**Step 1**: Start tracking work

```
/wrought:finding "describe the problem, feature, or debt item"
```

**Step 2**: Follow the pipeline

- **Proactive** (new features, improvements): `/wrought:research` -> `/wrought:design` -> [`/wrought:ux-design`] -> `/wrought:blueprint` -> `/wrought:wrought-implement` -> `/wrought:forge-review`
- **Reactive** (bugs, incidents): `/wrought:incident` -> `/wrought:investigate` -> `/wrought:rca-bugfix` -> `/wrought:wrought-rca-fix` -> `/wrought:forge-review`

**Step 3**: Review

```
/wrought:forge-review --scope=diff
```

## Skills

### Tier 1: Start Here

| Slash command | Description |
|---------------|-------------|
| `/wrought:genesis` | Greenfield/brownfield project onboarding wizard. Produces PRD + ARCHITECTURE.md |
| `/wrought:finding` | Create a Findings Tracker for cross-session memory and audit trail |
| `/wrought:incident` | Structured incident capture with timeline and impact assessment |

### Tier 2: Core Pipeline

| Slash command | Description |
|---------------|-------------|
| `/wrought:research` | Deep research with external sources and documentation review |
| `/wrought:design` | Interactive design analysis with tradeoff evaluation and recommendations |
| `/wrought:ux-design` | Generate a Design Brief — application-type-aware design system, typography, colour, motion, anti-patterns. Used between `/wrought:design` and `/wrought:blueprint` for frontend work. |
| `/wrought:blueprint` | Transform design into implementation spec and prompt for `/plan` |
| `/wrought:investigate` | Root cause investigation with hypothesis testing and evidence gathering |
| `/wrought:rca-bugfix` | Root cause analysis document and fix design with implementation prompt |
| `/wrought:forge-review` | Multi-agent code review (complexity, data structures, paradigm, efficiency, flow-integrity) |

### Tier 3: Advanced

| Slash command | Description |
|---------------|-------------|
| `/wrought:analyze` | Codebase architecture analysis and system mapping |
| `/wrought:safeguard` | Environment profiling and deployment risk detection |
| `/wrought:watchdog` | Continuous monitoring and drift detection |

## Commands

| Slash command | Description |
|---------------|-------------|
| `/wrought:wrought-implement` | Start autonomous implementation loop with test verification |
| `/wrought:wrought-rca-fix` | Start autonomous bugfix loop with test verification |
| `/wrought:cancel-wrought-loop` | Cancel the active implementation/RCA loop |
| `/wrought:session-start` | Start new session with context loading and greeting |
| `/wrought:session-end` | End session with handoff documentation and tracker updates |

## Pipeline Overview

### Proactive Track (Features, Improvements, Tech Debt)

```
/wrought:finding -> /wrought:research -> /wrought:design -> [/wrought:ux-design] -> /wrought:blueprint -> /plan -> /wrought:wrought-implement -> /wrought:forge-review
```

Each step produces artifacts consumed by the next. The pipeline enforces quality gates -- you cannot skip steps without explicit override. (Note: `/plan` is Claude Code's built-in plan-mode command, not a Wrought-provided slash command, so it has no `/wrought:` prefix.)

### Reactive Track (Bugs, Incidents, Outages)

```
/wrought:incident -> /wrought:investigate -> /wrought:rca-bugfix -> /plan -> /wrought:wrought-rca-fix -> /wrought:forge-review
```

Starts with structured incident capture, proceeds through investigation and root cause analysis, then implements the fix with automated verification.

### Key Concepts

- **Findings Tracker**: Cross-session memory that tracks work items through the pipeline. Every significant task gets a tracker.
- **Ralph Wiggum Loop**: Autonomous implementation loop where a Stop hook runs the test verifier after each iteration, blocking exit until tests pass.
- **Capsule Artifacts**: Each loop iteration produces a capsule (`docs/capsules/{id}/iter_{n}/`) with verifier output for debugging.
- **Pipeline Enforcement**: Skills validate that prerequisite artifacts exist before executing.

## Getting Help

- Website: [fluxforge.ai](https://fluxforge.ai)
- For consulting and custom integrations, contact FluxForge AI™

## Brand Use Notice

The source code in this repository is licensed under MIT (see LICENSE). However,
the names "Wrought", "FluxForge AI", and any associated logos or wordmarks are
trademarks of FluxForge AI and are not licensed under MIT. You are welcome to
fork, modify, redistribute, and build on this code under MIT terms. You are not
licensed to use the names "Wrought" or "FluxForge AI" to market a competing or
substantially-derivative product without express written permission.

If you build something on top of this code, please pick your own name. We will
help amplify your work; we will not let you confuse our users about whose work
they are using.

## License

MIT
