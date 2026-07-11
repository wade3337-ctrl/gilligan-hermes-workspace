---
title: GSTS 2026 Monthly Sales Goals (seasonalized revenue budget)
type: reference
domain: work
tags: [goals, budget, sales, seasonality, revenue, financials, v15-assistant]
links: ["[[gsts-financials-2026-summary]]", "[[v15-landing-assistant]]", "[[rc-02-revenue-performance]]"]
updated: 2026-07-11
---

# GSTS 2026 Monthly Sales Goals

The **seasonalized monthly revenue budget** = the real sales goals. Pulled from the exec deck's **`2026 Budget` sheet, row 9 "Total Income"** (sums exactly to the $24.0M annual plan). Source: `arbor-stack/exec-financials/January 2026 ...xlsx`; see [[gsts-financials-2026-summary]].

**These are the authoritative goals** and now live in a **single source of truth: `Workbench.dbo.SalesGoal`** (FiscalYear, MonthNum, Goal — survives the nightly refresh). BOTH the [[v15-landing-assistant]] (`AI-Chat.cfm` reads the table) and the **Revenue Performance dashboard** (seasonal `periodGoal`/pace now query the table) read from it, so they always agree. **Edit/import via `Dashboard-SalesGoals.cfm`** (linked from the dashboard header "Goals" button): edit 12 months or paste from the budget sheet → Save. **Next year = update the numbers there, no code change.** The table below is the seed; the live values are whatever's in the table.

> ⚠️ Minor follow-up: the dashboard's old inline "Monthly Goal" input still writes to `GoalSettings` but is now superseded by the table for pace — repurpose/remove it later.

| Month | 2026 Goal |
| --- | --- |
| January | $2,534,354 |
| February | $1,829,430 |
| March | $1,831,427 |
| April | $2,117,795 |
| May | $1,950,446 |
| June | $1,987,524 |
| July | $2,087,119 |
| August | $1,836,385 |
| September | $1,827,249 |
| October | $1,997,901 |
| November | $1,691,243 |
| December | $2,309,127 |
| **Annual** | **$24,000,000** |

- Segment plan (annual): HOA $11.0M · Municipal-Cities $8.5M · Commercial $3.0M · Municipal-Other $1.5M.
- **Maintenance:** when 2027 goals arrive, add a `GOALS2027` map (or move to a `Workbench.dbo.SalesGoal` table keyed by year+month that both the assistant and dashboard read).

## Related
- [[gsts-financials-2026-summary]] — the P&L trend + annual budget/break-even these come from.
- [[v15-landing-assistant]] — consumes these. · [[rc-02-revenue-performance]] — the dashboard (still flat-goal for now).
