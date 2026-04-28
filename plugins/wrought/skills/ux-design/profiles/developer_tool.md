# Profile: Developer Tool

## Detection Signals

- **package.json**: CLI frameworks (commander, yargs, oclif, meow), terminal UI (ink, blessed, prompts), code editor extensions, API client generators, SDK generators
- **File patterns**: `cli/` or `bin/` directories, `.vscode/` extension manifests, Electron configs
- **Component patterns**: Terminal output displays, code editors, diff viewers, JSON explorers, API playgrounds
- **Keywords**: "CLI", "SDK", "developer", "API", "terminal", "extension" in README or package description

## Aesthetic Direction

Monospace-heavy, dark-first, terminal aesthetic. Built by developers for developers. Code is a first-class citizen in the UI — not an afterthought in a code block. The interface should feel like an extension of the terminal: fast, precise, keyboard-driven. Information density is a feature.

## Typography

- **Display**: Space Grotesk, Instrument Sans, Geist Sans (choose one — technical, geometric)
- **Body**: DM Sans, Geist Sans, IBM Plex Sans (choose one — clean, pairs well with mono)
- **Mono**: Fira Code, JetBrains Mono, Geist Mono (PRIMARY citizen — used for code, data, IDs, paths, commands). Must support ligatures.
- **Scale**: 1.2 ratio. Body 14-15px, mono 13-14px (mono needs slightly smaller due to fixed-width). Display 24-32px.
- **Weights**: 400 body, 500 mono (for better readability at small sizes), 600 headings only. Minimal weight variation.
- **Line height**: 1.5 for body, 1.6-1.7 for mono/code blocks (generous for code readability)

## Color System

- **Philosophy**: Dark background default. Syntax-highlighting-inspired accents. Color carries semantic meaning from the terminal.
- **Surfaces**: Dark primary (#0d1117 GitHub-style, or #1e1e1e VS Code-style). Elevated surface +1 lightness step (#161b22). Borders at low contrast (#30363d).
- **Text**: #e6edf3 primary, #8b949e secondary, #484f58 muted
- **Accent**: Syntax-inspired palette. Blue (#58a6ff) for links/primary actions, green (#3fb950) for success/add, red (#f85149) for error/delete, yellow (#d29922) for warnings, purple (#bc8cff) for special/highlight.
- **Code syntax**: Follow the project's preferred syntax theme. If none, use GitHub Dark or One Dark Pro as baseline.
- **Dark/Light**: Dark is default (developer preference, matches terminal). Light mode as option, not priority.

## Motion

- **Approach**: Functional only. Instant feedback. Developers notice latency before aesthetics.
- **Terminal-style typing**: Optional typewriter effect for key moments (CLI output display, demo mode). 20-50ms per character.
- **Expand/collapse**: 100-150ms. Code block expand, panel resize, tree node toggle.
- **Copy feedback**: Brief flash or checkmark on copy button (200ms). Confirm the action happened.
- **Avoid**: Smooth scroll in code views (instant scroll preferred), page transition animations, loading spinners longer than 200ms (show skeleton or content immediately).

## Layout

- **Structure**: Resizable panels (editor-style). Command palette accessible via Ctrl+K/Cmd+K. Sidebar navigation for sections.
- **Grid**: Panel-based, not grid-based. Draggable dividers between panels. Minimum panel widths enforced.
- **Spacing**: Compact — 4/8/12/16/24px scale. Code areas: 8px inner padding, 4px between lines.
- **Breakpoints**: Desktop-only (developer tools are used on monitors). Minimum 1024px width. No mobile optimization.
- **Key patterns**: Split-pane (code left, output right), command palette overlay, file tree sidebar, tabbed editor areas, terminal/output panel at bottom, breadcrumb path display.

## Component Patterns

- **Code blocks**: Syntax-highlighted, line numbers, copy button, language badge, filename header. Expandable for long blocks.
- **Terminal emulator**: Monospace output area, command input with history (up arrow), colored output (ANSI colors).
- **Diff viewer**: Side-by-side or unified diff. Green/red line highlighting. Line number gutters.
- **JSON/YAML viewer**: Collapsible tree. Syntax-colored keys and values. Copy path, copy value actions.
- **API playground**: Method selector (GET/POST/PUT/DELETE), URL input, headers editor, body editor, response viewer with timing.
- **Keyboard shortcut help**: Modal or panel showing all shortcuts. Grouped by context. Toggled via `?` key.

## Anti-Patterns (Developer-Tool-Specific)

- Light mode as only option — developers overwhelmingly prefer dark mode for code-heavy interfaces
- Non-monospace code displays — code must always be in a monospace font, no exceptions
- Copy buttons that disappear until hover — always visible for code blocks (no hover on touch, and even on desktop, visible is faster)
- Missing keyboard navigation — every action should be keyboard-accessible. Command palette is essential.
- Syntax highlighting without theme consistency — all code views must use the same syntax theme

## Performance Budget

- **Fonts**: Max 2 families (1 sans + 1 mono required), preload mono font
- **Syntax highlighting**: Lazy-load grammar definitions. Use Shiki or Prism with dynamic import.
- **Dark mode**: Default (no flash — set theme before first paint via blocking script or `<meta name="color-scheme">`)
- **Initial load**: < 2s to interactive
- **Code rendering**: Handle 1000+ line files without scroll jank. Virtualize if needed.
