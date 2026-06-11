---
name: ionis-app-system
description: Apply the Ionis application design system — a complete token system (spacing, type scale, color, elevation, radius, motion, focus rings, z-index) and component specs (data tables, empty states, buttons, forms, badges, cards, modals, loading patterns) — to any web app, dashboard, HTML artifact, UI component, or Databricks App (Streamlit, Dash, Gradio, or React frontends — includes a framework adapter). Use whenever building or restyling browser-based tools, demo decks rendered as HTML, patient-finding dashboards, KPI views, internal apps, or React/HTML artifacts; whenever the user says an app should look "polished", "professional", "expensive", "consistent", or "on-brand"; and whenever choosing any spacing, color, shadow, animation, or table styling value. Use alongside (not instead of) frontend-design — that skill sets creative direction, this one enforces systematic consistency. Do not use for PowerPoint slides (use ionis-brand-slides).
---

# Ionis App System

Make apps feel expensive through systematic consistency. "Expensive feeling" is not an aesthetic — it is the absence of arbitrary decisions. Every spacing value from one scale, every color from one palette, every transition from one set of durations, every table built to one spec. Users can't name what's consistent, but they instantly feel what isn't.

This skill is the systematic layer; the `frontend-design` skill is the creative layer. When both apply: take aesthetic direction (mood, typography personality, density) from frontend-design or the user, then implement it exclusively through this token system. When they conflict on a concrete value, this system wins.

## The contract

1. **Tokens only.** Components never contain raw values. No `padding: 10px`, no `#ccc`, no `transition: 0.3s`. If you're typing a hex code or a px value outside the token sheet, stop and use a token. The full sheet is in `references/tokens.css` — paste it into the app verbatim (it includes the dark theme and baseline rules).
2. **The five-state rule.** Every interactive element ships with hover, active, focus-visible, disabled, and (where async) loading states. See the universal contract in `references/components.md`.
3. **The three-absence rule.** Every data view ships with its loading state (skeleton, dimension-preserving), its empty state (says what would be here and how to get it there), and its error state (what happened + what to do). A view that only handles the happy path is unfinished.
4. **One accent.** Raspberry (`--raspberry`) is the single interactive accent — primary buttons, links, selection, focus rings. Magenta is for data viz and selected indicators. Semantic colors only carry status meaning. An app where everything is colorful is an app where nothing is.

## Core values (memorize these; full sheet in references/tokens.css)

- **Spacing**: 4px base. Allowed: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64. Component-internal gaps use 4–12; between components 16–24; between sections 32–48.
- **Type**: 14px UI base (13px dense), Inter/system stack for UI text; `--font-display` (Gotham → Montserrat fallback) for page titles and KPI stats, per the brand portal's Gotham-for-designed-materials rule. Sizes: 12/13/14/16/20/24/32 + 40 for KPI stats. Weights: 400/500/600 only. Headings and stats at line-height 1.25; body 1.5. All numerals in tables and stats: `tabular-nums`.
- **Color**: neutrals are an 11-step gray ramp anchored at brand Cool Gray 1 (`#EBECEE`) and Cool Gray 11 (`#53565A`, the default text color). Accents: Raspberry `#A20067`, Magenta `#D70073`. Components use semantic aliases (`--bg-surface`, `--text-primary`, `--border-default`), never raw grays — this is what makes the dark theme free.
- **Radius**: 4 (badges) / 6 (buttons, inputs) / 8 (cards) / 12 (containers).
- **Elevation**: 3 shadow levels = 3 stacking meanings: resting (1), floating (2: menus, popovers), modal (3). Shadows communicate stacking, never decoration. Dark theme swaps shadows for borders automatically via tokens.
- **Motion**: 100ms micro / 150ms standard / 200ms emphasis / 300ms large surfaces. Enter with `--ease-out`, exit with `--ease-in`. Animate only transform and opacity. Spinners delayed 150ms so fast operations never flicker. `prefers-reduced-motion` respected (built into the token sheet).
- **Focus**: 2px offset ring in Raspberry on `:focus-visible` only. `outline: none` without the ring replacement is forbidden.

## Brand integration rules (apps ≠ slides)

The slide brand book maximizes Raspberry/Magenta presence; apps invert this. In an app, neutral surfaces dominate and brand color concentrates in interactive and signature moments:

- Raspberry/Magenta must appear somewhere meaningful in every view (primary action, selected nav item, KPI accent, header rule) — but as accent, never as large surface fills behind content.
- **Amber (`#FFAF00`) is never text on white** — fills with dark text, and charts, only.
- The **Prow** (one large rounded corner, e.g. `border-radius: 8px 32px 8px 8px`) is available as a signature flourish on at most one hero/KPI surface per view.
- Semantic status colors are darkened versions of the brand secondary palette so they pass WCAG AA as text (already in the token sheet) — never use raw brand blue/green/bright-yellow as text.

## Workflow

1. **Paste the token sheet** (`references/tokens.css`) into the app first, before writing any component. Pick light or dark via `data-theme`.
2. **Read `references/components.md`** before building any of: data tables, forms, empty states, buttons, badges, modals, toasts, KPI cards, or loading states. These specs are exact (row heights, paddings, state behaviors) — don't improvise them.
3. **Databricks Apps / Streamlit / Dash / Gradio**: read `references/databricks-apps.md` first — it translates the system into config.toml theming, CSS injection, and framework idioms for environments where you don't control the DOM. The token values are universal; the mechanism differs.
4. **Build with semantic aliases** (`--bg-surface`, `--text-secondary`) so theming stays intact.
5. **Self-review before returning** (below).

## Self-review checklist — run before returning any UI

1. Grep your output for raw values: any hex outside the token sheet, any px spacing not in the scale, any raw `ms` duration? Fix to tokens.
2. Tab through mentally: every interactive element reachable, visible focus ring, logical order, no traps?
3. For each async region: skeleton present and dimension-stable? Empty state with guidance? Error state with recovery?
4. Every interactive element: all five states implemented?
5. Tables: numbers right-aligned tabular-nums, headers match column alignment, sticky header, hover row, in-table empty state?
6. One primary button per region? Raspberry present somewhere meaningful but not flooding?
7. Color never the sole carrier of meaning (badges have text/dot, errors have messages)?
8. Layout shift: does anything resize when data, fonts, or pending states resolve?

If the user asks for something off-system ("make it neon green"), do it — but route it through a token (define `--accent-custom` once) and tell them what you changed, so the system stays auditable.
