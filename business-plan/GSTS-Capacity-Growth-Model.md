# GSTS Capacity & Growth Model
**v0.2 — 2026-07-26.** BASELINE measured, ramp scaffolded, assumptions flagged.
**v0.2 changes (Skipper, 2026-07-26):**
1. The three yards are **Stanton · Laguna Hills · Irvine**, and **Irvine is a dedicated single-contract yard** (~15 guys). Retired v0.1's use of `SiteAssigned` as the yard key and its uniform 8.3-crews-per-yard density — §2.
2. *"A crew can't be 2.5 or 10.5 people."* Right — v0.1 reported **FTE person-years as people**. **Crew size is now whole bodies on a working day** (hours ÷ working days ÷ 8), which reproduces his Irvine yard exactly: **12 + 3 = 15** — §2a.
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
| Average crew size (hours ÷ working days ÷ 8) | **4.4** *(range 2–12)* |
| Field direct-labor headcount (2026 payroll) | **83** |

**Why 25 and not 31.** 31 crew IDs recorded activity; 25 worked 100+ days and produced **98.5%** of everything. The other six are fragments — the model is built on the 25.

### The four ratios everything else derives from
| Ratio | Value | Basis |
|---|---|---|
| **Production per crew per year** | **$861,600** | 📏 measured |
| **Field hours per crew per year** | **6,990** | 📏 measured |
| **Crews per $1M of production** | **1.16** | 📏 derived |
| **Field employees per crew** | **3.3** *(payroll basis)* | 📏 83 payroll ÷ 25 crews. ⚠️ **Crew size on the ground averages 4.4 and runs 2–12 people (§2a) — the two bases do not yet reconcile.** |

---

## 2 — Where the capacity physically sits

> 🚫 **`CrewNames.SiteAssigned` is NOT the yard — do not use it.** v0.1 read its values 1/2/3 as the three yards and built a "8.3 crews per yard" density on it. **Wrong:** both City-of-Irvine crews carry `SiteAssigned = 2`, but that value holds ten crews, and the Irvine yard holds only those two. The field is unmaintained or means something else. *(Skipper, 2026-07-26.)*

**The three real yards (Skipper): Stanton · Laguna Hills · Irvine.**

**The Irvine yard is a dedicated single-contract yard** — it houses only the City of Irvine work: Isahi's production crew and Gerardo's planting crew, *"about 15 guys."*

| Irvine yard | Hours | **Crew size** | Production | TPH |
|---|---|---|---|---|
| Isahi M Vazquez — production | 21,779 | **12** | $2,571,000 | 118 |
| Gerardo Ramos — planting | 5,295 | **3** | $380,509 | 72 |
| **Total** | **27,074** | **15** | **$2,951,509** | 109 |

📏 **15 against his "about 15 guys" — exact.** See §2a for why this is the right basis.

### ⚠️ The consequence: yards are not interchangeable units
Irvine is **2 crews serving one contract**. The other **23 crews** sit across **Stanton and Laguna Hills** — roughly **11.5 crews per general-purpose yard**, not 8.3. **A "yard" in this business is either a general operating base or a contract outpost, and they scale completely differently.** v0.1's uniform-yard arithmetic is retired; §5 is rebuilt on the split.

### The core fleet by focus (📏 measured — the grouping to map onto yards)
| Crew focus | Crews | People | Production | TPH |
|---|---|---|---|---|
| **LWV-COM** (Laguna Woods Village) | 7 | 33 | $7,311,796 | **139** |
| **COMM** | 4 | 20 | $3,459,640 | 112 |
| **IRVINE** | 3 | 18 | $4,036,591 | 120 |
| *(blank)* | 5 | 18 | $2,417,075 | 109 |
| **NPB** (Newport Beach) | 4 | 14 | $2,745,330 | 120 |
| **Other** | 1 | 6 | $938,926 | 115 |
| **MUNI** | 1 | 3 | $637,281 | **137** |
| **Total** | **25** | **110** | **$21,539,106** | **123** |

*(People on the working-day basis — §2a. The 110 total is the unreconciled figure; payroll says 83.)*

❓ **The IRVINE focus has 3 crews / 18 people, not the 2 / 15 at the yard.** A third crew — **Jose L Ortiz, 4 people, $1.09M, TPH 166, the best in the fleet** — carries the Irvine focus. Whether it yards at Irvine or elsewhere is open. → §7

## 2a — How to count crew size (📏 validated — and they are whole people)

> **Skipper, 2026-07-26: *"a crew can't be 2.5 or 10.5 people."*** Correct — v0.1 quoted **FTE person-years**, which is a unit of labor, not a unit of person. A crew is whole people. **Fixed throughout.**

**Crew size = field hours ÷ working days ÷ 8.** That is how many bodies show up on a working day, and it lands on whole numbers that match reality:

| Crew | Hours | Working days | Hours per day | **Crew size** |
|---|---|---|---|---|
| Isahi M Vazquez | 21,779 | 231 | 94.3 | **12** |
| Gerardo Ramos | 5,295 | 220 | 24.1 | **3** |

**Validation: 12 + 3 = 15 at the Irvine yard — exactly the Skipper's "about 15 guys."**

**Across the core fleet: crews run 2 to 12 people, averaging 4.4.** Working year averages **195 days** per crew.

### ⚠️ Two headcount numbers that do not yet reconcile — do not average them
| Basis | Result |
|---|---|
| People on a working day (hours ÷ days ÷ 8) | **110** |
| FTE person-years (hours ÷ 2,080) | **84** |
| 2026 payroll, field direct labor | **83** |

