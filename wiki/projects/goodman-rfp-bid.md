---
title: Goodman Portfolio RFP bid (via Gothic)
type: project
domain: work
tags: [rfp, bid, goodman, gothic, gps-import, herman]
track: 1
status: active
updated: 2026-07-25
applies: ["[[trimit-gps-import-pipeline]]", "[[repair-contract]]", "[[herman-agent]]", "[[our-work-kanban]]"]
links: ["[[PROJECTS]]", "[[sales-cockpit]]", "[[50m-growth-goal]]", "[[play-gsts-is-ephemeral]]", "[[prod-backup-chain]]"]
---

# 🌳 Goodman Portfolio RFP bid (via Gothic)

> 🧨 **2026-07-25 — ALL THREE BUILDS WIPED.** The nightly restore ([[prod-backup-chain]]) re-applied a 7/22 backup, erasing projects **1105465** (Fullerton pilot), **1105467** (Eastvale, 313 trees) and **1105468** (El Monte, 298 trees) plus LocationIDs 1285095/96/97 and Herman's in-flight El Monte fixes. **Survived:** the `Workbench.dbo.*_bak_*` snapshots (full tree rows), all source xlsx/answer keys, and the recipe [[trimit-gps-import-pipeline]]. Skipper: *"no big deal — an opportunity to run another build test."* **Parked pending his call.**
> ▶️ **Recommendation on the table:** don't hand-rebuild. Have Herman write ONE parameterized, idempotent build script (project → location → trees → address FKs → height model → publish) and run it for all three — it tests the recipe just as hard, survives the nightly wipe, and is the tool needed for the remaining 26 properties. → [[play-gsts-is-ephemeral]]

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

## ✅ PROPERTY 2 — Eastvale (proj **1105467**), publish + full field population (2026-07-24)
Herman built; Gilligan verified live off play. **PUBLISH WORKS** — 313 trees, `IsNewPlot=0` on all (grey dots + info-card, no blue = "complete"), `apiCall.cfm` GeoJSON generator contract-correct, backup kept, PLAY-only. Mechanism → `trimit-knowledge/procedures/gps-publish-info-card-mechanism.md`.
⚠️ **Trees resolve via `Projects.LocationID → InventoryDetail.LocationID`, NOT `InventoryDetail.ProjectID`** (unset on GPS rows). My first pass queried ProjectID, got 0, and wrongly reported "trees wiped / publish gate missing." → LESSONS.
⚠️ *The 07-24 log records Eastvale's LocationID as **1285096**, which collides with the Fullerton pilot's above — confirm which is right before reusing either ID.*

**Skipper's drill-down punch list — COMPLETE, one at a time, each verified:**
- **Tree ID (GSTSID)** ✅ card read "tree id 0" because GSTSID was NULL on all 313; customer tags lived in `LegacyRef` (2043–2937). `LegacyRef`→`GSTSID`, 313/313. Safe — **GSTSID is per-site, not globally unique.**
- **Address** ✅ Herman replicated Irvine's **4-field model** (StreetNumber + StreetName + `StreetNameID`→StreetNames + `LocationStreetID`→LocationStreets); created 2 streets (GOODMAN WAY ×112, BELLGRAVE AVE ×201), joined per-tree by tag. Verify: **313/313 match the source sheet on street AND number, 0 mismatch, 0 orphan FK, 0 unmatched tag.** Backup `Workbench.dbo.InventoryDetail_bak_address_1285096_20260724`.
- **Observations** ✅ **not broken** — the records show in the real **Observations tab**; the Details-tab "Observations:" field is `LineNote001`, which the import ignores. Closed, no fix.
- **Height** ✅ numeric was NULL (only the bucket set). Location height dropdowns are scoped to the location's HeightModel and the default ("USC", ID 2) is **shared by 35 locations → untouchable**; so Herman created a dedicated **HeightModel 11 "Goodman Survey (10ft bands)"** + 4 ranges (0-10/11-20/21-30/31-40 ft), repointed the location, set all 313 by tag. Verify: 313/313 match the sheet, 0 off-model, JSON regenerated.
- 🧹 **Landmine cleared for backup:** 197 orphaned `InventoryGPSModel` staging rows for proj 1094998 "USC Contract" — **it's a GLOBAL staging table**, so they'd contaminate the next import. Assessed as **2014 leftovers already in InventoryDetail** → safe to clear; backed up to `Workbench.dbo.InventoryGPSModel_bak_USC1094998_20260724`. ⏳ **Awaiting Skipper's nod on the `DELETE FROM dbo.InventoryGPSModel WHERE ProjectID=1094998`** (only bites at the next import).
- 📄 Reusable recipe for the other 27 properties → `trimit-knowledge/procedures/gps-inventory-import-pipeline.md`.

## 🧪 PROPERTY 3 — El Monte Bldg 1 (proj **1105468** / Loc **1285097**), Herman solo — STRONG PASS, 1 gap
Skipper had Herman build a second property **unaided** to test generalization (new county, 15 species). Verified tag-by-tag against `inbox-pull/goodman-rfp-2026-07-22/elmonte-bldg1-verify-answerkey.md`:
- ✅ 298 trees, tags 4382-4795, 0 duplicate GSTSID, IsNewPlot cleared, Condition/LZR/lat-lng all 298.
- ✅ **Height 298/298** match the sheet (dedicated HeightModel 17). Nit: 4 bands created, only 3 used (templated from Eastvale).
- ✅✅ **Species 15/15 correct including the hard aliases** — Christmasberry→Toyon, Afghan Pine→Pine-Eldarica, Chinese Flame Tree→Koelreuteria-Bipinnata, Goldenrain→Koelreuteria-Paniculata, African Sumac→Rhus. The trickiest step, nailed.
- ❌ **Address incomplete (the one gap):** StreetNumber + StreetName text correct (4300 NORTH SHIRLEY AVE) but **`StreetNameID`=0/298 and `LocationStreetID`=0/298** — the two FK links skipped. A regression against his own Eastvale build; fix = Eastvale address recipe steps 3-4.

