---
title: GSTS UI Spec (v1.2)
type: reference
domain: how-we-work
tags: [ui, spec, brand, protip, welcome-modal, applies-target]
links: ["[[gsts-ui-style-guide]]", "[[dashboard-metric-standards]]", "[[repair-contract]]"]
updated: 2026-07-03
---

# GSTS UI Spec (v1.2)

**What it is:** The canonical, detailed UI spec for the GSTS ColdFusion app — brand tokens, typography/spacing, Pro Tip help-popup pattern, the required Welcome modal, KPI drill-down, and CSV export. The full-detail companion to the quick [[gsts-ui-style-guide]]; attach this file whenever asking an LLM to build/update GSTS UI.
**📁 Source:** `arbor-stack/gsts-ui-spec-v1.0.md` (currently v1.2)

**Used by (must follow):** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]], [[sales-cockpit]], [[pricing-guide-bid-prefill]], [[v15-landing-page]] — **any UI work.**

## Key rules
- **Learn-once consistency (§0):** every page behaves identically; add/change an interaction on ALL applicable pages in the same motion. New pages inherit every established pattern.
- **Hard rules:** never remove/rename existing IDs, classes, form names, query columns, or handlers; no new third-party libraries (vanilla JS/CSS only); all new code additive; mobile-first from ~360px.
- **Brand tokens (§1):** define colors once in `:root` as CSS custom properties (`--gsts-green-800` header bars, `--gsts-green-700` primary/active) — never hard-code hex. System font stack, no web fonts. 4px spacing base; cards radius 8px, buttons/badges 6px. KPI badges good/watch/poor = green-200/yellow-200/red-200. Contrast ≥4.5:1, visible focus rings.
- **Pro Tip popups (§2):** at-a-glance help, NO permanent helper text. Desktop hover ~0.7s (+ passive ⓘ cue); touch "?" badge; keyboard `?`/F1/Esc. Every helpable element gets `data-protip-key` (dot.case, category prefix per §2.6); copy lives in `protips.content.json`. Shared assets (`protips.{css,js,content.json}`) via one `cfinclude`. Tone plain/executive, 1–3 sentences.
- **Welcome modal (§2A — REQUIRED on every dashboard):** on the front page / parent frame of a dashboard SET (one per set). Auto-shows first visit; "Don't show again" via `localStorage` (`gsts<App>WelcomeDismissed`); persistent header **ⓘ Welcome** reopen button. Title + each section bullet LED BY A COLORED EMOJI (required look); emoji as HTML numeric entities (BOM-safe). Help line says **hover** (no "?" badge on desktop).
- **KPI drill-down (§2B):** countable/summable tiles are clickable → modal drill listing underlying records (totals foot back to the box), each row links to its TrimIT source in a new tab. One shared `…$Drill.cfm` engine keyed by `metric=`.
- **CSV export (§CSV):** every data page gets a top "⬇ Export CSV" button → re-submits same page with `exportCSV=1` + current filters; use `csv-export-include.cfm` (`csvField()`). Reference impl: `Dashboard-RevenuePerformance.cfm`.
- **Safety:** backup to `/jasonsrepairs/` before edits; run the §3 QA checklist. Reference the spec version built against.
