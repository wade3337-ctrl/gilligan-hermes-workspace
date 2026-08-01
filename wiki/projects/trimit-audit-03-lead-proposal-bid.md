---
title: TRIM IT Audit 03 — Lead → Proposal / Bid
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, proposal, bid, project, rfp, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-02-contact-location]]", "[[trimit-db-cleanup]]"]
updated: 2026-08-01
---

# TRIM IT Audit 03 — Lead → Proposal / Bid

> Stage 3 of the [[trimit-deep-audit]]. **Map-only pass (Skipper "A")** — zero writes. Every figure from a
> `gsql.sh` query or file read run THIS session. This is the **heart of the business** — the proposal/bid
> engine — and the biggest surface in the app by far.

## ⭐ Headline: this is where the 66M "derived rows" live, and 98% of it is dead-on-arrival
- **`ProposalPageLines` (33,673,377) + `ProposalLines` (32,606,517) = 66.3M rows** — against just **267,128 proposals** (~248 line-rows per proposal). This is the [[trimit-db-cleanup]] "66M derived rows" figure, confirmed live.
- **97.91% of proposals are NEVER approved** (5,585 approved / 261,543 not, of 267,128). The July-20 audit's "98% never-approved" — confirmed exactly. So ~65M of those 66M line-rows belong to proposals that never became work.
- **Nothing is ever purged:** proposals go back to **2008**, ~15,000–23,000 created *every year*, steadily. The line tables grow ~unboundedly with a 2% hit rate.

## 1. Entry points (code) — create pattern confirmed (same as Stage 1)
- **Base create:** `CodeGenerateProposal.cfm` → `<CFSTOREDPROC dbo.GenerateProposal>` (the Stage-1 executor pattern).
- **This is a POLYMORPHIC creator — 153 `GenerateProposal*` procs**, surfaced as ~20+ `CodeGenerateProposal$*.cfm` executors, one per bid type:
  `$Immediate`, `$SeasonalImmediate`, `$MultiYearImmediate`, `$GPS`, `$RFP` / `$RFP$OUT`, `$ChangeOrder`, `$FromWorkRequest`, `$FromBlanketCrewSheet`, `$FromSource`, `$ByModel`, `$ProjectAddress`, `$ProjectLayer`, `$Placeholder`, `$Watering`, `$NoBlanks`, `$User$RFP$OUT`, … → the different ways GSTS bids (one-off, seasonal, multi-year contract, GPS-inventory, RFP response, change order).
- **Edit/detail UI:** `Profile.Proposal.Detail.cfm` + `Profile.Proposal.Parameters.Content.cfm` (+ attachments/maps/notes/followup sub-pages).
- **Workflow position:** a Proposal ties **Company + Project + Location + Contact + RFP + SalesRep** together and, when `Approved`, fans out to `GoAheads` → `WorkOrders` → `Invoices` (its child tables — the downstream stages).

## 2. Data model (verified live)
- **`dbo.Proposals` — 267,128 rows, 221 columns** (the largest entity in the audit so far; bigger than Locations' 123, Companies' 133). Denormalized like the others: address block duplicated (`Location*`, `Address*`), ~30 `Prior/Future/CurrentYear` rollup columns (Total/Qty/Label ×6 years), ~30 map/geo columns (`neLat`..`seLng`, fonts, icons), scoring columns (`IsOnTime`/`IsLate`/`IsCorrect`/`NetPoints`).
- **Key state columns:** `Approved` (bit) + `DateApproved`, `StatusDefID`, `IsImmediate`, `IsMultiYear`, `IsChangeOrderProposal`, `IsGPSProposal`, `IsDevProposal`, `IsPlaceholder`, `ISBookmark`, `MasterProposal`/`ParentProposalID` (proposals nest), `RFPID`, `ContractID`, `WorkRequestID`.
- **14 parent FKs (needs-first):** `Companies`, `Projects`, `RFPs`, `Contracts`, `SalesReps` (×3: sales/field/inside rep), `StatusDefs`, `ProjectContacts`, `ProjectLayers`, `BlanketOrders`, `ColorDefs`, `PackageItemModels`, `UOMDefs`.
- **13 child tables:** `ProposalLines`, `ProposalPageLines`, `ProposalSections`, `ProposalLineGroups`, `ProposalCrewSheets`, `DefaultLabelLocations`, `InventoryHitRates`, **`GoAheads`, `WorkOrders`, `Invoices`, `GPSWorkOrders`, `CrewPackets`, `ProjectBudgetScopes`** (the last 6 = the downstream workflow stages 4–6).
- **The wider "project/proposal/RFP" cluster is ~90 tables**; top row-counts: `ProjectSeasonTotals` (3.6M), `RFPs` (1.69M), `ProposalTotals` (1.25M), `TempProposalTotals` (962K), `RFPItems` (955K), `ProposalOverview` (892K), `ProposalSeasons` (806K), `ProposalSections` (783K). Many are *rollup/temp* tables (see §5).

