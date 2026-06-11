# ionis-brand-slides (skill bundle)

A Claude Code skill that produces brand-compliant Ionis slide work — either by building a single-file HTML deck or by reviewing / rewriting PowerPoint slide copy. The model loads `SKILL.md` when its description matches the user's request and pulls in supporting files (references, assets, examples) on demand.

## What's in this bundle

```
ionis-brand-slides/
├── SKILL.md                           ← the skill itself (always loaded first)
├── README.md                          ← this file
│
├── assets/
│   ├── colors.json                    ← machine-readable brand color tokens
│   ├── template-wing.png              ← canonical wing watermark from PPT template
│   ├── wing-watermark-gray.svg        ← SVG fallback (PNG preferred)
│   ├── template.pptx                  ← official 2024 Ionis PowerPoint template
│   └── logos/                         ← all 9 approved SVG logo variants
│       ├── Ionis_Logo_HEX.svg                 ← 4-color (print)
│       ├── Ionis_Logo_web_HEX.svg             ← 4-color (web — default)
│       ├── Ionis_Logo_Grayscale.svg           ← grayscale (print)
│       ├── Ionis_Logo_web_Grayscale.svg       ← grayscale (web)
│       ├── Ionis_Logo_KO_RGB.svg              ← KO white (print)
│       ├── Ionis_Logo_KO_Wing_RGB.svg         ← KO with 4-color wing
│       ├── Ionis_Logo_web_WHT.svg             ← KO white (web)
│       ├── Ionis_Logo_Wing_RGB.svg            ← wing only (4-color RGB)
│       └── Ionis_Logo_Wing_CMYK.svg           ← wing only (CMYK print)
│
├── references/
│   ├── visual_system.md               ← full visual ref: colors, type, Prow, Wing, photography
│   ├── footer_spec.md                 ← footer pattern + safe-area rule
│   ├── voice_examples.md              ← paired off-brand vs. on-brand sentences
│   ├── pipeline_language.md           ← medicines/investigational compliance guardrail
│   ├── css_tokens.css                 ← drop-in CSS variables for HTML decks
│   └── html_deck_starter.html         ← minimal HTML deck skeleton, fully wired
│
├── examples/                          ← worked specs and a complete deck
│   ├── deck.html                      ← 14-slide internal talk using every layout (A–P)
│   ├── layout_A_cover.md
│   ├── layout_J_compare.md
│   └── layout_K_numbered_steps.md
│
└── scripts/
    ├── inline_assets.py               ← REQUIRED final step: bundle all assets as base64 into deck.html
    └── screenshot_deck.ps1            ← headless-Chrome screenshot helper
```

## What this skill enforces

- **The Four Hard Rules:** scope (no bonus slides), solid colors only (no gradients), Prow rounded bottom-right only, wing watermark recipe matches the PPT template exactly.
- **16-layout library (A–P):** every content slide picks from a named layout. No PowerPoint-default title + bullets.
- **Color hierarchy:** Raspberry or Magenta visibly featured on every slide beyond the logo. Secondary colors never dominant. Solid colors only.
- **Typography:** Gotham when available, Arial otherwise. HTML font stack Arial-first so HTML matches PPT.
- **Voice:** Driven, Inquisitive, Pioneering, Confident, Passionate — all five at once. Specific over abstract. Biotech-trope words cut.
- **Medicines language:** "investigational" before every pre-approval medicine name, "medicine" not "drug," ® on marketed brands.
- **Wing watermark:** exact PPT template recipe (left:0, top:0, 17.3% width, 100% height, alt-cropped, Cool Gray 1, opacity 1.0).
- **Logo:** approved variants only, real SVG in the footer (not typed text), ® on full lockup, never recolored / rotated / shadowed.
- **Footer + safe area:** every content slide. Bottom 12% reserved as no-content zone. Title and closing slides skip the footer.
- **Assets inlined:** every HTML deck ships as a single file with all images and CSS base64-encoded. The single most common failure mode is the deck losing logos when emailed without its asset folder; inlining prevents it.

## How the skill is invoked

The model loads this skill automatically when the user's request matches its `description` — any mention of Ionis slides, decks, presentations, brand compliance, "is this on-brand?", "make this sound more Ionis," etc.

Two modes:

1. **Build a deck.** User asks "make me a deck about X." The model uses the layout library + starter HTML to produce a single `deck.html`, then inlines assets with `scripts/inline_assets.py`.
2. **Review or rewrite copy.** User pastes PowerPoint text and asks for an on-brand pass. The model returns revised copy with voice notes, layout recommendation, and (when medicines are referenced) a `## Compliance notes` section.

## Brand contact

For brand questions outside this skill's scope, route to **corporatebrand@ionis.com** and the Ionis Corporate Brand Portal. For materials with high external visibility (investor day, major congress, press releases, patient-facing), recommend routing through Corporate Affairs before finalizing.

## Quick start (HTML deck)

1. Copy `references/html_deck_starter.html` to a working file (or open `examples/deck.html` as a more complete reference).
2. Edit slide content. Each `<section class="slide">` picks one layout from A–P.
3. Apply the voice rules (`references/voice_examples.md`) on every headline and body region.
4. Run the self-review checklist in SKILL.md.
5. Inline assets: `python scripts/inline_assets.py deck.html`.
6. Open `deck.html` in Chrome / Edge / Safari. Present full-screen with arrow keys / space / click.

## Quick start (PPT copy review)

1. Paste the slide copy into a message addressed to Claude with a request like "make this on-brand" or "review this for the Ionis brand."
2. The model maps each slide to a Layout, runs the voice pass, runs the medicines pass (if applicable), and returns revised copy with rationale.
3. If medicines are referenced, the response includes a `## Compliance notes` checklist.

## Versioning

Brand book version: 2025. Color values, PMS codes, and layout patterns reflect the current brand book. If the brand book updates, refresh `references/visual_system.md`, `assets/colors.json`, and any layout examples that reference superseded patterns.
