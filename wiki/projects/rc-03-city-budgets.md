---
title: RC-03 City Budgets Dashboard
type: project
domain: work
track: 1
status: active
tags: [dashboard, municipal, city-budgets, release-candidate, brent]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[budget-report-municipal]]", "[[contract-dashboard-fix-longbeach]]", "[[city-forecasting]]", "[[anomaly-monitor-suite]]"]
updated: 2026-07-14
---

# RC-03 City Budgets Dashboard

**One-liner:** Automates the Municipal Budget Report Contract-Admin Brent Beller built by hand — pick a city + fiscal year → Budgeted / Invoiced / Call-Ins / Scheduled / Remaining, month-by-month, + Work-at-Hand WOs; 2-tab Excel export; 16–17 cities.
**Status:** 🔵 active — built + crew-verified on play; **awaiting Brent's final sign-off** (RC-03 gate).
**📁 Location:** `production-dashboard/Dashboard-CityBudgets.cfm` + `CityBudgets.data.cfm` + `CityBudgetsForecast.data.cfm` + `CityBudgetsRenewals.data.cfm` + `Dashboard-CityBudgets.Export.cfm`
**▶️ Resume:** `arbor-stack/release-candidates/RC-03-city-budgets-dashboard.md`
**Tabs:** City Budgets (default) · Forecasting (`ZTab=forecast`, → [[city-forecasting]]) · **Renewals** (`ZTab=renewals`, 2026-07-14).

## Renewals tab (built 2026-07-14, Skipper-approved)
Accounts whose **own current fiscal year has no budget yet** (contract not renewed / budget not entered) — they default off the Forecasting tab, so this tab surfaces every one. Engine `CityBudgetsRenewals.data.cfm` reuses the all-cities structures + the shared `cb*` FY helpers (`cbFyStartFor`+`cbResolveCurrent`) so **Stanton shows** and Industry's $666K-under-label-"26" is NOT a false positive. Split 🏛 Municipal / 🏢 Commercial; **Working** (actively billing/producing with no budget = unbudgeted-work alarm) flagged **red at top**, **Dormant** below; `⬇ Export CSV`. Live at build: 75 accounts / 10 funded / 65 renewals (Commercial 59 = 11 working/48 dormant; Municipal 6). Surfaced San Clemente $258,957 + Fountain Valley $45,936 muni unbudgeted work. Built to [[gsts-ui-spec]] v1.2. Ship #166.

## Applies / uses
- [[dashboard-metric-standards]] — metric bands, welcome modal, pro-tips.
- [[gsts-ui-spec]] — UI/styling; emoji `.cfm` needs a UTF-8 BOM.
- [[repair-contract]] — backup-first, render-verify the served output, log to ship-log.
- City = Municipal Contracts tag `ProjectGroupDefID=11`; per-city budget-FY map (`cbFyStartFor`, Long Beach = Oct–Sep).

## State & flags
- ⚠️ **Awaiting Brent sign-off.** He sends his verified municipal doc after his **Jul 8** manual update; watcher armed:
  `anomaly-monitor/brent-citybudgets-check.js` + gateway cron "Brent City Budgets report check" (9am/3pm PT, Jul 8-20)
  → auto-reconcile vs the play dashboard, then disable. (Play link verified live.)
- Buckets C/D parked (Newport carryover, LB 2nd contract, San Clemente CI re-tag).
- Play was **stale at 6/30** on 2026-07-02 — verify freshness before the comparison.

## Related
- [[budget-report-municipal]] — the per-city FY analysis that feeds this.
- [[contract-dashboard-fix-longbeach]] — Bucket C depends on it.
