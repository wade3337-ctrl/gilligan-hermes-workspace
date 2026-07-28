---
title: 🚨 CrewSheets.ActHours is the ESTIMATE — TPH is measured on scheduled hours, not labor
type: fact
domain: work
track: 1
tags: [trimit, tph, data-quality, crew-sheets, payroll, metric-basis, CRITICAL]
applies: ["[[only-trustworthy-data]]", "[[dashboard-metric-standards]]"]
links: ["[[trimit-stack-and-tph]]", "[[trimit-db-gotchas]]", "[[path-to-25m-2026]]", "[[production-perf-future-dated-crewsheets]]"]
updated: 2026-07-28
---

# `CrewSheets.ActHours` is the estimate, not recorded labor

Found 2026-07-28 while reconciling job-sheet hours to payroll, after the Skipper pointed out that the
Controller's report and the daily schedule both showed ~80 crew a day.

## The measurement
**`ActHours = EstHours` on 98–99% of every month's crew sheets:**

| Month 2026 | Sheets | ActHours = EstHours | |
|---|---|---|---|
| Jan | 633 | 622 | **98.3%** |
| Feb | 609 | 604 | **99.2%** |
| Mar | 883 | 875 | **99.1%** |
| Apr | 857 | 841 | **98.1%** |
| May | 698 | 684 | **98.0%** |
| Jun | 675 | 663 | **98.2%** |

**The "actual" hours field is the scheduled figure carried over. Real labor time is not captured on the
crew sheet.** Dollars *are* genuinely actualised — `ActValue = EstValue` on only ~20% — so the sheet
records what was earned but not what it took.

## Where real labor hours live
**`dbo.CrewMemberCalendars`** — per crew member, per day: `TotalHours`, plus `YardHours`,
`VacationHours`, `HolidayHours`, `SickHours`, `OTHours`, `TotalCost`. Join `CalendarID → dbo.Calendars.CalDate`.
*(`RegularHours`/`OTHours`/`YardHours` are NULL in practice — use `TotalHours`.)*

## What it does to TPH
TPH is `production $ ÷ CrewSheets.ActHours`, so **TPH is revenue per *scheduled* hour, not per labor hour.**
Job-sheet hours run about **90% of paid hours**, and the gap swings hard month to month:

| 2026 | Reported TPH | TPH on paid hours | sheet ÷ paid |
|---|---|---|---|
| Jan | $122.57 | $105.52 | 86% |
| Feb | $126.98 | $102.31 | 81% |
| Mar | $126.73 | $132.27 | **104%** |
| Apr | $137.71 | $144.32 | **105%** |
| May | $133.87 | $120.64 | 90% |
| Jun | $131.87 | **$96.19** | **73%** |
| **H1** | **$130.19** | **$116.87** | **90%** |

**The reported metric overstates revenue-per-labor-hour by ~11%.** In March and April scheduled hours
*exceeded* paid hours (estimates were generous); in June they fell far short.

⚠️ **This does NOT make TPH useless or the trend false.** The basis is consistent year over year, so the
improvement is real on either measure: **reported +6.5% (122.18 → 130.19), paid-hour basis +3.7%
(112.70 → 116.87).** But "$130 TPH" means *revenue per planned crew-hour*, and should never be described
to anyone as labor efficiency without that qualifier.

**Rule: plan and price on TPH if you like — but size CAPACITY and HEADCOUNT on `CrewMemberCalendars`,
never on crew-sheet hours.** → [[path-to-25m-2026]]

## ❌ It also invalidates one of my own findings
In [[production-perf-future-dated-crewsheets]] I offered *"`ActHours = EstHours` on 144/148 (97%) versus
20% for real June work"* as evidence the future-dated sheets were fabricated. **That comparison was
invalid** — I compared future-sheet **hours** against past-sheet **dollars**. The correct baseline is
**98.2% for June hours**, so 97% is completely normal and proves nothing.
**The finding still stands on its real evidence** (741 future sheets correctly `Pending`/$0 versus 148
flipped to `Complete`+checked-in), but that one supporting line has been struck.
*Lesson: compare like with like — same field, same population.*

## Also worth knowing
- **Roster ≠ working headcount:** 94 on the field roster · ~83 log hours in a month · **~76 work a typical
  weekday** at ~8.9 hrs each. The third is the one that governs capacity.
- **Paid hours are flat YoY (91,736 → 91,976) on ~8 fewer people** — the crew absorbed the loss at
  168 → 184 hrs/person/month.
- Crew-sheet entry lag is small (7–15 sheets/month unentered), so lag does *not* explain the gap — the
  estimate basis does.
