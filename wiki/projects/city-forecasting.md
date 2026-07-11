---
title: City Forecasting (live forecast tab)
type: project
domain: work
track: 1
status: shipped
tags: [dashboard, municipal, city-budgets, forecasting, brent, shared-engine, release-candidate]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-style-guide]]", "[[csv-export-standard]]"]
links: ["[[rc-03-city-budgets]]", "[[budget-report-municipal]]", "[[shared-engine-kills-dashboard-drift]]", "[[brent-forecast-178k-artifact]]", "[[our-work-kanban]]"]
updated: 2026-07-10
---

# City Forecasting (live forecast tab)

**One-liner:** Replaced Contract-Admin Brent Beller's **manual Excel "City Forecasting" workbook** with a LIVE, TRIM-IT-driven **Forecasting tab** on the City Budgets dashboard — per-city monthly grid (Budgeted ÷12 spread / Invoiced / Callins / Scheduled / Remaining / Projected) + a **Scheduled Ahead** column + an all-cities summary with a **GRAND-TOTAL** row + CSV. Built on a shared FY engine consumed by three dashboards so they can't drift.
**Status:** 🟢 live on play, **prod-pending** (would join a deploy package to Jordan/Travis when the Skipper says go). Ship-log **#118**; [[our-work-kanban]] card **47** (trimit/rc lane). Spec marked COMPLETE.
**📁 Location:** `arbor-stack/production-dashboard/` — `Dashboard-CityBudgets.cfm` (new `ZTab=forecast`), `CityBudgetsForecast.data.cfm` (NEW), `citybudget-fy-helpers.cfm` (NEW shared engine), `CityBudgets.data.cfm`, `ProductionPerf.data.cfm`, `Dashboard-ProductionPerf.cfm`.
**▶️ Resume:** `arbor-stack/city-budgets-review/FORECASTING-BUILD-SPEC.md` (approved spec + ✅ COMPLETE status).

## URLs
- Per-city forecast: `Dashboard-CityBudgets.cfm?ZTab=forecast` (default budgets view UNCHANGED).
- All-cities summary + grand total: `Dashboard-CityBudgets.cfm?ZProjectID=all&ZTab=forecast`.
- CSV: `&exportForecastCSV=1` (per-city) / `&exportForecastAllCSV=1` (all-cities) — requires `ZTab=forecast`.

## Applies / uses
- [[dashboard-metric-standards]] — same metric rules as the rest of the dashboards; welcome modal / pro-tips.
- [[gsts-ui-style-guide]] — GSTS look; emoji `.cfm` needs a UTF-8 BOM.
- [[csv-export-standard]] — CSV export wired up front (per-city + all-cities).
- Reuses the City Budgets data sources verbatim: budget = `Contracts.YearNNBudget` (Approved, non-Homeowner); invoiced = `InvoiceMasters` by `ProjectYearLabel` (hybrid actual-`Invoices` fallback when 0 masters); callins/scheduled = `WorkOrders`; per-city FY = `cbFyStartFor()` + `cbResolveCurrent()`.

## The reconciliation model (option-a: reconcile the SPINE, not every number)
ONE shared, load-guarded include **`citybudget-fy-helpers.cfm`** (5 canonical `cb*` helpers) feeds all three surfaces — **City Budgets** current view, the **Forecast** tab, and **RC-06 Production** (`ProductionPerf.data.cfm`, whose verbatim FY/budget copy was deleted). All three share the identical budget/FY/monthly-spread spine (Newport 25/26 = **$2,030,649.30**). **Produced $** (CrewSheets, e.g. $2,027,793.81) stays a DISTINCT labeled figure from **Invoiced $** (InvoiceMasters, $1,999,929.91) — they are NOT forced equal. See [[shared-engine-kills-dashboard-drift]].

## Phases (all done + verified)
- **P1 — engine** `CityBudgetsForecast.data.cfm`: `forecastMonths[12]{monthLabel,budgeted,invoiced,callins,scheduled,remaining,projected}` + totals. Verified to the penny via gsql.
- **P2 — Forecasting tab** on `Dashboard-CityBudgets.cfm` (`ZTab=forecast`) + Scheduled-Ahead col + CSV. Label total ties to the current view; dates only lay out the monthly columns.
- **P3 — shared FY engine** `citybudget-fy-helpers.cfm` — one source, load-guarded (`request.cbHelpersLoaded`); RC-06 Production rewired to it (drift killed, byte-identical before/after).
- **P4 / P4b — adversarial QA** across ALL munis + FY types (Jan-Dec/Sep-Aug/Oct-Sep/Mar-Feb) + all-cities + CSV; fixed 2 invoiced bugs (Anaheim $0→$122,739.20 actual-invoice fallback; Fountain Valley current-month hold-out).
- **P5 — FY-rollover labeling (Option 1):** Production shows an amber **"prior FY · new year (26/27) just starting"** badge in its 60-day grace (also settles the RC-06 turnover-grace-label decision).
- **P6 — all-cities summary** + GRAND-TOTAL row (9 munis: Budgeted $7,317,742.97 / Remaining $2,300,695.38; schools/HOA in a separate labeled table) + CSV.

## KEY FACT (don't reverse-engineer Brent's numbers)
Brent's "$178,347.51 FY24/25 June Overages" carry-over is **NOT** a TRIM IT or QuickBooks transaction — it's a spreadsheet **true-up plug** (his annual budget − a hand-entered short 12-mo base). The live version drops it. Full detail: [[brent-forecast-178k-artifact]].

## Related
- [[rc-03-city-budgets]] — the dashboard this forecast tab lives on ("Brent's City Budgets dashboard").
- [[budget-report-municipal]] — the per-city FY analysis that seeded the reconciliation.
- [[shared-engine-kills-dashboard-drift]] — the reusable pattern this build established.
- V1.5 Home wired both new dashboards in (ship #119): Forecasting → SALES node, Production Performance → PRODUCTION node.
