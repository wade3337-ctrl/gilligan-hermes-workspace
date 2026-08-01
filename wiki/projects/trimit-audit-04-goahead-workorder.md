---
title: TRIM IT Audit 04 — Go-Ahead / Activation → Work Order
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, goahead, workorder, activation, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-03-lead-proposal-bid]]", "[[goahead-status-lifecycle]]", "[[trimit-recurring-contract-lookahead-gap]]"]
updated: 2026-08-01
---

# TRIM IT Audit 04 — Go-Ahead / Activation → Work Order

> Stage 4 of the [[trimit-deep-audit]]. **Map-only pass (Skipper "A")** — zero writes. Every figure from a
> `gsql.sh` query or file read run THIS session. This stage is the **approval→execution bridge**: an
> approved Proposal becomes a GoAhead, which (once activated) spawns WorkOrders that go to Scheduling.

## ⭐ Headline: the workflow chain, and the two-step activation that lives ONLY in an SOP
- **Chain confirmed by reading the executors:** `Proposal` → `GenerateGoAhead(@ZProposalID)` → **GoAhead** → (activation: two-step status flip) → `GenerateWorkOrders(@ZLocationID,@ZYear)` → **WorkOrders** → Scheduling/Crew Sheets (Stage 5).
- **Activation is a TWO-STEP status flip that the schema does not encode** (from [[goahead-status-lifecycle]] / Rosa's SOP): set `StatusDefID`→InProcess, Update Record, THEN →Active, Update Record. **A GoAhead stuck in `InProcess` = a half-finished activation** — a data-quality signal that exists nowhere in the code, only the SOP. Done via the `Synch.GoAhead.*` UI (the MM_UpdateRecord inline-UPDATE pattern from Stage 2, not a proc).

## 1. Entry points (code) — verified by reading
- **GoAhead create:** `CodeGenerateGoAhead.cfm` → `<CFSTOREDPROC dbo.GenerateGoAhead>` param **`@ZProposalID`** (born from a proposal). Variants: `CodeGenerateGoAhead$InventoryDetail.cfm`, `$YearLabel$SeasonID.cfm` (multi-season splits — the SOP's legitimate fan-out).
- **WorkOrder create:** `CodeGenerateWorkOrders.cfm` → `<CFSTOREDPROC dbo.GenerateWorkOrders>` params **`@ZLocationID, @ZYear`** (WOs generated per location+year). Also `CodeGenerateWorkOrder.cfm` (singular) + a `GenerateWorkOrderLine*` family (AdHoc, LineGroup-from-WO).
- **Activation/edit UI:** `Synch.GoAhead.Detail.cfm`, `Synch.GoAhead.Parameters.cfm`, `Synch.GoAhead.Selection.cfm`; `Profile.GoAhead.Detail.cfm`; `Profile.WorkOrder.Detail.cfm`, `Profile.WorkOrders.Focus.cfm`.
- **Trigger:** `GoAheadsPostUpdate` (fires on GoAhead status change).

## 2. Data model (verified live)
**`dbo.GoAheads` — 94,291 rows, 54 columns.** The approval record. Sits between Proposal and WorkOrder.
- Key cols: `ProposalID`, `CompanyID`, `ProjectID`, `Approved`+`ApprovedDate`, `StatusDefID`, `Total`/`EstValue`, `PONumber`, `GoAheadScope` (Future01 etc. — the future-year CO signal), `SeasonID`, `GoAheadGroupID`, `ContractID`, `WorkRequestID`, `OriginalStartDate`/`OriginalEndDate`, `IsServiceRequest`.
- **6 parent FKs:** `Proposals`, `Companies`, `Projects`, `ProjectYears`, `ProjectContacts`, `StatusDefs`.
- **4 child tables:** `GoAheadLines` (3.2M rows), `WorkOrders`, `GPSWorkOrders`, `InventoryHitRates`.

**`dbo.WorkOrders` — 52,680 rows, 168 columns.** The execution record; the first entity with REAL production columns:
- Production data: `EstTrees`/`ActTrees`, `EstCrew`/`ActCrew`, `EstTrimTime`/`EstCleanTime`/`EstCycleTime`/`EstTPH`, `TotalItems`/`TotalComplete`/`TotalIncomplete`, `StartDate`/`EndDate`, `WorkOrderType`, `NotifiedDate`/`ConfirmationDate`.
- **21 parent FKs** (the most yet) — incl. `GoAheads`, `Proposals`, `Locations`, `Contracts`, `CrewNames`, `YardTypes`, `ValueMethods`, `ProjectSeasons`, `BlanketOrders`, `CallInModels`. It's the convergence point of sales + site + crew + contract.
- **20 child tables** (WorkOrderLines 1.35M, WorkOrderInventory, WorkOrderCalendars, WorkOrderMaps, WorkOrderSlopes, WorkOrderSummary…).

## 3. Used vs. dead
- **Used:** `GenerateGoAhead`, `GenerateWorkOrders`, the Synch activation UI, `Profile.WorkOrder.Detail.cfm`, the FK graphs.
- **Dead / orphan (flagged):** WorkOrder detail has **6+ stale versions** — `Profile.WorkOrder.Detail$03172011.cfm`, `$dev.cfm`, `.Orig.cfm`, `.V2.cfm`, `.New.cfm`, `Profile.WorkOrder.Calendar$10022023.cfm`; plus `CodeGenerateWorkOrderLine$AdHoc$dev.cfm`, `Profile.GoAhead.Detail$dev.cfm`, `Profile.WorkOrderPackage.Preview$dev.cfm`.

## 4. Works vs. broken
- 🩹 **Half-finished activations are LIVE and now re-measured:** **40 GoAheads stuck in `InProcess` = $415,590** (all-history, 2026-08-01). *Scope note:* [[goahead-status-lifecycle]] reported 8/$120,861 but that was **created-in-last-2-years only**; all-history is 40/$415,590. Each is a go-ahead that did step 1 of the two-step flip and never reached Active → **may never have reached Scheduling.** This is the cleanest data-quality query in the whole workflow (a status no one intends to rest in).
- ⚠️ **Duplicate work-order lines are a KNOWN unresolved TRIM IT defect** (SOP Important Note #1: "leave as-is until IT resolves"). Consistent with the 5 near-identical Irvine/Crystal Cove $22,649 InProcess records the lifecycle note found.
- ⚠️ **Future-year CO trap:** activating a future-year change order requires temporarily setting the wrong year then restoring it; "failure to do this bills in the wrong year." A GoAhead with a mismatched `ProjectYearLabel`/`GoAheadScope` may be a half-completed future CO. (Not a code bug — a process landmine.)

## 5. Cleanup candidates (FLAG only — map-only pass)
- **`zDelete-*` tables in THIS stage's domain:** `zDelete-IMP$CityofAnaheimContractImportSeptl2018_2` **and** `_3` (6,339 rows EACH — duplicate 2018 Anaheim contract-import scratch), `zDelete-WorkOrdersTPH_Temp` (422), `zDelete-WorkOrderLinesTravisTemp` (72), `zDelete-GoAheadGroups` (3). All quarantine-and-drop candidates (rehearse first).
- **Empty/dead structures:** `ContractPeriodScopeWorkOrders`, `GSTSContractPeriods`, `GSTSContractCalendars`, `ContractCalendarYears` (0 rows).
- **The 40 InProcess GoAheads** = a *data* cleanup (finish or void the activation), distinct from schema cleanup — best handled operationally by the account owner, not a bulk drop.
- Dead `.cfm` from §3 (esp. the 6 WorkOrder.Detail versions).

## 6. Knowledge delta
- **Already knew:** [[goahead-status-lifecycle]] (the two-step activation SOP, status enum meaning, the 8 stuck records at last-2-yr scope), [[trimit-audit-03-lead-proposal-bid]] (GoAheads/WorkOrders are Proposal children), [[trimit-recurring-contract-lookahead-gap]].
- **NEW this pass:** the create-path params proving the chain (`GenerateGoAhead(@ZProposalID)` → `GenerateWorkOrders(@ZLocationID,@ZYear)`); GoAheads = 54 cols/94,291 rows (6 parents/4 children); WorkOrders = **168 cols/52,680 rows, 21 parent FKs** (the convergence point, first real production columns); **all-history InProcess = 40/$415,590** (vs the note's 2-yr 8/$120,861); the duplicate-2018-Anaheim `zDelete` pair + WO-line temp tables; the 6-version WorkOrder.Detail dead cluster.

## Resume pointer
**Stage 4 COMPLETE (map-only, 2026-08-01).** Chain Proposal→GoAhead→WorkOrder confirmed by reading the create
executors; both entities' schema + FK graphs mapped; InProcess data-quality re-measured live. **Next = Stage 5:
Scheduling → Crew Sheets → Production** (`CrewSheets`, `InventoryAssignments`, `WorkOrderCalendars` — much already
known from the dashboard/production-perf work: [[production-perf-future-dated-crewsheets]], the `Calendars.CalDate`
vs `WorkDate` binding gotcha). Deferred: read a `GenerateWorkOrders` body for how WO lines are populated from the
go-ahead; the 40 InProcess list is a ready operational-cleanup rehearsal if the Skipper wants it. Cleanup execution deferred (map-first).
