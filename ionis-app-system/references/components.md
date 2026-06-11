# Component Specifications

Concrete specs for the components that make or break "expensive feeling." Every value references a token from `tokens.css`. If a component needs a value that doesn't exist as a token, the answer is almost always one of the existing tokens — resist inventing values.

## Interaction states — the universal contract

Every interactive element implements ALL of these states. Missing states are the #1 source of cheap-feeling UI.

| State | Spec |
|---|---|
| Rest | Defined per component below |
| Hover | Background shifts by `--bg-hover` overlay (or one gray step darker for filled elements). Contrast INCREASES on hover — never fades. `transition: background var(--duration-micro) var(--ease-standard)` |
| Active/pressed | `--bg-active` overlay (or two steps). No scale transforms on press for desktop tools |
| Focus | `:focus-visible` → `--focus-ring`. Never on mouse click, always on keyboard |
| Selected | `--bg-selected` background + 2px `--border-accent` left edge or full border. Selection must survive hover (selected+hover is visibly both) |
| Disabled | `opacity: 0.45; pointer-events: none; cursor: not-allowed` on wrapper. Disabled elements are skipped in tab order |
| Loading | Element keeps its size (no layout shift); label swaps to spinner or spinner prepends; element disabled during pending |

## Buttons

- Height: 32px (default), 28px (dense toolbars), 40px (primary page actions). Padding: `0 var(--space-3)` to `0 var(--space-4)`.
- Font: `--text-base`, `--weight-medium`. Radius: `--radius-md`.
- **Primary**: `--raspberry` bg, white text → hover `--raspberry-hover` → active `--raspberry-active`. ONE primary button per view region.
- **Secondary**: `--bg-surface` bg, `--border-default` 1px border, `--text-primary` → hover `--bg-hover`.
- **Ghost**: transparent → hover `--bg-hover`. For toolbars and table row actions.
- **Danger**: `--danger` bg only for the confirming action inside a destructive flow; elsewhere use secondary with `--danger` text.
- Icon+label gap: `--space-2`. Icon-only buttons: square, with `aria-label` and a tooltip.
- Pending: spinner replaces or precedes label, width locked (`min-width` set from rest state) so the button doesn't resize.

## Data tables

The dashboard workhorse. Spec:

- **Row height**: 40px default, 32px dense. Cell padding: `var(--space-2) var(--space-3)`.
- **Header**: `--bg-sunken` background, `--text-xs` UPPERCASE `--tracking-caps` `--weight-medium` `--text-secondary`. Sticky: `position: sticky; top: 0; z-index: var(--z-sticky)`. 1px `--border-default` bottom border, slightly stronger (`--border-strong`) to separate from body.
- **Body rows**: 1px `--border-default` bottom borders. No zebra striping by default (borders + hover are enough; zebra adds noise). Hover: `--bg-hover` on the full row. Selected: per universal contract.
- **Numbers**: right-aligned, `font-variant-numeric: tabular-nums`, `--font-mono` optional for ID-like values. Text: left-aligned. Never center-align data columns.
- **First column** carries the row identity — `--weight-medium`, `--text-strong`.
- **Alignment**: header alignment always matches its column's data alignment.
- **Truncation**: `text-overflow: ellipsis` + `title` attribute (or tooltip) on overflow. Never wrap mid-row in dense tables.
- **Status in tables**: badge (below), not colored text alone — color is never the only signal.
- **Sorting**: clickable headers show direction caret; the sorted column header gets `--text-strong`.
- **Loading**: skeleton rows (3–7 gray `--gray-100` bars at 60% width, subtle pulse) preserving exact row height — never a spinner replacing the table.
- **Empty**: empty-state block rendered INSIDE the table region at ≥200px height (see Empty states). Keep the header row visible so context isn't lost.

## Empty states

Render one anywhere a collection can be empty: first run, zero results after filtering, cleared data, errors.

