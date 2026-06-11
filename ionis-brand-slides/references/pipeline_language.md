# Medicines & pipeline language reference

Load this file whenever a deck references medicines, pipeline programs, indications, or clinical trial information. These are not style preferences — they are compliance guardrails. Failing them creates regulatory exposure.

For internal-only, operational, or tooling decks with zero medicine references (AI Data Club, IT enablement, town halls, hackathon presentations), this file does not apply. Omit the `## Compliance notes` section from the output entirely.

## The required words

| Use | Don't use |
|---|---|
| medicine | drug, compound, asset, product |
| investigational medicine | candidate, pipeline drug, experimental drug |
| marketed medicine | approved drug, commercial drug |
| treats / is used for | cures, fixes, heals (unless approved labeling supports it) |
| indication | "disease space," "therapeutic area" (acceptable in business contexts; never in patient-facing) |
| clinical trial | "study" (acceptable as shorthand once trial has been named) |

## The "investigational" rule

For every pre-approval medicine — anything in Phase 1, Phase 2, Phase 3, or filed but not yet approved — **the word "investigational" appears every time the medicine is named.** Not just first reference. Every time.

✅ "Our investigational medicine [name] hit primary endpoint in Phase 2. Phase 3 of [name], the investigational medicine, starts next quarter."

❌ "Our pipeline drug [name] hit endpoint. [name] starts Phase 3 next quarter."

For marketed medicines, include the brand name with **®** on first reference per indication, then the generic name on subsequent references.

## When to flag for review

These cases require routing through Corporate Affairs / **corporatebrand@ionis.com** before the deck ships:

- **Ex-US audience.** EMA, PMDA, regional congress, ex-US investor meeting. Even if the science is the same, the language requirements differ.
- **External visibility.** Investor day, major congress, press release embeds, IR backup, patient-facing materials, advocacy group meetings.
- **Off-label / on-label boundary.** If the deck describes use of an approved medicine outside its label, the regulatory team must review.
- **Comparison to competitor medicines.** Comparative claims require substantiation and legal review.
- **Patient stories.** Any named patient or patient ambassador requires their written consent on file with Corporate Affairs.

For routine internal R&D updates with no external visibility, no off-label claims, and no patient PII, the deck author can self-review against this file.

## The status taxonomy for pipeline rows (Layout G)

When using Layout G (Pipeline / data table), each row's color signals status:

| Status | Row color | Required language |
|---|---|---|
| Marketed (approved, on-label use) | Solid Raspberry or Magenta | Brand name® on first reference, generic name after |
| Investigational, Phase 3 | Solid Orange | "Investigational [name]" |
| Investigational, Phase 2 | Pink tint background, Magenta accent | "Investigational [name]" |
| Investigational, Phase 1 | Yellow tint background, Orange accent | "Investigational [name]" |
| Preclinical | Cool Gray 1 background, Raspberry accent | "Investigational [name]" or "discovery program" |

Never list a preclinical or Phase 1 program with the same visual weight as a marketed medicine. The color hierarchy carries the regulatory weight.

## Common rewrite patterns

### ❌ "We're excited to share that our drug X showed promising results."

✅ "Investigational medicine X met its primary endpoint."

Why: kills "excited" (banned voice trope), replaces "drug" with "medicine," replaces "promising results" (regulatory hedge that means nothing) with the actual claim, adds "investigational."

### ❌ "X is the future of [disease] treatment."

✅ "X, our investigational medicine for [disease], enters Phase 3 in [quarter]."

Why: forward-looking promotional claims about pre-approval medicines are a regulatory issue. Replace with factual milestones.

### ❌ "Patients on X experienced significant improvement."

✅ "In the [trial name] Phase 2 trial, patients receiving investigational medicine X showed [specific endpoint reading, e.g., 'a 47% reduction in [biomarker]']."

Why: "significant improvement" without the endpoint and the trial is a hand-wave that fails on both voice (specifics) and compliance (substantiated claims).

### ❌ "X works by targeting RNA."

✅ "Investigational medicine X uses antisense technology to reduce production of the [target] protein."

Why: "works by" is acceptable in casual contexts, but for medicine descriptions in any external-bound deck, name the mechanism precisely.

## The Compliance notes section template

When the deck references medicines, append a section like this after the slide content:

```markdown
## Compliance notes

- Slide [N]: Confirm investigational status of [medicine name] — included "investigational" per pre-approval status. Verify before ship if approval has occurred.
- Slide [N]: Indication wording "[exact text]" — verify against current approved labeling or trial protocol.
- Slide [N]: [Trial name] cited — confirm patient consent on file if patient quote or imagery is used.
- Ex-US audience flag: [yes/no]. If yes, route through regional team before ship.
- External visibility flag: [internal R&D / investor / patient / press]. If anything other than internal, route through corporatebrand@ionis.com.
```

Keep it tight — bullet points, no padding. Its job is to give the reviewer a checklist, not a narrative.

## When in doubt

Ask the user. The question "is this medicine approved or investigational?" is cheaper than the alternative. Never guess at regulatory status.
