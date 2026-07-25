---
title: RC-02 Revenue Performance
type: project
domain: work
track: 1
status: shipped
tags: [dashboard, revenue, tph, pace, drill-through, release-candidate]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-01-executive-financial]]", "[[rc-03-city-budgets]]", "[[anomaly-monitor-suite]]", "[[trimit-dual-webroot-shadow]]", "[[trimit-investor-case]]"]
updated: 2026-07-24
---

# RC-02 Revenue Performance

**One-liner:** Live view of scheduled revenue vs monthly goal + crew productivity (TPH) — actual-through-today / projected-after, by day/week/month, filterable by territory / work type / revenue source; Pace-vs-Goal tile, click-a-bar drill-through to the work orders, per-job deep-links, CSV export.
**Status:** 🟢 shipped — **REVIEWED & PARKED** (Jun 28), crew-cleared, verified on PLAY. Ready to ship with the Executive-dashboard prod deploy; kept in release candidates.
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

## Related
- [[rc-01-executive-financial]] — ships in the same Executive prod-deploy batch.
- [[anomaly-monitor-suite]] — COO monitor shares the invoiced/accrued revenue source scoped in the Billed backlog.
- [[trimit-dual-webroot-shadow]] — why this file must go to both roots.

## Superseded / historical
- (2026-07-24, superseded) "True Produced Work" was previously past days = day-sheet **`Calendars.EstValue`** (reconciled to the Day Sheet to the penny), today+future = schedule; and before that `WorkOrders.CompletedDollars` (spiky, wrong). The EstValue basis was retired because it reported an **estimate** as produced.
