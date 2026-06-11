# Footer + safe area spec

The footer is the strip at the bottom of every content slide in the official Ionis PPT template, carrying org/section/date on the left and slide number on the right. Title and closing slides own their full canvas and skip the footer.

This file documents the exact pattern so HTML decks read identically to PPT decks, and so the most common slide bug — content overlapping the footer — does not recur.

## Position

| Property | Value |
|---|---|
| Vertical position | ~95% of slide height (16px from bottom on 720px slide) |
| Horizontal margins | 70px from each edge (consistent with slide-inner padding) |
| Total footer height | ~12–14px including text |

## Content pattern

```
[IONIS-LOGO] · [Section] · [Date or Confidentiality]                     NN / TT
```

**The "Ionis" prefix is rendered as the actual Ionis logo SVG, not as text.** Use `../assets/logos/Ionis_Logo_web_HEX.svg` at ~17px tall (the small footer-logo lockup). Per brand book p.12, never type "IONIS" where the logo is meant to appear.

Left-side text after the logo (small caps, letter-spaced):
- `[IONIS] · AI DATA CLUB · SKILLZ`
- `[IONIS] · PIPELINE UPDATE · Q3 2025`
- `[IONIS] CONFIDENTIAL · INVESTOR DAY · MAY 2026`

Right side: zero-padded slide number / total. Examples:
- `01 / 14`
- `07 / 22`

## Typography

| Property | Value |
|---|---|
| Font | Arial Bold (Gotham Bold if available) |
| Size | 10px (PPT: ~8pt) |
| Color | Cool Gray 11 (#53565A) |
| Letter-spacing | .14em |
| Transform | Uppercase |

Footer logo: ~42px wide × 17px tall (preserving the lockup's aspect ratio). Separator dots (`·`) in Cool Gray 11 at 45% opacity.

## Safe area — the no-content rule

**Reserve the bottom 10–12% of the slide as a no-content zone** so body content never collides with the footer or with any bottom Prow accent.

For HTML decks on a 720px slide: `padding-bottom: 78px` on `.slide-inner`. This accounts for:
- 16px footer offset from bottom
- ~14px footer text height
- ~48px safe buffer / Prow-accent clearance

Failing this rule is the #1 source of "footer-overlap" bugs. Verify before returning specs:

- Code blocks, image cards, and tables must not extend past the safe-area boundary.
- Grids with `flex: 1` filling the slide-body need `align-items: start` or explicit max-height, not `align-items: stretch`, when their content can exceed the available height.

## When to omit the footer

- **Layout A — Cover / Title slide:** no footer. The cover owns its full canvas.
- **Layout B — Section divider:** no footer. The breath-pause owns its full canvas.
- **Layout I — Closing slide:** no footer. The closing owns its full canvas (the band layout includes the slide number in the top band corner if needed).

Every other layout uses the footer.

## Multi-presenter handling

The footer is not the place for presenter names. Presenters belong on the title slide (Layout A) and optionally on the closing slide (Layout I), credited as `**Name** · Role` separated by a small Raspberry or Orange dot.

## Reference HTML

```html
<div class="slide-footer">
  <span class="slide-footer-left">
    <span class="footer-logo" aria-label="Ionis"></span>
    <span class="sep">·</span>AI Data Club<span class="sep">·</span>Skillz
  </span>
  <span>01 / 14</span>
</div>
```

```css
.slide-footer {
  position: absolute;
  bottom: 16px;
  left: 70px; right: 70px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: .14em;
  text-transform: uppercase;
  color: var(--gray-11);
  z-index: 2;
  pointer-events: none;
}
.slide-footer .sep { color: var(--gray-11); opacity: .45; margin: 0 10px; }
.slide-footer .slide-footer-left { display: inline-flex; align-items: center; }
.slide-footer .footer-logo {
  display: inline-block;
  width: 42px;
  height: 17px;
  background-image: url("../assets/logos/Ionis_Logo_web_HEX.svg");
  background-repeat: no-repeat;
  background-position: left center;
  background-size: contain;
  vertical-align: middle;
}
```

Inject this into every content slide via JS so authoring HTML stays clean:

```js
slides.forEach((slide, i) => {
  if (slide.classList.contains('title-slide') || slide.classList.contains('closing')) return;
  const inner = slide.querySelector('.slide-inner');
  const footer = document.createElement('div');
  footer.className = 'slide-footer';
  footer.innerHTML = `
    <span class="slide-footer-left">
      <span class="footer-logo" aria-label="Ionis"></span>
      <span class="sep">·</span>[Section]<span class="sep">·</span>[Date]
    </span>
    <span>${String(i+1).padStart(2,'0')} / ${String(slides.length).padStart(2,'0')}</span>
  `;
  inner.appendChild(footer);
});
```
