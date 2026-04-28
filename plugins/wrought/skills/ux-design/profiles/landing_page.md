# Profile: Landing Page

## Detection Signals

- **package.json**: Next.js, Astro, Gatsby, or Remix without e-commerce libraries; limited route count (< 10 pages)
- **File patterns**: Hero components, CTA components, testimonial sections, pricing tables
- **Component patterns**: Section-based layouts, full-width containers, animated entrance components
- **Keywords**: "landing", "marketing", "launch", "waitlist" in README or meta

## Aesthetic Direction

Hero-driven, conversion-focused, bold typographic statements. First impression defines everything. Scroll is a narrative — each section reveals new information. Typography creates the drama. Animation creates the delight.

## Typography

- **Display**: Clash Display, Cabinet Grotesk, Satoshi, Syne (choose one — bold, distinctive)
- **Body**: General Sans, Plus Jakarta Sans, Outfit (choose one — clean, readable)
- **Scale**: 1.333 ratio (perfect fourth) or 1.414 (augmented fourth). Hero text 48-72px on desktop.
- **Weights**: 400 body, 500 subheadings, 700-900 hero headlines. Extreme weight contrast.
- **Line height**: 1.1-1.2 for display, 1.6 for body paragraphs
- **Tracking**: Tight (-0.02em) for large display text, normal for body

## Color System

- **Philosophy**: Bold and decisive. Large color blocks. One primary that owns the page.
- **Primary**: Strong, saturated. Not purple (anti-pattern). Consider: deep blue, warm coral, forest green, rich amber, midnight black.
- **Accent**: Contrasting CTA color — must pop against primary. Orange/amber CTAs on blue, white CTAs on dark.
- **Gradients**: Permissible if intentional and brand-aligned. Multi-stop gradients (3+) with subtle hue shifts. Never default purple-to-pink.
- **Semantic**: Minimal — landing pages rarely need error/warning states. Success for form submission confirmation.
- **Dark/Light**: Choose one and commit. Dark creates drama; light creates openness.

## Motion

- **Approach**: High-impact, narrative. Animation tells the story as the user scrolls.
- **Hero entrance**: 600-800ms staggered reveal. Headline first, then subtext, then CTA (100ms stagger).
- **Scroll reveals**: IntersectionObserver-triggered. Fade-up with 20-30px translate. 400-600ms per section.
- **Parallax**: Sparingly — one element per viewport maximum. Subtle (0.1-0.3 factor).
- **Hover effects**: CTAs scale 1.02-1.05 on hover with shadow elevation. Links underline-animate.
- **Avoid**: Auto-playing carousels, confetti, bouncing elements, animation-on-load for below-fold content.

## Layout

- **Structure**: Full-width sections stacked vertically. Each section is a "scene" in the scroll narrative.
- **Grid**: 12-column with generous gutters (24-32px). Content max-width 1200px centered.
- **Spacing**: Generous between sections (80-120px). Tight within sections.
- **Breakpoints**: Desktop 1280px, tablet 768px, mobile 375px. Hero must work at all three.
- **Key patterns**: Asymmetric hero (text left, visual right or vice versa), feature grid (3 or 4 columns), social proof bar, pricing comparison, final CTA section.

## Component Patterns

- **Hero**: Full-viewport or near-full. Headline (h1, 48-72px), subheadline (18-20px, muted), primary CTA button (large, high-contrast), optional secondary CTA (ghost/outline)
- **Feature cards**: Icon + title + description. 3-column grid on desktop, stack on mobile.
- **Pricing tables**: 2-3 tiers. Recommended tier visually emphasized (scale, border, badge). Annual/monthly toggle.
- **Testimonials**: Quote + name + role + company + avatar. Carousel or grid of 3.
- **Social proof**: Logo bar of 4-6 company logos, grayscale, horizontally centered.
- **Newsletter capture**: Email input + submit button inline. Minimal friction.

## Anti-Patterns (Landing-Page-Specific)

- Generic stock photography — use illustrations, abstract graphics, or real product screenshots
- "Learn more" as CTA text — use specific action verbs ("Start free trial", "Get early access", "See pricing")
- More than 2 CTAs per viewport — focus attention, don't scatter it
- Auto-playing video backgrounds — performance killer, often inaccessible
- Below-fold content that's invisible without scrolling indicator — add scroll hint or partial next-section peek

## Performance Budget

- **Fonts**: Max 2 families, preload hero font, use `font-display: swap`
- **LCP**: < 2.5s (hero section)
- **CLS**: < 0.1 (no layout shifts from lazy-loaded images or fonts)
- **Images**: Responsive with srcset, WebP/AVIF format, lazy-load below-fold
- **JS**: Minimal — scroll animations via CSS where possible, IntersectionObserver for triggers
