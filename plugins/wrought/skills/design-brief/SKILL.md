---
name: design-brief
description: "Produce an adversarially-verified, source-cited, full-stack, interactive HTML decision brief for informed go/no-go sign-off at a human decision boundary. MVP mode: pivot-review. Extends /ux-design; consumes /research and /design; feeds /design on GO."
disable-model-invocation: false
argument-hint: "<decision-name> [--mode=pivot-review] [--force]"
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch, Write, Agent
effort: xhigh
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - search_content
      - find_files
      - web_search
      - web_fetch
      - write_file
      - delegate
  platforms:
    claude-code:
      allowed-tools: "Read, Grep, Glob, WebSearch, WebFetch, Write, Agent"
      disable-model-invocation: false
  agent:
    role: "Decision-Brief Synthesist"
    expertise:
      - "honest technical synthesis"
      - "source verification (fetch-and-field-match)"
      - "self-contained interactive HTML / data-viz"
      - "adversarial de-hyping"
    non_goals:
      - "writing production code"
      - "replacing /research, /design, /ux-design, or /blueprint"
      - "fabricating or over-claiming sources"
      - "deciding the go/no-go (the human owner decides)"
  execution:
    default_mode: react
    max_iterations: 8
    stop_conditions:
      - "Interactive brief saved to docs/design-briefs/ (durable, required)"
      - "Structural self-check passed"
      - "Artifact publish attempted (best-effort — cleanly skipped if the Artifact tool is unavailable)"
      - "User instructed to stop"
  output:
    format: html
    template: "docs/design-briefs/{YYYY-MM-DD_HHMM}_{decision}.html"
    required_sections:
      - "Honest Thesis"
      - "As-Is / To-Be / Change Map"
      - "Cost (dual-framed)"
      - "Benefit (claim to evidence to honest ceiling)"
      - "References (verified, confidence-tiered)"
      - "Glossary"
      - "Decision Requested"
  pipeline:
    track: proactive
    standalone: false
    prerequisites: []
    produces:
      - "docs/design-briefs/*.html"
    suggested_next:
      - design
---

# Design Brief Skill

**Trigger**: `/design-brief <decision-name> [--mode=pivot-review] [--force]`

**Purpose**: Render a proposed change as an adversarially-verified, source-cited, self-contained **interactive HTML decision brief** — a "wireframe on steroids" — so a human can understand and sign off on the direction before expensive, hard-to-reverse work begins. This is a **communication + decision gate**, not a production step. It **extends** `/ux-design` (frontend-only markdown Design Brief → full-stack interactive HTML), **consumes** `/research` and `/design`, and **feeds** `/design` on a GO.

**MVP scope**: only the `pivot-review` mode is implemented. The honesty spine — ≥3 diverse adversarial lenses, fetch-and-field-match source verification, a structural self-check, and disk-save durability — is **non-negotiable**.

---

## Pre-flight Check

This skill is **not standalone** — it synthesizes upstream artifacts. Before proceeding:

1. Confirm a Findings Tracker exists: Glob `docs/findings/*_FINDINGS_TRACKER.md`. If none, **STOP**: "Run `/finding` first to create a Findings Tracker." (`--force` bypasses.)
2. Confirm at least one artifact describing the proposed change exists — a `/design` doc (`docs/design/*.md`), else a `/research` doc (`docs/research/*.md`), else the finding report itself. If none of these describe the change, **STOP** and ask the user to point at the change source.

See [context_check.md](../_shared/context_check.md).

---

## Modes

| Mode | Status | When it fires |
|------|--------|---------------|
| `pivot-review` | **Implemented (MVP)** | In-flight major/irreversible change → as-is vs to-be → GO/NO-GO, before designing the pivot. |
| `proposal` | Phase 2 — not yet implemented | Greenfield pre-design proposal. |
| `design-review` | Phase 2 — not yet implemented | Present the chosen design pre-blueprint. |
| `on-demand` | Phase 2 — not yet implemented | Synthesize current state into one navigable brief. |

If the user passes any `--mode` other than `pivot-review`, respond exactly: `Mode '{mode}' is Phase 2 — not yet implemented. Only --mode=pivot-review is available.` and **STOP**.

---

## Flags

```
--mode=pivot-review   The only implemented mode (default).
--force               Skip the Findings Tracker prerequisite check (if run via workflow).
```

