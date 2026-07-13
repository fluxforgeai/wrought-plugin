# Design Brief Template — Section Skeleton

This is the content skeleton for a `/design-brief` interactive HTML decision brief. A brief is *complete* when it carries the sections below. **Sections marked `[MVP-CORE]` are non-negotiable** for the `pivot-review` MVP; the others are authored when the change warrants them (a pure-frontend change thins the back-end section, and vice-versa) — but **never** drop References, the honest-ceiling discipline, or the Decision-Requested block.

**Full-stack mockup sections** §4/§5 are *conditional-core* keyed to the **change-type** (SKILL.md Step 1): a `front-end`/`full-stack` change emits §4 (container `id="mockups"`), a `back-end`/`full-stack` change emits §5 (container `id="backendmockup"`), and a `decision-only` brief emits neither (staying exactly as the shipped S119/S125 briefs). A required mockup block whose dimension has no change may honestly state *"no change"* — **never fabricate a diagram**. The lint checks the anchor ids are present, not that a mockup is accurate.

The brief is rendered as a self-contained, CSP-safe interactive HTML artifact (both themes, hand-built SVG, as-is⇄to-be toggle, provenance chips, `prefers-reduced-motion`, no horizontal body scroll). See the `/design-brief` SKILL.md Step 5 for the render contract and Step 7 for the structural self-check anchors.

---

## 1. Honest Thesis — `[MVP-CORE]`  (`id="thesis"`)

The whole argument in one paragraph, honest noun up front. No hype; the honest framing is the persuasive one for a technical audience.

## 2. Motivation

The problem, the opportunity, why now.

## 3. As-Is / To-Be / Change Map — `[MVP-CORE]`

The verified current state (**cite file paths**), the proposed state, and the EXACT change map. Rendered with the global **as-is ⇄ to-be toggle** motif (`id="vAsis"` / `id="vTobe"` / `data-view`).

## 4. Front-End Proposal — `[MVP-CORE-when-front-end]`  (container `id="mockups"`)

UX flows (`id="uxflow"`) · screen wireframes/mockups (`id="wireframe"`) · design system — type/color/motion (`id="designsystem"`, consumed from `/ux-design`) · component inventory (`id="componentinv"`). *(interactive HTML/CSS on the `.card`/`.grid` system; emitted when the change-type is front-end or full-stack. A dimension with no change may state "no change" — never fabricate a mockup.)*

## 5. Back-End Proposal — `[MVP-CORE-when-back-end]`  (container `id="backendmockup"`)

Architecture / C4 diagram (`id="architecture"`) · data model / ERD (`id="erd"`) · API/contract surface (`id="apisurface"`) · control + data flow / sequence (`id="dataflow"`) · dependency/change map. *(hand-built static inline SVG with live `var()` theming; emitted when the change-type is back-end or full-stack. Reserve `id="architecture"` for this diagram container only — never a prose heading.)*

## 6. Diagrams

As-is vs to-be, flow, file/component change map. *(hand-built SVG)*

## 7. Mechanism Explanations

Any technical resolution the reader must understand, with terms defined.

## 8. Interactive Walkthrough

Per-component / per-stage, as-is vs to-be, clickable. IF rendered as a `role="tablist"` stepper, it MUST carry a `keydown` arrow-key roving-tabindex handler.

## 9. Cost (dual-framed) — `[MVP-CORE]`

Cost / effort / impact with graphs, **dual-framed** (the **risk case first**, then the conditional savings case). Every number carries a provenance chip: `empirical` (`chip emp`) / `estimate` (`chip est`) / `reported` (`chip rep`).

## 10. Benefit (claim → evidence → honest ceiling) — `[MVP-CORE]`

A claim → evidence → **honest ceiling** table. Every benefit states its evidence AND its honest ceiling — no naked claims. Followed by a mandatory **What this is NOT** list that de-hypes the claim.

## 11. References (verified, confidence-tiered) — `[MVP-CORE]`  (`id="refsList"`, `class="reflist"`)

**ALWAYS present.** Every load-bearing claim links to a source. Sources are **verified** via fetch-and-field-match (Step 6) and tiered: `verified` / `prior art` / `attributed post-hoc` / `official / vendor`. The unverifiable is labelled "reported, not cited" — **never fabricated**. External links carry `rel="noopener"`.

## 12. Glossary — `[MVP-CORE]`  (`id="gloss"`)

Define **every** technical term AND abbreviation. Lean — only terms the brief actually uses.

## 13. Decision Requested — `[MVP-CORE]`  (`id="decision"`)

The structure: one or more `.ask` blocks (each with a `class="riskgrid"` two-cell **Risk of YES** / **Risk of NO**), then a single `class="verdict"` banner carrying an explicit **Recommended:** line. Framed to resist rubber-stamping / review-fatigue — the risk-of-YES and risk-of-NO are explicit, and a **named human owner** is stated.

### 13a. CST-005 human-spine sub-block — *conditional (irreversible + public decisions only)*

IF the briefed decision is a **CST-005** trigger (SemVer-permanent surface / relicensing / trademark class / public launch copy — see SKILL.md Step 1), the Decision-Requested block MUST additionally surface:

- a named **second-human** sign-off (not one person alone);
- a prompted **cooling-off** period before the one-way door;
- a **lawyer / TM-attorney** review for relicensing / trademark-class triggers (no LLM layer substitutes);
- the explicit caveat: *"This brief is NOT the decorrelation hedge — a same-lab LLM pass does not decorrelate shared blind spots (that residual is owned by the Layer-0 human spine and the Layer-3 cross-lab hedge)."*

If the decision is not an irreversible+public trigger, this sub-block is N/A.
