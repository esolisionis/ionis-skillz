# Visual system reference

Detailed visual specifications for the Ionis brand. Load this file when assembling a visual spec, when answering a precise design question (hex codes, PMS values, exact ratios), or when the user asks an edge-case question.

## Color palette — full values

### Primary colors

| Name | Use | HEX | RGB | CMYK | PMS |
|---|---|---|---|---|---|
| Raspberry | Logo color, key brand color | `#A20067` | 162, 0, 103 | 18, 100, 6, 18 | 235C |
| Magenta | Subordinate primary partner | `#D70073` | 215, 0, 115 | 12, 100, 24, 0 | 226C |
| Orange/Yellow | Tertiary primary, warm accents | `#FFAF00` | 255, 175, 0 | 0, 35, 100, 0 | 124C |

**Designer note from the brand book:** Use these PMS values as listed; do not convert PMS C to Process unless production demands it.

### Secondary tints (backgrounds only, paired with a primary)

| Name | HEX | RGB | CMYK | PMS |
|---|---|---|---|---|
| Pink tint | `#FEE4FC` | 254, 228, 252 | 1, 12, 0, 0 | 7436C |
| Yellow tint | `#F5F08B` | 245, 240, 139 | 6, 0, 57, 0 | 601C |
| Green tint | `#BEE169` | 190, 225, 105 | 29, 0, 74, 0 | 374C |
| Cool Gray 1 | `#EBECEE` | 235, 236, 238 | 7, 4, 4, 0 | Cool Gray 1 |

### Secondary colors (typography, icons, rules, frames — accents only)

| Name | HEX | RGB | CMYK | PMS |
|---|---|---|---|---|
| Blue | `#71A6E7` | 113, 166, 231 | 53, 26, 0, 0 | 284C |
| Green | `#0EAA0E` | 14, 170, 14 | 81, 4, 100, 0 | 354C |
| Bright Yellow | `#EDF950` | 237, 249, 80 | 11, 0, 80, 0 | 101C |
| Cool Gray 11 | `#53565A` | 83, 86, 90 | 44, 34, 22, 77 | Cool Gray 11 |

### About black

Use Cool Gray 11 as the default body-text color in both print and screen. Solid black is acceptable only when logistical or production constraints prevent the gray. **Cool Gray 11 must never be placed over Raspberry or Magenta** — use solid black for that, not the gray.

### Color pairing rules (the don'ts)

- Don't place Raspberry over Magenta or Magenta over Raspberry.
- Don't place the secondary Blue, secondary Green, or Bright Yellow on top of either red.
- Don't let secondary colors become a slide's dominant color. Their job is detail and accent.
- Don't use secondary tints without a primary color also present somewhere on the surface.

### Color usage philosophy

Strong vibrant primaries reinforce passionate determination. The energy of the palette dramatizes Ionis's ambition. White is unlisted but essential — it's the foil that makes the bright colors read as confident and clean rather than busy. Cool Gray 1 functions as a softer white-equivalent for organizing content and data.

When using color in data visualization: pick one color for **consistency** across charts representing the same dimension, use a contrast color for **emphasis** to call out one element among many, use related colors for **association** to group variables, and use color temperature for **mood**.

## Typography — full details

### Gotham (default, when available)

Gotham strikes a balance between confidence and compassion. It's the first choice for customer-facing communications and the required choice for commercial vendors producing marketing and identity materials.

Available weights:
- Gotham Light / Light Italic
- Gotham Book / Book Italic
- Gotham Medium / Medium Italic
- Gotham Bold / Bold Italic
- Gotham Black

### Arial (PowerPoint default)

Use Arial whenever Gotham isn't available:
- Everyday business communications (MS Office should default to Arial)
- PowerPoint presentations
- Printed communications on Ionis preprinted letterhead
- Promotional items where production processes can't render Gotham

Available weights:
- Arial Regular / Regular Italic
- Arial Bold / Bold Italic

### Typography do's and don'ts

**Do:**
- Vary weight and size to create hierarchy: title > main head > subhead > body > caption.
- Use color on type sparingly — typically one primary-color accent per slide for the headline or a key subhead.

**Don't:**
- Stretch, condense, or skew the font. Use the proper italic weight, never a digital italic transformation.
- Set body text with excessive letter-spacing or so tight that characters touch.
- Use color combinations that confuse hierarchy (e.g., a subhead lighter than body, or a head in a barely-visible tint).
- Use yellow or pale tints for text on white — they fail accessibility and read as a mistake.

## The Prow — geometry

A rectangle with a **single** rounded corner. The rounded corner suggests forward motion. Use one rounded corner only; rounding two or more turns the Prow into a pill or capsule, which breaks the signature.

**Direction of the rounded corner:**
- For elements that read left-to-right (most content blocks), round the right-hand corner — the leading edge of motion.
- For ascending stat callouts, round the top-right.
- For descending or anchoring blocks, round the bottom-right.

**Typical Prow applications:**
- Stat callout containers (large number + label).
- Section header bars in 3-column layouts.
- Title-slide background accent.
- Pipeline row containers.

## The Logo Wing — usage detail

### Standalone forms

| Form | Use case |
|---|---|
| 4-color Wing (Raspberry → Magenta → Orange gradient) | Bold graphic device over photography |
| Black / grayscale Wing | Single-color print, black-only output |
| Solid white reversed out of dark | On dark backgrounds |
| Solid Raspberry PMS 235C | One-color brand application |
| Solid Cool Gray 1 | Watermark behind content |
| Solid black or Solid PMS 235C | Promotional items only |

### Watermark cropping

