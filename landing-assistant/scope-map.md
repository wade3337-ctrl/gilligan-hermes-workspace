---
title: Scope Map — in-scope pages & data
type: reference
track: 1
updated: 2026-07-11
---

# Scope Map — what the assistant may read

The finite list of landing-page-reachable pages, the data each exposes, and the query file behind it. **This list + [[data-scope-contract]] are the only definition of "in scope."** Each entry notes the role-node it hangs under.

> Grounding rule: for a number, run the page's **own query** and inject the rows; the model narrates. It never invents figures. → [[architecture]]

## PRODUCTION / EXECUTIVE node
### Revenue Performance — `Dashboard-RevenuePerformance.cfm`
- **Exposes:** scheduled revenue vs monthly goal; crew productivity **TPH** (target **130** → [[guardrails]]); Pace-vs-Goal; actual-through-today / projected-after; by day/week/month; filter by territory / work type / revenue source; drill to the work orders.
- **Query:** `Dashboard-RevenuePerformance.cfm` (+ `.Export.cfm`).
- **Good questions:** "Are we on pace to goal this month?" · "What's TPH this week?" · "Revenue by territory MTD?"

### City Budgets — `Dashboard-CityBudgets.cfm`
- **Exposes:** per **city + fiscal year** → Budgeted / Invoiced / Call-Ins / Scheduled / Remaining, month-by-month; Work-at-Hand WOs; 16–17 cities.
- **Query:** `CityBudgets.data.cfm` (export `Dashboard-CityBudgets.Export.cfm`).
- **Good questions:** "How much budget is left in Anaheim this FY?" · "What's invoiced vs budgeted for Long Beach?"
- ⚠️ Say **"invoiced," never "paid"** — invoice *status* is dead data. → [[guardrails]]

## SALES / EXECUTIVE node
### SPM — Sales Production Meeting — `SalesProductionMeetingDashboard.cfm`
- **Exposes:** 4-layer funnel — **Pipeline · Sold · Production · Results** — DB-reconciled to the penny.
- **Query:** the four `SalesProductionMeeting$Pipeline/Sold/Production/Results.cfm` + `$Drill.cfm`.
- **Good questions:** "How much is in the pipeline?" · "What sold last week?"

### Sales Cockpit — `ZTest-Cockpit*.cfm`
- **Exposes:** customer relationship profiles → sites, each with **$ · TPH(vs 130) · last job · forward-status**; search by rep/territory/manager/company; bid on-ramp.
- **Query:** `ZTest-Cockpit-Search/-Profile/-List/-Book.cfm`.
- **Good questions:** "When did we last work site X?" · "Show CBRE sites for rep Garrett."
- ⚠️ Invoice = "invoiced" not "paid"; manager identity is free-text (dupes exist) — don't assert a single manager as fact.

### Arborist Workbench / My Jobs — `ZTest-SiteMap.cfm` / `ZTest-MyJobs.cfm`
- **Exposes:** rep portfolio & 5 lifecycle tabs; **Done = WO Complete (StatusDefID 48) + non-void invoice**; Re-bid Radar.
- ⚠️ Site map from `dbo.Locations` (not `Projects.Lat/Long` — dead).

## EXECUTIVE node
### Executive Review — `Executive$Financial$Overview$Frame$Beta.cfm`
- **Exposes:** 5 tabs — Sales by Rep · Sales by Market · Closing % by Rep · Closing % by Market · Crew Performance (+ drills).
- **Role:** executive-gated — enforce the role test hard. → [[data-scope-contract]]

---
**Not on this list = out of scope.** Adding a page means editing this file + [[data-scope-contract]], nothing implicit.
