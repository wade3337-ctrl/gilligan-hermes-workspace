---
title: Goodman Portfolio RFP bid (via Gothic)
type: project
domain: work
track: 1
status: active
updated: 2026-07-23
applies: ["[[trimit-gps-import-pipeline]]", "[[repair-contract]]", "[[herman-agent]]", "[[our-work-kanban]]"]
links: ["[[PROJECTS]]", "[[sales-cockpit]]", "[[50m-growth-goal]]"]
---

# 🌳 Goodman Portfolio RFP bid (via Gothic)

**One-liner:** Bid the entire **Goodman industrial portfolio** tree-trimming — **~28 biddable properties / ~6,400 trees, LA + Inland Empire** — as a **subcontractor to Gothic Landscape Maintenance** (Lacy Anderson). Our relationship is **Rebekah Barker's**. **DUE 2026-08-03.** Kanban: trimit board card **56** (New builds).

## The ask (from the RFP)
- 3-year contract (2026/27/28). Client wants **cost AND estimated labor hours** per property. Reactive $/hr rate too.
- **Per-property awards** (not all-or-nothing) → each property = its own priced bid/e-Traveler.
- They supplied a **complete GPS tree inventory** (Schedule 2 — Woodworks **May-2026** survey): species, DBH, height, condition, recommended maintenance, lat/long per tree.

## Files
- `inbox-pull/goodman-rfp-2026-07-22/` — RFP PDF, **Schedule 2** (inventory xlsx, 6,305 rows), **Schedule 3** (bid sheet), `property-roster.md` (34 deduped properties w/ address/GPS/counts/owner-LLC).
- Email source: forwarded to gilligan.gsts gmail, "FW: RFP - Goodman Portfolio - DUE 8/3".

