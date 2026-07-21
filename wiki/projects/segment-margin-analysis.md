---
title: Segment margin analysis — municipal vs HOA vs commercial
type: project
domain: work
track: 1
status: active — revenue/hours/wage-premium half DONE from TRIM IT; cost half needs Steve (payroll/accounting)
tags: [pricing, margin, tph, municipal, hoa, commercial, prevailing-wage, dir, segment, efficiency]
applies: ["[[only-trustworthy-data]]", "[[trimit-stack-and-tph]]", "[[gsts-field-labor-rate]]"]
links: ["[[50m-growth-goal]]", "[[pricing-guide-bid-prefill]]", "[[munibot-smart-bidding-tool]]"]
updated: 2026-07-21
---

# Segment margin analysis — municipal vs HOA vs commercial

**Origin (Skipper, 2026-07-21):** Herman/MuniBot pricing work surfaced that TRIM IT holds two price worlds
(municipal vs commercial/HOA). Skipper's hypothesis: **municipal is "done at a lower rate."** Goal: understand the
efficiency/margin difference, then bake segment-aware logic into the pricing tools. Analyze first, then build.

## How segments live in TRIM IT
- **`Projects.ProjectTypeID` → `dbo.ProjectType`** = the clean 4-way classifier: **1 Municipal–Cities · 2 Municipal–Other · 3 HOA · 4 Commercial**. Use this.
- Also `dbo.ProjectGroupDefs`: **11 Municipal Contracts (TPHTarget 75)** · **14 Commercial Contracts (TPHTarget 70)** — the two "measured" contract groups (narrower population than ProjectType).
- `dbo.CompanyMarkets` (21 cats: HOA, Comm/Industrial, Cities…) + `dbo.GeoMarkets` (geo × market, has HTDTPH) for finer cuts.
- Data path: `~/herman-gateway/trimit-ro-query.sh` (HermanRO read-only, play GSTS = nightly prod mirror).

## Findings (TTM, pulled 2026-07-21)
1. **TPH (rev/crew-hour) is equalized ~$123 across ALL segments** — HOA $124.9 · Muni-Cities $124.4 · Muni-Other $123.6 · Commercial $122.5. GSTS prices/schedules to a target rev/hr regardless of segment.
2. **Price-per-tree varies wildly** — Muni-Other $236 · HOA $146 · Muni-Cities $104 · Commercial $97 — explained by **throughput × tree size**, NOT margin. Muni-Cities = cheap-per-tree but fast route work (~1.4 trees/hr); HOA = premium-per-tree but slower (~0.9). Both land at ~$123 TPH. *(Corrects an early cut using the narrow "Commercial Contracts" group that showed Commercial $188/tree.)*
3. **Prevailing wage is SMALL, not 2×.** Municipal tree work is bid under the **DIR Tree Maintenance determination (total ~$33–37/hr)**, NOT the construction-Laborer determination ($75/hr all-in — my first, wrong pull). From the Skipper's `Pay_Rates` sheet (87 field staff): avg GSTS pay $28.88 vs DIR total $34.59 → **avg municipal top-up ~$5.80/hr/worker (~20%); 83/87 below DIR total.** By role: Groundsperson +$6.88 · Tree Trimmer +$5.77 · Sr Tree Trimmer +$4.73.
4. **TRIM IT holds NO job cost** — `CrewSheets.DirectCostTotalPrice` empty on all ~11.6k rows. Realized margin needs payroll/accounting (Steve), not TRIM IT.
5. **Execution efficiency is FINE — not the problem.** Actual-vs-target hours: Commercial +3.9% · HOA +2.0% · Muni-Other +1.6% · **Muni-Cities +0.8% (tightest)**. Municipal crews hit estimates best. Non-productive time (traffic control, inspections) sits as **off-crew-sheet overhead**, not billable-hour overrun.
6. **Fixed-price erosion is VISIBLE (the sawtooth).** TPH by year: HOA $92(2021)→$122(2025), Commercial $92→$125 (both +~33%, repriced ~annually). **Municipal–Cities $96→$119(2023) then FLAT $117→$116 (2023–25)** while private escalated ~20% past it → muni fell **~$6–9/hr behind** by 2025. 2026 partial jumps to $130 = **renewal reset**. Multi-year lock erodes mid-contract, resets at renewal.

## Synthesis (the answer)
Skipper's "lower rate" = **NOT crew inefficiency** (TPH equal, muni hits targets best). It's **pricing lock + cost structure**:
- **Revenue:** municipal loses ~$6–9/hr to fixed-price erosion mid-contract (equal only just after renewal).
- **Cost:** municipal carries ~$6/hr wage top-up + off-book compliance (certified payroll, DIR reg, apprenticeship, traffic crews).
- **Combined margin gap ≈ ~$6/hr right after renewal → ~$12/hr mid-contract.** Municipal's value = predictable base-load volume/cash, not margin.

## Strategic use (→ [[50m-growth-goal]])
- **Escalators on municipal renewals** to kill the erosion (cross-check vs RFP renewal-cap language — the Irvine trap; see [[munibot-smart-bidding-tool]]).
- **Weight growth toward HOA/commercial** — more margin per crew-hour → more AGP per hour.
- Treat municipal as base-load volume, not the margin engine.
- Feeds segment-aware pricing into [[pricing-guide-bid-prefill]] + [[munibot-smart-bidding-tool]] (the "then build" half).

## Open / next
- **(b) Cost half from Steve:** loaded labor by segment + municipal-specific overhead → close the realized-margin number (same per-crew unit economics the growth plan needs).
- Confirm **which DIR determination** each city contract specifies (Tree Maintenance vs Laborer) — changes the top-up.
- Then build: segment-aware margin logic in the pricing tools.

## Sources
- DIR Tree Maintenance determination SC-102-X (2024-1) · DIR Laborer SC-23-102-2 (2026-1, Group 2 tree climber $75.64 — the wrong one for muni tree trimming).
- Skipper's `Pay_Rates` sheet (media/inbound, 2026-07-21) — GSTS base vs DIR total reconciliation.
