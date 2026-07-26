# Overtime vs Straight Time Audit — 2026 YTD
**Period: 1 January 2026 → 25 July 2026** (last punch in the system). Built 2026-07-26.
**Source: the TRIM IT timeclock** — `CrewAssignments` clock-in/clock-out punches, routed to crews via `CrewSheets`.
**⚠️ BLACK — deal-aware.**

---

## 🚨 Finding 1 — TRIM IT stopped recording the overtime split in October 2025

The payroll calendar (`CrewMemberCalendars`) has separate Regular / OT / Double-time fields. **They decayed through 2025 and have been exactly zero for ten months.** Total hours still record normally.

| Year | Total hours | Regular | **OT** |
|---|---|---|---|
| 2022 | 177,440 | 147,243 | **27,547** |
| 2023 | 208,578 | 168,513 | **30,300** |
| 2024 | 200,470 | 167,492 | **24,364** |
| 2025 | 172,748 | 108,366 | **11,211** |
| **2026** | **104,306** | **0** | **0** |

**Month it died:** Jan-25 2,598 OT hrs → Jul-25 709 → Sep-25 126 → **Oct-25 onward: 0.00, every month.**

**So the ERP cannot currently tell you what overtime costs.** Everything below is reconstructed from the raw punches, which *do* still work.

---

## 📏 Finding 2 — The audit (reconstructed from clock punches)

**99 people · 11,252 person-days · 97,710 hours clocked.**

| | Hours | Share |
|---|---|---|
| Straight time (first 8 hrs/day) | **87,769** | 89.8% |
| **Overtime** (8–12 hrs/day, 1.5×) | **9,832** | **10.1%** |
| Double time (12+ hrs/day, 2×) | 109 | 0.1% |

**The premium — what the extra half/full rate costs, over and above base pay for those hours:**

| | |
|---|---|
| 2026 YTD, base rates | **$139,961** |
| 2026 YTD, loaded at 1.3× | **$181,949** |
| **Annualised run rate, base** | **≈$240,000** |
| **Annualised run rate, loaded** | **≈$312,000** |

> ### 🚨 **The 8-hour day is a fiction. 87% of person-days run past 8 hours; the average day is 8.68 hours.**
> The 2026 budget assumes 40-hour weeks with **~$219K of OT all year (~3.5% of DL)** → [[gsts-field-labor-rate]]. **Measured premium is running at ≈$240K base / $312K loaded on 10.2% of hours — roughly triple the budgeted share.**

---

## 📏 Finding 3 — By crew (2026 YTD, 50+ person-days)

| Crew | Person-days | Total hrs | Straight | **OT** | DT | **% premium** | Avg day |
|---|---|---|---|---|---|---|---|
| Isahi M Vazquez (7/2) | 1,247 | 9,974 | 9,240 | 668 | 66 | 7.4% | 8.00 |
| Paulino Lopez (3/1) | 699 | 6,183 | 5,490 | **692** | 1 | 11.2% | 8.84 |
| Humberto Sanchez (2/1) | 639 | 5,672 | 5,035 | 636 | 1 | 11.2% | 8.88 |
| Daniel Meza | 557 | 5,047 | 4,433 | 614 | 0 | **12.2%** | **9.06** |
| Pablo Vergara (2/2) | 509 | 4,533 | 4,013 | 520 | 0 | 11.5% | 8.90 |
| Luis Cuevas (3/1) | 474 | 4,178 | 3,721 | 457 | 0 | 10.9% | 8.81 |
| Luis Valdovinos (1) | 437 | 3,885 | 3,443 | 440 | 2 | 11.4% | 8.89 |
| Jose Antonio (3/1) | 437 | 3,851 | 3,415 | 437 | 0 | 11.3% | 8.81 |
| Martimiano Leana (2/1) | 452 | 4,009 | 3,577 | 432 | 0 | 10.8% | 8.87 |
| Jose Castro (2/2) | 446 | 3,923 | 3,501 | 422 | 0 | 10.8% | 8.80 |
| Mario Ramirez (3/2) | 443 | 3,900 | 3,480 | 420 | 0 | 10.8% | 8.80 |
| Jose Vallejo | 429 | 3,791 | 3,387 | 401 | 3 | 10.7% | 8.84 |
| Jesus Escobedo (2/1) | 463 | 4,047 | 3,644 | 402 | 0 | 9.9% | 8.74 |
| Antolin De La Cruz (1/1) | 401 | 3,555 | 3,162 | 393 | 0 | 11.1% | 8.86 |
| Sergio Cuevas (2/1) | 380 | 3,395 | 3,015 | 380 | 0 | 11.2% | 8.93 |
| Naum Cruz (2/1) | 417 | 3,639 | 3,273 | 365 | 0 | 10.0% | 8.73 |
| Ruben Gonzalez (2/1) | 412 | 3,628 | 3,265 | 364 | 0 | 10.0% | 8.81 |
| Omar Mendoza (1/1) | 316 | 2,778 | 2,468 | 297 | 12 | 11.1% | 8.79 |
| Alfredo Lopez (2/1) | 292 | 2,563 | 2,292 | 271 | 0 | 10.6% | 8.78 |
| Rodolfo Padilla (1/1) | 266 | 2,343 | 2,083 | 258 | 2 | 11.1% | 8.81 |
| Jose L Ortiz (1/1) | 427 | 3,548 | 3,311 | 234 | 4 | **6.7%** | 8.31 |
| Javier I. Villalobos (1) | 188 | 1,702 | 1,470 | 227 | 4 | **13.6%** | **9.05** |
| Gerardo Ramos (1/1) | 412 | 3,256 | 3,074 | 170 | 12 | **5.6%** | **7.90** |
| Rafael Alvarez | 142 | 1,283 | 1,127 | 155 | 2 | 12.2% | 9.03 |
| Daniel Cruz Aranda | 150 | 1,302 | 1,169 | 133 | 0 | 10.2% | 8.68 |
| PRODUCTION | 214 | 1,700 | 1,658 | 41 | 1 | **2.5%** | 7.94 |

