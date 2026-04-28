# Profile: Admin Panel

## Detection Signals

- **package.json**: Admin template libraries (react-admin, AdminJS, Retool SDK, Refine), role/permission libraries (CASL, casbin)
- **File patterns**: Routes containing `/admin`, `/settings`, `/users`, `/roles`, `/permissions`, `/config`
- **Component patterns**: CRUD tables, form builders, role selectors, audit log displays
- **Keywords**: "admin", "backoffice", "internal", "management" in README or config

## Aesthetic Direction

Dense, functional, keyboard-navigable. Information over aesthetics. Optimized for power users who spend hours daily in this interface. Every pixel serves a purpose. The UI should feel like a well-organized control room — everything reachable, nothing wasted.

## Typography

- **Display**: Space Grotesk, Instrument Sans, General Sans (choose one — technical, clean)
- **Body**: DM Sans, IBM Plex Sans, Source Sans 3 (choose one — highly readable at small sizes)
- **Mono**: JetBrains Mono, Space Mono, IBM Plex Mono (for IDs, timestamps, JSON, code snippets)
- **Scale**: 1.125 ratio (major second — tight). Sizes: 11/12/13/14/16/18/20px. Dense by design.
- **Weights**: 400 body/table cells, 500 table headers/labels, 600 section headings, 700 page titles
- **Line height**: 1.4 for body, 1.2 for headings, 1.0 for mono/data

## Color System

- **Philosophy**: Muted, professional. Color is for status and actions, not decoration.
- **Surfaces**: Near-white (#fafafa primary, #ffffff cards, #f3f4f6 table striping)
- **Text**: #111827 primary, #6b7280 secondary, #9ca3af placeholder
- **Accent**: Muted blue (#3b82f6) or indigo (#6366f1) for primary actions. Not too saturated.
- **Semantic**: Prominent — status badges are a primary UI element. Success #059669, Warning #d97706, Error #dc2626, Info #2563eb. Badge backgrounds at 10% opacity of their color.
- **Borders**: #e5e7eb (light, consistent). Tables, cards, inputs all use same border color.
- **Dark/Light**: Light default (document-reading context). Dark mode optional.

## Motion

- **Approach**: Minimal, functional. Speed over style. Power users notice slowness, not prettiness.
- **Expand/collapse**: 150ms ease-out. Sidebar collapse, accordion panels, detail drawers.
- **Toast notifications**: Slide in from top-right, 200ms. Auto-dismiss after 5s. Stack if multiple.
- **Loading**: Skeleton screens for tables. Inline spinners (16px) for button actions.
- **Avoid**: Page transition animations, staggered reveals, hover effects with delay. Instant feedback always.

## Layout

- **Structure**: Collapsible sidebar (256px expanded, 64px collapsed) + top bar (48px) + content area
- **Grid**: Content in 12-column grid. Tables expand to full width. Forms in 2-column layout (label: value).
- **Spacing**: 8px base. Compact: 8/12/16/24/32px. Cards with 16px padding, 12px gap between.
- **Breakpoints**: Desktop-first (1440px design). Tablet (1024px — sidebar collapses). No mobile optimization (admin panels are desktop tools).
- **Key patterns**: Breadcrumbs on every page, tabbed content sections, split-pane layouts, settings pages with sidebar sub-navigation.

## Component Patterns

- **Data tables**: Sortable columns, column visibility toggles, bulk action checkbox, row-level actions dropdown, pagination (10/25/50/100 per page), export button
- **Filter bars**: Inline above table. Text search + dropdown filters + date range picker + active filter chips with clear-all
- **Forms**: Labels above fields. Validation inline on blur. Submit disabled until valid. Cancel always available. Multi-step wizards for complex creation.
- **Role/permission badges**: Colored chips with icon. Admin (red), Editor (blue), Viewer (gray).
- **Audit logs**: Timestamp + user + action + target + diff. Filterable, exportable.
- **Settings panels**: Left sidebar with sections, right content area. Save per-section, not per-page.

## Anti-Patterns (Admin-Specific)

- Infinite scroll on data tables — admin users need to reference row counts and navigate pages
- Confirmation modals for non-destructive actions — only confirm deletes and irreversible operations
- Missing keyboard shortcuts — power users expect Ctrl+S (save), Escape (cancel), Tab (next field)
- Single-column forms stretching to full width — cap form width at 600px or use 2-column label:value layout
- Hiding the sidebar to gain space — use collapsible sidebar instead, never remove navigation

## Performance Budget

- **Fonts**: Max 2 families (1 sans + 1 mono), preload body font
- **CSS**: < 40KB gzipped
- **Tables**: Virtualized rendering for 100+ rows (react-virtual, TanStack Virtual)
- **Initial load**: < 2s to interactive (shell + first data load)
- **Subsequent navigation**: < 500ms (cached data, client-side routing)
