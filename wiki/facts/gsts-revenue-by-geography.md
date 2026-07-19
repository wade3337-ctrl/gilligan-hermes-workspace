---
title: GSTS revenue by geography (county split)
type: fact
domain: work
tags: [financials, geography, revenue, county, oc, la, ie, growth-plan, canonical]
links: ["[[50m-growth-goal]]", "[[canonical-definition]]", "[[gstsreadonly-prod-dsn]]", "[[inland-empire-expansion]]"]
updated: 2026-07-19
---

# GSTS revenue by geography (county split)

**Pulled 2026-07-19** (play SQL, nightly prod mirror) using the **CFO-canonical revenue definition** ([[canonical-definition]]) grouped by service county. Service location path: `Projects.LocationID → Locations.ZipCodeID → ZipCodes.County`. Window = TTM period-month **Jul 2025–Jun 2026**. 100% of invoices mapped, zero nulls.

| Region | Revenue (TTM) | Share | Invoices |
| --- | --- | --- | --- |
| OC (Orange) | $18.12M | 85.1% | 2,711 |
| LA (Los Angeles) | $2.91M | 13.7% | 288 |
| IE (Riverside + San Bernardino) | $0.26M | 1.2% | 31 |
| **Total** | **$21.29M** | 100% | 3,030 |

- No San Diego / Ventura / other counties in the book — it's an OC/LA/IE company.
- **Key strategic fact:** LA is **already a ~$2.9M business** (warm-start, not greenfield); IE is **true greenfield** (~$0.3M). This reshaped the [[50m-growth-goal]] ramp → **LA leads early years** (warm base + 2028 Olympics), **IE back-loaded** greenfield build.
- TTM invoiced $21.29M vs $24M produced plan → ~$2.7M invoiced-vs-booked/below-plan gap.
- Method reusable: county rollup via `ZipCodes.County` is reliable (there's a real County column keyed by ZipCodeID). Query in `business-plan/GSTS-50M-Growth-Plan.md` §6.
