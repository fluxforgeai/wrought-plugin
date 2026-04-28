# Design Brief Template

Output artifact template for `/ux-design`. Fill `{placeholders}` with concrete values from the matched profile, anti-patterns database, and codebase scan.

Write to: `docs/design-briefs/{YYYY-MM-DD_HHMM}_{project_name}.md`

---

```markdown
# Design Brief: {project_name}

**Generated**: {YYYY-MM-DD HH:MM} UTC
**Application Type**: {detected_type}
**Profile**: {profile_name}
**Session**: {session_number}
**Existing Design System**: {existing_system_summary or "None detected"}

---

## Aesthetic Direction

{2-3 sentences from profile, adapted to project context. Include the "feel" and personality.}

---

## Design Tokens

### Colors

```css
:root {
  /* Primary */
  --color-primary: {value};
  --color-primary-hover: {value};
  --color-primary-active: {value};

  /* Secondary */
  --color-secondary: {value};

  /* Accent */
  --color-accent: {value};
  --color-accent-hover: {value};

  /* Surfaces */
  --color-surface: {value};
  --color-surface-elevated: {value};
  --color-surface-overlay: {value};

  /* Text */
  --color-text-primary: {value};
  --color-text-secondary: {value};
  --color-text-muted: {value};

  /* Semantic */
  --color-success: {value};
  --color-warning: {value};
  --color-error: {value};
  --color-info: {value};

  /* Borders */
  --color-border: {value};
  --color-border-strong: {value};
}
```

### Typography

```css
:root {
  --font-display: '{display_font}', {fallback_stack};
  --font-body: '{body_font}', {fallback_stack};
  --font-mono: '{mono_font}', monospace;

  --font-size-xs: {value};   /* ~11-12px */
  --font-size-sm: {value};   /* ~13-14px */
  --font-size-base: {value}; /* ~15-16px */
  --font-size-lg: {value};   /* ~18-20px */
  --font-size-xl: {value};   /* ~24px */
  --font-size-2xl: {value};  /* ~32px */
  --font-size-3xl: {value};  /* ~48px+ */

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  --line-height-tight: {value};    /* 1.1-1.2 */
  --line-height-normal: {value};   /* 1.4-1.5 */
  --line-height-relaxed: {value};  /* 1.6-1.8 */
}
```

### Spacing

```css
:root {
  --space-1: {value};  /* 4px */
  --space-2: {value};  /* 8px */
  --space-3: {value};  /* 12px */
  --space-4: {value};  /* 16px */
  --space-6: {value};  /* 24px */
  --space-8: {value};  /* 32px */
  --space-12: {value}; /* 48px */
  --space-16: {value}; /* 64px */
}
```

### Borders and Shadows

```css
:root {
  --radius-sm: {value};    /* 4px */
  --radius-md: {value};    /* 8px */
  --radius-lg: {value};    /* 12px */
  --radius-full: 9999px;

  --shadow-sm: {value};
  --shadow-md: {value};
  --shadow-lg: {value};
}
```

---

## Typography Rules

{Font pairing rationale. Scale explanation. Weight usage rules. Reading width if applicable.}

**Google Fonts to load**:
```html
<link href="https://fonts.googleapis.com/css2?family={display_font}:wght@{weights}&family={body_font}:wght@{weights}&display=swap" rel="stylesheet">
```

---

## Color System

{Palette rationale. Contrast ratios for text on backgrounds. Dark/light variant notes. Semantic color usage rules.}

---

## Motion Guidelines

- **Default transition**: `{duration} {easing}` (e.g., `200ms ease-out`)
- **Entrance animations**: {approach}
- **Exit animations**: {approach}
- **Loading states**: {approach}
- **Reduced motion**: `@media (prefers-reduced-motion: reduce) { * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; } }`

---

## Layout Conventions

- **Grid**: {grid system description}
- **Breakpoints**: {breakpoint values and approach}
- **Spacing scale**: {spacing philosophy}
- **Max content width**: {value}

---

## Component Patterns

{Application-type-specific component conventions from profile. List key components with their design rules.}

---

## Anti-Patterns

**Do NOT use these patterns** (see `skills/ux-design/anti_patterns.md` for full rationale):

{Merged list from global anti-patterns + profile-specific anti-patterns, prioritized by relevance to this application type.}

---

## Accessibility Requirements

- **Standard**: WCAG 2.1 Level AA minimum
- **Contrast**: Body text 4.5:1, large text 3:1, UI components 3:1
- **Focus**: Visible focus ring on all interactive elements (`:focus-visible`)
- **Landmarks**: Semantic HTML (`nav`, `main`, `section`, `article`, `aside`)
- **Skip link**: "Skip to main content" as first focusable element
- **Labels**: Every form input has an associated `<label>`
- **Color independence**: Color is never the sole indicator of meaning
- **Motion**: `prefers-reduced-motion` media query wraps non-essential animations

---

## Performance Budgets

{From profile — font count, CSS size, LCP/FID/CLS targets, image strategy, bundle size targets.}

---

*This Design Brief is a pipeline artifact. It is consumed by `/wrought-implement` (design context loading) and `/forge-review` (design quality checks via the design-quality subagent).*
```