- Centered in the content region, max-width 360px, padding `--space-8` vertical.
- Structure: optional glyph (24–32px, `--text-muted`) → title (`--text-md`, `--weight-semibold`, `--text-strong`) → one line of description (`--text-base`, `--text-secondary`) → optional primary or secondary action.
- The copy says what would be here and how to get it there: "No patients match these filters. Try widening the date range." Not: "No data."
- Zero-results-from-filter empty states MUST offer a "Clear filters" action.
- Error empty states use the same layout with `--danger` glyph and a retry action.

## Forms & inputs

- Input height matches buttons (32px default). Padding `0 var(--space-3)`. Radius `--radius-md`. 1px `--border-default`, bg `--bg-surface`.
- Hover: `--border-strong`. Focus: `--focus-ring` (border does not also change color — one signal).
- Label: above the field, `--text-sm` `--weight-medium`, gap `--space-1`. Never placeholder-as-label.
- Placeholder: `--text-muted`. Helper text below: `--text-xs` `--text-secondary`.
- Error: 1px `--danger` border + `--text-xs` `--danger` message below the field. Message says how to fix, not just "invalid." On submit, focus moves to the first errored field.
- Required: mark the exceptions — if most fields are required, mark the optional ones "(optional)".
- Vertical rhythm between fields: `--space-4`. Between sections: `--space-8`.

## Badges & status

- Height 20px, padding `0 var(--space-2)`, radius `--radius-sm` (or `--radius-full` for pills), `--text-xs` `--weight-medium`.
- Tint background + dark text from the same semantic family: `--success-tint`/`--success`, etc. Never white text on tint.
- `--amber` fills always pair with `--gray-900` text (amber fails contrast with white).
- Include a dot, icon, or label — color alone is never the only differentiator.

## Cards & panels

- `--bg-surface`, `--radius-lg`, `--shadow-1` (light theme) or token border (dark). Padding `--space-4` to `--space-6`.
- Card title: `--text-base` or `--text-md`, `--weight-semibold`, `--text-strong`; gap to content `--space-3`.
- KPI cards: number in `--text-stat` `--weight-semibold` `tabular-nums` `--text-strong`; label `--text-xs` uppercase `--text-secondary` above or below; delta as a semantic badge.
- Brand flourish: a hero/KPI card MAY use the Prow corner (`border-radius: 8px 32px 8px 8px`) and a `--raspberry` accent. One Prow surface per view, maximum — it's a signature, not a pattern fill.

## Modals & overlays

- Scrim: `rgba(13,14,16,0.5)`, `z-index: var(--z-overlay)`. Modal: `--bg-surface`, `--radius-xl`, `--shadow-3`, `z-index: var(--z-modal)`, max-width 480px (forms) / 720px (content), enters with `--duration-large` `--ease-out` fade+4px rise; exits `--duration-standard` `--ease-in`.
- Focus is trapped inside; Escape closes (unless mid-destructive-confirm); focus returns to the trigger on close.
- Footer actions right-aligned: secondary (Cancel) left of primary. Destructive confirms put the destructive action in `--danger` and name the object ("Delete 14 rows", not "OK").

## Toasts

- Bottom-left or bottom-center, `--bg-surface` (light) / `--gray-800` (dark elevated), `--shadow-2`, `--radius-lg`, auto-dismiss 5s with pause-on-hover.
- Destructive-action toasts carry an **Undo** action whenever the operation is reversible — prefer undo-toast over confirm-dialog for frequent operations.

## Loading patterns (choosing the right one)

| Situation | Pattern |
|---|---|
| < 150ms expected | Nothing. Delay any spinner by 150ms so it never flickers |
| Button-triggered action | Pending state on the button itself |
| Table/list/chart region | Skeleton preserving final layout dimensions |
| Whole-page first load | Skeleton of the page shell, never a blank screen |
| Long operation (>3s) | Progress indication + what's happening text; cancel if possible |

Layout shift when content arrives is a defect: skeletons must match final dimensions.