### What the spread says
- **The band is tight — most crews sit at 10–12%.** This is not a few crews abusing overtime; **it is how the whole operation runs.** A structural 8.8-hour day, not crew-level indiscipline.
- **The outliers are the interesting ones.** Javier Villalobos **13.6%** and Daniel Meza **12.2%** at the top; the two Irvine contract crews — **Gerardo 5.6%** and **Isahi 7.4%** — at the bottom, along with **Jose L Ortiz 6.7%**.
- **The Irvine contract crews run the lowest premium in the company.** Isahi averages exactly **8.00 hours** a day across 1,247 person-days. Municipal contract work appears to hold an 8-hour discipline that commercial work does not. **Worth understanding — it may be the contract, the yard, or the supervisor, and each has a different lesson.**

---

## ✅ Finding 4 — The clock reconciles with the crew sheets (±1.5%)

| Source | Hours, same period |
|---|---|
| Timeclock punches | 97,710 |
| Crew sheets (`ActHours`) | 96,219 |
| **Variance** | **+1,491 (+1.5%)** |

**The two systems agree at company level** — the crew sheets are not materially over- or under-stating field hours. That is a genuinely reassuring result and worth knowing before anyone audits us.

---

## ⚠️ Finding 5 — Half the punches carry the wrong date

**7,437 of 14,780 punch records (50.3%) are stamped on a different calendar date than their crew sheet's work date** — scattered from 8 days early to 7+ days late, with no consistent offset.

Each punch pair is internally sane (no negative spans, none over 24 hours), so the **hours** are trustworthy; the **date alignment between the two systems is not**. This is the same after-the-fact entry pattern Deck A documents for bids, showing up in the field records.

**Consequence:** this audit groups by the punch's own date, which is the defensible basis. Grouping by crew-sheet date produces impossible days (up to 139 hours) and must not be used.

---

## Method & caveats
- **Daily California rules applied:** first 8 hrs straight · 8–12 at 1.5× · 12+ at 2×.
- **NOT applied:** the >40-hour weekly rule and the 7th-consecutive-day rule. Both would **increase** the premium, so **these figures are a floor.**
- Person-days built from `CrewAssignments.ActStart/ActEnd` minus `BreakTime`, aggregated per person per punch-date *before* the 8-hour test (a person often appears on several crew sheets in a day).
- Rates from `CrewMembers.HourlyRate`, defaulting to the $27.45 field average where blank → [[gsts-field-labor-rate]].
- Crew attribution = the crew where the person spent the most hours that day.
- Annualised = YTD ÷ (7/12). Tree work is seasonal, so treat as indicative.

## Why this matters to the capacity model
This settles the open question in [[capacity-growth-model]] §2a: **the working day is 8.68 hours, not 8.** Crew-size and headcount figures derived on an 8-hour assumption overstate bodies by roughly 8%; the payroll basis (83) remains the conservative one to plan on.
