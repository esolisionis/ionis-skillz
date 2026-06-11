# Databricks Apps adapter

How to apply the Ionis App System inside Databricks Apps, by framework. The token *values* are universal; the *mechanism* depends on how much DOM control the framework gives you.

## Framework decision

| Framework | Fidelity | How |
|---|---|---|
| FastAPI/Flask + custom HTML or React | Full | Paste `tokens.css`, follow `components.md` literally. Use `react-best-practices` skill for the React template. |
| Dash | Full | Put `tokens.css` in `assets/` (Dash auto-loads it); style components with classNames referencing tokens. |
| Streamlit | Partial — theme config + CSS injection | This file, below. |
| Gradio | Partial | Use a `gr.themes.Base()` subclass with the values below; CSS injection via `css=` parameter for the rest. |

When a stakeholder-facing app needs full design fidelity (the demo deck, the readout dashboard), prefer Dash or the React template. Streamlit is right for fast internal tools; accept its rendering opinions there rather than fighting them.

## Streamlit: config.toml theme

Create `.streamlit/config.toml` in the app root. This is the supported theming path — it themes Streamlit's own widgets correctly, including states you can't reach with CSS.

```toml
[theme]
base = "light"
primaryColor = "#A20067"              # Raspberry — accents, focus, sliders, checkboxes
backgroundColor = "#F7F8F9"           # --bg-app (gray-25)
secondaryBackgroundColor = "#EBECEE"  # --bg-sunken (Cool Gray 1) — sidebar, inputs
textColor = "#53565A"                 # --text-primary (Cool Gray 11)
font = "sans serif"
```

Recent Streamlit versions accept extended keys — set them if the runtime supports them (harmless if ignored):

```toml
baseRadius = "6px"                    # --radius-md
borderColor = "#DDDFE2"               # --border-default (gray-100)
showWidgetBorder = true
```

Dark variant: `base = "dark"`, `backgroundColor = "#121316"`, `secondaryBackgroundColor = "#1A1B1F"`, `textColor = "#C6C9CD"`, `primaryColor = "#FF4FA3"` (the dark-theme accent — raw Raspberry is too dark against dark surfaces).

## Streamlit: CSS injection for the rest

For what config.toml can't express, inject once at the top of the app:

```python
import streamlit as st

st.markdown("""
<style>
:root {
  --raspberry:#A20067; --raspberry-tint:#FBEAF4; --magenta:#D70073;
  --gray-600:#53565A; --gray-100:#DDDFE2; --gray-50:#EBECEE;
  --success:#0B7A0B; --success-tint:#E9F6E9;
  --warning:#9A6700; --warning-tint:#FFF4D6;
  --danger:#C42B1C;  --danger-tint:#FBEAE8;
  --info:#2E6BBF;    --info-tint:#EAF1FB;
}
/* KPI metrics: strong numbers, tabular figures */
[data-testid="stMetricValue"] {
  font-variant-numeric: tabular-nums; font-weight: 600; color: #1A1B1D;
}
[data-testid="stMetricLabel"] {
  text-transform: uppercase; letter-spacing: 0.06em; font-size: 12px; color: #6E7278;
}
/* Primary buttons already themed via primaryColor; fix hover depth */
.stButton button[kind="primary"]:hover { background-color: #8A0058; border-color: #8A0058; }
/* Headings */
h1, h2, h3 { color: #1A1B1D; line-height: 1.25; }
</style>
""", unsafe_allow_html=True)
```

Rules for injection: keep it to ONE block, comment what each selector themes, and treat `data-testid` selectors as fragile — they can break on Streamlit upgrades, so never put load-bearing functionality there, only polish. Don't fight Streamlit's layout system with CSS; use `st.columns` spacing as-is.

## Streamlit: component spec translation

The three-absence rule and the system's intent still apply — they just route through Streamlit idioms instead of hand-built components:

| System spec | Streamlit idiom |
|---|---|
| Loading states | `with st.spinner("Loading claims data…"):` around every query; `st.cache_data` so reruns don't re-trigger; `st.progress` for long operations |
| Empty states | Explicit branch: `if df.empty: st.info("No patients match these filters. Try widening the date range.")` — with a clear-filters button. Never render an empty `st.dataframe` |
| Error states | `try/except` around data access → `st.error("Couldn't reach the warehouse: …")` + `st.button("Retry")`. Never let a stack trace be the error UI |
| Data tables | `st.dataframe` with `column_config`: `NumberColumn(format=...)` for right-ish numeric display, `ProgressColumn` for rates, explicit `width`/`hide_index=True`. Accept its row styling; don't CSS-hack table internals |
| Status badges | `column_config.TextColumn` + emoji/text prefix, or `st.markdown` pills using the semantic tint/ink pairs above — never color alone |
| KPI cards | `st.metric` (styled via the injection block), `delta=` for change indicators |
| One primary action | Exactly one `type="primary"` button per view; everything else `secondary` |
| Undo affordances | Confirmation gate (`st.dialog` or a two-step button) for destructive writes; Streamlit has no toast-undo, so prefer confirm + an explicit revert path |

## Databricks Apps specifics

- The app runs behind Databricks auth; don't build your own login UI.
- Long warehouse queries are the main loading-state risk: always `st.cache_data(ttl=...)` query functions and show spinners with operation-specific text ("Querying claims_gold…"), not generic "Loading…".
- Put `.streamlit/config.toml` in the repo with `app.py` so the theme deploys with the app — it's part of the system, not local preference.
