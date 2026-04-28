# Profile: SaaS Dashboard

## Detection Signals

- **package.json**: React/Vue/Svelte + charting library (recharts, d3, visx, nivo, chart.js, ApexCharts)
- **File patterns**: Routes containing `/dashboard`, `/analytics`, `/reports`, `/metrics`, `/overview`
- **Component patterns**: Data tables, metric cards, chart wrappers, filter bars
- **Keywords**: "dashboard", "analytics", "metrics" in README or config

## Aesthetic Direction

Data-dense but breathable. Professional without being corporate. Information hierarchy through typography weight and spatial grouping, not color variety. Dark mode as default — reduces eye strain for daily-use tools. Light mode as secondary option.

## Typography

- **Display**: Instrument Sans, Plus Jakarta Sans, General Sans (choose one — never Inter)
- **Body**: IBM Plex Sans, DM Sans, Geist Sans (choose one)
- **Mono**: JetBrains Mono, Fira Code (for data displays, code snippets, IDs)
- **Scale**: 1.2 ratio (minor third) — tight for data density. Sizes: 11/12/14/16/20/24px
- **Weights**: 400 body, 500 labels/table headers, 600 section headings, 700 page titles
- **Line height**: 1.4 for body, 1.2 for headings, 1.0 for metric numbers

## Color System

- **Philosophy**: Muted, low-saturation. Let the data speak, not the chrome.
- **Surfaces**: Dark backgrounds (#0f1117 primary, #161b22 secondary, #1c2128 elevated)
- **Text**: #e6edf3 primary, #8b949e secondary, #484f58 tertiary
- **Accent**: Single vibrant accent for key metrics and CTAs (pick one: blue, teal, or amber)
- **Semantic**: Success #3fb950, Warning #d29922, Error #f85149, Info #58a6ff
- **Dark/Light**: Dark is default. Light variant: #ffffff surfaces, #1f2328 text

## Motion

- **Approach**: Subtle, functional. Motion should indicate state change, not decorate.
- **Data transitions**: 200-400ms ease-out for chart updates and data refreshes
- **UI transitions**: 150-250ms ease-out for panels, dropdowns, tooltips
- **Loading**: Skeleton screens for data areas, pulse animation for refreshing metrics
- **Avoid**: Entrance animations for dashboard panels (they load frequently), parallax, bounce effects

## Layout

- **Structure**: Collapsible sidebar (240px expanded, 64px collapsed) + main content area
- **Grid**: 8px base grid. Content in 12-column grid with 16px gutters
- **Spacing**: Scale: 4/8/12/16/24/32/48px. Generous padding inside cards (16-24px)
- **Breakpoints**: Desktop-first (1440px design, 1024px compact, 768px tablet stack)
- **Key patterns**: Sticky top bar, fixed sidebar, scrollable main content, resizable panels

## Component Patterns

- **Metric cards**: Number prominent (24-32px, 600 weight), label secondary, trend indicator with semantic color
- **Data tables**: Sticky header, hover rows, sortable columns, dense rows (40px height), pagination or virtual scroll
- **Charts**: Consistent color palette across all charts, tooltips on hover, axis labels in secondary text
- **Filters**: Inline filter bar above data, active filters as removable chips
- **Navigation**: Sidebar with icon + label, collapsible groups, active state with accent indicator

## Anti-Patterns (Dashboard-Specific)

- Rainbow dashboards with 6+ chart colors competing for attention — use 3-4 harmonious colors max
- Gradient backgrounds behind data — impairs readability, keep data areas flat
- Oversized cards with minimal content — density is a feature, not a bug
- Pagination for small datasets (< 100 rows) — use client-side filtering or virtual scroll
- Real-time animations that distract from reading — debounce updates, batch visual changes

## Performance Budget

- **Fonts**: Max 2 families (1 sans + 1 mono), preload display font
- **CSS**: < 30KB gzipped
- **First paint**: < 1.5s (shell), < 3s (data populated)
- **Interactive**: < 2s
- **Bundle**: Lazy-load chart libraries, code-split by route
