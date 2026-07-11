---
title: Brent's forecast $178K carry-over is an Excel true-up plug
type: fact
domain: work
tags: [brent, city-budgets, forecasting, newport, data-provenance, excel, gotcha]
links: ["[[city-forecasting]]", "[[rc-03-city-budgets]]", "[[budget-report-municipal]]"]
updated: 2026-07-10
---

# Brent's forecast $178K carry-over is an Excel true-up plug

**The fact:** the "overage / carry-over" lines in Contract-Admin Brent Beller's manual **City Forecasting** workbook (e.g. Newport's **$178,347.51 "FY 2024/2025 June Overages"**) are **spreadsheet true-up plugs — hand-typed values, NOT transactions.** They exist in **neither TRIM IT nor QuickBooks.** Do **not** try to reproduce them from source data — there is no source; they were manual balancing entries.

## The arithmetic (it's a plug)
The plug = **annual budget − a hand-entered short 12-month base**:

```
Newport 25/26 budget (B145)         =  2,030,649.30   (matches the TRIM IT 25/26 slice)
Brent's hand-entered "invoiced"     =  1,852,301.79   (typed; does NOT tie to TRIM IT)
------------------------------------------------------
"June Overages" plug                =    178,347.51   (2,030,649.30 − 1,852,301.79)
```

The $178,347.51 lives in cell `DH146` as a **literal number, no formula**; `Remaining` (`EGx45 − (Inv+Callins+Sched+Placeholder)`) then references it. His invoiced figure is hand-pasted and doesn't match TRIM IT (masters = **$1,999,929.91** for the same city/FY).

## What we confirmed it is NOT
- **Not in TRIM IT:** no $178,347.51 anywhere in Newport; LegacyRef 121827 = a June 2023 master ($131,140.10), a different thing. 0 rows any company/status.
- **Not the TRIM-IT-computed 24/25 overage** either ($2,073,774.55 invoiced − $1,971,504.17 slice = $102,270.38 — a different number).
- **Not QuickBooks** (Skipper confirmed). It's a manual Excel entry, full stop.

## Consequence for the build
You **cannot and should not** penny-match Brent's manual numbers — they're hand inputs, not source-derived. His **logic** (budget spread ÷12 → invoiced → callins → scheduled → remaining → projected) IS reproducible live from TRIM IT and is **more accurate** than his hand-entry. That is exactly what the [[city-forecasting]] tab does: it spreads the **true annual budget ÷ 12** (not Brent's short `$B146/12` base), which makes the fake "overage" plug disappear.

Cross-links: [[city-forecasting]] (the live replacement) · [[rc-03-city-budgets]] (the dashboard) · [[budget-report-municipal]] (the reconciliation analysis).
