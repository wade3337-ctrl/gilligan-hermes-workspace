---
title: North yard 45→40 hour cut — revenue-impact analysis (COMPLETE)
type: reference
domain: work-gsts
status: complete
tags: [gsts, production, tph, crew-hours, revenue, labor-cost, seasonality, schedule-board]
links: ["[[gsts-field-labor-rate]]", "[[trimit-stack-and-tph]]"]
updated: 2026-07-08
---

# North yard 45→40h cut — revenue impact (COMPLETE 2026-07-08)

**Question (Skipper):** Ops managers want to cut North-yard crews from 45+ to 40 h/week because they're worried about **not enough work on the schedule**. How does that affect projected revenue?

## Bottom line (the answer)
- **Cutting to 40 is essentially cutting *back to budget*, not below it.** The 2026 budget is built on **40-hour weeks** (2,080 reg hrs/person) with only **~$219K OT all year** (~3.5% of a $6.3M direct-labor plan = minimal). Crews working 45+ now are running **unbudgeted overtime overage.**
- **Summer (now):** minimal revenue downside — North's book is a lean **~3 weeks**, which fits inside 40-hour weeks. Cutting saves the OT: **~$9K/week ≈ ~$90K over a ~10-week summer trough** (North).
- **The one guardrail:** **restore hours (45+) for September's pre-holiday surge.** Fall runs **12–16% hotter** than the summer trough (Oct is often the year's peak) and it's *deadline* work (before the holidays) — that's the only window where 40h would cost real revenue.
- **Net for the ops managers:** cut to 40 through the summer trough (banks OT, back on budget); step back to 45+ for the fall push. It's a *seasonal lever*, not a permanent cut.

## The numbers (all cross-sourced)
**Production rate (North, clean-tagged 2026 window):**
- ~$3.22M produced in ~14 wks → **~$232K/week**; **TPH $127** (target $130); ~**1,830 crew field-hrs/week**.
- Monthly climbed Feb→Jun ($302K→**$1.10M peak Jun**), Jul on pace — North is at seasonal peak *now*.

**Loaded field-labor cost (validated two ways):**
- Dec-2025 financials "**DL Cost per Hour**" (groundsmen/trimmers/drivers) = **$35.61** (2023 $39.66 → 2024 $36.45 → 2025 $35.61).
- 2026 payroll budget fully-loaded = **$36.57/hr**. → **use ~$36/hr loaded.** (OT hour ≈ 1.5× base + burden ≈ ~$46–50.)

**Crews (from the Schedule Board's own logic):**
- Board = `ScheduleBoard$Frame.cfm`; blue/red split = **`CrewNames.SiteAssigned` (1=North, 2=South, 3=both)**.
- **North 16 crews · South 14 · +4 flex.** Company field DL headcount = **83** (29 Sr Trimmer, 26 Trimmer, 25 Groundsman, 3 Groundsman/Driver; base $22–$36.55, avg $27.45). North ≈ ~40 field people.

**Forward book (open Active+InProcess WOs):** North ~112 jobs / **~5,477 sched hrs / ~$1.15M** ≈ ~3 weeks; South ~161 jobs / ~4,827 hrs / ~$1.43M. Roughly comparable — North isn't starkly thinner than South.

**Seasonality (2024–25 company production, `dbo.Calendars`):** summer trough (2025 May–Aug ~$1.6–1.7M/mo) → **Sept–Oct pickup** (2024 Oct $2.04M peak; 2025 Oct $1.90M). Field hours rise ~12% into fall.

## Data mechanics / gotchas (for reproduction)
- **North/South = `WorkOrders.YardTypeID` (1/2)** for completed production; **crew→yard = `CrewNames.SiteAssigned`** for the board.
- **Yard tag only exists from 2026** (2025 = 0% tagged, 2026 Q2 88%, Q3 100%) → **use a 2026 window**, NOT trailing-12-mo (that was 66% "Unset" = the tag not existing yet).
- **`YardHours` + `CrewAssignments` are stale/archived** (end 2025-10 / 2008-09) → not live sources. Use WorkOrders + Calendars.
- **TPH = SUM(CompletedDollars)/SUM(CompletedHours)**, crew-labor only (`CompletedHours>0`), status Complete. Playbook: `~/trimit-knowledge/query-playbook/production-tph.md`.
- Source files (Skipper-provided, in `~/.openclaw/media/inbound/`): *December_2025_Financials* (DL cost/hr) + *2026_Budget_Fixed_Payroll_Forecast* (per-person wages, 40h/2080 basis).
