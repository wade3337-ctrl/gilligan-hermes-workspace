---
title: Deal Tracker — live private dashboard + 2026 re-goal
type: project
domain: work
status: active — LIVE; pending Skipper "tune-up" (see Resume)
confidential: black
applies: ["[[fort-point-confidentiality]]"]
links: ["[[fort-point-acquisition]]", "[[gsts-growth-plan-fort-point]]", "[[gsts-adjusted-ebitda]]", "[[gsts-2026-earnout]]", "[[segment-margin-analysis]]"]
updated: 2026-07-22
---

# 🔒 Deal Tracker — live private dashboard + 2026 re-goal

## 🔷 REBUILT as COUNT-ONCE LEDGER (2026-07-22, per Boss Herman's spec + Gilligan reconciliation)
Skipper forwarded Herman's detailed "count-once path to goal" prompt; verified every layer LIVE (Herman's snapshot #s were pre-refresh). **Skipper decisions:** goal=**GoalSettings×12 $25.05M** (live, ZUserID9 $2,087,119/mo — flat, supersedes the SalesGoal monthly shape) · muni=**calendar-H2 $3.74M** (config `MUNI_H2_CALENDAR_FORECAST`; engine budget−invoiced reconciles ~$3.19M — TODO live calendar-muni calc) · accrual=**pursue** (needs Brent/accounting feed — canNOT infer from WO−invoice; adjusted actual = invoiced until fed).
**Count-once bridge (live):** actual(acct-period, status-filtered) **$12.01M** + muni **$3.74M** + firm sold WO(46/109 dated ≤12/31, nonmuni) **$3.11M** + fresh pipeline(GoAheads 49 <90d HOA/Comm/PM deduped $3.88M ×40%) **$1.55M** = $20.42M covered → **UNCOVERED $4.63M** (vs Herman snapshot $2.95M — real gap is bigger). Muni classification `ProjectGroups.ProjectGroupDefID=11` validated (muni invoiced $4,192,062 = Herman's TRIM IT to the $). Actuals basis = `Invoices.PeriodID→Periods.StartDate`, `StatusDefID IN (21,100,22,23,148)`, no proforma/credit (was InvoiceDate+unfiltered = $66K high). Action lists: undated sold WOs $3.17M/251 · pending nearing 90d $0.55M/24 · muni over-budget cities · reconciliation diffs. Full proof: `business-plan/count-once-ledger-2026-07-22.md`. Script fully rewritten.
**▶️ OPEN:** (1) accrual feed from Brent (needs Skipper OK to contact) · (2) live calendar-muni calc to replace the $3.74M config · (3) confirm sold-status list (46,109) w/ Herman (firm-WO recompute $1.5M under his snapshot) · (4) per-month coverage cols + drill-throughs (Herman §11 full table) not yet built.

Applies [[fort-point-confidentiality]]. Skipper-only glanceable view of the numbers the $55M Fort Point deal rides on. Built 2026-07-21.

## The dashboard — REDESIGNED 2026-07-22 → revenue-productivity board
Skipper's steer: *"I'd prefer to know what revenue numbers I need to hit — that's how we measure productivity."* So the old 6 deal-outcome cards (EBITDA/AGP/earnout/proceeds/rollover as heroes) were **demoted to a collapsed context strip**, and the hero is now **monthly goal vs live actual**.
- **File:** `business-plan/deal-tracker-dashboard.html` — regenerated from LIVE TRIM IT by `business-plan/refresh-deal-dashboard.py` (**cron every 2h**; play DB = nightly prod mirror, daily-fresh).
- **Shows now:** 3 hero cards (Booked YTD $12.08M/48% · Remaining to goal $13.02M · **Pace vs plan** −$1.11M behind thru Jun) → a **12-month goal-vs-actual table** (each month: goal, live actual, Δ / for upcoming months the $/wk + crew-hrs @130 TPH needed, and a hit/missed/close/in-progress/upcoming status) → a **"what it takes to land $25.1M"** note (the recovery-gap math) → a `<details>` **collapsed deal-context strip** (earnout, EBITDA, net proceeds, your EIP).
- **The recovery-gap insight (why it's honest now):** hitting *every* remaining monthly goal still lands ~$1.1M short of $25.1M because of the H1 miss → need ~$220K/mo *extra* Aug–Dec. The old board hid this.
- **MUNI FORECAST added 2026-07-22** (Skipper: "add Brent's muni forecasting as forecasted sales" → chose option (a) = remaining budget on EXISTING city contracts): coverage bar is now a **3-way split — booked · forecasted muni · still-to-sell**. Muni number = **all-cities grand-total "Remaining"** pulled LIVE from Brent's **canonical** City Budgets forecast engine (`Dashboard-CityBudgets.cfm?ZProjectID=all&ZTab=forecast&exportForecastAllCSV=1`, fetched via `curl` + `ZUserID=376` cookie like `view.sh`) — reusing his engine so this board can't drift from his dashboard. Currently **$2.22M**. **No double-count:** that "Remaining" already subtracts Invoiced (in my YTD actual) and Scheduled (in my on-schedule) → it's the contracted-but-unbooked slice. **Caveat flagged on the board:** it's FY-based per city (varying FYs; some invoices past Dec 2026) while my goal is calendar-2026. Has a snapshot-fallback note if the fetch fails. → [[city-forecasting]] · [[brent-forecast-178k-artifact]].
- **SCHEDULE VIEW added 2026-07-22** (Skipper: "include a view of what's on the schedule"): a **coverage bar** ($3.34M booked / $9.68M still-to-sell of the $13.02M remaining, ~26% covered) + **On-schedule & Still-to-sell columns** in the monthly table + a **next-4-weeks strip** ($/hrs/utilization per week). **Data source:** `dbo.CrewSheets.ScheduledTotal` grouped by `WorkDate` month = booked crew backlog (clears to ~$0 as work completes, so past months read ~$0 and future months show what's booked); `ScheduledHours` for utilization vs `FIELD_STAFF*40` weekly capacity. `GPSWorkOrders` is empty/unused. Far-out months (Sep/Dec) read low only because booking fills in closer to the date — flagged on the board so it's not misread.
- **GOALS NOW LIVE via the READ-ONLY login (2026-07-22):** monthly goals pull **live from `Workbench.dbo.SalesGoal`** on every refresh through the RO gateway `q()` (edit in TRIM IT → dash follows, no hand-sync). Unlock: HermanRO was walled off from `Workbench`, so we **granted `HermanRO` a Workbench user + `SELECT ON dbo.SalesGoal`** (ship log 2026-07-22; revert `recovery/workbench-hermanro-grant-revert-20260722.sql`). **Durable:** `Workbench` is NOT in the nightly refresh (only GSTS is restored — verified via `msdb.restorehistory`), so the grant persists. Script keeps a `FALLBACK_TARGET` snapshot (only trusts a complete 12-month pull). Skipper flattened H2 on 7/22 → **$25.19M** (Aug–Nov $2.20M, Dec $2.05M; was front-loaded $25.10M). Revenue ACTUALS + schedule also via RO gateway. Deal constants hardcoded in `DEAL` (Cam datapack 7/21, FTI QoE). *(The admin path `arbor-stack/production-dashboard/gsql.sh` (auths as play Administrator via `-E`, reads any DB incl. Workbench) was used to discover this + apply the grant — keep for future Workbench reads/writes, but the dashboard no longer needs it.)*
- **EIP / your rollover — corrected 2026-07-22** (from Skipper's `FPC_EIP_Example` sheet): the old "$27M rollover + MIP up to 15%" line conflated seller-group rollover with your slice. Truth: **your EIP/MIP = 15% of the key-personnel pool = ~$1.44M (Scenario 1, few small add-ons) to ~$2.48M (Scenario 2, several larger add-ons)**. Pool = Tier1 (10% above 1.0x) + Tier2 (5% above 25% IRR) of combined profit ($87.5M S1 / $150M S2, off $35M/$60M equity × FPC's 3.5x). Splits: Scott(CEO) 25% · **Jason(COO) 15%** · Sales 15% · Branch/Crew leads 15% · future add-on employees 30%.

## Access (Tailscale/LAN, no login)
- **URL:** `http://100.82.161.7:8091/<token>` (token in `~/.secrets/deal-dash-auth.json`). Also LAN `http://192.168.1.70:8091/<token>`.
- **Served by Docker container `deal-dash`** (image `arbor-core-api`, `-p 8091:8091`, mounts the HTML ro + `DASH_TOKEN` env, `--restart unless-stopped`). Server script `~/deal-dash-server/serve-container.py`.
- ⚠️ **Why Docker, not a host process:** host-bound ports are blocked by the box firewall (no root to open them); **Docker-publish manages its own iptables via the daemon** = reachable, same as the arbor kanban :8088. The old `systemd --user deal-dash.service` (host-bound) is **stopped+disabled** — don't revive it. → [[PLAYBOOK]] infra/network.
- Secret-URL token = the key (no basic-auth prompt); bare paths 404. Tailnet-only (box has no public IP).

## 2026 re-goal (team) — $25.1M, front-loaded
- Skipper (7/21): **max the earnout** → raised the team goal $24M → **$25.1M**. The **Revenue Performance / Sales Goals dashboards read `Workbench.dbo.SalesGoal`** (edited via `Dashboard-SalesGoals.cfm`; survives nightly refresh). **NOT** `GoalSettings` (a secondary per-user flat monthly override in RevPerf — don't confuse them).
- Front-loaded H2 (Aug–Oct heavy for daylight): Aug $2.30M · Sep $2.35M · Oct $2.30M · Nov $1.90M · Dec $1.91M; Jan–Jul unchanged; annual $25.1M. Backup: `recovery/salesgoal-2026-backup-20260721.sql`.
- Reality: YTD ~$12.1M (through Jul), ~$13.0M remaining → to actually LAND $25.1M (recovering the H1 miss), the 5 remaining months avg ~$2.60M = **~56 hr/wk/person** (Saturdays/OT). Above the ~$24.8M weekday-only modeled capacity.

## ✅ TUNE-UP DONE (2026-07-22) — reframed as a revenue-productivity board
Skipper chose: revenue-target framing + deal metrics in a **collapsed strip**. Rebuilt `refresh-deal-dashboard.py`, regenerated, verified live (container serving HTTP 200, new title "GSTS Revenue Tracker"). See "The dashboard" above. **Open threads still his court** (below).
▶️ Possible next polish if he wants: per-remaining-month recovery targets baked INTO the goal column (show "goal + recovery" blended); or a small sparkline of monthly trend.

## Other open threads (Skipper's court)
- Confirm **Jason's $1.0M closing payout** base with **Gary** (phantom formula ≈ $0.8M).
- **Defend-the-EBITDA** narrative for diligence (H2 recovery = price defense). → [[gsts-growth-plan-fort-point]] §9e.