## 3. Used vs. dead
- **Used:** the `GenerateProposal*` family, `Proposals`, the line/section tables, the FK graph, `Profile.Proposal.Detail.cfm`.
- **Dead / orphan (flagged):** `Profile.Proposal.Detail$dev.cfm`, `$dev2.cfm`, `Profile.Proposal.DetailTravisTest.cfm`, `Profile.Proposal.Parameters.Conten$devt.cfm` (typo'd "$devt"), `Parameters.Content$dev.cfm`, `Parameters.ContentTest.cfm`.
- **Proc-family dead markers** (from Stage 1 sweep, still relevant): `GenerateProposal$dev`, `GenerateProposal$dev$03182010`, `GenerateProposal$dev$09112013` — date-stamped dev backups inside the 153-proc family.

## 4. Works vs. broken
- **No create defect found** (map-only). The proc pattern is clean; `Approved`/`DateApproved` gate the fan-out to downstream stages.
- **⚠️ The 2% hit rate is a design reality, not a bug:** TRIM IT snapshots a full priced proposal (with hundreds of line/page-line rows) for *every* bid attempt, and 98% never approve. Storage/perf cost is structural. (The investor case already measures the *bid-loop* friction that drives this — [[trimit-investor-case]].)
- **⚠️ Derived-column drift risk** (same pattern as Stages 1–2): the ~30 rollup columns on `Proposals` + the `ProposalTotals`/`ProposalOverview`/`ProposalSummary` tables are all stored aggregates that can drift from the line tables. Any figure taken from a rollup must be validated against the lines (name-the-command rule).

## 5. Cleanup candidates (FLAG only — map-only pass)
- **🥇 THE big one: dead proposal lines.** ~261,543 never-approved proposals own the overwhelming majority of the 66.3M `ProposalLines`+`ProposalPageLines` rows. A reversible archive of line-rows for proposals that are (never-approved AND older than N years) is the single largest space reclaim in the DB. **Rehearse on a frozen copy; the Proposals rows themselves may be worth keeping for win-rate history even when their lines are archived.** This is the marquee "cleanup as testing" candidate.
- **Temp / rollup tables to review:** `TempProposalTotals` (962,378 rows — a "Temp" table with ~1M rows is a red flag), `ProposalTotals` (1.25M), `ProposalOverview` (892K), plus `ProjectSeasonTotals` (3.6M) — confirm which are live-derived vs. abandoned scratch.
- **`zDelete-RFPPriorities`** (0 rows) + 8 empty `Project*` tables (`ProjectBudgetScopes/Lines`, `ProjectPeriods`, `ProjectSchedules`, `ProjectReps`, `ProjectCalendarYears`, `ProjectExportQueues`, `RFPPackageLetters`) — empty/dead structures.
- Dead `.cfm`/proc from §3.

## 6. Knowledge delta
- **Already knew:** [[trimit-db-cleanup]] (66M derived rows + 98% never-approved claims — both now confirmed live), [[trimit-investor-case]] (the bid-loop friction that produces the 2% rate), [[trimit-audit-02-contact-location]] (Company/Location/Contact all become FKs on a Proposal).
- **NEW this pass:** Proposals = 267,128 rows / **221 columns** (biggest entity); **153 `GenerateProposal*` procs** = a polymorphic creator, one variant per bid type; 14 parent FKs + 13 children (6 children ARE downstream stages 4–6); exact reconciliations — **97.91% not approved**, **66.3M line rows**, proposals back to 2008 with ~15–23K/yr and no purge; the dead-line-archive as the marquee cleanup; `TempProposalTotals` ~1M-row smell.

## ✅ WRITE-TEST VERIFICATION (2026-08-01, Skipper-directed)
**Method:** PLAY only (prod write blocked), `BEGIN TRAN … ROLLBACK` (executes for real, reverts); read the 6,476-char `GenerateProposal` body before executing; zero residue confirmed. Test project 1105554 → created ProposalID 802714.

| # | Finding (map-only claim) | Write-test | Verdict |
|---|---|---|---|
| 1 | Create path = `GenerateProposal` (base takes `@ZProjectID`) | S3-T1: EXEC’d → ProposalID 802714 seeded from Project→Location→Company, status Pending | ✅ CONFIRMED |
| 2 | 97.91% never approved | S3-T2: new proposal born `Approved=NULL`, status Pending | ✅ CONFIRMED — proposals are created UNAPPROVED; approval is an explicit later step, so the 2% hit-rate is by-design |
| 3 | Creating a proposal drives the 66.3M `ProposalLines`/`PageLines` (~248/proposal) | S3-T3: after create, **Proposals +1, ProposalLines +0, ProposalPageLines +0** | ⚠️ **REFINED — the BASE proc is HEADER-ONLY; it spawns ZERO line-rows.** The 66M lines come from the VARIANT creators (`GenerateProposal$Immediate`/`$Seasonal`/`$GPS`…) that populate from inventory in a SECOND phase. Proposal creation is two-phase: header shell → line population. |
| 4 | 14 parent FKs (Companies/Projects/…) | S3-T4: `SET CompanyID=-99999` → rejected (`FK_Proposals_Companies`) | ✅ CONFIRMED enforced |

**Correction/refinement:** §1 of this note framed the polymorphic `GenerateProposal*` family as “creators” generically; the write-test shows the **base `GenerateProposal` only writes the Proposals header** (Total/EstValue/Approved all NULL), and the massive line-row volume is produced by the inventory-driven *variant* procs. Header ≠ lines. Residue: identity ticks only; reverted to 267,128 proposals.

## Resume pointer
**Stage 3 COMPLETE (map-only, 2026-08-01).** Create path (`CodeGenerateProposal*` → `GenerateProposal*` ×153),
221-col data model, FK graph, and the two headline reconciliations captured live. **Next = Stage 4:
Go-Ahead / activation → Work Order** (`GenerateGoAhead`, `GoAheadsPostUpdate`, `GoAheads`+`WorkOrders` tables —
already partly known from [[goahead-status-lifecycle]]). Deferred: read a representative `GenerateProposal$Immediate`
body to see how line/page-line rows get generated; quantify line-rows owned by never-approved+old proposals (the
archive sizing). Cleanup execution still deferred (map-first).
