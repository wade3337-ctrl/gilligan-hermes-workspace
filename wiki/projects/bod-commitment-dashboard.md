---
title: BOD Commitment Dashboard — track what the Skipper told the Board he would do
type: project
domain: work
track: 1
status: 🔵 NEXT — spec written 2026-07-29, not started
tags: [dashboard, board, kpi, trimit, play, q3-2026]
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[dashboard-metric-standards]]", "[[only-trustworthy-data]]", "[[dashboard-auth-gate]]"]
links: ["[[path-to-25m-2026]]", "[[crewsheet-acthours-is-the-estimate]]", "[[timekeeping-live-nov-2025]]", "[[crew-assignment-drift]]", "[[production-perf-future-dated-crewsheets]]"]
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
