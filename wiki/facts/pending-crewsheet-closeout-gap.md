---
title: 🚨 The 5.7% "hours not booked to jobs" is INTERNAL time (meetings/yard/OJT/modified duty)
type: fact
domain: work
track: 1
tags: [trimit, crew-sheets, tph, data-quality, metric-basis, board, CRITICAL]
applies: ["[[only-trustworthy-data]]", "[[dashboard-metric-standards]]"]
links: ["[[crewsheet-acthours-is-the-estimate]]", "[[crew-assignment-drift]]", "[[bod-commitment-dashboard]]", "[[path-to-25m-2026]]"]
updated: 2026-07-29
---

# The job-booked gap is INTERNAL non-productive time

> ⚠️ **REVISED AGAIN 2026-07-29 (third pass) — this note's original conclusion was wrong.**
> The gap is **not** unclosed paperwork. **Q2: of 2,640 unbooked hours, 2,526 (96%) are INTERNAL work
> orders** — Safety Training/Meetings, Modified Duty, On-the-Job Training, Yard Hours — booked to the
> `PRODUCTION` crew record (`CrewNameID 38`, 1 member record, 0 active). They never reach Complete
> **because there is nothing to bill**. Only **115 Q2 hours** are genuinely unclosed real-job sheets.
> H1: **4,910 internal vs 313 real-job** pending hours.
>
> **This is good news and it inverts the recommendation.** The metric is not measuring sloppiness — it is
> measuring exactly the thing the plan committed to attack ("yard time, travel, standby and equipment
> downtime"), and the categories are individually trackable month by month:
> *H1 monthly avg — Safety/Meetings 296 · OJT 257 · Modified Duty 168 · Yard 99.*
> The safety-meeting change should land in the Safety/Meetings row (~59 crew-hrs/mo estimated).
> Do **not** claim the effect until several closed months move together.
> Now shown on [[bod-commitment-dashboard]] as a monthly category table.
>
> 🔑 **Why I got this wrong twice:** I decomposed by *crew* (→ "attribution drift"), then by *status*
> (→ "unclosed paperwork"), and stopped each time the first plausible story appeared. The answer needed a
> third axis — **what the work order IS**. My own internal-category classifier already existed in
> `Dashboard-RevenuePerformance.cfm`; I had even queried it, but filtered `StatusDefID=5` and got zero
> internal hours, which I read as "the categories are unused" instead of "they are all in the other
> status." **A filter that returns zero is a question, not an answer.**


Found 2026-07-29 while specifying [[bod-commitment-dashboard]], verifying the basis of the metric the
Skipper committed to the Board: *"share of paid hours booked to jobs, from 94.3% toward 95.3%."*

## The measurement (Q2 2026, play)
Clocked payroll **47,195.05** hrs vs crew-sheet hours on **Complete** sheets **44,498.72** → the committed
**94.3%**. The gap is **2,696 hrs**.

**Q2 crew sheets still in `StatusDefID = 39` (Pending) hold 2,640.69 hrs across 959 sheets — 98% of the
gap in a single bucket.** And they are not cancelled work: **902 of 959 are `IsCheckedIn = 1`, 905 have
`HoursEntered = 1`.** The crews went out, worked, and logged hours. Nobody marked the sheet Complete.

`StatusDefID`: **5 = CrewSheets/Complete · 39 = CrewSheets/Pending** (`dbo.StatusDefs`, Scope='CrewSheets').

## It is structural, not a backlog
Pending hours by month 2026 — and **100% checked in every month**:

| | Jan | Feb | Mar | Apr | May | Jun | Jul (open) |
|---|---|---|---|---|---|---|---|
| Complete hrs | 14,625 | 12,841 | 14,464 | 14,816 | 13,804 | 15,879 | 8,382 |
| Pending hrs | 694 | 945 | 944 | 916 | 851 | 873 | 3,763 |

A steady ~5–6% every closed month. A backlog would grow; this does not. **Some recurring class of sheet
never gets closed** — not yet identified (open thread). July's 3,763 is just the open month.

## What it does to the metric
1. ⚠️ **The metric cannot detect returned field time.** The numerator is `ActHours`, which is the estimate
   (= `EstHours` on 98–99% of sheets → [[crewsheet-acthours-is-the-estimate]]). Also checked and ruled out
   as independent sources: **`CompletedHours` is a copy of `ActHours`** (Q2: 44,498.60 vs 44,498.72) and
   **`ScheduledHours` is unused** (1 populated row in 3,305). If a crew returns 5 min/person/day to the
   job, this number does not move.
2. ⚠️ **It will improve if somebody simply closes out old sheets** — a paperwork action, reported as
   operational discipline. This is the trap the dashboard has to defuse.
3. ❌ **No clocked-side breakdown exists to use instead:** `YardHours`, `OTHours`, `RegularHours` are
   **100% NULL** in `CrewMemberCalendars` (Q2: 0 non-null rows of 8,270). `VacationHours`/`HolidayHours`
   are 0. Only `SickHours` carries data (632 hrs).

## Correction to a previous finding
[[crew-assignment-drift]] attributes this same 2,696-hr gap to stale `CrewMembers.CrewNameID` assignments.
**That explanation is at best partial** — 98% of the gap sits in the Pending bucket. Crew-assignment drift
is real and still makes *per-crew* TPH untrustworthy, but it is not the company-level gap.

## Decided (Skipper, 2026-07-29)
The BOD dashboard reports **94.3% → 95.3% exactly as committed** (board consistency is non-negotiable),
with a **"why it moved" breakdown** underneath splitting the change into *sheets closed out* vs
*everything else*, so the cause can never be misreported. → [[bod-commitment-dashboard]]

## Open thread
`TotalClimberHours + TotalGroundHours` = **50,450 hrs** for Q2 Complete sheets — *more* than both sheet
hours (44,499) and clocked hours (47,195), so it is independently entered rather than derived. Unknown
what it counts. It is the only remaining candidate for a real labor-time measure; worth a look before
anyone promises a true non-productive-time metric.