### ⏳ IN FLIGHT — verify when Herman reports
1. **Address FKs** → expect 298/298 on both, 0 orphan FK, drill-down showing "4300 NORTH SHIRLEY AVE, El Monte".
2. **Pricing worksheet** was blank. **DB counts EXIST** (`InventorySummary`=15, 298 trees; Price=0 is normal pre-Price-Buddy) ⇒ it's a **worksheet GENERATION** issue. Verify it's fetched from **El Monte's own ProjectID 1105468** (`ReportDev/Project$PricingWorksheet$…cfr?ZProjectID=1105468`) with **El Monte's address baked in** — NOT copied from another property (that trap = `genuine-pricing-worksheet-overlay.md`) — and shows the 298-tree counts by species/service.

## ▶️ RESUME (next session) — gates 10–15 walkthrough (Skipper teaching)
Skipper walks the remaining lifecycle: **E-Traveler → Pricing Worksheet → Project Master → Arborist/IQC → Proposal → GoAhead → Work Order.** The crux inside that:
1. **PRICING = the last standalone piece.** The GPS importer does **NOT** run Price Buddy → all prices null, no labor hours. **✅ METHOD CRACKED (2026-07-23):** price from **TRUE labor** = median `InvoiceLines.HoursEach` (species×size×service) × **$130/hr** × access — NOT the circular price-derived back-solve. Full recipe + pilot numbers → **[[pricing-true-labor-method]]**. Herman ran the 81-tree pilot (ship #80): **~$5,455 / 42 hrs** on the fallback version.
   - **⚠️ Import bug found (2026-07-23):** 62% of pilot trees fell to the generic size-fallback because the importer made **duplicate `InventoryGroups` in category 197 "UNDEFINED"** instead of matching the existing catalog → orphaned from history. **Exact catalog mappings** (all real species w/ big samples): London Plane→"Sycamore - London Plane" (0.529hr, N=1348) · Brisbane Box→"Tristania (Brisbane Box)" (0.525hr, N=11,613) · S.Magnolia→"Magnolia" (0.560hr, N=8577) · Afghan Pine→"Pine - Eldarica" (0.501hr, N=967). **Mapped bid ≈ $5,406 / 41.6 hrs** — moved <1% (validates the fallback) but now 100% real species history. See [[pricing-true-labor-method]] + LESSONS.
   - **✅ PORTFOLIO SPECIES CROSSWALK DONE (v3, 2026-07-23, Herman built → Gilligan-verified over 3 passes).** 58 RFP species → 53 matched (4 Skipper-confirmed + 49 auto) + 5 provisional (arborist may override). File: `.hermes/home/vault-inbox/trimit/procedures/goodman-species-crosswalk.md` + Workbench table + import-skill pitfall #16. Two-phase rule: correct species/cultivar first, then most-0-6-history among **same-plant** dups only (never cross species / dissolve cultivars for volume). Verify caught: African Sumac→259, Callery Pear→247(Bradford), Elm Hybrid→287, and reverted over-corrections Marina→29 / Little Gem→844. Micro-note (non-blocking): Bottlebrush Red(10 trees)→46 "Lemon"; slightly cleaner=1852 "Bottlebrush Spp." — immaterial. Ship #81-83. Lessons in LESSONS.md.
   - **✅ IMPORTER FIXED + verified (v-dry-run, 2026-07-23, Herman built → Gilligan-verified, ship #84).** Crosswalk-first species resolution wired into the import chain (joins `InventoryGPSModel.SPECIES`→`Workbench.dbo.GoodmanSpeciesCrosswalk`→catalog ID, **takes precedence over the fuzzy `GetBestInventoryGRoup`**; unmatched→flagged, never cat-197). Verified: crosswalk table = 59 rows, **0 cat-197 targets, 0 nulls**; Fullerton dry-run → 50 orphans resolve to real IDs, 31 stay correct, zero UNDEFINED. Every future property import now lands on real pricing history.
   - **✅ Fullerton remap DONE + verified (2026-07-23, first DB write, Herman → Gilligan-verified, ship #85).** 50 orphaned trees repointed to catalog IDs (224/284/175/209); Herman updated the **full chain** (InventoryClassID: broadleaves→1, Afghan Pine→12 Pine; 4 new InventorySummary rows). Verified: **all 81 on correct groups, 0 cat-197, SelectedPoints=81 (map intact), pricing history reachable** (224:1348 · 284:11613 · 175:8577 · 209:967 @0-6). Backups: `HermanBackup_FullertonB4_GroupRemap_/InvSummary_20260723`. **Pilot's real-history bid now = the mapped ~$5,406 / 41.6 hrs.**
   - ▶️ **Next:** (a) **scale true-labor pricing to all ~28 properties** via the crosswalk — the RFP deliverable, **due 8/3.** (b) TRIM IT price-write into ProjectInventory = separate backup-first greenlight.
2. **Then scale** the proven pipeline + converter spec to the **other ~27 properties**.
3. **No-source fields** (need site data from Gothic, not in RFP): Crown, on-site LocationContact/Phone/Fax/Email/AccessInstructions.
4. Confirm **Anaheim** scope with Rebekah.

⚠️ All on **PLAY** (reverts nightly except .cfm). Prod deploy is a separate step. PLAY-only guardrail held throughout.
