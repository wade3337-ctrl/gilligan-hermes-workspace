---
title: TRIM IT GPS inventory import pipeline (reverse-engineered)
type: reference
domain: work
track: 1
status: proven
updated: 2026-07-24
applies: ["[[repair-contract]]", "[[play-dev-access]]"]
links: ["[[goodman-rfp-bid]]", "[[trimit-db-gotchas]]", "[[herman-agent]]", "[[workbench-play-db]]"]
---

# 🗺️ TRIM IT GPS inventory import pipeline (how a spreadsheet becomes visible, priced-ready tree inventory)

Reverse-engineered 2026-07-23 (Goodman pilot). **Build GPS inventory via these procs — NOT raw `InventoryDetail` inserts** (raw inserts skip the whole setup layer and the trees never render). Herman's full converter spec: `vault-inbox/trimit/procedures/rfp-to-trimit-field-mapping.md`.

## The pipeline
1. **Load `dbo.InventoryGPSModel`** (staging, one row/tree): `ProjectID` + survey columns (`ZIPCODE, ON_ADDRESS/StreetNumber, ON_STREET, SPECIES, BOTANICALNAME, DBH, HEIGHT, SIZECODE, CONDITION, REC__MAINT, LATITUDE, LONGITUDE, TREE_ID, Qty`).
2. **`EXEC dbo.ImportInventoryGPSModelWithSeasonAndSizeAndServiceAndInventoryGroupID @ZProjectID=<pid>`** — the importer. It chains: `ImportGPSLocationZipCodes` + **`ImportGPSLocationZipRegions`** (creates the LocationZipRegion), `UpdateInventoryGPSModel` (species→group), builds the batch + summary + `InventoryDetail` with the **full FK chain**.
3. **`Process$IMP$Standard @ProjectID`** goes the OTHER way (inventory → InventoryGPSModel export). Don't confuse it with the importer.

## Species resolution
`dbo.GetBestInventoryGRoup(@species)` fuzzy-maps species text → InventoryGroupID. **Only matches ~1/3 of RFP "Family, Type" names** (e.g. "Planetree, London" fails; it wants "London Plane"). → a species-name mapping is required per portfolio.

## Making dots RENDER on the field map (multiple gates — ALL required)
The field app (`FieldApp/Field.Map.Map.Municipal.Desktop.cfm`) plots dots from a **server-side query `SelectedPoints`** → JS `store_locations` → markers. A tree shows only if:
- **`IsNewPlot = 1`** AND **`DevMark = 'NewPlot'`** (the "eligible for map publication" state field-created trees use; `Prep$FusionTables$NewTreeFlags` clears it after export). Set via the field-map state, not a blind flip.
- **Full inner-join chain intact:** `InventorySummary → InventoryGroup → InventoryClass → InventoryRealm`, `LocationZipRegion → District → ZoneDef`, `ServiceType → ServiceClass`. **`District.ZoneDefID` must be non-NULL** — raw setup leaves it NULL and kills all rows; fix with `EXEC dbo.GenerateZoneDef$Force$One @ZProjectID=<pid>`.
- `Latitude BETWEEN 30 AND 38`, `Qty=1`, `IsNewPlot=1`.
- **Batch bounding box** (`InventoryBatches.Min/Mid/Max Lat/Long` + `Qty`) rolled up from the tree points.

## ⚠️ Field DISPLAY traps (data is populated but shows blank = wrong column)
The detail popup (`FieldApp/Field-Inventory-Update.cfm?ZInventoryDetailID=<id>` — **404s via view.sh; FieldApp not served on that read path — verify visually**) reads specific columns:
- **Size / DBH:** reads **`SizeCode` (as a DBH-range string) + `SizeModelSizeID`** — NOT `DBHRange`, NOT the importer's `'XSML'`. Buckets (**SizeModelID = 2**): `8=0-6`, `9=07-12`, `10=13-18`, `11=19-24`, `12=25-30`, `18=31+`. (Set `DBHRange=NULL` to match surveyed trees.)
- **Height:** `HeightRange` + `HeightRangeID` (Model 4: `12=01-15`, `13=15-30`, `15=45-60`).
- **PruningFrequency:** `int` (RFP "1/2yr"→2, "1/3yr"→3).
- **SpaceSize** + **`GrowSpaceID`** (Landscape bed→13 Planter, Parking lot→5 Open).
- **Observations:** separate **`dbo.Observations`** table (`Desc1='Observation Recorded'`, `ObservationClassID`, `StatusDefID=392`, `LongDesc1`=text, per-tree `InventoryDetailID`). ObservationDefs: 19=Declining, 28=Limb Damage, 30=Trunk Damage, 43=Sucker branches, 47=Dead top.
- **Location "Name"** box on `Profile.Location.Update.New.cfm` reads **`LocationCompany`**, not `LocationName`.
- **Crown / on-site contact/phone/gate** = no RFP source (operational, from client).

