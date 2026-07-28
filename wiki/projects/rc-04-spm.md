---
title: RC-04 SPM (Sales Production Meeting)
type: project
domain: work
track: 1
status: active
tags: [dashboard, spm, funnel, pipeline, release-candidate, reconciliation]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-01-executive-financial]]", "[[rc-03-city-budgets]]", "[[steve-diligence-dashboard]]", "[[revenue-goal-close]]", "[[v15-prod-deploy-state]]", "[[dashboard-auth-gate]]", "[[sales-cockpit]]"]
updated: 2026-07-28
---

# RC-04 SPM (Sales Production Meeting)

**One-liner:** 4-layer sales funnel board (iframes) — Pipeline · Sold · Production · Results — plus a Drill page; crew-reconciled to the TrimIT DB to the penny, replaces Nate Perkins' 6 manual meeting reports.
**Status:** 🔵 active — **VERIFYING** (Jun 25). Audited + hardened + DB-reconciled; **one item pending** (Go-Aheads weekly match, confirmed by a scheduled post-refresh check). Ships as a UNIT at the next prod deploy after that confirms.
**📁 Location:** `SalesProductionMeetingDashboard.cfm` (shell) + `SalesProductionMeeting$Pipeline/Sold/Production/Results.cfm` + `$Drill.cfm`
**▶️ Resume:** `arbor-stack/release-candidates/RC-04-sales-production-meeting-dashboard.md`

## 🔓 2026-07-28 — SPM's auth gate was BYPASSABLE ON PROD by one URL param (finding #5, fixed + shipped)
The Results auth gate sat **inside `<cfif showComm>`** — so `?ZCustType=municipal` took the branch that
skipped the include, and the page ran ungated. A **forged cookie got HTTP 200 / 19,291 b**; after hoisting the
gate above every conditional it is **403 on all three paths**, real users unchanged. Hoisting it also fixed
**#31** — the municipal CSV export called `csvField()` from that same skipped include.
🧭 **Rule:** an auth gate belongs on **line 1**, never inside a branch — a gate a URL parameter can route around
is not a gate. → [[dashboard-auth-gate]]
Same pass, same file: **#26** a stack-trace leak (`?page=abc` rendered `coldfusion.runtime` + `D:\home`),
**#23** reflected XSS (18 hrefs + 1 input value), and an unvalidated `?step=` that built a 180 KB page.

## 📅 2026-07-28 — `DateCompleted` end-day truncation (finding #4): Results was the worst hit
`BETWEEN` excludes the end day's own timestamps. **18 sites found suite-wide, 17 fixed, 1 correctly left** —
`Results.cfm` alone held **12**, including a second Municipal query block and the 5 year-over-year comparison
bars no finding mentioned, so it was **silently dropping today from every YTD figure, permanently**.
Measured (2026-07-18→24, all customers): 56 WOs / $582,445 / 3,937.9 h → **64 WOs / $644,250 / 4,369.4 h** —
**Completed $ had been reading 9.6% LOW**, and **3,088 of 3,088** WOs in the last 400 days carry a non-midnight
time, so it hit every window. Verified end-to-end through the served `exportCSV=1` file.
⚠️ **`exportCSV=1`, not `export=csv`** — the wrong param silently returns the HTML page at an identical byte
count, which is exactly how a bogus "verified" happens.

## 🔥 2026-07-27 — the **Results** tab was CRASHING on PRODUCTION (fix ✅ **SHIPPED 2026-07-28**)
📦 Shipped in `TRIMIT-BUGFIXES-20260728.zip` as **`database\01-create-workbench-objects-PROD.sql`** — renamed
and widened from `01-create-rgc-vProjectMarket-PROD.sql` because it now also stands up the empty
`Workbench.dbo.BidQueue` that the Sales Cockpit pop-out needs ([[sales-cockpit]]). Awaiting Jordan's run.

`208 Invalid object name 'Workbench.rgc.vProjectMarket'` at `SalesProductionMeeting$Results.cfm:116`. The
by-market and multi-year panels below `LEFT JOIN` that RGC view — and **[[revenue-goal-close]] was deliberately
held out of the V1.5 deploy**, so the `rgc` schema was never created on prod. The join is **UNGUARDED**, so the
page dies instead of degrading. Play works because play's `Workbench` has the full `rgc` schema (32 objects).
- **Fix:** `arbor-stack/dev-tasks/spm-results-prod-fix/01-create-rgc-vProjectMarket-PROD.sql` — creates *only*
  the `rgc` schema, the 21-row `MarketMap` and the view. Idempotent, `SET XACT_ABORT ON`, `THROW`s and rolls
  back if the row count ≠ 21. **Does NOT install Revenue Goal Close.**
- ✅ **Proven from nothing, not just re-run where it already worked** — created a scratch DB, ran it in cold, and
  queried the view: COMMERCIAL 6,418 · HOA 3,626 · MUNI_OTHER 1,438 · MUNI_CITIES 734 · UNCLASSIFIED 608.
- ▶️ Needs Travis to run it **plus `GRANT SELECT ON SCHEMA::rgc`** — without the grant the page fails with 916
  instead of 208. **Bundled into the one batched database ask** → [[v15-prod-deploy-state]].
- ⚠️ **The scan that missed this** grepped `Workbench.dbo.` only; the killer was in a different schema.
  **Match `Db.<anyschema>.<obj>` — a dependency scan that assumes `dbo` is not a dependency scan.**

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

- **Multi-Year Trend by Market (2026-07-16, ship #175):** new Results panel — HOA/Commercial/Muni-cities/Muni-other produced-$ across the **last 5 years (dynamic)**, **same-date YTD** for fair comparison + full-year secondary + YoY badge. Same RGC `vProjectMarket` classifier as the by-market panel (ties out). Answers Skipper's "how are we tracking vs 2023/2024, by segment." Reveals: HOA grew then flat, muni-cities declining every year ($4.75M→$3.89M), commercial bumpy. Optional polish: add a `spm.results.mktyears` pro-tip.
