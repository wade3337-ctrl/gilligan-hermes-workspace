---
title: RC-02 Revenue Performance
type: project
domain: work
track: 1
status: shipped
tags: [dashboard, revenue, tph, pace, drill-through, release-candidate]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-01-executive-financial]]", "[[rc-03-city-budgets]]", "[[anomaly-monitor-suite]]", "[[trimit-dual-webroot-shadow]]", "[[trimit-investor-case]]", "[[v15-prod-deploy-state]]"]
updated: 2026-07-28
---

# RC-02 Revenue Performance

**One-liner:** Live view of scheduled revenue vs monthly goal + crew productivity (TPH) — actual-through-today / projected-after, by day/week/month, filterable by territory / work type / revenue source; Pace-vs-Goal tile, click-a-bar drill-through to the work orders, per-job deep-links, CSV export.
**Status:** 📦 **(2026-07-28) SHIPPED to Jordan** in `TRIMIT-BUGFIXES-20260728.zip` (md5 `8227d6b7…`, 109,592 b) — the 36-defect gate **CLOSED 07-27** (31 fixed/closed, 5 deferred with recorded reasons), so this file went out with the batch; awaiting install on prod. → [[v15-prod-deploy-state]] · fixlist `arbor-stack/predeploy-pkg3/MORNING-FIXLIST.md`. ⚠️ It is the **only file in the package that also needs the C:\ CF shadow webroot** ([[trimit-dual-webroot-shadow]]) — the other 7 are D: only, verified. Prior: 🚧 (07-27) HELD behind the 36; 🟢 shipped — REVIEWED & PARKED (Jun 28), crew-cleared, verified on PLAY.
**📁 Location:** `Dashboard-RevenuePerformance.cfm` + `Dashboard-RevenuePerformance.Export.cfm` (+ shared `css/gsts-protips.css`)
**▶️ Resume:** `arbor-stack/release-candidates/RC-02-revenue-performance-dashboard.md`

## Applies / uses
- [[dashboard-metric-standards]] — target-driven TPH bands (Green/Amber/Red/Rainbow); Pace-vs-Co.-Goal proration.
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — colored-emoji welcome modal (enhanced the existing DB-based one, not duplicated); pro-tip hover help.
- [[repair-contract]] — backup-first, render-verify, penny-reconcile, log to ship-log.

