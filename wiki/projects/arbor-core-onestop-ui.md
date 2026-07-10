---
title: arbor-core — One-Stop UI (commercial estimator)
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, estimator, pricing-engine, inventory, georeferencing, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-cockpit-bidqueue-handoff]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-ai-tree-vision]]", "[[arbor-core-municipal-bid-branch]]"]
updated: 2026-07-07
---

# arbor-core — One-Stop UI (commercial estimator)

**One-liner:** The single front-to-back workflow app — **customer → inventory (map) → quote → work order** — on the clean arbor-core DB. FastAPI + single-file preact `index.html`, Postgres + RLS. The commercial/HOA estimating tool is now **feature-complete**.
**Status:** 🔵 active — **2026-07-06: numbered-map→GPS-trees pipeline works END-TO-END** (map-corner bug + timeout both fixed; classifier/preview/gating shipped). Skipper live-testing; next = pricing Phase 2. See BUILD SESSION + RESOLVED sections below.
**📁 Location:** `arbor-core/app/api/` (main.py · index.html · maps_api.py) · `arbor-core/importer/` (georef_map.py · detect_markers.py · bidqueue_import.py)
**▶️ Resume:** this note's **BUILD SESSION** + **PINNED/OPEN** sections · pricing Phase 2 → `arbor-core/docs/PRICING-SHEET-REDESIGN.md` · map-overlay design → `arbor-core/docs/MAP-OVERLAY-API-spec.md`. Live app `http://100.82.161.7:8088`. Kanban cards 21 (map overlay) + 22 (pricing).

**⏸️ PAUSED 2026-07-07 — Part (b) non-aerial map zone extraction (RESUME HERE):** georef of CAD/colored plans already works (proof + crew plan → `arbor-core/docs/GEOREF-B-NONAERIAL.md`). **Step 1 (multi-color zone extractor) BUILT + refined** in `importer/georef_map.py` (`run(mode='zones')` + MULTIZONE_HTML + `extract_multizone` + `label_zones`; commits 928ba08, f7efaaa). Verified on La Paz Colored Map: 7 labeled GPS zones on satellite (`memory/multizone-step1-labeled.png`). **NEXT:** polish (gold-zone fragmentation + label-match) → wire `mode='zones'` into `maps_api` + a review/commit UI → confidence gate + control-point confirm. Full detail in `memory/2026-07-07.md`.

**✅ 2026-07-08 EVENING — colored-area extractor FIXED + WIRED LIVE, and "Send Bid" tab shipped** (detail + resume: `memory/2026-07-08.md`; extractor design/checkpoint: `arbor-core/docs/GEOREF-B-NONAERIAL.md`):
- **Extractor fixed** (`importer/georef_map.py`, backup `.bak-20260709-holefill`): interior **hole-fill** (outline parcels fill solid; band zones keep open middles via a white-content guard) + **legend exclusion** (vision bbox; drops swatches <1.2% inside the key box, spares real parcels). Visually proven on La Paz Colored Map (harness: `importer/test-lapaz/`).
- **Wired into the app:** `maps_api` accepts **`mode='zones'`** (preview) + new **`POST /commit-zones`** (each zone → its own site_area); `index.html` "🗺️ Extract areas" now runs the multi-color extractor, previews all zones, commits N. Quote button renamed "Create work order"→**"Review bid →"**.
- **Step 4 reworked Work Order → "Send Bid"** (`SendBidStep`): confirm checklist + branded customer preview (internal hidden) + **interactive customer bid map** (`GET /bid/{id}` → `app/api/bid.html`, tap tree → species/service/price + photo placeholder) + **test-email to Skipper** (`POST /proposals/{id}/send-test` → `import_service /send-bid` via gilligan.gsts gmail). Full loop verified on the real Alhambra USD bid.
- **▶️ RESUME (Skipper, tmrw AM): more work on the QUOTE page** (`QuoteStep`, step 3 — ask what he wants). Open polish: tree photos (gated on capture), real customer send (draft→approve, currently test-to-Skipper), per-zone grouping in the preview, tree→zone tagging on commit-zones.

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

