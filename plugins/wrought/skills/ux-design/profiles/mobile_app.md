# Profile: Mobile App

## Detection Signals

- **package.json**: React Native, Expo, Flutter (pubspec.yaml), Capacitor, Ionic, NativeScript
- **File patterns**: Platform-specific directories (`ios/`, `android/`), `App.tsx`/`App.vue` as entry
- **Component patterns**: Tab navigators, stack navigators, bottom sheets, gesture handlers
- **Keywords**: "mobile", "native", "iOS", "Android", "cross-platform" in README

## Aesthetic Direction

Touch-first, native-feel, system-integrated. The app should feel like it belongs on the device, not like a website crammed into a phone. Respect platform conventions (iOS Human Interface Guidelines, Material Design 3) while maintaining brand identity. Thumb-zone ergonomics drive layout decisions.

## Typography

- **Display**: Plus Jakarta Sans, Nunito, Quicksand (choose one — friendly, rounded, mobile-optimized)
- **Body**: System font stack as primary option (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`). Plus Jakarta Sans or DM Sans as cross-platform web fallback.
- **Mono**: JetBrains Mono (if code/data display needed)
- **Scale**: 1.2 ratio. Minimum text size 16px (prevents iOS zoom on focus). Sizes: 12/14/16/20/24/32px.
- **Weights**: 400 body, 500 labels, 600 navigation titles, 700 screen headers
- **Note**: Roboto is acceptable ONLY as the Android system font, not as a design choice.

## Color System

- **Philosophy**: Platform-adaptive. Follow system light/dark mode. Tinted backgrounds for depth.
- **Surfaces**: Light: system white + tinted gray (#f2f2f7 iOS, #f5f5f5 Material). Dark: system dark + elevated surfaces.
- **Text**: System defaults — near-black on light, near-white on dark. System-provided opacity for secondary.
- **Accent**: Vibrant, saturated accent for primary actions. iOS default blue (#007AFF) or Material teal (#03DAC6) as starting points — customize for brand.
- **Semantic**: System-provided when possible. Success green, warning amber, error red, info blue.
- **Tinting**: Subtle background tints for grouped content (iOS grouped table style).

## Motion

- **Approach**: Spring physics, gesture-driven. Duration is a result of physics parameters, not a fixed value.
- **Spring animations**: Tension 170-300, friction 20-30 (react-native-reanimated or Animated API). Feels natural, not mechanical.
- **Gesture transitions**: Swipe-to-go-back, pull-to-refresh, swipe-to-delete with spring snap. Interactive, not scripted.
- **Screen transitions**: iOS push/pop (slide from right), Material shared-axis or fade-through.
- **Haptic cues**: Pair animation timing with haptic feedback for confirmations (impact, selection, notification).
- **Avoid**: CSS-style `transition: 300ms ease` — feels web-like, not native. Use spring-based motion.

## Layout

- **Structure**: Tab bar navigation (bottom). Stack navigation within each tab. Safe area insets respected.
- **Grid**: 16px horizontal margins. 8px base spacing unit. Content width = screen width - 32px.
- **Touch targets**: 44x44px minimum (iOS HIG). 48x48dp recommended (Material). Generous spacing between targets.
- **Breakpoints**: Phone (375px), large phone (414px), tablet (768px+). Tablet may use split-view.
- **Key patterns**: Bottom tab bar (4-5 tabs max), pull-to-refresh, bottom sheet modals (not centered modals), floating action button (Material), edge-to-edge content.

## Component Patterns

- **Navigation**: Bottom tabs with icon + label. Stack headers with back button and title.
- **Lists**: Grouped lists with section headers (iOS style) or continuous lists (Material).
- **Bottom sheets**: Drag handle, snap points (half-screen, full-screen). Primary interaction surface for actions.
- **Forms**: Large inputs (48px height), labels above fields, keyboard-aware scroll. "Done" button in keyboard toolbar.
- **Action sheets**: Platform-specific — iOS action sheet, Material bottom sheet with options.
- **Pull-to-refresh**: Spring overscroll animation. Loading indicator replaces pull indicator.

## Anti-Patterns (Mobile-Specific)

- Hamburger menus as primary navigation — use bottom tabs, they're always visible and thumb-reachable
- Hover effects (no hover on touch) — replace with tap highlighting and long-press actions
- Fixed-position headers taller than 64px — eat too much screen space on phones
- Text inputs smaller than 16px font-size — triggers auto-zoom on iOS, breaks layout
- Centered modals (web-style) — use bottom sheets that are thumb-reachable

## Performance Budget

- **Fonts**: Max 1 custom family (system fonts for everything else), preload critical font
- **JS bundle**: < 200KB initial (React Native) or equivalent
- **Time to interactive**: < 3s cold start, < 1s warm start
- **Frame rate**: 60fps for all animations and gestures (no jank during scroll)
- **Images**: Responsive sizes for device pixel ratio (@2x, @3x), lazy-load off-screen
