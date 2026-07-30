---
title: CFO financials — what we can DERIVE vs what we must ask for
type: reference
domain: work
track: 2
confidential: black
status: active
tags: [cfo, financials, agp, ebitda, earnout, derivation, xlsx, script, deal]
applies: ["[[fort-point-confidentiality]]", "[[two-track-confidentiality]]", "[[only-trustworthy-data]]"]
links: ["[[monthly-cfo-reconciliation]]", "[[gsts-2026-earnout]]", "[[gsts-adjusted-ebitda]]", "[[play-public-cookie-forgeable]]", "[[bod-commitment-dashboard]]"]
updated: 2026-07-30
---

# 🔒 Deriving the deal numbers from the CFO's own file

**Origin (Skipper, 2026-07-30):** *"can we calculate or figure all this out from all of the documents we
have? I'm tired of asking for data from these people."* **Mostly yes.** Tested, not assumed.

**Tool:** `business-plan/derive-financials.py` — stdlib only (there is no `pip` on this host).
`python3 derive-financials.py [file] [--json]`; with no argument it takes the newest file in
`arbor-stack/inbox-pull/steve-financials-*/`. **Exit code = number of FAILED controls**, so it can gate
anything downstream. First clean run 2026-07-30: **0 failed controls.**

## ✅ DERIVABLE — proven against the June-locked file
- **The CFO's reclass adjustment, rebuilt to $0.00.** The script parses the account numbers **out of his
  own row label** ("Adjustment for relocating 5152, 5155, 5157 5335,5344.5383,5430 to Overhead") and
  re-sums them from the P&L → **1,374,202.97 vs 1,374,202.97 stated.** Because it reads the accounts from
  the label, **if he adds or drops one the derivation follows him automatically.** (`5157` is named but
  absent from the P&L = zero balance; the script says so rather than failing.)
- **His FY targets** — lifted from the annotation column, not hardcoded: Total Income **$24.4M**,
  Adjusted Gross Profit **$11.4M–$12.2M**, Revised EBITDA **$4M+**.
- **The whole earnout position** at any revenue scenario (below).
- Structural controls: Income−COGS=GP · income accounts foot to Total Income · GP+reclass=AGP ·
  Base+Adjustments=Revised EBITDA. All PASS.

## 🟡 INFERRED — the deal-AGP hypothesis (stated as inference, not fact)
The gap between the CFO's 45.04% AGP and the deal's ~50% is **$557,854**, and account
**`5100 · Depreciation Expense (COGS)` is $549,135 — 98.4% of it**, leaving $8,719 (0.078% of revenue).

> **DEAL AGP = gross profit before non-cash D&A.** The CFO's "Adjusted" GP stops one line short of it.

- AGP + depreciation = **$5,616,561 = 49.92% of revenue**
- FTI/QoE datapack (Cam, 7/21) implies **~50.00%** — two **independent** paths **0.08 pts** apart.
- Accounting-coherent, not curve-fitted. The script re-checks this gap every run and **warns if the two
  ever diverge by more than 0.5 pts**.
- ⚠️ Still an inference. The confirming question is one line: *does deal AGP exclude depreciation?*

## ❌ NOT DERIVABLE — the only things still worth asking for
1. **Base EBITDA $944,015.39.** Four defensible reconstructions tried (net ordinary income ± D&A,
   ± interest, ± other income); **closest miss $16,056.** Something in his calc is not visible in the P&L.
2. **EBITDA "Adjustments" $429,484.02.** **Zero** itemization anywhere in the workbook — and this one
   **isn't really his to hand over**: QoE add-backs are FTI/BDO third-party work product.

**Net effect: the recurring ask shrinks from "explain your definitions" to two yes/no confirmations**,
one of which isn't his. Everything else recomputes monthly from the file he already sends.

## 💰 Earnout position (derived 2026-07-30, June locked)
Terms: floor **$11.4M** AGP → cap **$12.5M** AGP, max **$5.0M**, linear.
At 49.92%, **each $1 of revenue inside the band ≈ $2.27 of earnout.**

| Scenario | FY revenue | FY AGP | Earnout |
|---|---|---|---|
| **H1 × 2 (arithmetic, not a forecast)** | $22,501,121 | $11,232,560 | **$0** |
| CFO budget figure (his 2025 budget) | $24,400,000 | $12,181,090 | $3,550,408 |
| **FY2026 goal — `Workbench.dbo.SalesGoal`** | **$25,300,976** | $12,630,880 | **$5,000,000 (CAP)** |

- Revenue to **clear the floor**: **$22,835,395** · to **max the earnout**: **$25,038,811**.
- The goal clears the cap by **$262,165**; **choosing it over the CFO's budget figure is worth $1,449,592.**
- ⚠️ **At current pace the earnout is ZERO — short of the floor by $335,417** (~$55,900/month over the
  remaining six). The whole spread between $0 and $5M sits inside about **$2.8M of H2 revenue.**
- ⚠️ **His $24.4M is a BUDGET number, not the LOI** — his own words, 2026-07-29. Fourth goal figure in
  circulation. → [[path-to-25m-2026]]

## 🚨 Where the output may and may not go
`--json` writes `business-plan/derived-financials.json` **locally only**, feeding the Tailscale-private
[[deal-tracker-dashboard]]. **Never render earnout math on play** — it is publicly resolvable with a
forgeable cookie → [[play-public-cookie-forgeable]]. GP/AGP/EBITDA-vs-CFO-target tracking on
[[bod-commitment-dashboard]] is fine; the *transaction framing* is what must not travel.

## 🪤 The parsing trap (cost a debugging cycle)
A row's **label is not "every string cell in the row."** The CFO parks targets in the column right of
TOTAL, so row 10 is `{C:'Total Income', T:'$24.4M'}` and a naive join yields `'Total Income $24.4M'` —
anchored `^Total Income$` matched **nothing**, while un-annotated rows matched fine. **The bug was
invisible in 4 of 6 cases.** Resolve a row's name from cells **left of the TOTAL column**; treat
everything right of it as annotation (which is how the targets get read for free). Also: find rows by
**label, never by index** — account `4210 · Fuel Surcharge` appeared for the first time in June and
shifted every row beneath it.

## Related
- [[monthly-cfo-reconciliation]] — the monthly procedure this plugs into.
- [[gsts-2026-earnout]] — the earnout strategy and H2 recovery play.
- [[gsts-adjusted-ebitda]] — the book-vs-deal EBITDA bridge (Steve's open item).
