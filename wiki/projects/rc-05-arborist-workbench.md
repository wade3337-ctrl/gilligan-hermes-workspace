---
title: RC-05 Arborist Workbench
type: project
domain: work
track: 1
status: active
tags: [dashboard, workbench, pipeline-tool, map, rebid-radar, release-candidate, database]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[sales-cockpit]]", "[[scott-manager-dashboard]]", "[[db-repair-contract]]"]
updated: 2026-07-02
---

# RC-05 Arborist Workbench

**One-liner:** Garrett Cornish's rep-facing pipeline tool (Track-1 V1 prototype → becomes the arbor-core framework) — one UNIT = map workbench (site pins, lasso, group-by lens, prospecting) + arborist work sheet (drill, notes that save) + My Jobs / Re-bid Radar + save-endpoints + the new **`Workbench` database**.
**Status:** 🔵 active — **IN PROGRESS**, actively shaped with the Skipper; **NOT yet review-approved/parked** (unlike RC-01–04). Components live on PLAY.
**📁 Location:** `production-dashboard/ZTest-SiteMap.cfm`, `ZTest-Drill.cfm`, `ZTest-MyJobs.cfm` + save-endpoints (`ZTest-Note-Save/Todo/MyJobs-Save.cfm`)
**▶️ Resume:** `arbor-stack/release-candidates/RC-05-arborist-workbench-suite.md`

## Applies / uses
- [[dashboard-metric-standards]] — Re-bid Radar renewal-gap; My Jobs lifecycle tabs.
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — welcome modal + pro-tips (10 `wb.*` keys); UTF-8 BOM; V1.5 Home SALES-node link.
- [[repair-contract]] + [[db-repair-contract]] — save-endpoints are MERGE/CRUD upserts (cfqueryparam); the DB deploy follows the db-repair contract.

## State & flags
- ⚠️ **First feature that ships a DATABASE, not just .cfm.** Must create the `Workbench` db + 3 tables (`RebidStatus`, `WorkbenchNote`, `Todo`) on the PROD SQL instance — it's a separate db that survives the nightly GSTS refresh. Until it exists on prod, notes/todos/radar-status won't persist.
- **Confirm prod CF datasource has cross-DB access** to `Workbench.dbo.*` 3-part names (works on play as `sa`; grant db_datareader/writer if prod login differs).
- **Rename `ZTest-*` prototype files** to real names before prod (throwaway convention) + update the V1.5 Home link.
- Depends on `Locations` lat/long + `Projects.SalesRepID` arborist def (the IsMeasured cleanup removes the hardcoded 1139/1142 exclusion).
- **Open before RC-ready:** Skipper/Garrett browser walk-through; crew names + territory on My Jobs; manager de-dupe/mapping layer; decode Scott's C/A shorthand + forward-status pick-list.

## Related
- [[sales-cockpit]] — Workbench folds into the unified Cockpit front door (naming ambiguity mostly resolved).
- [[scott-manager-dashboard]] — sibling rep/manager pipeline view.
