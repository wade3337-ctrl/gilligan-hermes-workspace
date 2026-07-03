---
title: Scott's Manager Dashboard
type: project
domain: work
track: 1
status: active
tags: [pipeline-tool, arborist-workbench, manager, portfolio, rep-facing, entity-resolution]
applies: ["[[gsts-ui-style-guide]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[apple-contacts-reconciler]]", "[[sales-cockpit]]", "[[anomaly-monitor-suite]]"]
updated: 2026-07-02
---

# Scott's Manager Dashboard

**One-liner:** A rep-facing portfolio view built on Scott's manager-lens — search by rep/territory/manager/company/map-lasso → results land grouped by their common denominator (management company / manager / area), each site showing $ · TPH(vs 130) · last job · forward-status. Feeds the Cockpit List/Book views.
**Status:** 🔵 active — working prototype live on play (**"Arborist Workbench"**); paused 2026-06-23; My Jobs + Re-bid Radar prototype built (ship-log #82/#83).
**📁 Location:** `ZTest-SiteMap.cfm` (the Workbench) + `ZTest-Drill.cfm` + `ZTest-MyJobs.cfm`; state in the refresh-proof `Workbench` play DB
**▶️ Resume:** `arbor-stack/pipeline-tool/PROJECT-scott-manager-dashboard.md`

## Applies / uses
- [[gsts-ui-style-guide]] — pro-tip "?" popups + welcome modal on the map done (10 `wb.*` keys); ASCII/BOM discipline.
- [[gsts-ui-spec]] — UI tokens/styling; welcome modal on front page.
- [[repair-contract]] — new files, touched nothing existing, safe to delete; render-verify; log to ship-log.
- Data: sites map from `dbo.Locations` Lat/Long (⚠️ `Projects.Lat/Long` are DEAD — 1/12,700); TPH bands live from `GoalSettings.TargetTPH` (guarded — nightly refresh drops the play-only table).

## State & flags
- **v0.2 reframe (Skipper):** rep-facing, territory-first, site-level map — supersedes the CEO-only manager-card v0.1. One grouping engine, search is just the way in; landing = search not a fixed list.
- **The landmine = data quality, not data model.** Manager identity is only free-text `ProjectContacts.Desc1` (CompanyID = company-level like CBRE, NOT manager); Janina Bates exists 6-7×. Core work = a **read-side entity-resolution mapping layer** (`CanonicalManager` / `ManagerAlias` / `ProjectManagerAssignment`) — human-validated, not pure fuzzy; this becomes arbor-core's clean ManagerID.
- **My Jobs + Re-bid Radar prototype BUILT** (`ZTest-MyJobs.cfm`, default Garrett rep=1118): 5 lifecycle tabs w/ adjustable date ranges; **Done = WO Complete (StatusDefID=48) + non-void invoice**; Re-bid Radar (project-level renewal gap, RFP-status persists to `Workbench.dbo.RebidStatus` and drops handled jobs). ⚠️ Invoice STATUS is dead data → show "invoiced", NOT "paid".
- Notes/drill persist to `Workbench.dbo.WorkbenchNote`; V1.5 "get it done today" todo → `Workbench.dbo.Todo`.
- **Open:** browser interaction check (no headless here) · decode Scott's **C / A** shorthand · confirm forward-status pick-list · geocode backfill (twins-copy → Census, $0) · bundle SalesRepType/IsMeasured prod fix with Travis (`dev-tasks/ismeasured-managers-fix-PROD.md`).

## Related
- [[apple-contacts-reconciler]] — feeds the manager mapping layer (Scott's clean answer key).
- [[sales-cockpit]] — the Workbench/My Jobs folded in as the cockpit's List/Book.
- [[anomaly-monitor-suite]] — Garrett's salesperson-email buckets are the source model for My Jobs.
