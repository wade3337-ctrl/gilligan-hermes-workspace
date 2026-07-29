---
title: BOD Commitment Dashboard — track what the Skipper told the Board he would do
type: project
domain: work
track: 1
status: 🟢 BUILT on play 2026-07-29 — render-verified, gate proven, headcount basis reconciled.
tags: [dashboard, board, kpi, trimit, play, q3-2026]
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[dashboard-metric-standards]]", "[[only-trustworthy-data]]", "[[dashboard-auth-gate]]"]
links: ["[[pending-crewsheet-closeout-gap]]", "[[path-to-25m-2026]]", "[[crewsheet-acthours-is-the-estimate]]", "[[timekeeping-live-nov-2025]]", "[[crew-assignment-drift]]", "[[production-perf-future-dated-crewsheets]]"]
updated: 2026-07-29
---

# BOD Commitment Dashboard

**The Skipper (2026-07-29, 02:13 UTC):** *"build a dashboard to track what I told the BOD I would do over
the next quarter. It should read from TRIM IT real data and align with my reporting. Build it on play."*

Delivered plan → `board-reports/Q2-2026-coo-plan-SENT-20260729.md` · every figure's source →
`…-SENT-20260729-BASIS.md`. **The dashboard must reproduce those numbers exactly.**

## The four tiles — his own closing section, verbatim
| # | Commitment | Today | Target |
|---|---|---|---|
| 1 | **Net field headcount** — people working a typical weekday | **~76** | **91** |
| 2 | **Fully weighted productivity** | **$125.10** | **$130** target · **$127.86** the plan needs |
| 3 | **Share of paid hours booked to jobs** | **94.3%** | **95.3%** |
| 4 | **Revenue against the re-based plan** | — | **$2.31M/month**, Jul–Dec |

Secondary, because he committed to them in the body: the **$1.38/paid-hr** rate improvement and the
**5 min/person/day** of returned time are just tiles 2 and 3 expressed the way he said them — show both
framings on hover or in the subtitle.

## 🚨 BASIS RULES — non-negotiable, all learned the hard way on 2026-07-28
Get any of these wrong and the dashboard will disagree with what the Board was told.

1. **Productivity = CFO revenue ÷ CLOCKED payroll hours.** Not production, not crew-sheet hours.
   - Revenue: **`SUM(dbo.Invoices.Total)`** × `Periods` on `PeriodID`, bucketed by **accounting period**
     (`Periods.StartDate`). Verified 2026-07-29: H1 = **$11,078,311.77** ✅.
   - 🚨 **CORRECTED 2026-07-29 — do NOT add `IsProForma=0 AND IsCredit=0`.** Both columns are **100% NULL**
     (0 of 1,501 H1 invoices have either set), so that filter returns **ZERO rows** and the tile would read
     $0. The earlier version of this rule was wrong. `StatusDefID` is 21 on every H1 invoice, so the
     `IN (21,100,22,23,148)` list is currently a no-op — keep it only if you also handle NULL.
   - Amount column is **`Total`**, not `NetTotal` ($10.86M, net of something) and not `InvoiceSubTotal`
     (all NULL). `SurchargeTotal` is $37,674 of the H1 figure; retention is $0.
   - Hours: `CrewMemberCalendars.TotalHours` joined `CalendarID → Calendars.CalDate`.
   - ⛔ **Never `CrewSheets.ActHours`** — it is the ESTIMATE (= `EstHours` on 98–99% of sheets)
     → [[crewsheet-acthours-is-the-estimate]].
   - ⛔ **Do NOT show the production-based $128.88 / $136.69 anywhere board-facing.** Different basis,
     different answer, and the Board has been given the revenue one.
2. **Anything binned from crew sheets uses `Calendars.CalDate` via `cs.CalendarID`, never
   `cs.WorkDate`** — `WorkDate` disagrees on ~47% of sheets → [[production-perf-future-dated-crewsheets]].
3. **Headcount = distinct `CrewMemberID` with `TotalHours > 0` on weekdays.** The 94-person roster and the
   ~83 who log hours in a month are different numbers; **91 refers to the weekday figure.**
4. **No year-over-year on clocked hours before Nov 2025** — timekeeping went live then
   → [[timekeeping-live-nov-2025]]. First clean YoY is Nov 2026.
5. **The current month is always incomplete** — invoicing runs 3–10 days past month end
   ([[june-invoicing-lag]]). Label partial months; never present one as a miss.
6. **Company level only.** Per-crew productivity is unreliable until crew-member assignments are cleaned
   → [[crew-assignment-drift]].

## Reference values to test against (H1 2026, must reproduce)
Q1 revenue $5,318,331 / 44,781 clocked hrs = **$118.76** · Q2 $5,904,101 / 47,195 = **$125.10** ·
H1 $11,222,433 / 91,976 = **$122.01** · Q2 job-booked share 44,499 / 47,195 = **94.3%** ·
~76 people per weekday at ~8.9 hrs.

