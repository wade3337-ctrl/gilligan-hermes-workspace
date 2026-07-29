---
title: Path to $25.1M (2026) — run-rate and crew-capacity math
type: reference
domain: work
confidential: black
tags: [revenue, goal, run-rate, capacity, tph, production, board, 2026]
applies: ["[[only-trustworthy-data]]", "[[fort-point-confidentiality]]"]
links: ["[[count-once-revenue-ledger]]", "[[gsts-2026-sales-goals-monthly]]", "[[trimit-stack-and-tph]]", "[[production-perf-future-dated-crewsheets]]", "[[june-invoicing-lag]]", "[[deal-tracker-dashboard]]", "[[bod-commitment-dashboard]]", "[[revenue-goal-close]]", "[[crewsheet-acthours-is-the-estimate]]"]
updated: 2026-07-29
---

# Path to $25.1M — what the rest of 2026 has to deliver

Computed live 2026-07-28 against the nightly restore (restored 08:51 UTC) and reconciled to Dimitry's
June pack. **The coverage view (what's already sold/forecast) lives in [[count-once-revenue-ledger]];
this note is the run-rate and capacity view.**

## ⚠️ Which "goal" you mean — SETTLED 2026-07-29 at $25,300,976
| Figure | Source | Use |
|---|---|---|
| **$25,300,976** | `Workbench.dbo.SalesGoal` (12 FY2026 rows) — and since **2026-07-29** `rgc.Plan.ApprovedAnnualGoal` too | ✅ **THE authoritative goal.** What the V1.5 assistant, Revenue Performance and [[revenue-goal-close]] all read |
| **$25.1M** | the team number the Skipper works to | what he asks about — round to it, don't recompute from it |
| $24,000,000 | the RGC plan row approved 2026-07-13 | ⛔ **RETIRED 2026-07-29.** It went stale when `SalesGoal` was raised, and RGC **fail-closed** rather than compute coverage against a wrong denominator — every tile showed an em-dash until the plan row was re-based (Skipper's call) |
| $25.05M | the deal dashboard's **stale fallback constant** | ❌ broken — July's OLD $24M-budget month × 12 |

**What that does to the run-rate below:** against $25,300,976 the H2 requirement is **$2,346,424/month**
(Jul–Dec), not the $2,312,928 computed against $25.1M. **$2,346,424 is the figure now tracked on the
[[bod-commitment-dashboard]]** and re-based into the plan. ⚠️ Re-basing H2 alone makes the twelve `SalesGoal`
rows sum to $26.3M and RGC fail-closes again — **the plan table is a whole; re-base it as one.**

## Where H1 landed
- **Book (Dimitry, Jan–Jun): $11,222,433.** TRIM IT invoiced: **$11,078,312** — **−$144K / −1.28%**, months
  swinging ±$183K both ways on timing. **The ERP is a sound proxy for the books within ~1%.**
- **H1 plan was $12,250,976 → behind by $1.03M** (book basis; $1.17M on the ERP basis). **91.6% of plan.**
- **H1 production: $11,295,695** on the corrected `Calendars.CalDate` basis — **0.65% of the book**, versus
  the `WorkDate` basis that reads $10,748,976 and is **4.2% adrift**. → [[production-perf-future-dated-crewsheets]]
- 🔻 **The old "TPH $130.19 vs target 130" line is retired as an efficiency claim.** That rate is revenue per
  **scheduled** hour (`CrewSheets.ActHours` = the estimate → [[crewsheet-acthours-is-the-estimate]]).
  The number now on record with the Board is **CFO revenue ÷ clocked payroll hours: Q1 $118.76 → Q2 $125.10,
  H1 $122.01, target $130** — deliberately the basis nobody can recompute differently. → [[bod-commitment-dashboard]]

⭐ **The headline for any exec conversation (restated 2026-07-29 on the honest basis): the shortfall is
mostly VOLUME, and efficiency is close but NOT quite there.** On clocked hours H1 came in at **$122.01 vs
the $130 target** while *improving 10.7% in a single quarter* ($118.76 → $125.10) — so the crews are
converting hours at close to the asked rate and the binding constraint is that there aren't enough hours.
**Do not say "efficiency is on target"** — that was the scheduled-hour rate reading $130.19, and it
overstated by ~11%.

## What $2.2M/month gets you — it is NOT enough
- **Jul–Dec all at $2.20M → lands $24,422,433. Short $678K.**
- **The plan exactly as written** ($2.20M Jul–Nov + $2.05M Dec) **→ $24,272,433. Short $828K.**

**Why:** the $2.2M/month H2 shape was built assuming H1 delivered $12.25M. H1 delivered $11.22M, and the
plan never absorbed the miss. **Running the plan as written now lands ~$800K short.**

## What is actually required
*(Computed against the $25.1M team number. Against the authoritative $25,300,976 it is **$2,346,424/month** —
the figure re-based into the plan and tracked on the [[bod-commitment-dashboard]] on 2026-07-29.)*
- **$2,312,928/month, Jul–Dec** ($13,877,567 total).
- If July closes at **$2.2M → Aug–Dec needs $2,335,513/mo** (+$136K/mo over $2.2M)
- If July closes at **$2.0M → $2,375,513/mo** · at **$1.9M → $2,395,513/mo** (+$196K/mo)
- **Practical framing: $2.2M/month PLUS about $165K/month for the last five months — or one extra $828K month.**

## What that costs in crew hours (H1 average was 13,761 hrs/mo; best month April = 16,512.8)
| Monthly revenue | Hours at TPH 130 | vs H1 avg | vs April (best) |
|---|---|---|---|
| $2.20M | 16,923 | +23% | +2% |
| **$2.31M (required)** | **17,792** | **+29%** | **+8%** |
| $2.40M (if July lands 1.9) | 18,431 | +34% | +12% |

- **If hours stay flat at 13,761, the required TPH is $173.81** — a 34% rate lift. Not a real option; say so.
- So $2.2M/mo ≈ "sustain your best month, five months running." The true number is that **plus ~900 hrs/mo.**
- **The lever is hours or price.** Every point of TPH above 130 buys back hours you'd otherwise staff.
  *(Open: whether ~17,800 hrs/mo is physically available at current headcount — capacity view NOT yet built.)*

## Coverage cross-check (from [[count-once-revenue-ledger]])
Adj actual $12.53M + muni $3.74M + firm sold $2.91M + pipeline@40% $1.55M = **covered $20.73M**
→ **uncovered $4.37M vs $25.1M** ($4.57M vs the live $25.30M). That is genuinely net-new selling —
**there is no hidden backlog**: the "$3.2M undated sold work" is really $3.14M of *2027* work.

✅ **Two independent bases agree** — the invoicing side needs +36% over run rate, the production side +33.5%.
When crew sheets and invoices land within 3 points of each other, the number isn't a table artifact.

## Caveats to state out loud whenever these numbers are used
- **July is not callable.** $1.46M invoiced / $1.02M produced so far, but the month is open and invoicing
  runs 3–10 days into the next month (~25% understated at month-end) → [[june-invoicing-lag]].
- ⛔ **REVERSED 2026-07-28 — production was never overstated.** The old caveat here read *"production reads
  ~$671K high; 148 future-dated crew sheets marked complete."* Those sheets are **not** fabricated: a crew
  sheet carries two dates, and all 148 have a **past** `Calendars.CalDate` — it is `WorkDate` that is corrupt
  (2,064 of 4,355 H1 sheets, 47%, disagree). Binning on `CalDate` reconciles to the book within 0.65%.
  **The "cap production at today" fix was CANCELLED — it would have deleted ~$671K of real, worked revenue.**
  → [[production-perf-future-dated-crewsheets]]
- Data is the **nightly restore**, so ~1 day behind production.
- The accrual bridge is net **−$8K** (cur $153K − base $161K), which looks too small to be carrying the
  known invoicing lag. Do not lean on it.

## Sources
Live SQL via `~/herman-gateway/trimit-ro-query.sh` → play `localhost,14333` `GSTS`; goal table
`Workbench.dbo.SalesGoal`; book revenue from Dimitry's June pack
(`~/arbor-stack/anomaly-monitor/_pull/dimitry-2026-07-20/`).

## Superseded / historical
- *(2026-07-28, superseded)* H1 production stated as **$10,748,976 over 82,565 crew hours → TPH $130.19
  against a target of 130**, with the headline *"efficiency is ON target."* Both figures are the `WorkDate`
  /scheduled-hour basis: the dollars were 4.2% adrift and the rate overstated labor efficiency by ~11%.
- *(2026-07-29, superseded)* The required run-rate **$2,312,928/month Jul–Dec** and its ladder
  ($2.2M July → $2,335,513/mo; $2.0M → $2,375,513; $1.9M → $2,395,513) were computed against the **$25.1M**
  team number. Against the now-authoritative $25,300,976 the requirement is **$2,346,424/month**.
  The shape of the argument is unchanged — the plan as written still lands ~$800K short.
