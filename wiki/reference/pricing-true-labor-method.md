---
title: Pricing — TRUE labor from HoursEach (not price-derived)
type: reference
domain: work
track: 1
status: active
tags: [pricing, price-buddy, labor, hourseach, tph, estimating-engine, bid, arbor-core-stage3]
applies: ["[[repair-contract]]"]
links: ["[[pricing-guide-bid-prefill]]", "[[bid-process-reengineering]]", "[[goodman-rfp-bid]]", "[[trimit-stack-and-tph]]"]
updated: 2026-07-23
---

# Pricing — TRUE labor from `HoursEach` (the method that replaces the circular one)

**One-liner:** Price a tree job from **actual booked labor hours**, not from what we charged last time. Discovered 2026-07-23 while pricing the Goodman pilot; this is the estimating core for BOTH the V1 "Price Buddy" upgrade AND the arbor-core Stage-3 pricing engine. **Don't lose this — everything downstream is built on it.**

## The key facts (verified in the live DB)
- **`TPH` = dollars per hour**, NOT trees per hour. `Invoices.TPH = Total ÷ TotalHours` (confirmed: e.g. $2,295 ÷ 11.77 hr = $195/hr). **Target TPH = $130/hr** (`dbo.GetSystemListItem('Targets','TargetTPH')`).
- **`InvoiceLines.HoursEach`** = the **actual hours booked per tree**, already split by species × size × service. This is measured labor, independent of price. ← the gold field the old engine ignores.
- Mapping for structural pruning of small trees: **ServiceType 75 (Structural Pruning) → ServiceClass 1 (Trimming)**; **SizeCode `0-6` → size class `XSML`** (per the location's SizeModel).

## The OLD (broken) way — why it's circular
- `dbo.GetLevel4PriceRange$TPH` returns historical **BasePrice** (what we charged) + AVG(TPH) + Qty, filtered `HAVING AVG(TPH) < Target+20` (backwards — keeps LOW-$/hr points).
- `js/pricing-helper-v2.js` then back-solves **hours/tree = price ÷ TPH** and recommends **price = Target$/hr × hours/tree × access**.
- Algebraically that collapses to **newPrice = oldPrice × (130 ÷ the $/hr we hit)** — a *re-markup of old prices*, not a labor estimate. If we underpriced before, it stays low. Circular.

## The NEW (true-labor) way — the recipe
1. **Pull measured hours per tree** from `InvoiceLines.HoursEach` joined to `InventoryDetail` (species/size) + `ServiceTypes→ServiceClasses` (service). Filter to the target species × size × service class.
2. **Clean:** drop `HoursEach <= 0` and absurd highs (start cut: `> 20`; raw data ranges $0–$36,860/hr → real junk exists). Use the **MEDIAN**, not the mean.
3. **Min sample:** require **N ≥ ~8** lines and **show N**. A median off 1–2 invoices lies.
4. **Hierarchical fallback** when a combo is thin/empty: `species×size` → **`size-level` (all species at that size)** → `service default`. Flag which tier each number came from.
5. **Compute:** `labor hours = Σ(median hrs/tree × tree count)`; `price/tree = median hrs/tree × TargetTPH($/hr) × access`; `line = price/tree × count`.
6. **Access multiplier** (1 / 1.25 / 1.5 easy/med/hard) and final margin stay **human judgment** on top.

## Pilot proof — GLC Fullerton Bldg 4 (Proj 1105465, 81 trees, 0–6″ Structural Pruning)
Median `HoursEach` @ 0–6 Trimming: **Redbud 0.29** (N=850) · **Oak 0.45** (N=815) · **Olive 0.57** (N=675) · **Marina 0.56** (N=363) · **Pistache 0.42** (N=103). No/thin history → **fallback 0.54 hr/tree** (all-species @ 0-6): London Plane (21), Brisbane Box (n=1), S. Magnolia (6), Afghan Pine (3). At $130/hr → ~$38/$58/$74/$73/$54 per tree; fallback ~$70. **≈42 labor hrs / ~$5,480 base** for the property (before access/margin). Sanity: true-labor prices land on top of historical workhorse prices (Olive $74 ≈ the $75 we charge) → validates, now defensible + yields the **labor-hours** the RFP demands.

## Honest limits (carry these forward)
- **Selection bias:** history = WON work → a **floor, not a ceiling**. Add a market-override lever.
- **Access/canopy not in the data** → multiplier + judgment, not measured.
- Fixes several crew-flagged Price Buddy defects (circular hours, thin-combo noise, no-fallback). See `arbor-core/docs/reviews/2026-07-01-plan-review-SYNTHESIS.md`.

## Where this gets used
- **V1 Price Buddy upgrade:** replace the `GetLevel4PriceRange$TPH` + `pricing-helper-v2.js` price→hours back-solve with this HoursEach-median estimator. → [[pricing-guide-bid-prefill]].
- **arbor-core Stage-3 pricing engine** inherits the same recipe. → [[bid-process-reengineering]].
- **Goodman portfolio bid:** price all ~28 properties this way. → [[goodman-rfp-bid]].
