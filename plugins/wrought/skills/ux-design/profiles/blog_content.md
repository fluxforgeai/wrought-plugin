# Profile: Blog / Content Site

## Detection Signals

- **package.json**: MDX, @next/mdx, contentlayer, markdoc, @astrojs/mdx, gatsby-plugin-mdx, rehype, remark
- **File patterns**: `/blog`, `/posts`, `/articles` routes; `content/` or `posts/` directories with `.md`/`.mdx` files
- **Component patterns**: Article layouts, table of contents, code blocks, author cards, tag/category lists
- **Keywords**: "blog", "writing", "articles", "content", "posts" in README or config

## Aesthetic Direction

Readable, editorial, serif-forward. Content is king — typography creates the atmosphere, not graphics. The reading experience should feel like a well-designed magazine or literary journal. Generous whitespace signals confidence. Every typographic choice serves comprehension.

## Typography

- **Display**: Literata, Lora, Playfair Display (choose one — editorial, distinctive serif)
- **Body**: Source Serif 4, Merriweather, Crimson Pro (choose one — optimized for long-form reading)
- **Sans alternative**: Plus Jakarta Sans, DM Sans (for UI elements, navigation, metadata)
- **Mono**: Fira Code, JetBrains Mono (for code blocks within articles)
- **Scale**: 1.333 ratio (perfect fourth). Body 18-20px (larger for reading comfort). Display 36-48px.
- **Weights**: 400 body, 400 italic for emphasis, 600 subheadings, 700-800 article titles
- **Line height**: 1.6-1.8 for body (generous for reading), 1.2 for display headings
- **Reading width**: 65-75ch maximum. Never wider — eye tracking degrades past 80ch.

## Color System

- **Philosophy**: High contrast for reading. Color serves the words, never competes with them.
- **Surfaces**: Off-white (#fefefe, #faf9f6 warm, or #f8fafc cool). Never pure white.
- **Text**: Near-black (#1a1a1a or #2d2d2d) for body. Not pure #000. Slightly warm for serif contexts.
- **Accent**: Single muted accent for links and highlights. Underlined links preferred over colored text.
- **Pull quotes**: Muted color background or left border accent. Large italic text.
- **Code blocks**: Subtle background (#f6f8fa light, #1e1e1e dark) with syntax highlighting.
- **Dark/Light**: Light default (reading context). Dark mode with warm-toned dark (#1a1a2e or #1e1e1e), not pure black.

## Motion

- **Approach**: Subtle, unobtrusive. Reading should not be interrupted by animation.
- **Smooth scroll**: For table of contents anchor links. 300ms ease.
- **Read progress indicator**: Thin bar at top of viewport. Subtle color, 2-3px height.
- **Content reveal**: Optional fade-in on scroll for article body (opacity only, no translate — don't shift reading position).
- **Link hovers**: Underline animation or color transition (150ms). Subtle, not distracting.
- **Avoid**: Parallax, entrance animations for text content, floating share buttons that overlay text.

## Layout

- **Structure**: Single-column reading area, centered. Table of contents sidebar on desktop (optional, sticky).
- **Reading column**: Max-width 75ch (approximately 680px). Centered with generous side margins.
- **Spacing**: Between paragraphs: 1.5em. Between sections (h2): 3em above, 1em below. Between list items: 0.5em.
- **Breakpoints**: Content reflows naturally due to max-width. Mobile (375px): full-bleed images, tighter margins. Tablet (768px): ToC becomes top-of-article. Desktop (1200px+): sticky sidebar ToC.
- **Key patterns**: Article header with title + meta (author, date, reading time, tags), table of contents, footnotes, related articles grid at bottom, author bio card.

## Component Patterns

- **Article headers**: Large title (h1, 36-48px serif), meta row (author avatar + name + date + reading time), optional hero image (full-bleed or contained)
- **Code blocks**: Syntax-highlighted, filename/language label, copy button, line numbers optional. Dark background even in light mode.
- **Block quotes**: Left border (3-4px accent color) + italic text + optional attribution. Indented from body.
- **Image captions**: Small text (14px), muted color, centered below image. Alt text always present.
- **Table of contents**: h2/h3 hierarchy. Active section highlighted on scroll. Sticky on desktop sidebar.
- **Footnotes**: Numbered superscript links, footnote section at article bottom. Bi-directional links.

## Anti-Patterns (Blog-Specific)

- Body text wider than 75ch — long lines cause eye-tracking fatigue
- Sans-serif body text for long-form articles — serif fonts improve readability for sustained reading
- Intrusive share buttons overlaying the reading column — place at article top/bottom, not floating
- Auto-playing media within articles — reader controls when media plays
- Missing reading time estimate — readers want to know the commitment before starting

## Performance Budget

- **Fonts**: Max 2 families (1 serif + 1 sans or mono), preload above-fold display font
- **CLS**: < 0.05 (no layout shifts from font loading — use size-adjust or font-display: optional)
- **LCP**: < 2.5s (article title + first paragraph visible)
- **Images**: Responsive (srcset), lazy-load below first viewport, explicit width/height to prevent CLS
- **JS**: Minimal — table of contents, syntax highlighting, and reading progress can be progressive enhancement