## Account structure (LOCKED 2026-07-22)
- **Company = Gothic Landscape Maintenance (CompanyID 301382)** — standard Gothic pattern (they pay us).
- Each property = its own **Project + Location** under Gothic; **ProjectName + BillingRef = Goodman property name**; bill-to Gothic. Goodman identity lives at project level, not company. (Existing "Goodman Properties" 301482 is the old direct relationship — not used.)
- **RFP May-2026 survey = the single source of truth** for inventory (newer than TRIM IT's Sept-2024 data). Load fresh for every property — don't reconcile stale counts.

## Build method — the RIGHT way (learned the hard way)
Build via **TRIM IT's official GPS import**, NOT raw SQL inserts. Full pipeline + all field mappings + gotchas → **[[trimit-gps-import-pipeline]]**. Herman's complete converter spec: `vault-inbox/trimit/procedures/rfp-to-trimit-field-mapping.md` (his vault → synced to Skipper's Obsidian).

## Property map (Herman Task 2)
34 inventory properties, 6,304 trees. Because the RFP survey = source of truth, treat ALL as fresh import (~8 truly build-new: Eastvale ×4, Fullerton ×4; ~20 have stale existing projects). **Reconciliation flags:** **Anaheim (DCX8, 98 trees)** is in the inventory but NOT on the Schedule-3 bid sheet → **confirm scope w/ Rebekah** (likely OUT). **GG Santa Fe Springs** = "N/A, trimming not recommended" → excluded.

## ✅ PILOT COMPLETE + verified (2026-07-23) — GLC Fullerton Bldg 4
**Project 1105465 / Location 1285096**, 81 trees. Built end-to-end by **Boss Herman** across Tasks 4–6 (his first real write work — [[herman-agent]] now has play-write). Verified in DB + visually:
- Official GPS import → full FK chain (zip-region 129778, District 19082→ZoneDef 8827, Season, ServiceType=Structural Pruning) → **dots render on field map** (SelectedPoints=81, IsNewPlot=1) → **all detail fields populated** the surveyed-tree way (SizeCode `0-6` + SizeModelSizeID 8, HeightRange, PruningFrequency, SpaceSize/GrowSpace) → 81 Observations → LocationCompany set.
- Backups on PLAY: `dbo.HermanBackup_*Task4/5/6*` + `HermanBackup_FullertonB4_*`.

## ✅ SOP lifecycle audit (2026-07-23, Herman built → Gilligan-verified) — gates 1–9 complete
Herman audited the pilot against the 4 SOPs (rfp-handling/intake/go-aheads/arborist-workflow) and filled the missing **bid-workflow records** (we'd built inventory but skipped the RFP itself): created **RFPID 1972953** + set the project Setup fields. **Gilligan independently verified every field in the live DB** — all correct:
- RFP 1972953 → ProjectID 1105465, Type 2, Status 157 (Pending), SalesRep 1143 (Rebekah), ProposalDue 2026-08-03, `RFPNote001 = ==New Site No History==`, scope in Desc1 (SOP format), NeedMap/NeedPricing/NeedRecs/NeedProposal=1. Exactly **1** RFP on the project (no test dupes).
- Project 1105465 → CurrentYear 2026, FiscalYearConfirmed 1, ProjectNewSiteNoHistory 1, Status 104 (InProcess).
- Skill bumped → `commercial-portfolio-bid-pricing v1.1.0` (15-gate RFP→GoAhead checklist, pitfall #15). Herman ship #79.
- **Minor/non-blocking:** `NeedSiteWalk` is NULL (decide if a walk is wanted for a new site); one benign `GENERAL`/Pending RFPAction (692910) has `UserID` NULL — real pending RFPs route via SalesRepID, so harmless.

## ▶️ RESUME (next session) — gates 10–15 walkthrough (Skipper teaching)
Skipper walks the remaining lifecycle: **E-Traveler → Pricing Worksheet → Project Master → Arborist/IQC → Proposal → GoAhead → Work Order.** The crux inside that:
1. **PRICING = the last standalone piece.** The GPS importer does **NOT** run Price Buddy → all prices null, no labor hours. **✅ METHOD CRACKED (2026-07-23):** price from **TRUE labor** = median `InvoiceLines.HoursEach` (species×size×service) × **$130/hr** × access — NOT the circular price-derived back-solve. Full recipe + pilot numbers → **[[pricing-true-labor-method]]**. Herman ran the 81-tree pilot (ship #80): **~$5,455 / 42 hrs** on the fallback version.
   - **⚠️ Import bug found (2026-07-23):** 62% of pilot trees fell to the generic size-fallback because the importer made **duplicate `InventoryGroups` in category 197 "UNDEFINED"** instead of matching the existing catalog → orphaned from history. **Exact catalog mappings** (all real species w/ big samples): London Plane→"Sycamore - London Plane" (0.529hr, N=1348) · Brisbane Box→"Tristania (Brisbane Box)" (0.525hr, N=11,613) · S.Magnolia→"Magnolia" (0.560hr, N=8577) · Afghan Pine→"Pine - Eldarica" (0.501hr, N=967). **Mapped bid ≈ $5,406 / 41.6 hrs** — moved <1% (validates the fallback) but now 100% real species history. See [[pricing-true-labor-method]] + LESSONS.
   - **✅ PORTFOLIO SPECIES CROSSWALK DONE (v3, 2026-07-23, Herman built → Gilligan-verified over 3 passes).** 58 RFP species → 53 matched (4 Skipper-confirmed + 49 auto) + 5 provisional (arborist may override). File: `.hermes/home/vault-inbox/trimit/procedures/goodman-species-crosswalk.md` + Workbench table + import-skill pitfall #16. Two-phase rule: correct species/cultivar first, then most-0-6-history among **same-plant** dups only (never cross species / dissolve cultivars for volume). Verify caught: African Sumac→259, Callery Pear→247(Bradford), Elm Hybrid→287, and reverted over-corrections Marina→29 / Little Gem→844. Micro-note (non-blocking): Bottlebrush Red(10 trees)→46 "Lemon"; slightly cleaner=1852 "Bottlebrush Spp." — immaterial. Ship #81-83. Lessons in LESSONS.md.
   - ▶️ **Next:** (a) **fix the converter/import to USE the crosswalk** (match RFP species→catalog ID, kills UNDEFINED-dupe orphaning for all 28 properties); (b) **scale true-labor pricing to all ~28** via the crosswalk; (c) Fullerton pilot UNDEFINED-species remap = separate backup-first step; (d) TRIM IT price-write = separate backup-first greenlight.
2. **Then scale** the proven pipeline + converter spec to the **other ~27 properties**.
3. **No-source fields** (need site data from Gothic, not in RFP): Crown, on-site LocationContact/Phone/Fax/Email/AccessInstructions.
4. Confirm **Anaheim** scope with Rebekah.

⚠️ All on **PLAY** (reverts nightly except .cfm). Prod deploy is a separate step. PLAY-only guardrail held throughout.
