---
name: ux-design
description: "Generate a Design Brief with application-type-aware design system, typography, color, motion, and anti-patterns. Use before /blueprint for frontend work to avoid generic AI aesthetics."
disable-model-invocation: false
argument-hint: "[app-type or 'auto'] [--refresh]"
allowed-tools: Read, Grep, Glob, WebSearch, Write
effort: xhigh
wrought:
  version: "1.0"
  tools:
    capabilities:
      - read_file
      - search_content
      - find_files
      - web_search
      - write_file
  platforms:
    claude-code:
      allowed-tools: "Read, Grep, Glob, WebSearch, Write"
      disable-model-invocation: false
  agent:
    role: "Design System Architect"
    expertise:
      - "frontend design systems"
      - "application-type conventions"
      - "design token architecture"
      - "accessibility standards"
    non_goals:
      - "writing production code"
      - "creating visual mockups or wireframes"
      - "implementing the design"
  execution:
    default_mode: react
    max_iterations: 8
    stop_conditions:
      - "Design Brief written to docs/design-briefs/"
      - "User instructed to stop"
  output:
    format: markdown
    template: "docs/design-briefs/{YYYY-MM-DD_HHMM}_{project}.md"
    required_sections:
      - "Aesthetic Direction"
      - "Design Tokens"
      - "Typography Rules"
      - "Color System"
      - "Anti-Patterns"
  pipeline:
    track: proactive
    standalone: true
    prerequisites: []
    produces:
      - "docs/design-briefs/*.md"
    suggested_next:
      - blueprint
---

# UX Design Skill

**Trigger**: `/ux-design [app-type|auto] [--refresh]`

**Purpose**: Generate an application-type-aware Design Brief with design tokens, typography, color, motion, layout, anti-patterns, accessibility requirements, and performance budgets. Eliminates "AI slop" by providing concrete, opinionated design direction before implementation.

**Examples**:
- `/ux-design auto` — detect application type from codebase, generate brief
- `/ux-design saas-dashboard` — use SaaS Dashboard profile directly
- `/ux-design landing-page` — use Landing Page profile directly
- `/ux-design --refresh` — re-evaluate existing Design Brief against current recommendations

**Application types**: `saas-dashboard`, `landing-page`, `ecommerce`, `mobile-app`, `admin-panel`, `blog-content`, `developer-tool`, `auto`

---

## Pre-flight Check

This skill is **standalone** — it can be invoked at any time without prerequisites.

If this invocation is part of an active workflow, check `docs/findings/*_FINDINGS_TRACKER.md` for a relevant tracker and note it for context, but do not enforce stage requirements.

---

## Flags

```
--refresh    Re-evaluate existing Design Brief against current profiles and anti-patterns
--force      Skip Findings Tracker prerequisite check (if run via workflow)
```

---

## Step 1: Parse Arguments

Parse the user's invocation:

**If no arguments provided** (bare `/ux-design` invocation):

Display the following help text and **STOP** -- do not proceed to Step 2:

```
/ux-design -- Frontend Design Brief Generator

Application types:
  saas-dashboard    Data-dense dashboards, charts, real-time metrics
  landing-page      Hero-driven, conversion-focused marketing pages
  ecommerce         Product-focused storefronts, cart, checkout
  mobile-app        Touch-first, native-feel mobile interfaces
  admin-panel       Dense, functional, keyboard-navigable back-office
  blog-content      Readable, editorial, serif-forward content sites
  developer-tool    Monospace-heavy, dark-first, terminal aesthetic
  auto              Auto-detect from codebase signals

Flags:
  --refresh         Re-evaluate an existing Design Brief

Examples:
  /ux-design auto              Detect app type and generate brief
  /ux-design saas-dashboard    Generate with SaaS Dashboard profile
  /ux-design --refresh         Refresh existing brief against latest profiles
```

**If arguments are provided**, parse them:

1. **Application type**: First argument after `/ux-design`. One of: `saas-dashboard`,
   `landing-page`, `ecommerce`, `mobile-app`, `admin-panel`, `blog-content`,
   `developer-tool`, `auto`.
2. **Refresh flag**: `--refresh` -- triggers refresh mode (Step 5 instead of Steps 2-4)

If `--refresh` is present, skip to **Step 5: Refresh Mode**.

---

## Step 2: Detect Application Type

If user specified a type explicitly, skip detection and use it directly. Load the matching profile from `skills/ux-design/profiles/{type}.md` (replacing hyphens with underscores for filename).

If `auto` (or no argument):

### 2a: Read package.json

Read `package.json` (if exists) and analyze dependencies:

| Signal | Application Type |
|--------|-----------------|
| React/Vue/Svelte + charting lib (recharts, d3, visx, nivo, chart.js, ApexCharts) | SaaS Dashboard |
| Next.js/Astro/Gatsby without e-commerce libs, < 10 routes | Landing Page |
| Stripe, Shopify SDK, Snipcart, Commerce.js, cart/checkout libraries | E-Commerce |
| React Native, Expo, Flutter, Capacitor, Ionic | Mobile App |
| react-admin, AdminJS, Refine, CASL, role/permission libraries | Admin Panel |
| MDX, contentlayer, markdoc, @next/mdx, rehype/remark ecosystem | Blog/Content |
| CLI frameworks (commander, yargs, oclif), terminal UI (ink, blessed) | Developer Tool |

### 2b: Scan Route/Component Patterns

If package.json is ambiguous, scan file structure:

