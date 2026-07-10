---
title: Workbench PLAY database
type: fact
domain: env
tags: [infra, play, database, workbench, coldfusion, persistence]
links: ["[[play-dev-access]]", "[[trimit-db-gotchas]]"]
updated: 2026-07-02
---

# 🗄️ `Workbench` PLAY database (NEW 2026-06-25)

Full detail: `arbor-stack/gstsdatabase-access.md`. Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

A **SEPARATE SQL db** on the play instance for **prototype state that survives the nightly GSTS refresh** (refresh restores only GSTS, so a side db persists).

## Tables
- `dbo.RebidStatus` — Re-bid Radar RFP flags (`ProjectID` + `SalesRepID`).
- `dbo.WorkbenchNote` — drill relationship/site notes (`Scope` + `RefKey`).
- `dbo.Todo` — V1.5 home per-user todos (keyed `ZUserID`).
- `dbo.RepEffectiveDate` (2026-07-10) — reviewed rep hire/effective dates + Role + Source + ReviewedBy. HR-truth anchor for historical attribution (SalesReps has no hire column). See [[sales-rep-attribution]].
- `dbo.ProposalOriginalRep` (2026-07-10) — per-proposal original-seller override map (`ProposalID`, `OrigRepName`, `Source`, `Conflict`) for reassigned proposals; the Win/Loss report LEFT JOINs it and `COALESCE`s. **Static/reviewed — NOT auto-regenerated nightly** (crew rule: exception report, not silent recompute).

## Access pattern
- Reached from ColdFusion via the **GSTS datasource + 3-part names** (`Workbench.dbo.…`; CF connects as **`sa`** → cross-DB, **no new datasource/grant**).
- Writes via tiny MERGE/CRUD endpoints: `ZTest-Note-Save.cfm`, `ZTest-Todo.cfm`, `ZTest-MyJobs-Save.cfm`.

**The long-stuck "notes don't save on play" thread is now CLOSED** (drill notes persist). Technique → `PLAYBOOK.md`; this is the seed of the eventual clean DB restructure (Skipper, Jun 25).

## Related
- [[play-dev-access]] — the play server this DB lives on + its refresh behavior.
