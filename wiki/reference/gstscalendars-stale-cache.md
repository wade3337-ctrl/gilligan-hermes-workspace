---
title: GSTSCalendars — the accounting day-total cache that only refreshes when a human clicks "Update"
type: reference
domain: work
created: 2026-07-27
updated: 2026-07-27
tags: [trimit, sql, cache, revenue, reporting, gotcha]
applies: ["[[trimit-db-gotchas]]", "[[canonical-definition]]", "[[only-trustworthy-data]]"]
links: ["[[rc-02-revenue-performance]]", "[[dashboard-metric-standards]]", "[[data-freshness-contract]]"]
---

# `GSTSCalendars` is a stale cache, not a live total

**The daily production report accounting reads (`Exec-Performance-Day.cfm`, and the `Profile$Performed$Day*`
family) does NOT compute revenue. It reads a cached per-day rollup table: `dbo.GSTSCalendars.TotalPrice` /
`.TotalHours`.** One row per calendar day.

## How the cache gets written
`dbo.UpdateGSTSCalendars$Figures$CalendarID @ZCalendarID` recomputes ONE day from line-item detail:

- **`TotalPrice`** = `SUM(InventoryAssignments.TotalPrice)` for work orders whose `CallInModels.IsDynamic = 1`,
  **UNION** `SUM(CrewSlopes.CompletedDollars)` for `IsDynamic = 0` — both gated on
  `CrewSheets.HoursEntered = 1 AND CrewSheets.IsCheckedIn = 1`.
- **`TotalHours`** = `SUM(CrewAssignments.ActHours)`, same posted gate.
- `TPH` = TotalPrice / TotalHours.

## ⚠️ The trap — nothing refreshes it automatically
The proc is invoked **only** via `CodeUpdateCalendarFigures.cfm?ZCalendarID=…`, which is wired to a **manual
"Update" link on the day-detail page** (`Profile$Performed$Day.cfm` line ~148, plus the `Exec$Performed$Day$Frame`
/ `Synch$Performed$Day` variants). **No SQL Agent job and no trigger recomputes it.**

So a day's number is correct **only if a human clicked "Update" on that day *after* the last crew-sheet edit.**
Edit a crew sheet later and the report silently keeps the old number — **forever**. The month-total page just
sums the cache; it never refreshes it.

## Proof (2026-07-27, July 2026 / PeriodID 334)
| | Dollars |
|---|---|
| Rollup formula **recomputed live** | **$1,618,777.25** |
| `GSTSCalendars` **cached** (what the report shows) | **$1,601,495.86** |
| **Cache stale by** | **$17,281.39** |

Stale on **9 days**, drifting **both directions**: 7/14 **+$6,291.47** · 7/25 +$4,939.25 · 7/16 +$3,085.66 ·
7/22 +$2,282.11 · 7/17 +$745 · 7/23 +$69.43 · 7/21 +$64.08 · 7/08 +$53.39 · **7/06 −$249.00** (cache *higher*
than reality — work was reduced after the click).

**The Revenue Performance dashboard is NOT wrong.** It sums `CrewSheets.CompletedDollars` live, which reconciles
to the rollup formula within **$27** across the whole month. The ~$12.4K gap the Skipper spotted 2026-07-27 was
the cache being behind on 8 days (7/25 had since been clicked, which is why his live gap was $12,369.15 rather
than the full $17,281.39).

## Ruled out (don't re-investigate)
- **Not the posted gate** — all $1,618,804.26 sits on sheets with `HoursEntered=1 AND IsCheckedIn=1`; the 258
  unposted July sheets carry **$0.00**.
- **Not `ActValue` vs `CompletedDollars`** — they differ by 2¢ across July's 378 municipal sheets.
- **Not the report's filters** (`CrewNames.IsInternal=0`, crew status Active, non-Inactive sheets,
  ProjectGroup 11 split) — each removes **$0**; the two UNION branches recombine to the exact same total.
- **Not stale data on my side** — my analysis restore reproduces the live dashboard number to the cent.

## Latent bug (flagged, unverified)
The `TotalPrice` rollup uses **`UNION`, not `UNION ALL`**, over `(WorkOrderID, SUM)` rows. Identical
(WorkOrderID, amount) pairs across the two branches would be **silently de-duplicated**, under-counting.
The branches are mutually exclusive on `IsDynamic`, so it likely never fires — but it is the wrong operator.

## What to do
Refreshing a day = clicking "Update" on that day's page (or executing the proc per CalendarID). A scheduled
nightly sweep over recent days would end the whole class of problem. **Do not "fix" the dashboard to match the
report — the report is the one that's behind.**