- Glob for route files and scan for pattern keywords:
  - `/dashboard`, `/analytics`, `/reports` → SaaS Dashboard
  - `/products`, `/cart`, `/checkout` → E-Commerce
  - `/blog`, `/posts`, `/articles` → Blog/Content
  - `/admin`, `/settings`, `/users` → Admin Panel
- Check for platform directories: `ios/`, `android/` → Mobile App
- Check for `bin/`, `cli/` directories → Developer Tool

### 2c: Resolve Ambiguity

If detection is ambiguous (multiple signals), present the top 2-3 candidates with evidence:

```
Application type detection found multiple signals:

1. SaaS Dashboard (strong): React + recharts in package.json, /dashboard route
2. Admin Panel (moderate): /admin route, role management components

Which application type should I use? (1/2/other)
```

Wait for user response before proceeding.

### 2d: Load Profile

Read the matched profile: `skills/ux-design/profiles/{type}.md`

Map type argument to filename:
- `saas-dashboard` → `profiles/saas_dashboard.md`
- `landing-page` → `profiles/landing_page.md`
- `ecommerce` → `profiles/ecommerce.md`
- `mobile-app` → `profiles/mobile_app.md`
- `admin-panel` → `profiles/admin_panel.md`
- `blog-content` → `profiles/blog_content.md`
- `developer-tool` → `profiles/developer_tool.md`

---

## Step 3: Scan Existing Design System

Before generating from scratch, detect what already exists:

1. **CSS custom properties**: Glob for `**/*.css` files, Grep for `--` prefixed variable declarations inside `:root` blocks
2. **Tailwind config**: Glob for `tailwind.config.*`. If found, read the `theme.extend` section for existing tokens
3. **Design token files**: Glob for `**/tokens.json`, `**/design-tokens.*`, `**/theme.ts`, `**/theme.js`
4. **Design system docs**: Check for `DESIGN_SYSTEM.md`, `.wrought/design-system.md`, or `docs/design-system.*`
5. **Existing Design Brief**: Glob for `docs/design-briefs/*.md`

If existing design system artifacts are found:
- Note what exists: "Found existing design system: Tailwind config with custom colors, 12 CSS variables"
- The Design Brief should **augment and align** with the existing system, not replace it
- Flag any conflicts between existing system and profile recommendations

If no existing system is found:
- Note: "No existing design system detected. Generating from profile defaults."

---

## Step 4: Generate Design Brief

1. Read `skills/ux-design/design_brief_template.md`
2. Read `skills/ux-design/anti_patterns.md`
3. Read the loaded profile (from Step 2)
4. Fill the template by merging:
   - **Profile defaults** as the baseline for all sections
   - **Existing design system** as overrides where they exist (respect what's already built)
   - **Anti-pattern validation** — verify no template values violate anti-patterns
   - **Project-specific context** from the conversation (user's stated preferences, brand colors, etc.)
5. Generate **concrete CSS custom property values** — not abstract descriptions. Real hex codes, real pixel values, real font names.
6. Ensure all recommended fonts are available on Google Fonts (free, no licensing issues)
7. Create `docs/design-briefs/` directory if it doesn't exist
8. Write the completed brief to `docs/design-briefs/{YYYY-MM-DD_HHMM}_{project_name}.md`

**Project name**: Derive from `package.json` `name` field, or the directory name, or ask the user.

---

## Step 5: Refresh Mode (--refresh)

When `--refresh` flag is present:

1. Find the most recent file in `docs/design-briefs/` by timestamp prefix
2. If no existing brief found: "No existing Design Brief found. Run `/ux-design` without `--refresh` to generate one."
3. Read the existing brief
4. Re-read `skills/ux-design/anti_patterns.md` (may have been updated since the brief was generated)
5. Re-read the profile that matches the brief's Application Type header
6. Compare each section of the existing brief against current profile and anti-pattern recommendations
7. Output a summary:

```
Design Brief Refresh Analysis: {filename}

Sections still current:
- Aesthetic Direction: OK
- Typography: OK

Sections with recommended updates:
- Color System: Anti-pattern added — Space Grotesk is now overused, consider {alternative}
- Motion: Profile updated — reduced-motion media query pattern improved

Recommended action: Update the brief? (yes/no)
```

8. If user says yes, regenerate the brief (overwrite existing file)
9. If user says no, stop.

---

## After Generation

Update the Findings Tracker if this skill was invoked as part of a tracked workflow.

See [tracker_update_checklist.md](../_shared/tracker_update_checklist.md)
- Stage: "Designing"
- Task: FN.1 (Design approach — for design-route findings)

Output:

```
Design Brief generated: docs/design-briefs/{filename}.md

Application Type: {type}
Profile: {profile_name}
Existing design system: {summary or "None detected"}

Sections generated:
- Aesthetic Direction
- Design Tokens (colors, typography, spacing, borders)
- Typography Rules
- Color System
- Motion Guidelines
- Layout Conventions
- Component Patterns
- Anti-Patterns
- Accessibility Requirements
- Performance Budgets
```

**CRITICAL PIPELINE RULE**: Suggest ONLY the next pipeline step below. Do NOT offer to implement. Do NOT offer to skip steps.

```
Next step: Run /blueprint to create an implementation spec. The blueprint will load this Design Brief and reference its design tokens, typography, and component patterns.

Awaiting your instructions.
```

**STOP** — do NOT proceed with implementation. Do NOT add commentary suggesting any pipeline step could be skipped or is unnecessary. Wait for the user to decide how to proceed.
