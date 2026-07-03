---
title: Bid Process Re-engineering (FLAGSHIP)
type: project
domain: work
track: 1
status: parked
tags: [flagship, sales-engine, bid, traveler, future-state, north-star]
links: ["[[sales-cockpit]]", "[[sales-engine-prototypes]]", "[[pricing-guide-bid-prefill]]"]
updated: 2026-07-02
---

# Bid Process Re-engineering (FLAGSHIP)

**One-liner:** Redesign the whole bid/"traveler" workflow (Skipper's #1) — 11 AS-IS steps collapse into **5 stages (Intake · Scope · Price & Build · Send & Approve · Activate)** around ONE record (the evolved RFP) where every handoff = a status flip + auto-notify, not an email with a PDF.
**Status:** ⏸️ parked — **pending a process-walkthrough session** with the Skipper.
**📁 Location:** `arbor-stack/bid-process-reengineering/` (pairs w/ `AS-IS-WORKFLOW-MAP.md` + 6 SOPs in `sops/2026-revised/`)
**▶️ Resume:** `arbor-stack/bid-process-reengineering/FUTURE-STATE-v0.1.md`

## What it locks in
- **The canonical end-to-end vision:** request qualifies → RFP · inventory+price together · quote builder w/ LIVE TOTALS (seasons/patterns/per-tree serviced) · AI quote-checker suggests fixes · emailed with a **clickable LIVE MAP** (customer clicks trees) · approve by checkbox → auto go-ahead + WOs.
- **North star:** inventory moving **bulk → GPS-serialized per-tree** (3 modes: Bulk / Serialized / GPS); serialized ≠ forced per-tree pricing (bulk-apply to a selection). The bid becomes geospatial + interactive.
- **Design rules locked:** one record = the spine · sales arborist = final authority on scope+price · **no auto-pricing** (surface history/Price Buddy inline) · inventory crew = optional on-demand lane · intake = phone/`info@` email.
- **Finding:** the data model + write path for nearly every step already EXIST in TRIM IT; the build is the connective UI + 2 new pieces (live-totals quote builder, AI quote-checker) + the customer map.

## State & flags
- v0.1 scope = the SALES ENGINE (stages 1-5); downstream scheduling/production/invoicing/accounting = later slice.
- The **Sales Cockpit is the SHELL** this lives inside; the 5 stages are what happens in it.
- Prototype candidates ranked: (1) info@ → draft RFP · (2) auto-assemble E-Traveler button · (3) Price Buddy inline · (4) one-click Go-Ahead activate. Pick the first to build.
- Reference for the arbor-core sales engine (Track 2) — reference, don't copy into the black repo.

## Related
- [[sales-cockpit]] — the unifying shell / CRM front door.
- [[sales-engine-prototypes]] — the spikes that prove each stage.
- [[pricing-guide-bid-prefill]] — the Stage-3 estimating engine.
