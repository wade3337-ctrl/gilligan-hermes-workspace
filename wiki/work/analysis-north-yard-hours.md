---
title: North yard 45→40 hour cut — revenue-impact analysis (PAUSED, to discuss)
type: analysis
domain: work-gsts
status: paused
tags: [gsts, production, tph, crew-hours, revenue, municipal-note-no]
updated: 2026-07-07
---

# North yard 45→40h cut — revenue impact (PAUSED 2026-07-07)

**Question (Skipper):** Production wants to cut North-yard crews from 45+ h/week to 40. How does that affect projected revenue?

## The model (the framework we agreed on)
- Revenue engine = **TPH = $ produced per crew FIELD-hour** (target $130). Cutting hours costs revenue only if those hours produce billable work you can't make up.
- **Two regimes decide everything:**
  - **Backlog-constrained** (always more work than hours) → production ∝ hours → cut ~11% of hours (45→40) ≈ lose ~11% of that crew's production.
  - **Route/demand-constrained** (crews finish scheduled work; the extra hours are drive-back/cleanup/slack) → cutting the OT costs ~$0 revenue, mostly **saves OT pay**.
- The 5 cut hours are **overtime @ 1.5× pay**. So the COO-level answer is the **NET**:
  **Net = (OT pay saved) − (contribution margin on any production given up).**
- OT hours are often somewhat LESS productive (end-of-day) → real revenue hit usually < the raw hour %.

## First-cut data (TRIM IT, last 12 months, completed WOs, crew-labor only)
- **North yard = `WorkOrders.YardTypeID = 1`** (South = 2). YardTypes: 1 North, 2 South.
- North tagged: **$4.35M / ~34,800 crew-hrs → TPH $125** (South: $3.14M / 22,119h / TPH $142).
- ⚠️ **DATA CAVEAT — attribution gap:** **66% of completed WOs have NO yard tag** ("Unset" = $12.1M / 99,778h). North's true output is **understated**; some of that $12.1M is North. **Do not quote a revenue figure until this is fixed.**
- `YardHours` table (per-crew RegularHours/OTHours/DTHours) is **STALE** — ends 2025-10-31. Live hours source TBD (Calendars RegularHours/OTHours, or payroll).

## Resume checklist (todo)
1. **Fix North-yard attribution** — clean crew→yard mapping OR recent-window coverage so North production is complete (Task: "Clean North-yard production attribution").
2. **Get live North OT hours** — #crews, hrs/crew/week, OT hrs/week (YardHours dead → find live source).
3. **Build the model** — revenue give-up range (backlog→demand) + OT cost-savings offset + break-even; present a defensible $ range.
4. **OPEN QUESTION for Skipper:** are North crews backlog-constrained or route-constrained? (He'll give the operational read; it's the model's main lever.)

Key playbook: `~/trimit-knowledge/query-playbook/production-tph.md` (TPH = SUM(CompletedDollars)/SUM(CompletedHours); `dbo.Calendars` = authoritative day rollup).
