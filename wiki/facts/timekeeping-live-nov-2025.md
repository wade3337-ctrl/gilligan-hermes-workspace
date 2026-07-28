---
title: ⏱️ Electronic timekeeping went live Nov 2025 — do NOT compare field hours across that line
type: fact
domain: work
track: 1
tags: [trimit, timekeeping, hours, data-quality, metric-basis, payroll, CRITICAL]
applies: ["[[only-trustworthy-data]]", "[[dashboard-metric-standards]]"]
links: ["[[crewsheet-acthours-is-the-estimate]]", "[[path-to-25m-2026]]", "[[trimit-stack-and-tph]]"]
updated: 2026-07-28
---

# Electronic timekeeping went live ~Nov 2025

The Skipper: *"we have an electronic time keeping system built in that we started using in Dec. 25."*
Confirmed in the data, and the transition is sharp and datable.

## The evidence — granularity of `CrewMemberCalendars.TotalHours`
| Month | Distinct hour values | % whole numbers | Avg hrs |
|---|---|---|---|
| Jun 2025 | 20 | **87.9%** | 8.80 |
| Jul 2025 | 24 | 87.1% | 8.39 |
| Aug 2025 | 35 | 79.2% | 8.01 |
| Sep 2025 | 46 | 74.6% | 8.03 |
| Oct 2025 | 121 | 64.0% | 8.00 |
| **Nov 2025** | **233** | **5.8%** | 8.26 |
| Dec 2025 | 283 | 3.3% | 8.59 |
| Jan–Jun 2026 | 219–259 | 2.9–7.0% | 8.88–9.04 |

**Before Nov 2025: hand-entered round numbers (~8 or 9 hours). From Nov 2025: clocked time, minute-level.**
October is the transition month.

## 🚨 The consequence
**Any year-over-year comparison of field hours that crosses Nov 2025 compares two different measurement
systems.** The apparent rise in hours per person (168 → 184 per month, H1 2025 → H1 2026) is **not
demonstrably real** — clocked time naturally captures more than a rounded 8-hour entry.
**I made exactly this error** and had to pull it from the Q2 board report.

**What remains valid:**
- ✅ Anything computed **inside** the clocked era (Nov 2025 onward) — including the H1 2026 capacity
  analysis, the ~76-per-weekday headcount, and the **+23 field staff** requirement in [[path-to-25m-2026]].
- ✅ The **~$117 revenue-per-attendance-hour** figure for H1 2026 — genuine clocked hours, so it needs no
  external validation after all.
- ✅ Non-revenue share 23.0% → 17.0%, because that is measured on **crew-sheet scheduled hours**
  ([[crewsheet-acthours-is-the-estimate]]), a basis unaffected by the timekeeping change.
- ⚠️ **Headcount** counts (≈91 → ≈83 people/month) are probably robust — a person either has rows or does
  not — but treat with mild caution across the boundary.
- ❌ **Invalid:** hours-per-person YoY · total paid hours YoY · any attendance-basis TPH comparison to 2025.

## Practical rules
1. **Field-hours trending starts Nov 2025.** A clean prior-year comparison first becomes possible in
   **Nov 2026**.
2. For 2026-only work, `CrewMemberCalendars.TotalHours` is trustworthy clocked time (~1,700 person-day
   rows/month, ~76 people/weekday at ~9.0 hrs).
3. **`TotalCost`, `ScheduledTotalHours`, `RegularHours`, `OTHours` and `YardHours` are all NULL** — only
   `TotalHours` is populated. So labor *cost* cannot be derived here; hours only.
4. Sanity check for whether an hours field is clocked or entered: **count distinct values and the share of
   whole numbers.** Clocked ≈ 200+ distinct values, <10% whole. Entered ≈ <50 values, >60% whole.
