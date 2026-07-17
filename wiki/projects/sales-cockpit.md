---
title: Sales Cockpit
type: project
domain: work
track: 1
status: parked
tags: [sales-engine, crm, cockpit, workbench, bid-on-ramp]
applies: ["[[gsts-ui-style-guide]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[bid-process-reengineering]]", "[[scott-manager-dashboard]]", "[[pricing-guide-bid-prefill]]", "[[sales-engine-prototypes]]"]
updated: 2026-07-04
---

# Sales Cockpit

**One-liner:** The ONE consolidated front door for selling + bidding — folds 4 overlapping experimental pages (Arborist Workbench + Market Clusters + Customer Leads + My Jobs) into one cockpit over a customer relationship-profile spine, every site → drill → bid on-ramp.
**Status:** 🟢 active — #180 shipped (per-column dollar totals in the colored header bars: bidding=bidAmt, others=produced $; live-recompute; play-verified). #174 (property-name search + bid-out badge + orphans retired); Aspen reconciled to canonical defs. Owed: per-stage buttons, "Start a bid"→BidQueue, C (widen filter).
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
- **🔀 PIVOT (Skipper 2026-07-04):** cockpit judged too noisy/duplicative → replaced the Map/List/My-Book tabs with ONE **kanban stage-board `ZTest-SalesPipeline.cfm`** ("organize by what to do NEXT, not by tool"). 5 cols: Follow-up-now (dry) / Bidding / Won-schedule / Working / Recently-done. Reuses the profile drawer + search; Book selector + running-dry filter; Board/Map toggle (map = a lens). **Scott's sell-ahead flag built in:** account with no future WO **and** no approved go-ahead/proposal → red "Running dry, call the PM." Ship-log #105 (+#106 Work Kanban). Deployed play D:\, old cockpit untouched. **STILL OWED:** per-stage action buttons; a version where "Start a bid" pushes to arbor-core (`Workbench.dbo.BidQueue`); retire the 4 old pages via a Prototypes tab on `Reference-RepairsAndScheme.cfm`.

## Related
- [[bid-process-reengineering]] — the cockpit is the SHELL; the 5 stages are what happens inside it.
- [[scott-manager-dashboard]] — Workbench My Jobs / Re-bid Radar feed the List/Book views.
- [[pricing-guide-bid-prefill]] — plugs in at the bid on-ramp (Stage-3 pricing).

## ✅ 2026-07-16 — "can't find my job" repair (#174) + Aspen alignment
- **Root cause (Skipper: searched "Northwood", missing):** cards labeled by account name only; search = name+company+mgr+city. The $107K "Northwood Estates" bid showed as "Northwood II HOA", unfindable. (NOT the stage bug.)
- **A shipped:** cards now show the **property name** (JobAddress line-1, `PropName` via CROSS APPLY) as a sub-line + search folds in `prop`+`addr`. **B shipped:** active account w/ an open bid keeps its work column but shows a blue **"Bid out $X" badge** (Skipper chose badge over moving). **D:** retired the 7 `ZTest-Cockpit*/ZTest-SalesPipeline*` orphans on play (`.ORPHAN` + Jasonsrepairs) + archived local — **the live file is `Dashboard-SalesCockpit.cfm`, not the ZTest ones** (Skipper caught this). Backup-first, render-verified 0 CF errors, ship #174.
- **C deferred (held, not discarded):** widen the InProcess/Pending filter to include Active-status accounts with open bids (~700, many stale).
- **Aspen reconciled:** the cockpit is now the **canonical** source for pipeline signal defs (open-bid=Proposals 41/106 sent<6mo; running-dry=forward book<3mo + no fresh bid). Aspen's running-dry regenerated to the cockpit-exact set (223→**80**); property naming propagated. See `aspen-knowledge/business-development/CANONICAL-cockpit-alignment.md`.
- ⚠️ Known limit: property name = JobAddress line-1, imperfect (sometimes a contact/street) in BOTH systems — a recognizer aid.

## ✅ 2026-07-17 — running-dry recurring-account fix (deploy walkthrough) + data-gap flagged
- **Fix:** running-dry no longer flags actively-serviced RECURRING accounts (recent completed work ≤60d + a booked upcoming WO). Recurring maintenance books ~1mo ahead, so the raw "<3mo forward book" rule was false-flagging every recurring account (Skipper caught: Newport Coast Shopping Center under Irvine Co Retail = ~40 active centers). Ship #184, live on play, Newport Coast now clears; 52 still flagged (628 clear).
- **⚠️ Canonical def changed → re-sync Aspen** (its running-dry mirrors the cockpit).
- **▶ Bigger data fix owed (Skipper):** recurring commercial contracts aren't recorded in TRIM IT (only expired-2021 rows) → no real forward look-ahead. See [[trimit-recurring-contract-lookahead-gap]].

### running-dry: segment-scoped grain (final, 2026-07-17)
- **Commercial (ProjectTypeID=4):** account grain — not dry if the company is actively serviced (`ca.active`: future booked work + recent completed <=90d across any site). Fixes Irvine Co Retail's ~40 centers.
- **HOA / Municipal (type<>4):** per-property — clears only if THIS site had work <=60d, so a dying HOA under a busy management company still surfaces (mgmt cos aggregate many independent HOAs under one CompanyID).
- SQL: `RunningDry ... AND (p.ProjectTypeID <> 4 OR ca.active = 0) AND (dc.d IS NULL OR dc.d < 60d)`. Board flags 32 real. Still owed: Aspen re-sync + the [[trimit-recurring-contract-lookahead-gap]] data fix.
