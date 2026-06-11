---
name: ux-audit
description: Run a systematic UX audit of an app, dashboard, prototype, or UI code — heuristic walkthroughs (Nielsen's 10), cognitive walkthroughs of task flows, keyboard/accessibility passes, and code-level interface lints. Use whenever the user asks to "audit", "review", "critique", or "walk through" a UI; asks "what's wrong with this interface"; mentions error states, loading states, empty states, keyboard navigation, focus management, undo, or accessibility; pastes UI code or shares an HTML artifact and asks if it's good; or is polishing an app and wants it to feel professional. Also use proactively before a demo or readout when the user asks "is this ready to show". Do not use for visual brand compliance (use ionis-brand-slides) or for generating new designs (use ionis-app-system / frontend-design).
---

# UX Audit

Run disciplined, evidence-based usability evaluations. The value of this skill is *systematic coverage* — an expert walkthrough finds the problems a casual look misses, because it checks every category every time instead of reacting to what happens to stand out.

## Choose the audit mode

Pick based on what the user has and what they're worried about. Combine modes for a full audit; a single mode is fine for a focused question. State which mode(s) you're running at the top of the report.

| Mode | When | Reference to load |
|---|---|---|
| **Heuristic evaluation** | General "what's wrong with this UI" — screenshots, descriptions, live apps. The default mode. | `references/nielsen-heuristics.md` |
| **Cognitive walkthrough** | Evaluating specific *task flows* (onboarding, checkout, data export) step-by-step from a new user's perspective. Best for "will users figure this out?" | `references/cognitive-walkthrough.md` |
| **Keyboard & accessibility pass** | Keyboard nav, focus order, screen reader support, contrast, WCAG conformance. | `references/wcag-accessibility.md` |
| **Code-level lint** | The user shares actual UI source (HTML/JSX/CSS). Checks ~100 concrete rules: focus-visible, hit targets, form behavior, animation, hydration, empty-string handling. Output in terse `file:line` format. | `references/code-level-rules.md` |
| **Visual design review** | Typography, color, spacing, hierarchy, layout critique — "does this look professionally designed?" Complements heuristics (usability) with visual craft. | `references/ui-design-review.md` |
| **Don Norman principles** | Interaction-design fundamentals: affordances, signifiers, mapping, feedback, conceptual models. Best for "why is this confusing?" questions about physical-feeling interactions. | `references/don-norman.md` |
| **Holistic 7-factor audit** | Big-picture product evaluation via the IDF framework (Useful, Usable, Findable, Credible, Desirable, Accessible, Valuable). For strategic reviews, not screen-level polish. | `references/ux-audit-rethink.md` |

Load only the reference(s) for the mode(s) you're running.

## The five killers — always check these regardless of mode

These are the highest-frequency, highest-impact failures in internal tools and dashboards. Even in a narrow audit, scan for all five:

1. **Missing loading states.** Any async action (query, fetch, save) with no visible feedback. Includes: spinners that appear instantly and flicker (<150ms operations should show nothing or delay the spinner), progress with no indication for long operations, buttons that don't disable/show pending during submission.
2. **Missing or dead-end error states.** Errors that are silent, jargon-coded ("Error 500"), blame the user, or offer no recovery path. Every error message needs: what happened, why (if knowable), what to do next.
3. **Missing empty states.** First-run screens, zero-result filters, and empty tables that render as blank voids or broken layouts. A good empty state says what would be here and how to get it there.
4. **Keyboard traps and invisible focus.** Interactive elements unreachable by Tab, focus order that jumps around, `outline: none` with no replacement, modals that don't trap and restore focus.
5. **Missing undo affordances.** Destructive or hard-to-reverse actions with no undo, no confirmation calibrated to severity (confirmation for rare destructive actions; undo for frequent ones — undo is better than confirmation because it doesn't tax every action), no way to back out of multi-step flows without losing work.

## Severity scale

Rate every finding. Use Nielsen's 0–4 scale:

- **4 — Usability catastrophe.** Blocks task completion or causes data loss. Fix before release.
- **3 — Major.** Significant friction; users will struggle or err frequently. High priority.
- **2 — Minor.** Noticeable friction; users recover easily. Fix when convenient.
- **1 — Cosmetic.** Polish issue. Fix if time allows.
- **0 — Not a problem** / disagreement with a convention, noted for discussion.

Severity = frequency × impact × persistence (does it keep hurting, or only the first time?).

## Report structure

ALWAYS use this template (adapt section presence to modes run):

```
# UX Audit — [interface name]
**Modes run:** [...] · **Scope:** [pages/flows/files covered] · **Date:** [date]

## Summary
[2–4 sentences: overall assessment, count of findings by severity, the single most important fix.]

## Findings
[Grouped by severity, descending. Each finding:]
### [S4] Finding title
- **Where:** [screen/flow/file:line]
- **Heuristic/rule:** [e.g., H1 Visibility of system status / WCAG 2.4.7 / focus-states]
- **Problem:** [what's wrong and why it matters — evidence, not opinion]
- **Fix:** [concrete recommendation; code sketch if code-level]

## What's working
[2–5 genuine strengths — calibrates the critique and tells the user what not to break.]

## Prioritized fix list
[Ordered: catastrophes first, then quick wins among majors.]
```

For code-level lints, replace Findings with the terse `file:line` format specified in `references/code-level-rules.md`.

## Conduct rules

- **Evidence over taste.** Every finding cites a heuristic, WCAG criterion, or concrete rule. "I don't like this" is not a finding; "violates H4 consistency because the same action is labeled three different ways" is.
- **Walk, don't glance.** For heuristic evaluations, go heuristic-by-heuristic through all 10. For walkthroughs, go step-by-step through the task. Coverage is the whole point.
- **Don't pad.** If a category is clean, say so in one line. Ten real findings beat thirty manufactured ones.
- **Calibrate to context.** An internal dashboard for five power users has different bars than a patient-facing tool. Ask about the audience if it isn't obvious — severity ratings depend on it.
- **If you can't see it, say so.** When auditing from a description or static screenshot, mark dynamic concerns (focus order, loading behavior, animations) as "needs live verification" rather than guessing.
- **Pair with the design system.** If the project uses the `ionis-app-system` skill, check findings against its tokens and component specs — inconsistency with the declared system is itself a finding (H4).
