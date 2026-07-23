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

## ▶️ RESUME (next session)
1. **PRICING = the last standalone piece.** The GPS importer does **NOT** run Price Buddy → all prices null, no labor hours. Figure out **Price Buddy** (how GSTS prices a pruning job by species × size × service). Then the bid = cost + labor hours per property.
2. **Then scale** the proven pipeline + converter spec to the **other ~27 properties**.
3. **No-source fields** (need site data from Gothic, not in RFP): Crown, on-site LocationContact/Phone/Fax/Email/AccessInstructions.
4. Confirm **Anaheim** scope with Rebekah.

⚠️ All on **PLAY** (reverts nightly except .cfm). Prod deploy is a separate step. PLAY-only guardrail held throughout.
