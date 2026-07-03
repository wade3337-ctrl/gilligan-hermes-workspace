---
title: GSTS UI Style Guide
type: reference
domain: work
tags: [ui, style, standard, dashboard, applies-target]
links: ["[[gsts-ui-spec]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-02
---

# GSTS UI Style Guide

**What it is:** The normative UI/brand rules for every GSTS dashboard/page — welcome modal with colored-emoji on the
front page, pro-tip "?" popups (no permanent technical text on the page), CSS tokens, system fonts, 44px mobile taps,
no third-party UI libraries, and the **emoji/non-ASCII `.cfm` → UTF-8 BOM** rule (else ColdFusion serves mojibake).
**📁 Source:** `reference/GSTS-UI-STYLE-GUIDE.md` + `arbor-stack/gsts-ui-spec-v1.0.md` ([[gsts-ui-spec]]) + `reference/gsts-theme.css`

**Used by (must follow):** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]],
[[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]], [[pricing-guide-bid-prefill]],
[[sales-cockpit]], [[v15-landing-page]] — **any UI work.**

## Why this note exists
A UI got built without this guide applied because the guide was an *orphan* — it existed but nothing linked it. Now it's
an explicit `applies:` target on every UI project. **Rule:** on UI work, open the project note first → this guide is one hop away.

## Key rules (quick)
- Welcome modal (colored-emoji) on every dashboard front page.
- "How it's calculated" goes in the "?" pro-tip popup, **never** as permanent on-page text.
- `.cfm` containing emoji/non-ASCII **must** have a UTF-8 BOM (re-add after `ssh type` strips it, before deploy).
- Phone-friendly: short lines, no aligned columns / deep indents, key number first.