---

## Step 1: Scope & Inputs (Phase 0)

1. Name the decision the brief must support, and the audience (dev / owner / stakeholder).
2. Gather inputs: the findings tracker, `/research` and `/design` docs, `ARCHITECTURE.md`, the codebase (for the verified as-is), and any prior briefs in `docs/design-briefs/`.
3. **CST-005 trigger determination** (this drives Step 8's Decision-Requested content): ask *"Is the briefed decision irreversible AND public?"* — a SemVer-permanent surface, relicensing, a trademark class, or public launch copy. **Default yes when unsure.** If **yes**, set the **irreversible+public tag**: the Decision-Requested section MUST carry the CST-005 human-spine clause (Step 8). If **no**, the CST-005 clause is N/A for this brief. The human owns this call — a model self-assessing the trigger shares the blind spot it hedges.
4. **Change-type determination** (this drives which mockup sections Step 5 renders): decide the **change-type** — `decision-only` (the default; a pure go/no-go brief like the shipped S119/S125 — renders neither mockup container), `front-end`, `back-end`, or `full-stack`. A `front-end` or `full-stack` change emits the §4 front-end mockup container (`id="mockups"`); a `back-end` or `full-stack` change emits the §5 back-end mockup container (`id="backendmockup"`). A `decision-only` brief emits neither and stays exactly as today.

---

## Step 2: Ground — thinned (Phase 1)

Fan out the verification core as **parallel** `Agent` spawns. **CRITICAL**: launch all ground agents in a SINGLE message using the Agent tool (true parallel execution). For each: `subagent_type: "general-purpose"`, a per-spawn `model`, and a prompt instructing structured returns. Thin the front/back split to the **change-type** (Step 1): a `front-end` change thins the back-end agent, a `back-end` change thins the front-end agent, `full-stack` ⇒ thin NEITHER, `decision-only` ⇒ thin BOTH mockup agents:

- **Agent G1 — evidence & citations** (`model: opus`): consolidate every load-bearing claim; for each source, capture title/authors/date/venue/URL for the Step-6 fetch-and-field-match pass.
- **Agent G2 — as-is** (`model: sonnet`): extract the verified current state from the codebase; **cite file paths**.
- **Agent G3 — to-be + change-map** (`model: opus`): extract the proposed design and the EXACT change map from the design/research artifact. When the change-type touches **back-end**, also emit the back-end mockup specs — architecture nodes/edges, ERD entities/relations, API/contract endpoints, and sequence (control+data flow) steps — for the §5 `id="backendmockup"` container.
- **Agent G4 — front-end mockup specs** (`model: opus`, only when the change-type touches **front-end**): emit UX-flow, screen-wireframe, and component-inventory specs, and consume `/ux-design`'s design-system markdown (tokens/type/color/motion) for the §4 `id="mockups"` container. Fable stays holstered (CST-004).

Each spawn returns structured findings and returns ONLY those findings. **Do NOT include any "read/update your MEMORY.md" instruction** — these inline spawns have no agent-file memory scope (nothing to read or write).

---

## Step 3: Adversarial — KEPT (Phase 2)

**Barrier: this needs ALL of Step 2.** Spawn **exactly three diverse lenses** as **inline** prompts (no agent files), one lens per spawn, in a SINGLE message. Heterogeneous per-spawn model pins give same-lab **partial** decorrelation:

- **`honesty-hawk`** (`model: opus`) — hunt every overclaim; force the honest noun; reject hype.
- **`cost-skeptic`** (`model: sonnet`) — attack the numbers, baselines, and cherry-picks; demand the risk case first.
- **`mechanism-skeptic`** (`model: opus`) — attack every technical assertion stated as fact; flag the unverified.

Each inline lens prompt MUST embed this Discipline block verbatim:

- **Objections, never verdicts.** Never write "approve", "reject", "PASS", "looks good", a score, or a recommendation. Return a list of things the author must confront.
- **Tier every objection**: `MUST-ADDRESS` (a gap that could flip or badly damage the brief) · `SHOULD-CONSIDER` (a real omission worth a sentence) · `NOTE` (minor / for-the-record).
- **Ground each objection** in a specific artifact reference.
- **No consensus, no aggregation.** One independent lens per spawn; divergence is a feature.
- Close every non-empty response with the fixed caveat line: `Caveat: same-lab critic — catches skipped omissions only; does NOT decorrelate shared blind spots (that is the Layer-0 human + Layer-3 cross-lab hedge's job).`

**Fable stays holstered** (CST-004) — never a grader/verifier/judge here; use only `model: opus` / `model: sonnet` for the lenses. Collect the independent tiered objections — never a consensus vote, never a score.

---

## Step 4: Synthesize (Phase 3)

**Barrier: this needs ALL of Step 3.** Merge the ground content and **APPLY every valid adversarial correction** into ONE master content brief: all sections + chart data series + diagram specs + walkthrough content + glossary + the Decision-Requested content. Every load-bearing claim must carry its evidence AND its honest ceiling.

---

## Step 5: Render (Phase 4)

1. **Load the `artifact-design` skill FIRST** for design-craft guidance before writing any HTML.
2. Build the self-contained, CSP-safe interactive HTML from `skills/design-brief/design_brief_template.md`. Author it in **Artifact-compatible form**: inline `<style>` and `<script>`, embedded/hand-built SVG, **no** `<!doctype>`/`<html>`/`<head>`/`<body>` wrapper (the Artifact tool adds the skeleton; browsers render the wrapper-less file from disk).
3. Required interactive/robustness properties: both themes (`:root` light default + `@media (prefers-color-scheme:dark)` + `:root[data-theme="light"]`/`["dark"]` overrides); the as-is⇄to-be toggle (`id="vAsis"`/`id="vTobe"`/`aria-pressed`/`data-view` on the body); provenance chips; confidence-tiered references; the Decision-Requested block; the glossary; `:focus-visible`; `@media (prefers-reduced-motion:reduce)`; no horizontal body scroll (wrap wide content in an `overflow-x:auto` container such as `class="tablewrap"`).
4. **Conditional accessibility upgrade**: IF you emit a `role="tablist"` stepper, it MUST carry a `keydown` arrow-key roving-tabindex handler (`ArrowUp`/`ArrowDown`/`ArrowLeft`/`ArrowRight`). If no tablist is present, this is N/A.
5. **Full-stack mockup render** (only when the change-type is `front-end` / `back-end` / `full-stack`) — a **two-medium** contract inside this same CSP-safe envelope (no new render channel; a live-JS diagram lib such as Mermaid is a non-starter — CST-006):
   - **Back-end** structure (§5 container `id="backendmockup"`): hand-built **static inline SVG with live `var()` theming** — C4/architecture (`id="architecture"`), ERD data model (`id="erd"`), API/contract surface (`id="apisurface"`), and sequence / control+data flow (`id="dataflow"`). Each `<svg>` carries `role="img"` + `aria-label`, a `viewBox`, and `width:100%;height:auto` (fluid, no horizontal body scroll). Prefer static `var()`-SVG over JS-built SVG (theme-aware for free).
   - **Front-end** design (§4 container `id="mockups"`): render UX flows (`id="uxflow"`), screen wireframes (`id="wireframe"`), the design system (`id="designsystem"`, consumed from `/ux-design`), and a component inventory (`id="componentinv"`) as **HTML/CSS** on the proven `.card`/`.grid` system (text-dense UI reflows better than baked SVG text). Map the as-is⇄to-be toggle onto current-UI vs proposed-UI.
   - **Anti-slop (mandatory for front-end mockups)**: after `artifact-design`, load the `frontend-design` skill and run its ASCII-plan → critique-against-generic-defaults → build loop, plus `/ux-design`'s `anti_patterns.md` checklist, so the wireframes do not read as generic AI defaults.
   - **Honesty (structure-only)**: the lint verifies these anchor ids are **present**, NOT that a mockup is accurate or complete. A dimension with no change may honestly state *"no change"* — **never fabricate a diagram**. Pitch mockups as **ambiguity-reduction** / shared-understanding at a decision boundary, not a discredited fix-early 100×/13× multiplier.

---

## Step 6: Verify Sources — sharpened (Phase 5)

For **every** citation, run **fetch-and-field-match** (plausibility and id-resolves checks are insufficient — 2026 fabrications weaponize semantic plausibility and hijacked identifiers):

1. Extract the claimed fields (title, authors, year, venue, URL).
2. `WebFetch` the source.
3. Field-match the fetched content against the claimed fields.
4. Judge and assign a confidence tier: `verified` (real URL, fields match) · `prior art` · `attributed post-hoc` · `official / vendor`.
5. **quarantine-on-no-fetch**: if a source cannot be fetched, tag it explicitly as unverified/reported — **never fabricate a citation to fill a gap**, and name which sources cannot be named.

---

## Step 7: Structural Self-Check

Grep the generated `.html` for the **hard-invariant anchors**. If any is absent, fix the render before publishing. (Anchors are the S119-verified literals.)

**Provenance / confidence (the honesty spine):** `chip emp`, `chip est`, `chip rep`; `chip hi`, `chip med`, `chip low`; the tier labels `verified`, `prior art`, `attributed post-hoc`.

**Decision block:** `id="decision"`, `class="riskgrid"`, `Risk of YES`, `Risk of NO`, `class="verdict`, `Recommended:`.

**References:** `id="refsList"`, `class="reflist"`, `rel="noopener"`.

**As-is ⇄ to-be toggle:** `id="vAsis"`, `id="vTobe"`, `aria-pressed`, `data-view`.

**Thesis + glossary:** `id="thesis"`, `id="gloss"`.

**Theme + a11y:** `:root[data-theme="light"]`, `:root[data-theme="dark"]`, `@media (prefers-color-scheme:dark)`, `@media (prefers-reduced-motion:reduce)`, `:focus-visible`, `tablewrap`.

**Conditional — tablist:** IF the brief contains a `role="tablist"` stepper, it MUST also contain a `keydown` arrow-key handler; if no tablist, N/A (not a failure).

**Conditional — CST-005:** IF Step 1 set the irreversible+public tag, the Decision-Requested block MUST contain `CST-005` and `second-human`; if not tagged, N/A.

**Conditional — front-end mockups:** IF the brief communicates a front-end design (contains `id="mockups"`), it MUST also contain `id="uxflow"`, `id="wireframe"`, `id="designsystem"`, and `id="componentinv"`; if no mockups container, N/A (not a failure).

**Conditional — back-end mockups:** IF the brief communicates a back-end design (contains `id="backendmockup"`), it MUST also contain `id="architecture"`, `id="erd"`, `id="apisurface"`, and `id="dataflow"`; if no back-end mockup container, N/A (not a failure).

Soft anchors (warn only, vary per brief): specific numbered-section ids, exact reference counts.

---

## Step 8: Publish & Save (Phase 6)

**Disk-save is the durable, REQUIRED path; Artifact-publish is best-effort.**

1. **ALWAYS first** save the HTML to `docs/design-briefs/{YYYY-MM-DD_HHMM}_{decision}.html` (this saved file is what Step 7 self-checks). Create `docs/design-briefs/` if it does not exist.
2. The Decision-Requested block content depends on the Step-1 tag. **If the irreversible+public tag is set**, the block MUST surface the CST-005 human-spine obligations: a named **second-human** sign-off, a prompted **cooling-off**, a **lawyer / TM-attorney** review for relicensing / trademark-class triggers, and the explicit caveat that *this brief is NOT the decorrelation hedge — a same-lab LLM pass does not decorrelate shared blind spots*. A bare GO/NO-GO one person can rubber-stamp is not acceptable for a `CST-005` decision.
3. **THEN** attempt to publish the same saved file via the host `Artifact` tool (title, one-sentence description, favicon). The Artifact tool is a claude.ai-login capability and **MAY be absent in a plain terminal session** (it is not in `allowed-tools`). If available: publish and report the URL. If unavailable or it errors: **DO NOT fail** — report the saved path and tell the user to open the self-contained `.html` in a browser. The skill **SUCCEEDS on the saved file alone.**

---

## Step 9: Findings Tracker Update & Handoff

Update the Findings Tracker if this was invoked as part of a tracked workflow. See [tracker_update_checklist.md](../_shared/tracker_update_checklist.md).

**CRITICAL PIPELINE RULE**: Suggest ONLY the next pipeline step below. Do NOT offer to implement. Do NOT offer to skip steps.

```
Next step: this brief is a GO/NO-GO gate. On GO, run /design to design the pivot.
On NO-GO, revisit the finding.

Awaiting your instructions.
```

**STOP** — do NOT proceed with implementation. Do NOT add commentary suggesting any pipeline step could be skipped or is unnecessary. Wait for the user to decide how to proceed.
