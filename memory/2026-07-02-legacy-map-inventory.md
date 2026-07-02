# 2026-07-02 — Legacy base-map inventory (arbor-core)

## Correction (Skipper, do NOT re-misread)
- TRIM IT commercial "base maps" (Maps table, RecordType='Map', PDF under prod /Storage/Data/{LocationID}/)
  are **Google-Maps aerials** of the property. The pins/labels on them are **Google business POIs**
  (e.g. "Commercial Door of LA", "Montana Capital"), **NOT tree markers.**
- The ONLY real signal on the PDF = the **yellow AREA polygon** = the zone the trees are in.
  The map does NOT locate individual trees. Legacy workflow: crew counted trees in that area on-site.

## The real problem
- Going forward = **per-tree GPS inventory**. But lots of **old jobs** have only: an AREA polygon +
  an ungeolocated tree list (species/size, e.g. Greenwood loc 1283538 = 6-10 trees, 0 GPS anywhere,
  TRIM IT AddressLat/Long also NULL).
- Need: bring these legacy maps/areas into arbor-core so **inventory techs add the actual per-tree GPS.**

## Two placement modes the app must support (Skipper)
1. **Field capture (primary go-forward):** tech on-site sees the area highlighted on the map, walks to each
   tree, drops GPS + confirms species. (We already have tap-to-drop / field GPS mode.)
2. **Desk canopy assumption (small counts):** tech eyeballs the aerial, makes out tree canopies inside the
   polygon, drops pins + assigns species by safe assumption. Only viable when the tree count is small.

## Fact-find results (Greenwood 901 Greenwood Ave, Montebello CA, loc 1283538)
- Trees: TRIM IT has 10 InventoryDetail rows (5 species x2); arbor-core imported only 6 (dropped Carrotwood
  + "Various"). Map legend said "20" (likely template noise). Three numbers disagree → reconcile later.
- Importer tree query has NO species filter → a re-import should pull all 10; the 6 was likely a stale run.
- Rendered the PDF headless via pdfjs-dist + browser container (URL.parse polyfill needed for old Chrome);
  technique logged in PLAYBOOK.

## DECISION (Skipper 2026-07-02): wire vision-matching now; SOLVE it, don't patch.
- **Zones/areas are a CORE concept, not legacy-only** — current GPS jobs are also broken out by zone/area.
  So build a proper **zone system** (site -> zones -> trees); legacy-map georeference is just ONE way a zone
  is created, alongside GPS-drawn zones on live jobs.

## PROVEN 2026-07-02 — automated georeference works end-to-end (RMS 5.6 m on Greenwood)
Pipeline (all automatic, runs on this box):
1. Render old base-map PDF headless (pdfjs-dist + browser container, URL.parse polyfill for old Chrome).
2. Auto-extract yellow work-zone: color-threshold + **largest connected-component** (excludes legend's yellow
   cell) + angle-based corner simplify -> polygon in old-image fraction (0-1), scale-independent.
3. Geocode site address (Nominatim, already in db.py).
4. Pull live Esri World Imagery via headless Leaflet -> known corner lat/lng => exact pixel<->GPS (Web Mercator).
5. **Gemini 3.1-pro vision-matching**: feed old aerial + live satellite, get >=8 shared permanent landmarks as
   normalized [y,x] in each image. (Extended crew/gemini-ask.py with GEMINI_IMAGES=path,path -> inlineData parts.)
6. old-fraction <-> GPS control points -> solve affine (lat=a*fx+b*fy+c, lng=d*..; 3x3 normal eqs, no numpy).
7. Project zone polygon -> real GPS. Overlay on Leaflet Esri = lands tight on the complex.
- Accuracy ~5.6 m RMS (worst ~9 m from Gemini pixel jitter). Good enough for a work-zone; keep a one-drag nudge.
- Artifacts: /tmp/pdfrender/ (proof) ; will move the pipeline into arbor-core proper.

## BUILT 2026-07-02 (all verified end-to-end)
- Zone data model: zone(site_id, name, polygon geojson, source: legacy_map|gps_drawn|manual), tree.zone_id.
- Wire georeference into the import/handoff so opening a legacy job auto-creates its zone(s) + attaches the
  ungeolocated tree list; store the old base-map as a reference layer.
- UI: render zones on the map; "unplaced trees" tray; field GPS drop + desk canopy-pick to geolocate each tree.

### Shipped this session
- Migration 0023: site_area +source (gps_drawn|legacy_map|manual) +basemap_url +basemap_bounds +georef jsonb.
- importer/georef_map.py run(site_id,pdf,zone_name) — the proven pipeline as a module; extended crew/gemini-ask.py
  with GEMINI_IMAGES. import_service.py gained POST /georef. API POST /sites/{id}/legacy-zone (PDF upload ->
  host georef via IMPORT_SVC), GET /sites/{id}/unplaced-trees, POST /trees/{id}/place (sets gps + auto-tags zone).
- API container now runs with volumes: app/api live-mounted (+--reload), /app/basemaps + /app/uploads; serves
  /basemaps/* static. requirements +python-multipart.
- UI (InventoryStep): "Import legacy map" upload, georeferenced base-map imageOverlay + ON/OFF toggle, "N trees
  need a location" tray (tap a tree -> tap map -> placed + zoned). Headless-verified: 0 JS errors, overlay + tray render.
- Proof imgs: arbor-core/docs/greenwood-georef-proof.png + greenwood-legacy-inventory-ui.png.
- Constraint flagged: legacy base-map PDFs live on PROD web storage (firewalled from our box), so auto-FETCH of the
  PDF is blocked until prod access (Jordan) — for now the office uploads the PDF; pipeline auto-does the rest.