**Inventory-page bug fixes (Skipper live-testing):** pin-click dup (bubblingMouseEvents, `6063e40`) · no pre-selected species/size (`cf72b40`) · map corner-jam guard + Undo (`119d67f`) · **customer-switch stale state → `key`=site_id on Inventory/Quote steps** (`6cc25ac`) · **`Cache-Control: no-store` on index.html** (stubborn-cache killer, `2409ae5`) · okLatLng/okPoly guards + area-scan quality gate (`efe2906`) · **site name in header + clean map on open (base-map & zones opt-in)** (`71b4d26`) · dropped post-extract fitBounds (`8bda63c`).

**Map-type CLASSIFIER + preview + gating (2026-07-06, commit `442e701`, migration `0027`) — CREW-BUILT:** design converged across Gemini+Fable+Codex; **Codex built `importer/classify_map.py`** (render page-1 → 1 vision call → type) and tested it correct on 3 real maps. Each pulled map is classified (aerial_base / species_with_id / master_species_plan / work_order / non_map) + cached on `site_map` + a page-1 preview PNG. `POST /maps/{id}/classify`, `GET /maps/{id}/preview.png`, `list_maps` returns server-derived `allowed` (aerial⇒areas; aerial+markers⇒trees); the georef endpoint **409-gates** a wrong-type map (`force=true` override). UI: type badge in the picker, Extract buttons gated per type, 👁 **Preview modal** (image + AI verdict), classifies unclassified maps on inventory load. Fail-safe: unclassified/uncertain ⇒ locked. Verified 5/5 Los Olivos maps classified correctly.

## ✅ RESOLVED 2026-07-06 — the "map jumps to the corner on Extract Trees" saga (commits `8994c10` + `fb39c62`)
- **THE map-corner bug (root-caused + fixed, `8994c10`):** clicking Extract Trees set `note='Reading trees…'`, which **inserted a sibling `<div>` above the ref-held Leaflet map div → preact RECREATED the map DOM node → the Leaflet container went to 0×0 (map destroyed), jamming to the corner.** All the earlier framing/fitBounds/invalidateSize fixes were treating a symptom. **FIX: render the err+note banners ALWAYS (display:none when empty)** so the map's siblings never shift and its DOM node is never recreated. Reproduced + measured + visually verified headlessly (localStorage session-inject + button-click; container stayed 930×430 during extraction). See [[LESSONS]] (preact-recreates-map-div). *(How it was cracked: the Skipper insisted I stop guessing and use the crew — Codex; and I finally reproduced it headlessly instead of guessing.)*
- **Tree-extraction TIMEOUT fixed (`fb39c62`):** detection read the map in ~24 tiles with ONE sequential vision call each (>6 min) → blew the maps_api 400s timeout (broken-pipe in the host log). **FIX: parallelize tiles in a `ThreadPoolExecutor(max_workers=6)` + raise API timeout 400→900s.** Verified: Palm Dact trees scan **87s** (was >6 min), 80 palms proposed, rms 7.4m, completes cleanly. **The full numbered-map→GPS-trees pipeline now works end-to-end.**

## ⚠️ OPEN / NEXT
- **Pricing Phase 2** (parked): Profit Lens map · map↔grid sync · evidence-confidence tiers · Tap-to-Rebid. Spec `docs/PRICING-SHEET-REDESIGN.md`.
- **Area extraction on non-aerial sites (Ashford):** the classifier now correctly gates those maps out (work-order sheets → both buttons disabled), so the page can't break on them. If a site has a real aerial base map, area-scan works; Ashford's don't, which is expected/handled.
- Culver + Los Olivos are TEST sites; `FirstService Residential`→`Ashford Place` is a CORRECT mgmt-company→property link (not a bug).

## Related
- [[arbor-core-cockpit-bidqueue-handoff]] — feeds real jobs (customer + site + GPS trees) into this app to rebid.
- [[arbor-core-rfp-automation]] — B3 drafting hooks into this pricing engine (MainPlace bid sheet).
- [[arbor-core-ai-tree-vision]] — species/size-from-photo plugs into the inventory + pricing seams.
- [[arbor-core-strategy-foundation]] — the first product slice this realizes.
