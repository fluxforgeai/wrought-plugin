# Wrought™ -- Structured Engineering Methodology for Claude Code

A disciplined, pipeline-driven approach to software engineering that replaces ad-hoc coding with structured investigation, design, and implementation workflows.

## Quick Start

Install the plugin in your project:

```bash
claude plugin add fluxforgeai/wrought-plugin
```

**Step 1**: Start tracking work

```
/finding "describe the problem, feature, or debt item"
```

**Step 2**: Follow the pipeline

- **Proactive** (new features, improvements): `/research` -> `/design` -> [`/ux-design`] -> `/blueprint` -> `/wrought-implement` -> `/forge-review`
- **Reactive** (bugs, incidents): `/incident` -> `/investigate` -> `/rca-bugfix` -> `/wrought-rca-fix` -> `/forge-review`

**Step 3**: Review

```
/forge-review --scope=diff
```

## Skills

### Tier 1: Start Here

| Skill | Description |
|-------|-------------|
| `/genesis` | Greenfield/brownfield project onboarding wizard. Produces PRD + ARCHITECTURE.md |
| `/finding` | Create a Findings Tracker for cross-session memory and audit trail |
| `/incident` | Structured incident capture with timeline and impact assessment |

### Tier 2: Core Pipeline

| Skill | Description |
|-------|-------------|
| `/research` | Deep research with external sources and documentation review |
| `/design` | Interactive design analysis with tradeoff evaluation and recommendations |
| `/ux-design` | Generate a Design Brief — application-type-aware design system, typography, colour, motion, anti-patterns. Used between `/design` and `/blueprint` for frontend work. |
| `/blueprint` | Transform design into implementation spec and prompt for /plan |
| `/investigate` | Root cause investigation with hypothesis testing and evidence gathering |
| `/rca-bugfix` | Root cause analysis document and fix design with implementation prompt |
| `/forge-review` | Multi-agent code review (complexity, data structures, paradigm, efficiency, flow-integrity) |

### Tier 3: Advanced

| Skill | Description |
|-------|-------------|
| `/analyze` | Codebase architecture analysis and system mapping |
| `/safeguard` | Environment profiling and deployment risk detection |
| `/watchdog` | Continuous monitoring and drift detection |

## Commands

| Command | Description |
|---------|-------------|
| `/wrought-implement` | Start autonomous implementation loop with test verification |
| `/wrought-rca-fix` | Start autonomous bugfix loop with test verification |
| `/cancel-wrought-loop` | Cancel the active implementation/RCA loop |
| `/session-start` | Start new session with context loading and greeting |
| `/session-end` | End session with handoff documentation and tracker updates |

## Pipeline Overview

### Proactive Track (Features, Improvements, Tech Debt)

```
/finding -> /research -> /design -> [/ux-design] -> /blueprint -> /plan -> /wrought-implement -> /forge-review
```

Each step produces artifacts consumed by the next. The pipeline enforces quality gates -- you cannot skip steps without explicit override.

### Reactive Track (Bugs, Incidents, Outages)

```
/incident -> /investigate -> /rca-bugfix -> /plan -> /wrought-rca-fix -> /forge-review
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
