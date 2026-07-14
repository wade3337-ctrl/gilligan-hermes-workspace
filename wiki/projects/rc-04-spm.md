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
- **Awaiting-Schedule fixed (2026-07-14, ship #167):** was keyed off `DateScheduled IS NULL` (inconsistently populated → listed 15 already-scheduled jobs). Now `StartDate IS NULL AND no CrewSheets` = truly-not-on-the-board (same signal as the Cockpit). Currently 0 (every approved job is scheduled at approval in TRIM IT). The old SharePoint "$226,988" number was Nate's manual list — the DB doesn't carry a real awaiting-schedule population.
- **Prod data-fix:** Daniel Ruelas (1108) + Carlos Alcaraz (1145) still `IsMeasured=1` in prod (should be 0) — staged handoff. **Retire** orphaned `SalesProductionMeeting$ComingSoon.cfm`.

## Related
- [[rc-01-executive-financial]] — close%/win-rate definition shared across surfaces (centralize to prevent drift).
- [[steve-diligence-dashboard]] — city-exclusion (PG=11) propagated to SPM Pipeline + Drill.
