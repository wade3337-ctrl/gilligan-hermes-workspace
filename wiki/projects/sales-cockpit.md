---
title: Sales Cockpit
type: project
domain: work
track: 1
status: parked
tags: [sales-engine, crm, cockpit, workbench, bid-on-ramp]
applies: ["[[gsts-ui-style-guide]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[bid-process-reengineering]]", "[[scott-manager-dashboard]]", "[[pricing-guide-bid-prefill]]", "[[sales-engine-prototypes]]"]
updated: 2026-07-02
---

# Sales Cockpit

**One-liner:** The ONE consolidated front door for selling + bidding — folds 4 overlapping experimental pages (Arborist Workbench + Market Clusters + Customer Leads + My Jobs) into one cockpit over a customer relationship-profile spine, every site → drill → bid on-ramp.
**Status:** ⏸️ parked — **P0-P2 done, parked mid-P3** (bid on-ramp); the 4 old pages not yet retired.
**📁 Location:** `arbor-stack/sales-engine/ZTest-Cockpit*.cfm` (+ `-Search/-Profile/-List/-Book`); spec `SALES-COCKPIT-spec.md`
**▶️ Resume:** `arbor-stack/sales-engine/SALES-COCKPIT-spec.md`

## Applies / uses
- [[gsts-ui-style-guide]] — page has NO charset meta → keep additions ASCII (entities in innerHTML, `\u` escapes); welcome modal + "?" pro-tips.
- [[gsts-ui-spec]] — UI tokens/styling; emoji `.cfm` → UTF-8 BOM.
- [[repair-contract]] — backup-first (backups under `Jasonsrepairs\cockpit-*` / `workfinder-*`), render-verify, log to ship-log.
- Relationship spine = `Companies`→`Projects`(CompanyID)→`Locations`/`Contacts` + `CompanyGroups` (proven: Keystone Pacific → 171 props, 506 contacts).

## State & flags
- **File split (Skipper 2026-06-29):** cockpit is its OWN page (`ZTest-Cockpit.cfm`); **Arborist Workbench (`ZTest-SiteMap.cfm`) preserved untouched**. They evolve independently.
- **P0-P2 DONE + verified on play:** shell + Map/List/My Book tabs · relationship spine (typeahead → company-profile drawer w/ enriched property rows: last work, produced $, TPH badge, WIP) · LIST (age-chip filtered, capped 400) · MY BOOK (per-rep lifecycle + Re-bid Radar w/ persisted RFP status).
- ⚠️ **P3 bid on-ramp PARKED** — Skipper paused mid-recon to design the Work Finder. Chosen resume approach = **A: native wire + resume guard** (`GenerateRFP$User$General` proc INSERTs a Pending RFP → lands on `External$RFP$Detail.cfm`).
- **Work Finder** built as its own page (`ZTest-WorkFinder.cfm`, WF-P0/P1 done) — "where's the work to bid?" surface; WF-P2 (Garrett's follow-up list → `Workbench.dbo.Todo`) not built.
- Caveat: DOM/interaction NOT browser-verified (no headless browser); data endpoints + JS syntax verified independently.
- State persists to the refresh-proof `Workbench` play DB → becomes the arbor-core cockpit.

## Related
- [[bid-process-reengineering]] — the cockpit is the SHELL; the 5 stages are what happens inside it.
- [[scott-manager-dashboard]] — Workbench My Jobs / Re-bid Radar feed the List/Book views.
- [[pricing-guide-bid-prefill]] — plugs in at the bid on-ramp (Stage-3 pricing).
