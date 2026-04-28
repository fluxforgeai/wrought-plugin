# Changelog

## [1.1.0] - 2026-04-28

### Added
- **`flow-integrator` agent**: 5th `/forge-review` subagent. Reviews navigation-surface changes (routes, links, nav items, redirects, wizards) for end-to-end flow integrity. Conditionally spawned when the diff touches navigation surfaces.
- **`/ux-design` skill**: Generates a Design Brief with application-type-aware design system, typography, color, motion, and anti-patterns. Used between `/design` and `/blueprint` for frontend work to avoid generic AI aesthetics.
- **`/ux-design` slash command stub** alongside the skill.
- **`skills/_shared/`**: Shared utility templates (`context_check.md`, `post_plan_menu.md`, `tracker_update_checklist.md`) referenced across pipeline skills.
- **Full slash-command coverage**: 18 `commands/*.md` stubs (was 5) — now every pipeline skill has a matching slash command in addition to the skill body.
- **™ marks** on `Wrought` and `FluxForge AI` brand mentions in README.
- **Brand Use Notice** paragraph near License section (same pattern as Cursor/Sentry/Supabase) — code is MIT, brand names are not.

### Changed
- Refreshed all existing skills, commands, agents, and hook scripts from source as of 2026-04-28. Five weeks of upstream evolution since v1.0 — pipeline enforcement rules, zero-carry-over forge-review, context-compaction resilience, ralph-loop tightening, structured artifact index, skill-handoff prepopulation, etc.
- Install command corrected: `claude plugin add fluxforgeai/wrought-plugin` (was incorrectly pointing at the private core repo path).
- `plugin.json` `homepage` set to `https://fluxforge.ai` (was pointing at the private core repo URL).
- Sanitized illustrative API examples in `research`, `investigate`, and `analyze` skills — replaced internal-project-fingerprinting names with widely-known canonical APIs.

### Notes
- Plugin tracks the snapshot of the canonical source as of 2026-04-28. Future releases will sync at deliberate cadence rather than continuously.
- Agents (`complexity-analyst`, `ds-reviewer`, `efficiency-sentinel`, `flow-integrator`, `paradigm-enforcer`) use a per-project `MEMORY.md` pattern. On fresh install, the memory is empty until the agent has run on the codebase a few times.

## [1.0.0] - 2026-03-26

### Added
- Initial plugin release with 12 skills, 4 agents, 3 hooks, 5 commands
- Tiered progressive disclosure: Start Here (finding, research, forge-review), Core Pipeline (design, blueprint, investigate, rca-bugfix, incident), Advanced (analyze, genesis, safeguard, watchdog)
- Stop hook with verifier loop for autonomous implementation
- Context alert hook for context window monitoring
- PreCompact hook for session state preservation
