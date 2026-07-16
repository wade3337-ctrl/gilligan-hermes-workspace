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

## ✅ 2026-07-16 — Long Beach PO-stream sub-cards (ship #179)
- **Split found in TRIM IT:** LB's ONE agreement (RFP PR19-126) bills via 2 PO streams = 2 **sub-projects** under company 295947: **Parks & Rec (ProjectID 1098339)** + **Marine/Beaches (1101097)**. (3 dormant sub-projects ignored.) Brent's annual PO numbers (Marine 2260193x) are **NOT in TRIM IT** — contract PO=shared 22501007, invoice PO blank; Brent tracks them manually → split driven by **Project**, PO shown as static label.
- **Built:** "PO Streams" section on the LB drill-down → 2 sub-cards (Budgeted/Invoiced/Call-Ins/Scheduled/Remaining + "Work attached" WO table), each scoped to its ProjectID w/ same FY window + scope-guard as parent. Data block guarded `companyID EQ 295947` (extensible). Verified play, 0 CF errors; **sub-cards reconcile to parent exactly** ($904K/$730,432.92/$1,993.18/$98,071.98). Invoiced ties Brent's 2 PDFs to the penny.
- ⚠️ Parks budget = contract **$520,000** (so sub-cards sum to parent); Brent's report uses PO **$586,025** — contract-vs-PO nuance (same as Aliso).

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

## ✅ 2026-07-16 — accrual/scheduled SCOPE GUARD (ship #176) + Brent reconcile
- **Bug (Skipper, from Brent's report):** City of Industry Forecasting drill-down showed **$0 accrual / $1,876 scheduled** vs Brent's **$20,780 / $71,185**.
- **Root cause:** WO **166670** (the $152K live Citywide-Maintenance Active job) is data-entry-stamped FY **"05"** (contract 1248's valid labels are 26–30). Both `qFcWO` (forecast) + `qSumWO` (all-cities roll-up) scoped WOs by **`ProjectYearLabel` only** → dropped it → accrual/scheduled ≈ $0.
- **Fix = FY SCOPE GUARD:** a WO counts for a city's FY if label matches **OR** `DateScheduled ∈ [fyStart,fyEnd)`. `qSumWO` reworked to one-row-per-WO + CFML guard loop (mirrors invoice-fallback); per-city FY window hoisted so invoice + WO calcs share it. **Strictly additive** (label-vs-guard Δ: Industry +$53K sched/+$39K accr = the fix; Irvine +$1,215; Newport +$84; **LB + Anaheim = 0**).
- **Reconciled to Brent's 12 PDFs** (pulled from email, saved `inbox-pull/brent-budget-2026-07-09/`): **Long Beach ties to the dollar** ($94,601.88 in-FY = Brent $94,602; +$3,470 = one post-July-8 WO). Industry invoiced $380,375.36 ties exactly; accrual/scheduled now populate. Verified on play (ZUserID=376), 0 CF errors, no regression.
- ⚠️ **Not yet prod** — awaiting Skipper sign-off. Backup: `Jasonsrepairs\citybudgets-wo-scopeguard-20260716-175144`.
- 🔎 **Open — Irvine definitional:** dashboard scheduled ($184K) > Brent ($91K); Brent trims forward-scheduled/not-yet-started work as "not at hand." Decide whether to match his tighter cut or show all booked work.
- 📌 **Data-quality note:** the "05" mislabel is upstream (TRIM IT WO entry). The guard makes the dashboard robust to it, but flagging to Brent/ops to fix the WO label at source is the clean long-term move.
- ⚠️ **Regression I caught+fixed same session:** the #176 `woByCo` struct→array change broke `CityBudgetsRenewals.data.cfm` (a consumer that reused `woByCo`) → blanked the Renewals tab. Fixed (same guard), lesson logged. **Lesson:** change a shared data shape → grep+update every consumer + render-verify each sibling.

## ✅ 2026-07-16 — renewal-gap cities stay on the main page (ship #177, Skipper: "some cities missing")
- **Missing = Aliso Viejo + Stanton:** approved contracts end **FY25/26**; it's now **FY26/27** (turned July 1) with no renewal PO/budget → current-FY filter dropped them off the main tiles.
- **Fix (Skipper's call — keep visible):** **RENEWAL-GAP FALLBACK** in `CityBudgets.data.cfm` all-cities loop — a **municipal** city empty for its current FY falls back to its **most recent FUNDED FY**, stays tiled with real numbers + amber **"RENEWAL DUE"** badge; tile links to that fallback FY (drill matches). Current-FY view only; explicit FY picks unchanged; commercial unaffected.
- **RECENCY GUARD (Skipper refinement):** fall back ONLY if the last funded year is the **immediately prior FY** (`_bestYr >= cbStartYr(cbCurLabel(_sm,_now)) - 1`) — current FY start from TODAY, not the city's stale labels. Kills zombies: **CAL TRANS (last 17/18), Seal Beach (18/19)** no longer resurface; Aliso/Stanton (25/26) stay. Verified: RENEWAL DUE tiles = exactly those two.
- **Verified play** (0 CF errors, 5 surfaces): Stanton $115K/$58,320.10 (ties Brent), Aliso $50,900/$32,435.90 (invoiced ties; ⚠️ budget $50,900 vs Brent PO $52,400 = $1,500 contract-vs-PO nit).

## Related
- [[budget-report-municipal]] — the per-city FY analysis that feeds this.
- [[contract-dashboard-fix-longbeach]] — Bucket C depends on it.