✅ **RESOLVED 2026-07-26 from the timeclock** → `GSTS-Overtime-Audit-2026.md`. **The working day is 8.68 hours, and 87% of person-days run past 8.** The clock reconciles with the crew sheets to **±1.5%** (97,710 vs 96,219 hours), so the hours are sound.

At 8.68 hrs/day the fleet implies **~101 bodies**, still above the 83 on payroll — the residual is people appearing on crew sheets who don't sit on the field-DL payroll line (supervisors, shop, temporary labour). **§5 stays on the payroll basis (83), the conservative one**, but the *hours* basis is now measured rather than assumed.

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

**Held constant:** hours per crew (6,990/yr), people per crew (3.3 on the payroll basis — see §2a, crew size on the ground averages 4.4 and the two do not yet reconcile), general-yard density (11.5 crews). **Every one of those is a lever, not a law** — §6.

| | Today | At $50M, **TPH $123** (today's) | At $50M, **TPH $130** (target) |
|---|---|---|---|
| Production | $21.5M | $50.0M | $50.0M |
| **Crews** | **25** | **59** *(58.0 exact)* | **56** *(55.1 exact)* |
| Field hours | 174,686 | 405,500 | 384,600 |
| **Field employees** | **83** | **~195** | **~185** |
| **General-purpose yards** (at 11.5 crews each — §2) | **2** | **5** | **5** |
| *plus contract outposts (Irvine-type)* | *1* | *as won* | *as won* |
| Core rig units | 131 | ~309 | ~293 |
| Field DL cost @ $36.57/hr | $6.39M | $14.83M | $14.07M |

*(Crews round **up** — a fraction of a crew delivers nothing.)*

### The three numbers that matter
1. **The crew fleet must more than double — +31 to +34 crews.**
2. **+100 to +112 field employees.** *That is "we need to be prepared for these people."* Over five years that is **~20 net hires a year, every year**, before replacing a single leaver.
3. **Three more general-purpose yards — 2 → 5** (57 non-contract crews ÷ 11.5), **plus a contract outpost for every Irvine-type municipal win.** Yards are the long-lead, capital-heavy item and the most likely to bind first: you cannot hire 110 people into bases built for 25 crews.

> ⚠️ **The yard number is the softest figure in this model.** 11.5 crews per general yard is *what Stanton and Laguna Hills currently carry*, not what they can hold. If either has room for 15, $50M needs 4 general yards, not 5. **Settling actual yard capacity is the highest-value input still missing** — it moves the answer by a whole facility, and a facility is the longest lead item on the list.

> 📌 **And every municipal contract like Irvine brings its own yard.** Irvine = 2 crews, 13 people, $2.95M, its own base. Municipal is a named growth channel in the plan — so the yard count is not a single ramp, it is *general yards + one outpost per contract of that shape*. Budget it that way.

> **Hitting TPH 130 removes 3 crews and ~10 field hires from the requirement.** Real, but second-order — it does not change the shape. **Growth is a build-out problem, not a productivity problem.**

---

## 6 — What would change the answer (the levers, unmodelled)
- **Hours per crew.** 6,990/yr against a 2,080-hr budgeted year for 3.3 people (6,864) means the fleet is running *at* or slightly over budgeted capacity — there is little slack to absorb growth. → [[gsts-field-labor-rate]] notes the 2026 budget assumes 40-hour weeks with only ~3.5% OT.
- **Crew size / mix.** Crews run **2 to 12 people** (§2a). A different mix changes both headcount and TPH.
- **Yard density.** 11.5 crews per general yard is what Stanton and Laguna Hills *carry*, not what they *hold*. At 15 apiece, $50M needs 4 general yards instead of 5 — a whole facility of difference, and facilities are the longest lead item here.
- **TPH spread is the biggest unexploited lever in the data:** the core fleet runs **$22 to $183 per hour**. Closing the bottom quartile toward the median does more than adding crews — and costs no capital. **Not modelled here; it needs the job-mix explanation before it means anything.**

---

## 7 — What I could not measure (blocking v0.3)
1. ✅ ~~How long is the working day?~~ **ANSWERED: 8.68 hrs** from the timeclock → `GSTS-Overtime-Audit-2026.md`.
2. **Yard capacity** — how many crews Stanton and Laguna Hills can each actually hold. 11.5 is current load, not capacity, and it swings the $50M answer by a whole facility.
3. **The Stanton / Laguna Hills split** — which crew groups sit at which. Plausible from the names (LWV-COM = Laguna Woods Village), but not asserted without confirmation.
4. **Is the third IRVINE-focus crew (Jose L Ortiz — 4 people, $1.09M, TPH 166) at the Irvine yard?** The Skipper named only two crews there; the data shows three carrying that focus.
5. **Supervision structure** — `StaffMembers.StaffRole` is NULL on every active record, so span of control is not derivable. Crews per foreman / supervisor / manager today?
6. **Equipment capital cost and replacement cycle** — not in TRIM IT (§4). Needed for capex timing.

## Sources
Live production restore, trailing 12 months to 2026-07-22. Crew/production figures from `CrewSheets` (`ActValue` + `ActHours` — ⚠️ *not* `Total`, which is empty; → [[trimit-db-gotchas]]). Equipment from `Equipment` × `EquipmentTypes` by `StatusDefID`. Labor rate → [[gsts-field-labor-rate]]. Geography → [[gsts-revenue-by-geography]]. TPH basis → [[trimit-stack-and-tph]] (**blended** throughout — this is a cost-of-delivery model, not a segment comparison).
