---
title: arbor-core — One-Stop UI (commercial estimator)
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, estimator, pricing-engine, inventory, georeferencing, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-cockpit-bidqueue-handoff]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-ai-tree-vision]]", "[[arbor-core-municipal-bid-branch]]"]
updated: 2026-07-03
---

# arbor-core — One-Stop UI (commercial estimator)

**One-liner:** The single front-to-back workflow app — **customer → inventory (map) → quote → work order** — on the clean arbor-core DB. FastAPI + single-file preact `index.html`, Postgres + RLS. The commercial/HOA estimating tool is now **feature-complete**.
**Status:** 🔵 active — pricing engine COMPLETE (all slices ⓪①②③④ + access/equip + actual-vs-planned feedback loop + field UX + Risk/TRAQ, browser-verified). **NEXT: Skipper hands-on click-test live** (`http://100.82.161.7:8088`), then polish from feedback.
**📁 Location:** `arbor-core/app/api/`
**▶️ Resume:** `arbor-core/docs/ONESTOP-UI-CHECKPOINT.md`

## Applies / uses
- [[arbor-core-db-importers]] — schema v1.7 + migrations 0001–0023, RLS spine (`SET app.tenant_id`).
- Specs: `schema/STAGE3-pricing-engine-spec.md` · `docs/decisions/AREA-CLEANUP.md` · `docs/ADR-002-mapping.md`.
- Not the GSTS UI style guide — this is the clean arbor-core app, not a play/TRIM IT surface.

## State & flags
- **Step 0 Customer** ✅ · **Step 1 Inventory (map)** ✅ — tap-to-drop trees (auto asset #, GPS, species from real TRIM IT history), zones (`site_area`, click-to-place corners, color-coded, live membership), **✨ Tidy-up (geometric cleanup, fail-safe)**, right-click pin/map Details/Copy/Paste, field UX (📍stamp toggle · 🎯 drop-at-GPS · 📷 native camera), Risk/TRAQ (ISA matrix → color-coded rating).
- **Step 2 Quote — the Pricing Reconciler (Slices ①–④) COMPLETE:** hours→price, live blended-TPH gauge (target 130), non-tree charges (TBD), Price Buddy history-teaching chips (Slice ②, nightly grain 6:00), site-rebid anchor (Slice ③, nightly 6:05), per-year balance + season shift (Slice ④), access ×/equipment × multipliers, actual-vs-planned feedback loop.
- **Legacy-Map Georeferencing (2026-07-02, BUILT):** fully automatic, **~0.2–5.6 m** — render PDF headless → extract yellow zone → geocode → live Esri → **Gemini 3.1-pro vision landmark-match** → affine solve → project zone. Brings old AREA-only commercial jobs into the app for real per-tree GPS. Migration `0023`. ⚠️ legacy PDFs live on firewalled PROD storage → office UPLOADS the PDF for now (auto-pull unblocks when Jordan opens prod).
- **Big-Site Scaling** — handled natively (bbox viewport + grid clustering); see [[arbor-core-cockpit-bidqueue-handoff]] P1 (verified on 5,786-tree Long Beach; scales to 60k+).
- **Area Cleanup / zone tidy** — Phase 1 shipped (simplify + orthogonalize + weld, validates + falls back); CV/vision refinements parked.
- ⚠️ Deferred: photo object-storage (MinIO — currently by-URL) → gates [[arbor-core-ai-tree-vision]]; offline mode; DIR wage → [[arbor-core-municipal-bid-branch]].

## Related
- [[arbor-core-cockpit-bidqueue-handoff]] — feeds real jobs (customer + site + GPS trees) into this app to rebid.
- [[arbor-core-rfp-automation]] — B3 drafting hooks into this pricing engine (MainPlace bid sheet).
- [[arbor-core-ai-tree-vision]] — species/size-from-photo plugs into the inventory + pricing seams.
- [[arbor-core-strategy-foundation]] — the first product slice this realizes.
