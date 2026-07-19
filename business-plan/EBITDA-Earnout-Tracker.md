# GSTS — EBITDA & Earnout Tracker

> 🔒 **STRICTLY CONFIDENTIAL — Gilligan + Skipper only.** Tracks the two numbers the Fort Point deal pays on. Not for Aspen / Herman / team.
> Companion to `GSTS-50M-Growth-Plan.md` and `H2-2026-earnout-max-tracker.md`. Updated monthly when the new exec-financials deck lands.

## The two numbers to watch (this is the whole job)
| # | Metric | Target | Why |
| --- | --- | --- | --- |
| 1 | **TTM Adjusted EBITDA** | **$4.8M** (floor $4.1M) | The company's *valuation* is built on this (~10.75×). |
| 2 | **2026 Adjusted Gross Profit** | **$11.4M–$12.5M** | The 2026 **earnout** (up to $5M) rides on this. (2027 band: $13.3M–$14.9M.) |

## Where each number comes from (the data map)
- **Revenue** → live from TRIM IT (Gilligan pulls) + the monthly P&L. *(2026 tracking ~9.6% below plan — the January hole.)*
- **Gross Profit / Adjusted GP** → the monthly exec-financials deck (P&L).
- **EBITDA** → already computed inside each monthly deck. Two tabs: **"Top Sheet"** (EBITDA schedule) and **"IS – 12m rolling"** (the TTM statement — the deal's exact view).
- **Add-backs (accounting → "Management Adjusted")** → the QoE (BDO) + management schedule.

## Current read — 2026 YTD (Jan–May, from the vetted P&L)
| Month | Revenue | Gross Profit | Net Income |
| --- | --- | --- | --- |
| Jan | $1.795M | $0.536M | −$0.037M |
| Feb | $1.654M | $0.459M | −$0.120M |
| Mar | $1.870M | $0.649M | +$0.063M |
| Apr | $2.022M | $0.758M | +$0.003M |
| May | $1.960M | $0.618M | −$0.0004M |
| **YTD** | **$9.30M** | **$3.02M** | **−$0.09M** |

- Revenue YTD is ~$1.0M below the seasonalized plan (Jan −$0.74M = the bulk). Full-year pace ~$21.7–22.5M vs $24M.

## ⚠️ The reconciliation that matters: accounting EBITDA vs deal EBITDA
The deck's built-in **"EBITDA (Final)"** runs roughly **$150K–$420K/month** → annualizes to ~**$3.5–4.0M** (this is *accounting* EBITDA, net income + D&A + interest + an ERC adjustment).

The **deal** uses **"Management Adjusted EBITDA" = $4.1M TTM / $4.8M target** — *higher*, because it adds back more (owner comp normalization, one-time items). **The ~$0.5–1.0M gap between the two is the management add-backs**, and it's exactly what BDO's Quality of Earnings will validate line-by-line.

**➡️ Action to lock the live number:** read the **EBITDA line on the "IS – 12m rolling" tab** of the latest deck — that's the current TTM EBITDA. (I couldn't extract it cleanly by script; this workbook's tabs use coded labels. Easiest: you open that tab, or hand me the single EBITDA cell value and I'll plug it in + track it forward.)

## 📊 One-glance scorecard (fill each month)
```
TTM Adjusted EBITDA :  $____  /  $4.8M   (floor $4.1M)   [__% of target]
2026 Adj Gross Profit:  $____  /  $11.4–12.5M band        [earnout: $____]
2026 Revenue pace   :  ~$21.7–22.5M  /  $24M plan         [gap: ~$1.5–2.3M]
```

## Monthly update routine (what Gilligan does)
1. New exec-financials deck lands → read **Total Income, Gross Profit, EBITDA (12m-rolling tab)**.
2. Pull **live revenue** from TRIM IT for the current (open) month.
3. Update TTM EBITDA vs $4.8M, and YTD Adjusted GP vs the earnout band.
4. Flag: are we on pace for the 2026 earnout? Any month slipping below the run-rate needed.

---
*Built 2026-07-19. Revenue/GP/NI Jan–May from vetted P&L. EBITDA values directional pending a clean TTM read off the "IS – 12m rolling" tab. Confidential.*
