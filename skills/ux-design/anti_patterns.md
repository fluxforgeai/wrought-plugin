# Frontend Anti-Patterns

Prohibited patterns that produce generic "AI slop" aesthetics. Referenced by `/ux-design` and all application-type profiles. Each entry: pattern, why it fails, and what to do instead.

**Revision**: This file evolves. When the Intelligence Inbox flags a `[design-trend]` signal indicating a previously-distinctive choice has become overused, add it here.

---

## Typography Anti-Patterns

- **Inter, Roboto, Arial, or Open Sans as primary display font** — These are the most statistically common fonts in LLM training data. Using them guarantees your UI looks AI-generated. Use distinctive Google Fonts per your application-type profile instead.
- **system-ui / system font stack as the only font** — Acceptable for body text in mobile apps where native feel matters, but never as the sole typographic choice for web. Pair at least one distinctive display font.
- **Single font weight (400 only)** — Creates flat, undifferentiated hierarchy. Use 2-3 weights minimum: 400 for body, 500 or 600 for labels/emphasis, 700 for headings.
- **Uniform font sizes with no scale** — All text looking similar-sized destroys hierarchy. Apply a typographic scale (1.2 minor third minimum, 1.25-1.333 preferred). Display text should be 3x+ body size.
- **Space Grotesk as primary font** — Was distinctive in 2024, now overused in AI-generated UIs. Choose alternatives like Instrument Sans, General Sans, or Satoshi.
- **Missing `font-display: swap`** — Causes invisible text during font loading (FOIT). Always include `font-display: swap` or `optional` in @font-face declarations.
- **Excessive font families (4+)** — More than 3 font families creates visual chaos and hurts performance. Stick to 2 (display + body) or 3 (+ monospace if needed).

## Color Anti-Patterns

- **Purple/violet gradient on white background** — The single most recognizable AI-generated aesthetic. Commit to a non-default palette derived from your brand or application type.
- **Evenly distributed rainbow palette** — Using 5+ colors at equal visual weight creates visual noise. Apply the 90/10 rule: one dominant neutral, one strong accent. Use additional colors only for semantic meaning (success, warning, error, info).
- **Hardcoded hex values scattered in components** — Creates inconsistency and makes theming impossible. Define all colors as CSS custom properties or design tokens at a single source of truth.
- **Pure black (#000000) on pure white (#ffffff)** — Maximum contrast causes eye strain on screens. Use near-black (#1a1a1a-#2d2d2d) on near-white (#fafafa-#fefefe) for comfortable reading.
- **No dark mode consideration** — Define both light and dark token sets from the start. Even if you ship light-only initially, the token architecture should support both.
- **Missing semantic color mapping** — Using raw color names (blue-500) instead of semantic names (color-primary, color-success) makes the system fragile. Define semantic aliases.
- **Low contrast text (< 4.5:1 ratio)** — Fails WCAG AA. Body text must have 4.5:1 contrast ratio minimum; large text (18px+ or 14px+ bold) requires 3:1 minimum.

## Layout Anti-Patterns

- **Centered single-column for everything** — The default AI layout. Use asymmetry, sidebar layouts, grid-breaking hero sections, or editorial column variations to create visual interest.
- **Uniform card grids (same size, same spacing)** — Monotonous and forgettable. Vary card sizes (featured + standard), use masonry layouts, or combine grid with list views.
- **Fixed pixel widths** — Fragile across viewports. Use fluid layouts with `max-width` and `clamp()` for responsive typography and spacing.
- **Missing responsive breakpoints** — Build mobile-first with at minimum 3 breakpoints (mobile < 640px, tablet < 1024px, desktop). Test at each.
- **Content touching container edges** — No breathing room makes UI feel cramped. Apply a consistent spacing scale (4px or 8px base) with generous padding.
- **Symmetrical layouts everywhere** — Some symmetry is fine, but all-symmetrical layouts feel static. Introduce intentional asymmetry in hero sections, feature highlights, or testimonial areas.

## Motion Anti-Patterns

- **No animation at all** — Static interfaces feel lifeless. Add purposeful micro-interactions for state changes (hover, focus, active, loading, success, error).
- **Decorative animation without purpose** — Every motion should convey state change, guide attention, or provide feedback. Remove animations that exist only to look fancy.
- **Missing `prefers-reduced-motion` media query** — Always wrap non-essential animations in `@media (prefers-reduced-motion: no-preference)`. Essential state transitions (loading indicators) should remain but use opacity instead of movement.
- **Linear easing on everything** — Linear motion feels mechanical. Use `ease-out` for elements entering view, `ease-in` for elements leaving, `ease-in-out` for state changes.
- **UI transition duration > 500ms** — Slow transitions feel sluggish. Keep UI state transitions at 150-300ms. Only entrance/page-load animations can exceed 500ms.
- **Simultaneous animations without stagger** — Multiple elements animating at the exact same time look chaotic. Use `animation-delay` to stagger reveals (50-100ms between elements).

## Component Anti-Patterns

- **Emoji characters as icons in production UI** — Inconsistent across platforms, inaccessible, unprofessional. Use an SVG icon library (Lucide, Heroicons, Phosphor Icons, Tabler Icons).
- **Missing visible focus states on interactive elements** — Breaks keyboard navigation and accessibility. Every button, link, and input needs a visible focus ring (use `:focus-visible` for keyboard-only focus).
- **Spinners instead of skeleton screens** — Spinners provide no spatial information. Skeleton screens show the expected layout shape, reducing perceived loading time.
- **Missing error and empty states** — Every data-dependent component needs: loading, empty (no data), error, and populated states. Don't just handle the happy path.
- **Inconsistent border-radius** — Mixed sharp corners and rounded corners in the same context looks accidental. Define a radius scale (e.g., 4px, 8px, 12px, 9999px for pills) and use consistently.
- **Generic placeholder text ("Lorem ipsum")** — Use realistic content that matches actual data length and format. This reveals real layout problems that placeholder text hides.

## Accessibility Anti-Patterns

- **Color as sole indicator of meaning** — Color-blind users cannot distinguish. Supplement with icons, text labels, or patterns (e.g., strikethrough for errors, checkmark for success).
- **Contrast ratio below WCAG AA** — Body text needs 4.5:1, large text needs 3:1, UI components need 3:1 against adjacent colors.
- **Missing aria-labels on icon-only buttons** — Screen readers announce nothing for `<button><svg>...</svg></button>`. Add `aria-label="Close"` or visually-hidden text.
- **Non-semantic HTML (div soup)** — Use `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<header>`, `<footer>`. Screen readers use these landmarks for navigation.
- **Missing skip-to-content link** — First focusable element on every page should be a "Skip to main content" link that jumps past navigation. Essential for keyboard users.
- **Form inputs without associated labels** — Every `<input>` needs a `<label>` with matching `for`/`id`. Placeholder text is not a label.
