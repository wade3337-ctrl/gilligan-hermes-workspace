---
title: Crew-member assignments are stale — per-crew TPH does not reconcile
type: fact
domain: work
track: 1
tags: [trimit, crews, tph, data-quality, payroll, attribution]
applies: ["[[only-trustworthy-data]]"]
links: ["[[crewsheet-acthours-is-the-estimate]]", "[[timekeeping-live-nov-2025]]", "[[path-to-25m-2026]]"]
updated: 2026-07-29
---

# Crew-member assignments are stale

Found 2026-07-29 when the Skipper asked where a 5.7% gap between clocked payroll hours and crew-sheet
hours was going. **The answer is: nowhere. It is an attribution mismatch, not lost time.**

## The measurement (Q2 2026)
Clocked payroll hours **47,195** vs crew-sheet hours **44,499** — a gap of **2,696**. Broken down by crew,
**~2,100 (78%) sits in four crew records with ZERO active members**:

| Crew record | Crew status | Member records | Clocked hrs | On sheets |
|---|---|---|---|---|
| `POOL` | Active | 6 (0 active) | 582 | 0 |
| `Leocadio Cruz (1)` | Active | 1 (0 active) | 565 | 9 |
| `Noe  Guadarrama` | **Inactive** | **377** (0 active) | 485 | 0 |
| `DELETE` | **Inactive** | 44 (0 active) | 468 | 0 |

## Why it is attribution, not idle time
Clocked hours book against the crew on the person's **member record**; crew sheets book against the crew
they **actually worked with**. With 377 member records parked in an inactive bucket, those disagree often.

🔑 **The proof: several real crews show MORE sheet hours than clocked** — Luis Cuevas −219, Luis Valdovinos
−190, Martimiano Leana −141, Jose Antonio −130. **Hours cannot be negative.** That is the other end of the
same misattribution, and it is why the company-level totals nearly net out.

## Consequences
- ⚠️ **Per-crew TPH is not trustworthy** — the numerator and denominator can come from different crews.
  Relevant because crew performance is about to be used to manage a hiring plan → [[path-to-25m-2026]].
- ✅ **Company-level TPH is fine** — the misattribution nets out in aggregate.
- ❌ **Do NOT describe the gap as "hours that never reach a crew sheet" or as recoverable time.** I put
  exactly that in a draft board document; it implies idle time that does not exist. Cut on the Skipper's
  instruction.

## The fix (not started)
Clean up `dbo.CrewMembers.CrewNameID`: retire the `DELETE` and inactive-crew buckets, empty `POOL` of
non-working records, and re-point active staff at the crew they actually work with. Until then, treat
per-crew productivity as indicative only.
