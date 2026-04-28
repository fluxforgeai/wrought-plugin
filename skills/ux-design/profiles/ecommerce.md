# Profile: E-Commerce

## Detection Signals

- **package.json**: Stripe, Shopify SDK, Snipcart, Commerce.js, Medusa, Saleor, or cart/checkout libraries
- **File patterns**: Routes containing `/products`, `/cart`, `/checkout`, `/orders`, `/collections`
- **Component patterns**: Product cards, price displays, cart drawers, quantity selectors, rating stars
- **Keywords**: "shop", "store", "products", "cart", "checkout" in README or config

## Aesthetic Direction

Product-focused, trust-building, fast. Product images are the visual centerpiece — the UI stays out of the way. Trust signals are visible without being intrusive. Speed is a conversion metric: every 100ms of load time costs revenue.

## Typography

- **Display**: Outfit, Manrope, Sora (choose one — clean, modern, trustworthy)
- **Body**: DM Sans, Plus Jakarta Sans, Nunito Sans (choose one — highly readable)
- **Scale**: 1.25 ratio (major second). Product titles 20-24px, body 14-16px, prices prominent.
- **Weights**: 400 body/descriptions, 500 product titles, 600 prices, 700 CTAs
- **Line height**: 1.5 for descriptions, 1.3 for titles, 1.0 for prices
- **Max families**: 2 total (strict — every extra font costs conversion time)

## Color System

- **Philosophy**: Warm neutrals as base. UI disappears behind product photography. One bold accent for action buttons.
- **Surfaces**: Warm whites (#fafaf8, #f5f5f0) or cool whites (#fafbfc). Cards slightly elevated (#ffffff with subtle shadow).
- **Text**: Near-black (#1a1a1a) for readability. Muted (#6b7280) for secondary info.
- **Accent**: Bold, warm CTA color — amber (#f59e0b), coral (#ef4444), or brand-specific. Must pass contrast on white.
- **Trust signals**: Subtle green (#059669) for "In stock", "Verified", security badges. Never garish.
- **Sale/discount**: Red or coral for strike-through prices. Use sparingly — overuse cheapens perception.
- **Dark/Light**: Light mode default (product photos render best on light backgrounds).

## Motion

- **Approach**: Functional, conversion-supporting. Every animation serves a shopping task.
- **Add to cart**: Micro-animation confirming action (150ms). Cart icon badge increment with scale pulse.
- **Image galleries**: Smooth crossfade (200ms) between product images. Pinch-to-zoom on mobile.
- **Page transitions**: Fast (200ms). Cart drawer slides in (250ms ease-out).
- **Hover effects**: Product cards: subtle shadow elevation + image zoom (scale 1.05). Quick-view overlay.
- **Avoid**: Loading animations longer than 300ms, carousel auto-play, aggressive popups.

## Layout

- **Structure**: Top navigation with search + cart. Product grid as main content. Sidebar filters on desktop.
- **Grid**: Product grid: 4 columns desktop, 2 columns tablet, 1-2 columns mobile. Consistent card aspect ratio.
- **Spacing**: Tight grid gutters (12-16px) to show more products. Generous padding inside cards.
- **Breakpoints**: Mobile-first (375px design), tablet (768px), desktop (1280px). Mobile shopping is primary.
- **Key patterns**: Sticky add-to-cart bar on mobile, breadcrumb navigation, product filters (sidebar or drawer), recently viewed, related products.

## Component Patterns

- **Product cards**: Image (consistent aspect ratio), title, price, rating stars, quick-add button
- **Image gallery**: Main image + thumbnail strip or dot indicators. Zoom on hover/tap.
- **Price display**: Current price prominent. Original price strikethrough if discounted. Currency symbol.
- **Star ratings**: 5-star display with half-star support. Review count next to stars.
- **Cart drawer**: Slide-in from right. Item list with quantity +/-, remove button, subtotal, checkout CTA.
- **Trust badges**: SSL, money-back guarantee, shipping info — below fold or near checkout.

## Anti-Patterns (E-Commerce-Specific)

- Aggressive popups on page load — wait 30s+ or exit-intent, never immediate
- Product images with inconsistent aspect ratios — crop/pad all to same ratio
- "Out of stock" without alternatives — show similar products or notify-when-available
- Checkout forms requesting unnecessary information — minimize fields, autofill support
- Missing breadcrumbs on product pages — users need to navigate back to category

## Performance Budget

- **Fonts**: Max 2 families, preload body font
- **LCP**: < 2.0s (product grid or hero product)
- **Images**: Responsive srcset, WebP/AVIF, lazy-load below first viewport, consistent dimensions to prevent CLS
- **JS bundle**: < 150KB initial, lazy-load cart/checkout
- **Third-party**: Defer analytics, lazy-load reviews widget
