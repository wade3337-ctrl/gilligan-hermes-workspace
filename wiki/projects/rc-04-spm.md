---
title: RC-04 SPM (Sales Production Meeting)
type: project
domain: work
track: 1
status: active
tags: [dashboard, spm, funnel, pipeline, release-candidate, reconciliation]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-01-executive-financial]]", "[[rc-03-city-budgets]]", "[[steve-diligence-dashboard]]"]
updated: 2026-07-14
---

# RC-04 SPM (Sales Production Meeting)

**One-liner:** 4-layer sales funnel board (iframes) — Pipeline · Sold · Production · Results — plus a Drill page; crew-reconciled to the TrimIT DB to the penny, replaces Nate Perkins' 6 manual meeting reports.
**Status:** 🔵 active — **VERIFYING** (Jun 25). Audited + hardened + DB-reconciled; **one item pending** (Go-Aheads weekly match, confirmed by a scheduled post-refresh check). Ships as a UNIT at the next prod deploy after that confirms.
**📁 Location:** `SalesProductionMeetingDashboard.cfm` (shell) + `SalesProductionMeeting$Pipeline/Sold/Production/Results.cfm` + `$Drill.cfm`
**▶️ Resume:** `arbor-stack/release-candidates/RC-04-sales-production-meeting-dashboard.md`

## Applies / uses
- [[dashboard-metric-standards]] — close-% cohort, TPH tiles; municipal on the City Budgets engine (Allocated = $7.97M to the dollar).
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — Arbor guide circle-clipped; pro-tips; UTF-8 BOM before deploy.
- [[repair-contract]] — 7-agent crew reconciliation vs DB, backup-first, render-verify.

## State & flags
- ⚠️ **5 prod asset 404s must ship with the .cfm** (chart/pro-tip assets); use `deploy-manifest.js` for the full set (shell + 5 sub-pages + shared CSS/JS/protips). Backups in `\GSTS\Jasonsrepairs\`.
- **Reconciles to DB to the penny** on headline numbers: Sold $12,875,509 / 1307 WOs; Completed $10,061,151 / 1371 WOs. Discrepancies are in Nate's *reports*, not the dashboard.
- **Pending:** Go-Aheads weekly match over-counts vs Nate's "Last 7 Days"; the `WorkOrders.Created` fix was disproven (58% of go-aheads have no WO). A scheduled 6:34am PT job reconciles on fresh post-refresh data → flip to ready once it confirms.
- **Awaiting-Schedule fixed then REPURPOSED (2026-07-14, ship #167→#168):** the panel was keyed off `DateScheduled IS NULL` (inconsistently populated → listed 15 already-scheduled jobs). Root truth: every approved job gets a StartDate at approval, so a real "awaiting schedule" backlog is **always 0** in the DB (the old "$226,988" was Nate's manual SharePoint list). So (Skipper OK) **repurposed the panel → "Upcoming Scheduled Starts"**: approved+active booked to start today-or-later, soonest first (tile "Upcoming Starts") + an imminent "Starting ≤ 7 days" tile. Propagated to `$Drill.cfm` (soldBacklog/soldAging = upcoming/imminent). Live: 52 upcoming/$532K, 17 within 7d/$124,696. `StartDate` is the reliable schedule signal (same as the Cockpit).
- **Prod data-fix:** Daniel Ruelas (1108) + Carlos Alcaraz (1145) still `IsMeasured=1` in prod (should be 0) — staged handoff. **Retire** orphaned `SalesProductionMeeting$ComingSoon.cfm`.

- **Results re-cut to RGC markets (2026-07-14, ship #169):** Results "Commercial" (non-PG11) lumped HOA+commercial+schools ($7.53M) and contradicted RGC Commercial ($1.57M). Added a **By-market panel** using RGC's `rgc.vProjectMarket` classifier (HOA/Cities/Commercial/Muni-other) → reconciles to total completed $11.2M and lines up bucket-for-bucket with [[revenue-goal-close]] (Commercial $1.43M vs RGC $1.57M, HOA $5.10M broken out). Aggregate tiles relabeled Commercial→Non-Municipal. Residual per-bucket gaps = completed-WO vs crew-sheet-produced.

- **On-the-books + monthly SNAPSHOT (2026-07-14, ship #170-171):** Results now shows **Completed + Scheduled = on the books** (the fuller picture Nate's report gives; resolves the "−11% vs Nate's +7%" = completed-only vs completed+booked). A faithful same-date YoY needs last year's booking snapshot the live DB doesn't keep — so we now **capture it monthly** in `Workbench.dbo.SpmBookSnapshot` (lazy write on page view, ships with the page). True YoY appears once a year accrues. Prod deploy needs the table + INSERT grant + the `Workbench.rgc.vProjectMarket` cross-DB view — see RC-04 deploy doc DB step.

## Related
- [[rc-01-executive-financial]] — close%/win-rate definition shared across surfaces (centralize to prevent drift).
- [[steve-diligence-dashboard]] — city-exclusion (PG=11) propagated to SPM Pipeline + Drill.
