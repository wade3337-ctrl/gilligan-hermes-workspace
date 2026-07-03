---
title: arbor-core — Municipal Bid Branch
type: project
domain: work-arbor-core
track: 2
status: proposal
tags: [arbor-core, municipal, rfp, dir-wage, prevailing-wage, confidential]
applies: []
links: ["[[arbor-core-onestop-ui]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-strategy-foundation]]"]
updated: 2026-07-03
---

# arbor-core — Municipal Bid Branch

**One-liner:** A SEPARATE branch of the sales engine for municipal work — the Arbor AI flagship **"Municipal Tree Bid Manager."** Municipal pricing is fundamentally different from the commercial reconciler (the CITY issues the RFP; you fill THEIR bid schedule competitively with **DIR prevailing wage**; win = low/best responsive bid; award = a multi-year contract with LOCKED unit prices). Three phases: **BID → (if won) CONTRACT → EXECUTE against contract prices.**
**Status:** 📝 proposal — direction captured (Skipper 2026-07-01), not yet built. **Decision pending: spec the muni tool now vs. polish the commercial reconciler first.**
**📁 Location:** `arbor-core/docs/`
**▶️ Resume:** `arbor-core/docs/MUNICIPAL-BID-BRANCH-direction.md`

## Applies / uses
- **Reuses the commercial reconciler's cost engine** ([[arbor-core-onestop-ui]]) — hours × access × equipment × loaded cost, TPH discipline — but loaded with **DIR prevailing wage + fringe + burden**. DIR wage belongs HERE, not bolted onto the commercial tool (which is exactly why it was deferred).
- Municipal segment = `ProjectGroupDefID=11` (metric standard).

## State & flags
- **Draft scope:** (1) RFP intake/parse — bid schedule / unit-price lines, ANSI A300 specs, wage determination, dates, bonding/insurance. (2) Cost build-up per bid-schedule line (reuse cost engine + DIR wage) → competitive bid price. (3) Competitive positioning (margin vs win-probability; prior-award history). (4) Bid assembly in the city's required format + compliance packet. (5) Contract execution — awarded unit-price schedule becomes the pricing SOURCE for every WO under it (quote pulls CONTRACT prices, not computed fresh).
- **Build-on material (don't start cold):** `arbor-stack/Arbor AI/Brents Muni Pricing` · `Riverside Bid AI` · `Budget project` (real muni history) · `sales-engine/PROTOTYPE-01-intake-rfp-draft.md` · the RFP SOP · roadmap N1 (Municipal Tree Bid Manager).
- ⚠️ Gated on the Skipper's next decision (spec now vs polish commercial first).

## Related
- [[arbor-core-onestop-ui]] — supplies the cost engine this branch wraps; DIR-wage was deferred to here.
- [[arbor-core-rfp-automation]] — the `formal_rfp` archetype (B1) is the municipal intake front.
- [[arbor-core-strategy-foundation]] — a second sales-engine branch under the same product.
