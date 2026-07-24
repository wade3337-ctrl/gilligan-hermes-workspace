# El Monte Bldg 1 — verification answer key (Herman front-to-back test, 2026-07-24)

Source: `RFP Schedule 2 Goodman Tree Inventory Data redacted.xlsx`, PropertyNm = **"Goodman Logistics Center El Monte - Bldg. 1"**.
Verify Herman's TRIM IT build against THIS (tag-by-tag), same rigor as Eastvale 1105467.

- **Trees:** 298 | **tags (site_id):** 4382–4795, all 298 distinct → become `LegacyRef` and (after fix) `GSTSID`.
- **City/County:** El Monte / Los Angeles, CA  ← NEW county vs Eastvale (Riverside) — tests fresh zip/district/LZR/street setup.
- **Address:** 1 street — **4300 North Shirley Ave** (single number 4300 for all). → `StreetNumber`=4300, `StreetName`=NORTH SHIRLEY AVE (+ StreetNameID→StreetNames, LocationStreetID→LocationStreets, both must be created).
- **Height bands (only 3):** `0 - 10 ft`=32, `11 - 20 ft`=186, `21 - 30 ft`=80. → dedicated HeightModel with **3** ranges (not 4); each tree's HeightRange+HeightRangeID by tag.
- **Species (15 — the hard part, tests GetBestInventoryGroup):** Cypress Italian(69), Sumac African(49), Crapemyrtle Common(38), Brisbane Box(33), Pine Afghan(25), Chitalpa(17), Trumpet Tree Pink(14), Christmasberry(12), Oak Coastal/CA Live(11), Pine Canary Island(9), Camphor Tree(8), Goldenrain Tree(7), Flame Tree Chinese(2), Pepper Tree(2), Cypress Arizona(2).

## 12-gate checks to run when Herman reports (resolve trees via Projects.LocationID → InventoryDetail.LocationID)
1. 298 trees imported; tags 4382–4795 all present, 0 dup GSTSID.
2. GSTSID = LegacyRef (customer tag), 0 at '0'/NULL.
3. Address 4-field: 298/298 StreetNumber(4300)+StreetName+StreetNameID+LocationStreetID; FK 0 orphan; matches sheet.
4. Height: dedicated model, 3 bands, 298/298 match sheet by tag, 0 off-model; dropdown scoped.
5. Species: SpeciesRef set (not Desc1); resolved groups sane (watch Chitalpa/Christmasberry/Sumac African/Trumpet Tree Pink/Camphor — non-obvious aliases).
6. Observations linked (ProjectID/LocationID/LZR/DefID/ClassID=1) if survey had defects.
7. IsNewPlot cleared (grey only), LZR/Season/ServiceType set, lat/lng in-box.
8. Publish: GeoJSON regenerated, card shows tag + height band + address.