## ✅ Step 4 — PUBLISH (blue "selected" dots → grey published dots + info-card) — 2026-07-24
**Two different layers, and the finished state is grey-only:**
- **Blue dots = `SelectedPoints`** (the server-side query above, `IsNewPlot=1`) — the *working* layer.
- **Grey dots + info-card = pre-generated GeoJSON** files under **`/GSTS/API/JSON/`** (apiJS → `apiCall.cfm` → Taffy), gated **server-side to EXCLUDE `IsNewPlot=1`** — the *published* layer.
- ⇒ **Publish = (a) clear `IsNewPlot` + (b) generate the GeoJSON.** While IsNewPlot is still 1 you see BOTH; when the job is right you see **only grey**. (windowControl/FusionTables is an orphaned red herring — ignore.)
- **On PLAY** the Taffy route 404s (stub proc, `xp_cmdshell` off): patch `apiCall.cfm` to write the GeoJSON locally via `<cffile>` (the dir + icons already exist on play). Full mechanism → `trimit-knowledge/procedures/gps-publish-info-card-mechanism.md`. Reverse-engineered by the Kimi K3 crew, verified against code + server.
- ⚠️ **Regenerate the GeoJSON after ANY field-population change** — the card reads the file, not the table.

## ⚠️ Post-import FIELD POPULATION (the importer leaves these blank) — recipe, 2026-07-24
Proven across Eastvale (313 trees) + El Monte (298). Full recipe: `trimit-knowledge/procedures/gps-inventory-import-pipeline.md`. **Back up per-change** (`Workbench.dbo.<table>_bak_<what>_<loc>_<date>`), one item at a time, verify tag-by-tag against the source sheet.
- 🚨 **Trees resolve via `Projects.LocationID → InventoryDetail.LocationID`, NOT `InventoryDetail.ProjectID`** (unset on GPS rows). Querying by ProjectID returns 0 and looks like "the import was wiped."
- **Tree ID:** the importer parks the customer tag in **`LegacyRef`** and leaves **`GSTSID` NULL** → card reads "tree id 0". Copy `LegacyRef`→`GSTSID`. Safe: **GSTSID is per-site, not globally unique.**
- **Address = a 4-field model** (copy Irvine's): `StreetNumber` + `StreetName` text **plus the two FKs** `StreetNameID`→`StreetNames` and `LocationStreetID`→`LocationStreets`. Setting only the text leaves the drill-down blank — this is the single most-repeated miss. Create the street rows once per location, then join per-tree by tag.
- **Height:** the importer sets the bucket but leaves the numeric NULL. Dropdowns are **scoped to the location's HeightModel**, and the default model ("USC", ID 2) is **shared by ~35 locations → never edit it.** Create a **dedicated HeightModel per survey** (+ its ranges), repoint the location, then set trees by tag.
- **Observations are NOT broken:** they live in the real **Observations tab**. The Details-tab "Observations:" box is `LineNote001`, which the import ignores — blank there is expected.
- 🧹 **`dbo.InventoryGPSModel` is a GLOBAL staging table, not per-project.** Orphaned rows from old projects contaminate the next import — check for and back up/clear strays before importing (e.g. 197 rows left from 2014 proj 1094998 "USC Contract").

## Known field-app bug (fixed)
`SelectedPoints` had a hardcoded **`AND 1 = 0`** → zero dots for EVERY project. Removed on PLAY 2026-07-23 (was a play-only stray line; **prod was fine**). See `gsts-ship-log.md`.

## Not handled by the importer
**Pricing** — the GPS importer does NOT run **Price Buddy**; prices/labor-hours stay null. Separate step (still TBD as of 2026-07-23).
