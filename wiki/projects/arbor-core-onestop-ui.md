---
title: arbor-core — One-Stop UI (commercial estimator)
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, estimator, pricing-engine, inventory, georeferencing, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-cockpit-bidqueue-handoff]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-ai-tree-vision]]", "[[arbor-core-municipal-bid-branch]]"]
updated: 2026-07-06
---

# arbor-core — One-Stop UI (commercial estimator)

**One-liner:** The single front-to-back workflow app — **customer → inventory (map) → quote → work order** — on the clean arbor-core DB. FastAPI + single-file preact `index.html`, Postgres + RLS. The commercial/HOA estimating tool is now **feature-complete**.
**Status:** 🔵 active — pricing engine complete; **2026-07-06 Skipper live-testing the inventory + new pricing UI** (see the BUILD SESSION section below). **PINNED:** area-extraction on non-aerial (work-order) maps still not satisfying — revisit with a real aerial-map site.
**📁 Location:** `arbor-core/app/api/` (main.py · index.html · maps_api.py) · `arbor-core/importer/` (georef_map.py · detect_markers.py · bidqueue_import.py)
**▶️ Resume:** this note's **BUILD SESSION** + **PINNED/OPEN** sections · pricing Phase 2 → `arbor-core/docs/PRICING-SHEET-REDESIGN.md` · map-overlay design → `arbor-core/docs/MAP-OVERLAY-API-spec.md`. Live app `http://100.82.161.7:8088`. Kanban cards 21 (map overlay) + 22 (pricing).

## Applies / uses
- [[arbor-core-db-importers]] — schema v1.7 + migrations 0001–0023, RLS spine (`SET app.tenant_id`).
- Specs: `schema/STAGE3-pricing-engine-spec.md` · `docs/decisions/AREA-CLEANUP.md` · `docs/ADR-002-mapping.md`.
- Not the GSTS UI style guide — this is the clean arbor-core app, not a play/TRIM IT surface.

## State & flags
- **Step 0 Customer** ✅ · **Step 1 Inventory (map)** ✅ — tap-to-drop trees (auto asset #, GPS, species from real TRIM IT history), zones (`site_area`, click-to-place corners, color-coded, live membership), **✨ Tidy-up (geometric cleanup, fail-safe)**, right-click pin/map Details/Copy/Paste, field UX (📍stamp toggle · 🎯 drop-at-GPS · 📷 native camera), Risk/TRAQ (ISA matrix → color-coded rating).
- **Step 2 Quote — the Pricing Reconciler (Slices ①–④) COMPLETE:** hours→price, live blended-TPH gauge (target 130), non-tree charges (TBD), Price Buddy history-teaching chips (Slice ②, nightly grain 6:00), site-rebid anchor (Slice ③, nightly 6:05), per-year balance + season shift (Slice ④), access ×/equipment × multipliers, actual-vs-planned feedback loop.
- **Legacy-Map Georeferencing (2026-07-02, BUILT):** fully automatic, **~0.2–5.6 m** — render PDF headless → extract yellow zone → geocode → live Esri → **Gemini 3.1-pro vision landmark-match** → affine solve → project zone. Brings old AREA-only commercial jobs into the app for real per-tree GPS. Migration `0023`. ✅ **Auto-pull UNBLOCKED (2026-07-05):** the "PDFs are firewalled, office must upload" assumption was WRONG — `dbo.Maps.ImagePath` gives the real file URL (`…/gsts/Storage/Data/{ProjectID}/*.pdf`, HTTP 200/application-pdf, reachable from our box, prod & play). Recipe in [[PLAYBOOK]] top entry (URL-encode the spaces).
- **Slice 2 Inventory map-overlay + THE CROSSWALK (2026-07-05):** map's printed marker number = TRIM IT `dbo.InventoryDetail.GSTSID` (per-site seq 1..N) → `InventoryDetailID` → arbor-core `tree.asset_number`/`legacy_inventory_id` → `tree_id`. ⚠️ **GSTSID is NOT imported yet** — `bidqueue_import.py` only carries InventoryDetailID; importing GSTSID is the missing link that lets AI place map markers. Detection "returns 0" was a swallowed Postgres cast error (`coalesce(int,'')`), not vision — see [[LESSONS]].
- **Biggest free win — TRIM IT already stores lat/lng for most trees (~1.28M rows):** opportunity scan of 5,987 commercial sites — A full-GPS 362 sites (just import coords) · B ≥90% 210 · **C coordless+labeled+has-map = AI georef TARGET: ~2,004 sites / ~26K trees** · D unlabeled 3,379 (manual only). **Coordinate IMPORT (not AI) is the broad rollout;** AI georef is for bucket C. Culver is GPS-complete → a bad Slice-2 test site; validate on a real bucket-C site.
- **Big-Site Scaling** — handled natively (bbox viewport + grid clustering); see [[arbor-core-cockpit-bidqueue-handoff]] P1 (verified on 5,786-tree Long Beach; scales to 60k+).
- **Area Cleanup / zone tidy** — Phase 1 shipped (simplify + orthogonalize + weld, validates + falls back); CV/vision refinements parked.
- ⚠️ Deferred: photo object-storage (MinIO — currently by-URL) → gates [[arbor-core-ai-tree-vision]]; offline mode; DIR wage → [[arbor-core-municipal-bid-branch]].

## 🔨 2026-07-05/06 BUILD SESSION — map overlay slice 2, pricing redesign, inventory fixes (all committed to arbor-core git)
**Map overlay (Slice 2) — the crosswalk + tiled detector + commit flows:**
- **GSTSID crosswalk IMPORTED** (commit `bb4f459`, migration `0025` `tree.map_label`): `bidqueue_import.pull` now carries GSTSID; backfilled. `detect_markers` matches marker→`map_label`→tree. (The earlier note "GSTSID not imported yet" is now DONE.)
- **Map taxonomy (key learning):** 3 map classes — (1) master species-plan = symbols, NO numbers (not readable); (2) **species "WITH ID" map = numbered per tree → the real target**; (3) plain aerial = nothing plotted. Earlier "52/594 crosswalk proof" was a FALSE POSITIVE (legend totals). Verified by *looking* at rendered maps.
- **Robust tiled-vision detector** (`importer/detect_markers.py`, commit `50e61c6`): crew-converged (Gemini+GLM+Kimi+Codex+Fable) two-pass (map-bbox+marker-style → per-tile reads) + NMS dedup + **anti-hallucination gate** (JS variance patch + grid-reject). VALIDATED on coordless Los Olivos 2 WITH-ID map: **80 palms detected, 0 hallucination, matched map_label 1..81, georef 3.8 m, 80 placed w/ GPS**. Replaced naive single-shot that fabricated a grid.
- **Commit flows (propose→commit, nothing auto-writes):** trees → `GET /proposed-trees` + `POST /commit-trees` (commit `9fd50cd`); areas → **preview→commit** `POST /maps/{id}/commit-area` (commit `0f666ba`); `DELETE /areas/{id}` = Undo (commit `119d67f`).
- **Map picker + separate Extract-areas / Extract-trees** on the inventory page (commit `90b0aca`) — the pulled `site_map` maps; import-PDF kept as fallback. `georef_map.run(mode=areas|trees|both, write=)`.
- **Area COLOR matching** (commit `af47682`, migration `0026` `site.zone_colors`): extracted areas use GSTS's own palette (TRIM IT `dbo.ZoneDefs.ColorCode`→`ColorDefs` hex, prefer zone's stated text over ColorDefID FK), not arbitrary cyan.

