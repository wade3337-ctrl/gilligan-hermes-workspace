---
title: arbor-core — Cockpit → arbor-core Bid Handoff
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, cockpit, bid-queue, importer, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[sales-cockpit]]", "[[arbor-core-onestop-ui]]", "[[arbor-core-strategy-foundation]]"]
updated: 2026-07-03
---

# arbor-core — Cockpit → arbor-core Bid Handoff

**One-liner:** A one-way queue that lets the Skipper find a job in the TRIM IT **Sales Cockpit** (on play), hit **"Bid this work,"** and have it flow into arbor-core to rebid on the clean estimating engine — **without any dev/Jordan ever seeing arbor-core.** P0–P4 done + verified.
**Status:** 🔵 active — **PIPELINE COMPLETE, P0→P4 all done + verified (2026-07-02).** Whole loop proven end-to-end.
**📁 Location:** `arbor-core/importer/bidqueue_import.py` + `import_service.py`
**▶️ Resume:** `arbor-core/docs/COCKPIT-BIDQUEUE-HANDOFF-spec.md`

## Applies / uses
- [[arbor-core-db-importers]] — upserts customer/site/trees into the arbor-core RLS spine (idempotent on legacy ids).
- Core principle: **arbor-core reaches OUT; nothing reaches in.** Cockpit only writes a queue row; arbor-core PULLS host-side, **on-demand only (no standing poll)**. No arbor-core host/URL/credential ever in play-side code.
- Locked decisions (Skipper 2026-07-02): on-demand only · big sites solved for real (60k+, no cap) · idempotent re-queue · incomplete-data guard (no-contact job blocked from bidding) · **TRIM IT tree id = source of truth**.

## State & flags
- **P0 importer core** ✅ — `Workbench.dbo.BidQueue`; migrations `0021`+`0022`; pulls customer (Companies) + contacts + site (Locations, centroid) + trees (InventoryDetail → species/size/GPS, asset# = source of truth). Proven: Long Beach loc 1280579 → 5,786 trees / 126 species / 5 contacts, clean; re-run no dupes. ⚠️ single-column play queries have no `|` separator (parser needs ≥2 cols) — gotcha.
- **P1 big-site scaling** ✅ — `GET /sites/{id}/tree-meta` + `/tree-view?bbox` (≤800 in view → points; else grid CLUSTERS). Verified on Long Beach, ~155 clusters smooth, scales to 60k+.
- **P2 "Jobs to bid" front door + on-demand trigger** ✅ — `GET /jobs-to-bid`, `POST /jobs-to-bid/refresh`, contact-gate endpoint; host-side **`import_service.py`** (LISTENER on :8099, acts only on POST /run). Verified full loop.
- **P3 Cockpit "Bid this work" button** ✅ — CF `ZTest-BidQueue-Add.cfm` (play, ZTest-only, not in Jordan's deploys) wired into `ZTest-Cockpit.cfm`; dedupes pending.
- **P4 status feedback** ✅ — Cockpit drawer badge (⏳ queued / ✓ in bidding tool / ⚠ error) from BidQueue by LocationID.
- ⚠️ **`import_service.py` must be a persistent service (systemd/@reboot) for production** — currently a background process.

## Related
- [[sales-cockpit]] — the play-side front door; this completes its parked **P3** (wire "Start a bid" into the bid flow), pointed at arbor-core.
- [[arbor-core-onestop-ui]] — imported jobs open into Inventory (real trees) → Quote (rebid + history light up on location id). Big-site scaling built here also serves the estimator.