## State & flags
- ⚠️ **DUAL WEBROOT.** `Dashboard-RevenuePerformance.cfm` has a `C:\ColdFusion2023\...\GSTS\` shadow that OVERRIDES the D:\ root — deploy to BOTH or it serves stale (same gotcha as ship-log #15).
- **"True Produced Work" source (CURRENT, 2026-07-24):** past/today = **actual `CrewSheets.CompletedDollars`** — *Option A, strict* (Skipper's call). The prior `Calendars.EstValue` basis was an **ESTIMATE reported as produced** (~2.9%/mo overstatement); June 1 now = **$84,909.71**, matching the Day Sheets. Future days = schedule.
- **Pace tile** uses a stable calendar Mon–Sat count (6-day basis, Skipper-confirmed crews work Saturdays) minus 2026 holidays — NOT the live schedule (which fills incrementally → false "behind").
- **Drill-through** reconciles to each bar by construction (no new SQL, in-memory reuse); rows deep-link to `Profile.WorkOrder.Detail.cfm`. All params cfqueryparam'd / IsDate-validated → no injection.
- **BACKLOG (scoped, not built):** a "Billed (Invoiced)" source from `dbo.Invoices` + `GetPeriodAccrual` (monthly grain; needs work-type classification). Skipper deferred Jun 25.

## 🚀 2026-07-24 major upgrade (live on play, BOTH webroots, staged for prod)
Staged in `arbor-stack/release-candidates/NEXT-DEPLOY-20260724/` (manifest warns re: dual webroot) — **held out of the V1.5 package, next prod batch.** Kanban cards 59-61; backup `Workbench.dbo.WorkKanban_bak_20260724`.
1. Estimate → **actual** produced (above).
2. **"Actual to date" is now source-independent + restore-proof** — the nightly play restore was flipping `GoalSettings.RevenueSource`→ScheduleBoard, so the dashboard showed the estimate $1.68M vs the report's $1.29M.
3. **3-bucket model:** Confirmed (posted actuals) / **Pending** (worked-but-unposted lag → estimate shown as projected, so no false $0 dip) / Scheduled (future). Flag = `row.isPostedActual`.
4. **Projected day value = scheduled hours × Target TPH**, not the lumpy `EstValue` that front-loads whole-job values (e.g. the "Grid 2" $45,878-on-18hr sheet — flagged to the office as a real TRIM IT data error).
5. **FEATURE — dual TPH:** new **"True TPH"** tile (revenue ÷ **ALL paid hrs**) beside "Productive TPH", a **Non-Productive Time** collapsible tab (Yard/Safety/OJT/ModDuty/Meetings + TPH drag), and a **True-TPH tick on every bar** (3px/$ drag, colored by whether True clears target; shaded cap = productivity lost). `internalSubtype()` + `internalByType`.
6. **The daily COO/rep emails inherit all of it** ([[anomaly-monitor-suite]] `monitor.js` + `revenue-block.js`): **Produced = TrueProduced actual** ($1.295M July MTD), **Tracking-to-goal = ScheduleBoard total** (expected landing). Also fixed `monitor.js` passing `sampleDay` instead of `todayPT`, which was inflating tracking.

⚠️ **Always say WHICH TPH.** Productive-hours TPH and blended/True TPH rank segments *differently* — see [[trimit-investor-case]].

## 🩹 2026-07-27 — package 3: the two bugs prod exposed, plus the gate
**Package 3 = this file + `Executive$Sales$Unattributed.cfm`.** Both render-verified on play; **HELD** pending
the 36 fixes. Re-stamp the manifest MD5s after they land — *editing a shipped artifact and updating its
manifest are one action, not two.*

1. **The `##` render bug (found on PROD).** ColdFusion only collapses `##`→`#` **inside `<cfoutput>`**; outside
   it the raw entities print (`&##9662;`) and **~a dozen CSS colours are silently invalid** — no gradient bar,
   black text instead of white. ⚠️ **Reading the source found only 13 of 18.** The 5 missed have an inline
   `<cfoutput>` wrapping *only the variable*, so the surrounding HTML looks inside cfoutput but is not.
   **Settle it by deploying to play and grepping the SERVED HTML for `##` — expect zero.** The render also
   proves which lines are genuinely inside cfoutput, so correct ones don't get "fixed".
2. **Crew Sheets was showing an ESTIMATE under the word "Actual."** Line 581 applies the actual-completed
   override to `ScheduleBoard` and `TrueProduced` only; `CrewSheets` falls through and takes `row.csValue`
   raw — no posted/pending bucketing, no hours × TPH projection. **Skipper's call (option b): keep it as a
   deliberate raw lens and RELABEL** — *"the three sources exist to be different views; hiding the difference
   is how people stop trusting the number later."* Tile → **"Estimated to date"**, dropdown → "Crew Sheets
   (raw estimates — not actuals)". Labels only; no query or calculation touched.
   Verified by POST on play: TrueProduced/ScheduleBoard **$1,618,804** (identical — override working) vs
   CrewSheets **$1,670,085**. **The $51,281 gap is exactly what had been labelled "Actual."**
   ⚠️ The source selector is a **POST form** — a GET query string silently does not switch it, which made the
   first three "renders" identical and nearly read as a failed fix.
3. **The Unattributed drill's header bug was prod running the OLD file** — package 3's version already fixes it.
   Its date filter was deliberately **left on `BETWEEN`**: the parent `Executive$Sales$ByRep$Scope.cfm` still
   uses `BETWEEN` in four queries, and **a drill must share its parent's date predicate** or it explains a
   headline with a different number. Change both in one deploy or neither.
4. 🆕 **Found, not fixed** (awaiting the Skipper): the drill's *Current Rep* column prints a raw DB flag to
   users — `RG · Raudel Gutierrez (IsMeasured=0)`, line 152.

## Related
- [[v15-prod-deploy-state]] — the batched-deploy inventory this package sits in.
- [[rc-01-executive-financial]] — ships in the same Executive prod-deploy batch.
- [[anomaly-monitor-suite]] — COO monitor shares the invoiced/accrued revenue source scoped in the Billed backlog.
- [[trimit-dual-webroot-shadow]] — why this file must go to both roots.

## Superseded / historical
- (2026-07-24, superseded) "True Produced Work" was previously past days = day-sheet **`Calendars.EstValue`** (reconciled to the Day Sheet to the penny), today+future = schedule; and before that `WorkOrders.CompletedDollars` (spiky, wrong). The EstValue basis was retired because it reported an **estimate** as produced.