**Pricing sheet redesign — Phase 1 built:** group-first **cohort grid** (species×size×zone, history-seeded hrs/tree + green✓/red▼ Last-TPH pill) replacing the flat +species button wall; `GET /sites/{id}/cohorts` + `POST /proposals/{id}/cohort-line` (one-click history-priced line, sets `tree_count` so it prices ×N) (commit `cabe2c6`). Per-zone **access ×** = the Skipper's lever (same trees, harder zone → higher price). 5-lab crew-vetted design + mockup: **`arbor-core/docs/PRICING-SHEET-REDESIGN.md`** + `docs/pricing-mockup.html`. **Phase 2 pending: Profit Lens map · map↔grid sync · evidence-confidence tiers · Tap-to-Rebid.**

**Inventory-page bug fixes (Skipper live-testing):** pin-click dup (bubblingMouseEvents, `6063e40`) · no pre-selected species/size (`cf72b40`) · map corner-jam guard + Undo (`119d67f`) · **customer-switch stale state → `key`=site_id on Inventory/Quote steps** (`6cc25ac`) · **`Cache-Control: no-store` on index.html** (stubborn-cache killer, `2409ae5`) · okLatLng/okPoly guards + area-scan quality gate (`efe2906`).

## ⚠️ PINNED / OPEN (Skipper 2026-07-06 — "still doesn't seem to work right")
- **Area extraction on the Ashford/FirstService site still not right.** Root understanding: Ashford's maps are **work-order/removal sheets, not aerials** → they don't georeference (hard-fail 502 or garbage coords). The guards now stop the map corner-jam and the quality gate refuses to commit garbage, BUT the end-to-end area-scan UX still isn't satisfying the Skipper. **Revisit with fresh eyes.** Needs: a site with a real aerial base map to test area-scan cleanly; possibly a map-type classifier so the picker only offers scannable aerials; confirm the preview→commit feel. Live app: `http://100.82.161.7:8088`.
- Note: `FirstService Residential` customer → `Ashford Place` site is a CORRECT mgmt-company→property link, not a bug.
- Culver + Los Olivos are TEST sites (imported during build); their trees/zones were cleaned but they persist as test data.

## Related
- [[arbor-core-cockpit-bidqueue-handoff]] — feeds real jobs (customer + site + GPS trees) into this app to rebid.
- [[arbor-core-rfp-automation]] — B3 drafting hooks into this pricing engine (MainPlace bid sheet).
- [[arbor-core-ai-tree-vision]] — species/size-from-photo plugs into the inventory + pricing seams.
- [[arbor-core-strategy-foundation]] — the first product slice this realizes.
