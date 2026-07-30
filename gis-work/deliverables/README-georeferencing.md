# Blue Jay / Falcon Contract Area Map — GIS overlay package

USFS Cleveland National Forest post-fire fuels-reduction RFP (via Brent, 2026-07-30).
Source map: `C04e_4 Blue Jay-Falcon CAM.pdf` (the "Contract Area Map").

## What's in here
| File | Use |
|---|---|
| `BlueJay-Falcon-ContractAreaMap.png` | The map cropped to its frame (1870×1823) — the overlay image |
| `BlueJay-Falcon-CAM-fullsheet.png` | Full sheet incl. title/legend/inset (2376×1836) |
| `BlueJay-Falcon-overlay-APPROX.kmz` | **Google Earth** — double-click to open |
| `BlueJay-Falcon-ContractAreaMap.pgw` + `.prj` | **QGIS / ArcGIS** world file (WGS84) — put beside the PNG |

## ⚠️ Read this first — the fit is APPROXIMATE
The map has **no coordinate grid** printed on it, so it can't be georeferenced exactly by machine.
- **Scale/size IS reliable** — taken from the map's own scale bar (2.47 ft/pixel → the area is
  ~0.88 × 0.85 mi, north-up).
- **Absolute position is a best-estimate** — anchored on Blue Jay Campground. It may sit ~500–650 ft
  off until you nudge it. That's a 30-second fix in either tool (below).

## Precise fit — pick your tool

### Google Earth (easiest, no GIS skills)
1. Double-click `BlueJay-Falcon-overlay-APPROX.kmz`. The map appears, semi-transparent, plus two
   pushpins (Blue Jay & Falcon campgrounds — the truth points).
2. Right-click the overlay → **Properties** (opens edit handles + an opacity slider).
3. Drag/scale the green handles until the map's "Blue Jay Cg" and "Falcon Cg" units sit on top of the
   two pushpins and Long Canyon Rd lines up. Save.

### QGIS / ArcGIS (for exact bid work)
- Quick: drop `BlueJay-Falcon-ContractAreaMap.png` in — the `.pgw`/`.prj` place it automatically (approx).
- Exact: **Raster → Georeferencer**, load the PNG, and drop control points using the table below
  (click the feature on the map, enter the coordinate). 3–4 points → a precise fit.

## Ground-control coordinates (WGS84, lat/lon)
These are the reliable anchors — the accurate part of this job.
| Feature on the map | Latitude | Longitude |
|---|---|---|
| Blue Jay Campground (Unit 2, central) | 33.6517 | −117.4506 |
| Falcon Group Campground (Unit 3, north) | 33.6575 | −117.4508 |

Additional control available if needed: the magenta **T6S R6W / T6S R5W range line** and the section
corner where the Sec. 7/18 line meets it (BLM PLSS, San Bernardino Meridian) — look up the exact corner
in the BLM PLSS/CadNSDI layer for a survey-grade third point.

## Project facts (from the RFP)
- ~824 dead trees, ~32 acres of treatment units (Units 1–3) within a ~450-acre area.
- Trabuco Ranger District; Blue Jay CG, Falcon Group CG, El Cariso/Los Pinos admin sites.
- Pre-bid meeting: **Fri 2026-07-31 10:00 AM PT**, Long Canyon Rd/6S05 × Ortega Hwy (CA-74).
