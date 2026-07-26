# GSTS Capacity & Growth Model
**v0.1 — 2026-07-26. BASELINE ONLY: measured today, ramp scaffolded, assumptions flagged.**
**Purpose:** answer *"how do you physically deliver $50M?"* with a build-out plan — crews, people, yards, equipment — not a revenue curve.
**Discipline (same as the decks):** every figure is either **📏 MEASURED** from live data or **🔧 ASSUMPTION** stated as such. Every ratio is **per unit** so it scales without re-deriving.
**⚠️ BLACK — deal-aware. Never surface to Aspen / Herman / MuniBot / the team.**

---

## 1 — The production baseline (📏 all measured, trailing 12 months to 2026-07-22)

| | |
|---|---|
| **Core crews** (100+ working days) | **25** |
| Field hours | **174,686** |
| Production | **$21,539,106** |
| **Blended TPH** (production ÷ all paid hours) | **$123.30** |
| Average crew size on the sheet | **2.9** |
| Field direct-labor headcount (2026 payroll) | **83** |

**Why 25 and not 31.** 31 crew IDs recorded activity; 25 worked 100+ days and produced **98.5%** of everything. The other six are fragments — the model is built on the 25.

### The four ratios everything else derives from
| Ratio | Value | Basis |
|---|---|---|
| **Production per crew per year** | **$861,600** | 📏 measured |
| **Field hours per crew per year** | **6,990** | 📏 measured |
| **Crews per $1M of production** | **1.16** | 📏 derived |
| **Field employees per crew** | **3.3** | 📏 83 payroll ÷ 25 crews |

---

## 2 — Where the capacity physically sits (📏 measured)

Crews carry a `SiteAssigned` value of 1, 2 or 3 — **three yards**:

| Yard | Crews | Field hours | Production | Blended TPH |
|---|---|---|---|---|
| **Site 2** | 10 | 86,030 | **$11,340,853** | **$132** |
| **Site 1** | 12 | 77,441 | **$9,068,291** | **$117** |
| **Site 3** | 3 | 11,215 | **$1,129,962** | **$101** |
| **Total** | **25** | **174,686** | **$21,539,106** | **$123** |

- **Today's density: 8.3 crews per yard.** That is the number that decides how many yards $50M needs.
- **Site 2 out-produces Site 1 with two fewer crews** — $11.3M on 10 crews vs $9.1M on 12, and 15 TPH better. Worth understanding before replicating either as the template for a fourth yard.
- ❓ **Which physical yard each site ID is, and how many crews each can actually hold, is not in the database.** See §7.

## 3 — Where the revenue comes from (📏 measured, → [[gsts-revenue-by-geography]])

| Region | TTM revenue | Share |
|---|---|---|
| Orange County | $18.12M | 85.1% |
| Los Angeles | $2.91M | 13.7% |
| Inland Empire | $0.26M | 1.2% |

**LA is a warm start, not greenfield** (~$2.9M already). **IE is genuinely greenfield.** The build-out sequencing has to follow this, not treat the two as equivalent expansions.

---

## 4 — The fleet (📏 measured)

**210 of 435 equipment records are Active** — less than half. Active units, and what that is per crew:

| Type | Active | Per crew |
|---|---|---|
| Chipper | 41 | 1.64 |
| Dump Truck | 37 | 1.48 |
| Boom | 30 | 1.20 |
| Crew Truck | 23 | 0.92 |
| Trailer | 23 | 0.92 |
| Arrow Board | 15 | 0.60 |
| Tractor | 12 | 0.48 |
| Stump Grinder (small) | 10 | 0.40 |
| *Sales vehicles* | *15* | *n/a* |

**The core production rig ≈ 5.2 active units per crew** (chipper + dump + boom + crew truck = 131 units across 25 crews).

> 🚨 **TRIM IT cannot cost the fleet.** `Equipment.PurchasePrice` is **empty on all 435 records**, as are the loan fields. Equipment capex per crew has to come from the fixed-asset schedule or the CFO — it is not recoverable from the ERP. *(This is the §4 equivalent of the invoice-attribution gap in Deck A: the capability exists in the schema and was never populated.)*

---

## 5 — What $50M physically requires (🔧 scaffold — ratios measured, the arithmetic is the assumption)

**Held constant:** hours per crew (6,990/yr), crew size (3.3), yard density (8.3 crews). **Every one of those is a lever, not a law** — §6.

| | Today | At $50M, **TPH $123** (today's) | At $50M, **TPH $130** (target) |
|---|---|---|---|
| Production | $21.5M | $50.0M | $50.0M |
| **Crews** | **25** | **59** *(58.0 exact)* | **56** *(55.1 exact)* |
| Field hours | 174,686 | 405,500 | 384,600 |
| **Field employees** | **83** | **~195** | **~185** |
| **Yards** (at 8.3 crews each) | **3** | **7.1 → 7** | **6.7 → 7** |
| Core rig units | 131 | ~309 | ~293 |
| Field DL cost @ $36.57/hr | $6.39M | $14.83M | $14.07M |

*(Crews round **up** — a fraction of a crew delivers nothing.)*

### The three numbers that matter
1. **The crew fleet must more than double — +31 to +34 crews.**
2. **+100 to +112 field employees.** *That is "we need to be prepared for these people."* Over five years that is **~20 net hires a year, every year**, before replacing a single leaver.
3. **Four more yards — 3 → 7.** Long-lead, capital-heavy, and the item most likely to bind first: you cannot hire 110 people into three yards built for 25 crews.

> **Hitting TPH 130 removes 3 crews and ~10 field hires from the requirement.** Real, but second-order — it does not change the shape. **Growth is a build-out problem, not a productivity problem.**

---

## 6 — What would change the answer (the levers, unmodelled)
- **Hours per crew.** 6,990/yr against a 2,080-hr budgeted year for 3.3 people (6,864) means crews are running *at* or slightly over budgeted capacity — there is little slack to absorb growth. → [[gsts-field-labor-rate]] notes the 2026 budget assumes 40-hour weeks with only ~3.5% OT.
- **Crew size / mix.** The core fleet ranges 1.6 to 7.6 people per sheet. A different mix changes both headcount and TPH.
- **Yard density.** 8.3 crews/yard is what we *do*, not what a yard *holds*. If a yard holds 12, $50M needs 5 yards, not 7.
- **TPH spread is the biggest unexploited lever in the data:** the core fleet runs **$22 to $183 per hour**. Closing the bottom quartile toward the median does more than adding crews — and costs no capital. **Not modelled here; it needs the job-mix explanation before it means anything.**

---

## 7 — What I could not measure (blocking the next version)
1. **Yard identity and capacity** — which physical yard is Site 1 / 2 / 3, and how many crews each can hold. Density of 8.3 is an average of current practice, not a constraint.
2. **Supervision structure** — `StaffMembers.StaffRole` is NULL on every active record, so span of control is not derivable. How many crews per foreman/supervisor/manager today?
3. **Equipment capital cost and replacement cycle** — not in TRIM IT (§4). Needed for the capex timing.

## Sources
Live production restore, trailing 12 months to 2026-07-22. Crew/production figures from `CrewSheets` (`ActValue` + `ActHours` — ⚠️ *not* `Total`, which is empty; → [[trimit-db-gotchas]]). Equipment from `Equipment` × `EquipmentTypes` by `StatusDefID`. Labor rate → [[gsts-field-labor-rate]]. Geography → [[gsts-revenue-by-geography]]. TPH basis → [[trimit-stack-and-tph]] (**blended** throughout — this is a cost-of-delivery model, not a segment comparison).
