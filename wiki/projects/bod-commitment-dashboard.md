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
   - Revenue: `Invoices` × `Periods` on `PeriodID`, `StatusDefID IN (21,100,22,23,148)`,
     `IsProForma=0`, `IsCredit=0`, bucketed by **accounting period** (`Periods.StartDate`).
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

## Open before building
- Does he want the **$130 target and the $127.86 plan requirement** shown as two lines, or one with the
  gap called out? (He asked for both in the report.)
- Should tile 4 track **CFO revenue** (matches the Board) or **our accrual-adjusted actual** (matches the
  count-once ledger)? They differ; the Board saw CFO revenue.