When the Wing is used as a large watermark, the brand book specifies an **alternative cropping** — the wing extends past the page edge rather than being shown in full. This makes the watermark feel like part of the surface rather than a placed graphic.

### Wing as bold graphic device over photography

When laid over photography, set the wing to **Multiply** blend mode (in design tools) so it integrates with the photo's tones rather than sitting flat on top. This is the treatment used in the brand book's "powerful graphic device over photography" examples.

### What not to do with the Wing

- Don't lock up the Wing with the logo on the same surface unless they're visually separated (e.g., front and back of an object).
- Don't tilt or rotate it.
- Don't use a color outside the approved variants.
- Don't apply effects (shadows, glows, bevels).

## Logo — full usage

### Approved variants

- **4-color logo** — preferred, on white or light backgrounds.
- **Grayscale logo** — when black is the only available color, on a white background. The Wing contains gray gradients in this version.
- **Reversed out (KO) with 4-color wing** — on dark backgrounds with sufficient contrast for the wing detail.
- **Reversed out solid white** — on dark backgrounds.
- **Solid black or solid Raspberry PMS 235C** — promotional items only.

### Clear space

Always allow a clear space around the logo equal to **half the height of the letter "I"** on all sides. No other content should encroach on this margin.

### 3-D fabrication

When the logo is fabricated as a 3-D object (signage, awards, etc.), use Raspberry PMS 235C on the sides of the wing.

### Required mark

Always include the ® symbol with the logo.

### Don'ts

- Don't lock up the logo with words ("Ionis Pharmaceuticals", "A Genetic Company", department names — except a simple department name in Gotham on promotional items where appropriate).
- Don't rotate.
- Don't apply transparency.
- Don't apply drop shadows, glows, or other effects.

## Photography — direction detail

### Black-and-white vs. color decision

| Subject | Treatment |
|---|---|
| Campaign imagery — broad emotional benefit | Black and white |
| Specific named patient / patient ambassador / case study | Full color |
| Portrait of Ionis staff, guest speaker, or KOL | Full color |
| Scientist, lab worker, or science-themed imagery | Full color |

The rationale: black-and-white prevents the brand from becoming monochromatic across the visual system and gives campaign work an emotional, timeless quality. Color reserves prominence for real people and real science.

### Composition principles

- **Get close.** Subjects should feel like they "can barely be contained by the frame." This shifts the energy from documentary to engaged.
- **Simple or white backgrounds.** They highlight the subject's shape and mass. Make those shapes interesting and dimensional.
- **Strong contrasting light.** Drama from light/shadow contrast, not from saturated backgrounds.
- **Empowered, engaged subjects.** The brand is about the potential of everyone — never passive, posed, or stock-feeling.
- **Busy backgrounds are fine if the subject is dynamic.** The strong foreground/background contrast makes the subject feel like they're reaching out to the viewer.

## Communication-piece patterns from the brand book

These are reference patterns from the brand book itself, useful as direct models.

### Corporate Fact Sheet template

- Wing watermark in light Cool Gray 1 behind content.
- Headline in dark gray (Cool Gray 11).
- Two-column body with prose left, structured callouts right.
- Prow-shaped icon boxes for CSR pillars (innovate / empower / operate).
- Bottom-of-page copyright and update date.

### Investor / value-prop slide

- Bold title left ("Next-Level Value for Patients & All Stakeholders").
- Three Prow-shaped column blocks across the body, each in a different primary color (Yellow/Orange, Magenta, Raspberry).
- Each block: short headline + photo or icon at the bottom.

### Data-callout row

- Four Prow-shaped vertical blocks across the slide.
- Each block: large stat (49%, $221m, 18, 289%) in white on color.
- Block colors: secondary tints transitioning to primary Raspberry (lightest → darkest left to right is one pattern; full primary is another).
- Tiny "lorem ipsum"-style caption above and below the stat.

### Statistic + photograph layout

- Left half: tinted Prow block with one or two large stats (24, 80) and short captions.
- Right half: full-color photograph of patient or person with a tool of their craft (e.g., person with horse).
- Logo bottom-right.

### Three-column pillar / how-we-work slide

- Header bar with title.
- Three columns, each with: a small icon, a one-line headline, body copy.
- Subtle Raspberry rule between columns.
- Wing watermark behind the whole slide in Cool Gray 1.

## Promotional / merch — soft and hard goods

These rarely come up in slide work, but if a deck includes mockups of giveaways or branded merchandise, the rules differ:

- **Hard goods** (mugs, bottles, pens, USB drives): Ionis logo generally used. Solid white, solid black, or solid Raspberry PMS 235C are the safe one-color options.
- **Soft goods** (apparel, umbrellas, visors): Logo and Wing may both appear, but on separate surfaces of the item (e.g., front and back of a hat). Embroidery needs to render the wing detail correctly — if the embroidery area is too small, fall back to the logo alone.

## Quick visual-decision flow when drafting a slide

1. Is there a Raspberry or Magenta element visible on the slide? If no, add one.
2. Did I default to Arial type? (PPT yes, unless Gotham is confirmed available.)
3. Did I specify B&W vs. color for any photography per the subject rules?
4. Are any rectangles meant to be Prows? If so, did I specify one rounded corner with the right direction?
5. Is the Wing being used? If so, watermark (light Cool Gray 1, allow the alt-crop at large scale) or graphic device (full color, Multiply over photo)?
6. Did I avoid any pairing don'ts (Raspberry over Magenta, secondary blue/green/yellow over red, Cool Gray 11 over red)?
7. Is the logo treated correctly for its background (4-color on white, reversed on dark)?

If all seven check out, the visual spec is on-brand.
