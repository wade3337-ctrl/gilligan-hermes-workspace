---
title: Sales Engine Prototypes
type: project
domain: work
track: 1
status: proposal
tags: [sales-engine, prototype, recon, rfp-intake, e-traveler, live-inventory]
links: ["[[bid-process-reengineering]]", "[[sales-cockpit]]", "[[pricing-guide-bid-prefill]]"]
updated: 2026-07-02
---

# Sales Engine Prototypes

**One-liner:** The RFP-intake / e-traveler / live-inventory-capture spikes that prove each stage of the flagship bid re-engineering in the TRIM IT V1 proving ground before they become the arbor-core framework.
**Status:** 📝 proposal — **recon only, no builds.** Phase-1 recon (read-only forensics) done; unblocks the live field-inventory-capture extension.
**📁 Location:** `arbor-stack/sales-engine/`
**▶️ Resume:** `arbor-stack/sales-engine/phase1-recon.md`

## What the recon proved (READ-ONLY, PLAY, 2026-06-28)
- **Q1 — bulk → billing works in prod today, correctly Qty-scaled.** `UpdateInventoryDetailPrice` sets per-unit `Price = BasePrice × AccessFactor`; the Qty multiply happens at the proposal/invoice line (`TotalPrice = Qty × Price`). Verified on real Laguna Sands proposed + invoiced rows.
- **Q2 — no blocking DevMark/IsNewPlot filter.** No pricing/proposal/invoice/summary builder filters on those flags; the real on/off switch is **`DoNotCount`** (+ Inactive status, IsKitItem).
- **Q3 — no QC/"confirmed" gate on billing.** `Confirmation*` cols essentially unused (168/97,633 field rows); live capture doesn't need a confirmed state to be billable.
- **Q4 — bulk re-count/dedup is manual + key-less.** Re-count = insert new row + hand-set old row `DoNotCount=1`, scoped by `InventoryBatchID`/`BatchDate`/`SeasonID`. **No natural dedup key on bulk** = the unanimous crew blocker for live bulk capture.

## State & flags
- Proposal line Qty is a **snapshot decoupled from live Qty** — re-counting after a proposal is issued won't retro-change issued docs (good for integrity; needs a regenerate step to reach billing).
- ⚠️ **No auth on the field write path** (`?ZUserID=`, defaults 69) — `LastModifiedByID` (only entry-user audit) is spoofable; showstopper for exposing more write surface.
- Prototype candidates (from the flagship): info@ → draft RFP · auto-assemble E-Traveler · Price Buddy inline · one-click Go-Ahead activate.
- See also `fieldapp-discovery.md` (write path), `PROTOTYPE-03-live-inventory-capture.md`.

## Related
- [[bid-process-reengineering]] — the future-state these prototypes build toward.
- [[sales-cockpit]] — the shell the prototypes drop into.
- [[pricing-guide-bid-prefill]] — the pricing spike, already in flight.
