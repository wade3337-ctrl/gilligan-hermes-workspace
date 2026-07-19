# Great Scott Tree Care — $24M → $50M Five-Year Growth Plan

**Internal strategic plan / roadmap (investors will also see it).**
Owner: Jason Wade (Skipper), COO. Built with Gilligan. Status: **living document.**
Base year: 2026 ($24.0M produced-revenue plan). Horizon: 5 years (Year 5 = 2031). Games year: Year 2 = 2028.

> **Design principle:** WHERE the revenue comes from (geography) is the axis that *adds up*. HOW we win it (retention, portfolio expansion, pods, municipal bids, service penetration) are *motions* that **explain** the geography numbers — they do not stack on top. This fixes the double-counting in the earlier draft.

---

## 1. Scoreboard — 5-year revenue trajectory (LOCKED 2026-07-19, re-anchored to real data)

Built bottom-up by engine, base split anchored to the **real TTM geography data** (§6). **LA leads the early years** (warm $3.3M base + Olympics catalyst); **IE is the back-loaded greenfield build**; OC deepens steadily.

| Year | Total | OC/core | LA | IE | YoY |
| --- | --- | --- | --- | --- | --- |
| Now (2026) | $24.0M | $20.4M | $3.3M | $0.3M | — |
| Year 1 (2027) | $27.3M | $21.7M | $4.8M | $0.8M | +14% |
| Year 2 (2028) | $31.3M | $23.0M | $6.5M | $1.8M | +15% |
| Year 3 (2029) | $36.1M | $24.8M | $7.5M | $3.8M | +15% |
| Year 4 (2030) | $42.2M | $26.9M | $9.0M | $6.3M | +17% |
| Year 5 (2031) | $50.0M | $29.5M | $11.0M | $9.5M | +18% |

- New-market revenue (LA+IE): ~15% of book today → **~41% by Year 5** (the diversification / de-risking story).
- Curve accelerates each year (+14% → +18%): LA + Olympics carry the front; IE's greenfield dollars arrive in the back half as density builds.

## 2. Revenue architecture — the $26M increment

**By geography (adds to $26M):**
- **LA County — +$7.7M (30%)** — leads early; *warm-start* expansion on an existing $3.3M book + Olympics catalyst (below). Lower risk than greenfield.
- **IE — +$9.2M (35%)** — true greenfield ($0.3M base); back-loaded, biggest back-half increment; proven as the repeatable pod template.
- **OC deepening — +$9.1M (35%)** — warm backyard; +45% via better BD.
- **Acquisitions — optional accelerator** — deliberately OFF the base plan; upside only.

**By motion (explains the above; does NOT add):** retention & rebid defense · warm portfolio expansion (management companies) · territory pods · municipal/institutional bids · service penetration / recurring programs · price/margin correction.

## 3. LA 2028 Olympics — upside, not foundation

- Timing: Games = Year 2 (2028); prep demand runs ~2026–2028 (Years 1–2) — right when LA already leads the ramp.
- Opportunity: venue-corridor street-tree work, municipal beautification, commercial sprucing, public-agency readiness.
- **Held as separate upside:** LA's base ramp stands on its own; Olympics modeled as **+$2–4M concentrated in Years 1–2, flagged non-recurring** (competitive, prevailing-wage/bonding-heavy, likely post-Games dip in Year 3). If it lands, LA beats plan; if not, the base still hits $50M.

---

## 4. Margin & investment layer (the J-curve) — DRAFT, illustrative

*Planning estimates off our 2026 GP% actuals; per-crew unit economics still need a real pull (see §5).*

Key refinement from the real data: **only the truly new build carries the low ramp margin** — IE greenfield + LA's growth *above* its existing base. OC and LA's existing $3.3M book stay at mature margin. So the margin dip is **shallower** than a naive "all new markets start low" model.

Assumptions: mature (OC + LA base) GP ≈ 32% (Jan–May 2026 avg). Investment revenue (IE + LA-above-base) GP ramps 8% → 15% → 22% → 27% → 30%.

| Year | Total Rev | Mature Rev | Investment Rev | Inv GP% | Blended GP$ | Blended GP% |
| --- | --- | --- | --- | --- | --- | --- |
| Now | $24.0M | $23.7M | $0.3M | ~25% | $7.7M | 31.9% |
| Year 1 | $27.3M | $25.0M | $2.3M | 8% | $8.2M | 30.0% |
| Year 2 | $31.3M | $26.3M | $5.0M | 15% | $9.2M | 29.3% |
| Year 3 | $36.1M | $28.1M | $8.0M | 22% | $10.8M | 29.8% |
| Year 4 | $42.2M | $30.2M | $12.0M | 27% | $12.9M | 30.6% |
| Year 5 | $50.0M | $32.8M | $17.2M | 30% | $15.7M | 31.3% |

- **The story:** margin rate dips only ~2.6 points (31.9% → 29.3% trough in Yr2), fully recovers to ~31% by Year 5, while gross-profit **dollars double** ($7.7M → $15.7M). LA's warm base makes the J-curve shallower than a pure new-market model — a *stronger* investor story.

**What a pod costs (investment buckets to size):** equipment (bucket/chip trucks, chipper — buy vs lease) · yard + disposal site · leadership (supervisor) + BD/sales coverage · working capital / DSO drag (labor paid before collection) · startup operating losses until route density hits breakeven.

**Peak cash need** (the owner's scariest number): how deep the combined hole gets before the pods turn cash-positive — to be modeled once §5 data lands.

## 5. Open data needs (to make §4 real)
- ~~Current revenue **split by geography**~~ ✅ **DONE 2026-07-19** — see §6.
- **Per-crew unit economics**: revenue/crew/yr, fully-loaded crew cost, utilization.
- **Equipment cost** per crew (new vs used vs lease) and financing terms.
- **DSO** by segment (municipal vs HOA vs commercial) for the working-capital drag.
- June+ 2026 actuals (only Jan–May are in file).

## 6. Data findings — geography split (pulled 2026-07-19)

**Source:** play SQL (nightly prod mirror) via `gsql.sh`, using the CFO-canonical revenue definition (`SUM(Invoices.Total)`, status ∈ InProcess/Pending/Open/Paid/Locked, required joins) grouped by service county. Service location = `Projects.LocationID → Locations.ZipCodeID → ZipCodes.County`. Window = **TTM, period-month Jul 2025–Jun 2026** (12 full months, smooths seasonality). Integrity: 100% of invoices mapped to a county, zero nulls.

| Region | Revenue (TTM) | Share | Invoices |
| --- | --- | --- | --- |
| OC (Orange) | $18.12M | 85.1% | 2,711 |
| LA (Los Angeles) | $2.91M | 13.7% | 288 |
| IE (Riverside + San Bernardino) | $0.26M | 1.2% | 31 |
| **Total** | **$21.29M** | 100% | 3,030 |

- TTM invoiced $21.29M vs $24M produced plan — the ~$2.7M gap = invoiced-vs-booked timing + running below plan. Scoreboard base uses the $24M plan with the *real percentages* (OC $20.4M / LA $3.3M / IE $0.3M).
- **Key finding:** LA is already a real $2.9M business (not greenfield) → warm-start; IE is true greenfield. Drove the "LA leads early, IE back-loaded" decision (§1–2).

---
*Foundation (§1–3) locked + re-anchored to real data 2026-07-19. §4 illustrative pending unit-economics. §6 data logged.*
