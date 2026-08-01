---
title: Blue Jay / Falcon — USFS Cleveland NF post-fire fuels-reduction RFP
type: project
domain: work
track: 1
status: 🔵 ACTIVE — GIS package delivered; ⏰ pre-bid meeting Fri 2026-07-31 10:00 AM PT (in person)
tags: [rfp, bid, usfs, federal, gis, georeference, fuels-reduction, cleveland-nf, brent, gothic]
applies: ["[[external-comms-contract]]", "[[only-trustworthy-data]]"]
links: ["[[goodman-rfp-bid]]", "[[municipal-budgets-po-gated]]", "[[email-infrastructure]]", "[[brent-agent]]"]
updated: 2026-07-31
---

# 🌲 Blue Jay / Falcon — USFS post-fire fuels-reduction RFP

**Source:** Brent forwarded it 2026-07-30. **US Forest Service, Cleveland National Forest,
Trabuco Ranger District** — post-fire fuels reduction at **Blue Jay** and **Falcon Group** campgrounds
near Lake Elsinore. Structured as a **subcontract / teaming arrangement**, the same shape as
[[goodman-rfp-bid]] (sub to Gothic).

## The job
- **~824 dead trees · ~32 acres of treatment units (Units 1–3)** inside a ~450-acre area.
- Sites: Blue Jay CG, Falcon Group CG, El Cariso / Los Pinos admin sites.
- ⏰ **Pre-bid meeting: Friday 2026-07-31, 10:00 AM PT — IN PERSON**, Long Canyon Rd / 6S05 ×
  Ortega Hwy (CA-74). Federal pre-bids are typically attendance-gated — missing it can disqualify.

## Packet
`arbor-stack/inbox-pull/brent-bluejay-falcon-2026-07-30/` — RFP Overview · Bid Specifications & Pricing
Form · Appendix A / B · Contract Area Map (`C04e_4 Blue Jay-Falcon CAM.pdf`) · Fire Plan · Questions ·
**Federal Labor Rates and Estimated Usage** (federal wage determination — price against it, not our
standard labor rates).

## 🗺️ The GIS deliverable (built 2026-07-30)
`gis-work/deliverables/` — cropped map PNG · full sheet · **`.kmz`** (Google Earth) · **world file**
(`.pgw` + `.prj`, QGIS/ArcGIS) · `README-georeferencing.md` · and the one he actually wanted:
**`BlueJay-Falcon-SAT-overlay.pdf`** — Esri satellite base with the contract map multiplied on top.

- **What he asked for vs what he meant:** the request read as "give me the map," and the first four
  artifacts answered that. **What he actually wanted, revealed late, was a satellite view with the
  topo/contract map laid over it** — an orientation aid, not a file format. Worth asking "what will you
  be looking at when you use this?" before building the deliverable set.
- ⚠️ **Accuracy is APPROX and says so on the artifact.** The map carries a **PLSS Township/Range grid
  but no lat/lon graticule**, so it can only be georeferenced by feature-matching. Auto-fit came out
  **~25% off on scale**; scale from the map's own scale bar is reliable, absolute position is
  best-estimate (~500–650 ft, nudgeable in 30 seconds in either tool).
  - **Ground control (WGS84):** Blue Jay CG `33.6517 / −117.4506` · Falcon Group CG `33.6575 / −117.4508`.
    A survey-grade third point is available from the magenta **T6S R6W / T6S R5W** range line and the
    Sec. 7/18 corner via the BLM PLSS/CadNSDI layer.
  - **The sanity check that says it's usable:** contours hug real drainages and the drawn roads trace
    visible tracks on the satellite base. **Good for orientation and walking the units; not survey-grade** —
    and the file name and README both say so.
- **Tooling:** all of it in **Node 24 + npm** (`pdf-to-png`, `sharp`, `pdfkit`) — no pip, no sudo, and
  Python 3.14 has no wheels on this box. → [[env-host-and-tooling]]

## 📧 Delivery gotchas (cost several rounds)
- **`jwade@gstsinc.com` silently ate the `.kmz`** — a KMZ *is* a zip, and the corporate filter quarantined
  it with no bounce. Zip-free resends (PDF/PNG) landed.
- Verified personal fallbacks, taken from real message headers: **wadejason@hotmail.com** and
  **wade3337@gmail.com**. The SAT-overlay PDF went to all three.
- `send-files.js` is **hardwired to jwade** → a recipient-variant helper was needed, and it **must live in
  the `anomaly-monitor/` directory** where `nodemailer` resolves; the same script in `/tmp` fails.
  → [[email-infrastructure]]

## ⏭️ Open
- **Attend / cover the 7/31 pre-bid** (Skipper's call — in person, Ortega Hwy).
- Price against the **federal labor rate sheet** in the packet, not our standard rates.
- Nothing bid or committed yet — this is packet + orientation work only.