## Build notes
- **Play only**, backup-first per [[repair-contract]]; render-verify the served page, not the SQL.
- Follow [[gsts-ui-spec]] + [[gsts-ui-style-guide]]; gate it with `dashboard-access-check.cfm`
  ([[dashboard-auth-gate]]) — this is COO-level content.
- Monthly grain with a quarter roll-up; each tile shows **actual · target · gap**, and a plain-language
  "on track / behind" that a director could read without explanation.
- Check `Workbench` for anywhere to store targets so they are editable without a redeploy (the
  `SalesGoal` pattern), rather than hard-coding 91 / $127.86 / 95.3%.

## ✅ LOCKED — design decisions (Skipper, 2026-07-29 02:20–02:50 UTC)
1. **Audience: the Skipper's cockpit, him only.** Blunt framing, data caveats visible on the page.
   Gate to UserID 9 — not the general dashboard list.
2. **Control panel, not a scoreboard, + the lever math.** Every tile recomputes **what it now takes to
   still land the number** as the quarter burns ("Sep–Dec now needs $2.35M/mo"; "you're at 79, you need
   12 more by Sept 30"). Plus the substitution line he gave the Board: **+$5 of rate removes ~465 hrs/mo**
   of hiring need; **one point of booked share ≈ 153 hrs/mo**.
3. **Tile 4 revenue = invoiced (board basis) as the headline, count-once accrual as a shadow line.**
   Partial months always labelled — invoicing lags 3–10 days ([[june-invoicing-lag]]).
4. **Targets are a monthly RAMP the Skipper edits** — stored in `Workbench`, no redeploy. Applies to all
   four commitments, not just headcount. (Derive a starting ramp from "anyone hired after September cannot
   meaningfully contribute to Q4" — all 15 landed by Sept 30 — then let him re-base it.)
5. **Productivity shows BOTH gaps explicitly** — "vs commitment $130: −$4.90" and "vs plan requirement
   $127.86: −$2.76". $130 never moves; $127.86 is derived from the re-based plan and will drift as hours
   land, so it must never silently become the scored target.
6. **CFO revenue is STORED, with the ERP delta monitored.** The board numerator is the Controller's income
   statement, *not* queryable from TRIM IT — ERP invoiced revenue runs **~1.3% low** (H1 $11,078,312 vs
   $11,222,433). A `Workbench` table holds the CFO monthly figure; until it is entered the month shows the
   ERP estimate labelled **"ERP est. — awaiting CFO"**, and a small indicator tracks ERP-vs-CFO drift.
7. **Tile 3 ships exactly as committed (94.3% → 95.3%) with a "why it moved" breakdown** splitting the
   change into *sheets closed out* vs *everything else*. **Mandatory** — the metric is blind to returned
   field time and improves when someone closes old sheets → [[pending-crewsheet-closeout-gap]]. Without the
   breakdown the dashboard would hand the Board a false causal story next quarter.

## Verified against play 2026-07-29 (all reproduce exactly)
`clocked Q2 = 47,195.05` · `Complete-sheet hrs = 44,498.72` · `production = $6,082,462` → **94.3%** ✅
Status codes: **`CrewSheets`: 5 = Complete · 39 = Pending.** `Invoices`: 21/22/23/100/148.

## ✅ BUILT 2026-07-29 — `Dashboard-BODCommitments.cfm`
Play: `https://play.greatscotttreeservice.com/GSTS/Dashboard-BODCommitments.cfm`
Source: `arbor-stack/production-dashboard/Dashboard-BODCommitments.cfm` · webroot
`D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\`

**Access proven, not assumed:** UserID **9** and **376** → 200. **340** and **209** (both hold V1.5
dashboard access) → **403**. No cookie → 302. Narrower than `dashboard-access-check.cfm` by design.

**Workbench tables created (all editable without a redeploy):**
- `BODCommitmentTargets` — 36 rows: `headcount` 79/84/91/91/91/91 · `productivity_commit` 130 ·
  `productivity_plan` 127.86 · `bookedshare` 94.5→95.3 · `revenue` $2.31M · `paidhours` 18,089.
- `BODCfoRevenue` — the Controller's figure, `GrainCode` M or Q. Seeded Q1 $5,318,331 / Q2 $5,904,101.
- `BODMetricSnapshot` — one capture per month per day, written on page load. **This is what makes the
  tile-3 decomposition evidence rather than assertion**; the split only becomes meaningful from the
  second capture onward (baseline captured 2026-07-28).

**Render-verified on the served page** (per [[repair-contract]]): reporting month Jun 2026 —
productivity **$119.08**, booked share **94.7%** (873 pending hrs = 5.2 pts, ceiling 99.9%),
revenue **$1,996,306**, required run-rate **$127.70/hr** and **$2.31M/mo** for the remaining six.

### Three CFML traps hit while building (all cost a render cycle)
1. `NumberFormat(v,"+9.9;-9.9")` → `IllegalNumberFormatArgumentException`. CF has no negative-clause
   mask form; build the sign by hand.
2. A `>` inside a `<cfset>` expression **closes the tag** → `Invalid CFML construct`. Use `GT`.
3. `dbo.Calendars` carries future-dated rows with stray crew hours — the "latest month" was **October
   with 3 people**. Cap the month list at the live month.

## ⏭️ Open
- ✅ **RESOLVED — the headcount basis.** Not a population filter (`IsFieldCrew` is a red herring: it yields
  ~29 people/weekday and is set on only 266 of 572 records). It was **the statistic and the window**:
  the board's "about 76" is the **H1 mean, 75.75**. The H1 **median** is **77.0**, Q2 is 78.1 mean, and
  **July's median weekday is 78.5**.
  🚨 **A mean is the wrong statistic here** — public holidays land as near-empty weekdays and fake a
  staffing collapse: 6 Jul had **18 people**, 3 Jul 60, April has a **3-person** day, February a 13.
  July's mean is 74.1 against a median of 78.5. The page now uses the **median** ("typical weekday" is
  literally a median) and shows the mean plus the quietest day underneath.
  ✅ **DECIDED (Skipper, 2026-07-29): the commitment is the 15 NET ADDITIONS, not the absolute 91.**
  Tile 1 is now a net-adds tracker. Baseline **frozen at 79** = the Q2 2026 **pooled** median weekday
  (64 weekdays) — measured exactly the way the tracking is measured. **15 adds therefore lands at 94, not
  91**; the 91 in the delivered plan came from the holiday-contaminated mean of 76.
  Targets: `headcount_baseline` = 79 (frozen) · `headcount_netadds` 0/7/15/15/15/15 · `headcount`
  79/86/94/94/94/94, front-loaded so all 15 land by the 30 Sep cut-off.
  Reads today: **−0.5 net adds** vs a July ramp of 0 (78.5 working, 15.5 to go, 7.8/month).
- Decide whether tile 4 should score an H1 month at all before the first H2 month closes (currently
  shows June against $2.31M with a banner explaining it is a starting line, not a result).
- The on-job rate is built on the honest denominator (~$137, not $155) — confirm he wants that shown
  given $136.69 is also the production-TPH figure that must stay off board material.

## 💵 Revenue target re-based 2026-07-29 — $2,310,000 → $2,346,424/month
The **$2.31M/month** in the delivered board plan was derived against the **$25.1M** team goal. The Skipper
then set **$25,300,976** as the authoritative FY2026 goal ([[revenue-goal-close]]). Off H1 actual of
**$11,222,433** that requires **$2,346,424/month** for Jul–Dec — **$36,424/month more**, $218,543 over the
half. `BODCommitmentTargets.revenue` updated; H2 total $14,078,544, landing at $25,300,977.
*The cockpit shows what it actually takes; the board doc's $2.31M is the superseded figure.*

## ⛔ DECIDED (Skipper, 2026-07-29): leave `dbo.SalesGoal` alone — it is the plan of record
`SalesGoal` FY2026 currently holds the **original approved plan**: H1 $12,250,976 + H2 $13,050,000
($2,175,000/mo) = **$25,300,976**. It already reconciles exactly, which is what `usp_DashboardGet`'s
`GOAL_RECONCILE` control requires.

**Re-basing H2 to the real requirement is not possible without destroying H1 variance history.** Proven in
a rolled-back transaction: setting H2 to $2,346,424 while leaving H1 makes the sum $26,329,520 and RGC
**fails closed again with err 50022**. The only shape that satisfies both is to overwrite the H1 goal rows
with H1 actuals — and that erases this:

| 2026 | Planned goal | Actual | Variance | % of goal |
|---|---|---|---|---|
| **Jan** | 2,534,354 | 1,617,531 | **−916,823** | **63.8%** |
| Feb | 1,829,430 | 1,699,714 | −129,716 | 92.9% |
| Mar | 1,831,427 | 1,686,601 | −144,826 | 92.1% |
| Apr | 2,117,795 | 2,179,282 | +61,487 | 102.9% |
| May | 1,950,446 | 1,898,879 | −51,567 | 97.4% |
| Jun | 1,987,524 | 1,996,306 | +8,782 | 100.4% |

**January alone is 89% of the H1 miss.** Overwrite the goal rows and every H1 month reads ~100%, and the
one month that actually explains the shortfall disappears from every dashboard that compares actual to
goal. ✅ **His call: "leave it."** `SalesGoal` stays the approved plan of record — one immutable budget, with the
live re-based requirement carried on this cockpit, which recomputes it from actuals every month anyway.
