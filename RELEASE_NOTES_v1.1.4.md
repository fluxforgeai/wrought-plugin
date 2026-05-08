# wrought-plugin v1.1.4 — Privacy Redaction

**Release**: 2026-05-08
**Type**: Patch (privacy fix)

## Changes

- Genesis skill example replaced: `Kuda Data Connector — REST API for banking data aggregation` → `Acme Banking API — REST API for banking data aggregation` and `kuda_data_connector` → `acme_banking_api`. Privacy-redaction; matches canonical state from `wrought` commit `f101924` (Session 98 sweep) propagated via `wrought publish-plugin --bump=patch` after the canonical genesis SKILL.md was updated.

## Known regressions (carried over from Session-97 publish-plugin gaps)

The following Session 97 gaps in `wrought publish-plugin` are not yet fixed and are documented here per the v1.1.4 sweep's accept-and-document strategy. Fixes are tracked under separate findings; a v1.1.5 release will address them after pipeline clears.

1. **`marketplace.json` lockstep** — `publish-plugin` bumps `plugins/wrought/.claude-plugin/plugin.json` only; the top-level `.claude-plugin/marketplace.json` plugin entries do not carry a per-plugin version field in v1.1.4 (intentional, matches Anthropic's exact working pattern from Session 97 `f246e4b`). If a future schema requires version pinning at the marketplace level, that will be added in v1.1.5.

2. **`git-subdir` source format** — Resolved canonically in Session 97 (`91c016b`); marketplace.json now uses the `git-subdir` object form required by Claude Code v2.1.126+. v1.1.4 inherits this state unchanged.

3. **Unprefixed command refs** — Skill content references commands as `/blueprint`, `/finding`, etc.; plugin users must mentally substitute `/wrought:blueprint`, `/wrought:finding`. No rewrite at sync time. v1.1.4 inherits this; documentation rewrite planned for v1.1.5.

4. **README canonical-managed** — `wrought publish-plugin` does not propagate canonical README changes back into the plugin repo. v1.1.4 inherits the existing plugin-side README from Session 97 (`b57ebb3` namespace-all-slash-commands edit). If canonical README changes need to flow plugin-side, hand-sync until v1.1.5.

5. **`.sh` mode-bit preservation through squash-merge** — `shutil.copy2` preserves executable bit during canonical-to-plugin sync, but a subsequent squash-merge (`git checkout main --`) can lose `100755 → 100644`. v1.1.4 ships with the mode-bit issue if applicable on watchdog scripts; v1.1.5 will include a workaround.

## Tracking

These five gaps are tracked under separate findings in the `wrought` repo at `docs/findings/`. Search for "publish-plugin" tracker.

## Verification

- Plugin tree contains zero references to the redacted strings (`grep -r -i 'Kuda\|Eben\|Nagesh' . | grep -v .git/`)
- Plugin version: `1.1.4` (in `plugins/wrought/.claude-plugin/plugin.json`)
- Genesis quick-start uses the `Acme Banking API` example consistently
- Canonical state at `wrought` commit `3356ffa` (post-redaction main HEAD)

## Related

- Findings: `docs/findings/2026-05-07_1452_employer_redaction_drift_FINDINGS_TRACKER.md` (High Drift — F1 closed by this release)
- Findings: `docs/findings/2026-05-07_1552_redaction_drift_gh_metadata_FINDINGS_TRACKER.md` (Medium Drift — F1 closed alongside)
- Plan: `docs/plans/2026-05-07_1926_employer_redaction_combined_sweep.md`
- Cardinal rule 10 amendment: `CLAUDE.md` (employer extension + redaction-meta-document carve-out clause)
