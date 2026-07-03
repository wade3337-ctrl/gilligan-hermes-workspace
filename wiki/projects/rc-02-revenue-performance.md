---
title: RC-02 Revenue Performance
type: project
domain: work
track: 1
status: shipped
tags: [dashboard, revenue, tph, pace, drill-through, release-candidate]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-01-executive-financial]]", "[[rc-03-city-budgets]]", "[[anomaly-monitor-suite]]"]
updated: 2026-07-02
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
- **"True Produced Work" source** added: past days = day-sheet `Calendars.EstValue` (reconciles to the Day Sheet to the penny); today+future = schedule. First built on `WorkOrders.CompletedDollars` (spiky, wrong) — Skipper caught it, crew root-caused, fixed.
- **Pace tile** uses a stable calendar Mon–Sat count (6-day basis, Skipper-confirmed crews work Saturdays) minus 2026 holidays — NOT the live schedule (which fills incrementally → false "behind").
- **Drill-through** reconciles to each bar by construction (no new SQL, in-memory reuse); rows deep-link to `Profile.WorkOrder.Detail.cfm`. All params cfqueryparam'd / IsDate-validated → no injection.
- **BACKLOG (scoped, not built):** a "Billed (Invoiced)" source from `dbo.Invoices` + `GetPeriodAccrual` (monthly grain; needs work-type classification). Skipper deferred Jun 25.

## Related
- [[rc-01-executive-financial]] — ships in the same Executive prod-deploy batch.
- [[anomaly-monitor-suite]] — COO monitor shares the invoiced/accrued revenue source scoped in the Billed backlog.
