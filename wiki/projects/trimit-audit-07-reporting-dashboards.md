---
title: TRIM IT Audit 07 — Reporting / Dashboards (consolidation)
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, reporting, dashboards, rollup-drift, consolidation]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]", "[[dashboard-metric-standards]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-06-invoicing-ar]]", "[[shared-engine-kills-dashboard-drift]]", "[[bod-commitment-dashboard]]", "[[path-to-25m-2026]]"]
updated: 2026-08-01
---

# TRIM IT Audit 07 — Reporting / Dashboards (consolidation pass)

> Stage 7 of the [[trimit-deep-audit]]. **Map-only.** This is the layer WE built (RC-01..06, SPM, BOD, RGC),
> so this is a **consolidation/reconciliation** pass, not fresh discovery: where do dashboards read the
> now-mapped tables, and where is the derived-rollup drift risk concentrated? Every figure from a live query.

## ⭐ Headline: the reporting layer is a DERIVED tier sitting on stored rollups — drift is the systemic risk
Across Stages 1–6, every core entity carried **stored aggregate columns** (Companies' Prior/Future/HTD, Proposals' 30 rollups, CrewSheets' Completed/Scheduled). On top of those sit **~28 rollup TABLES** that dashboards read instead of recomputing from base rows. **This is the single systemic risk of the reporting layer: a number is only as fresh as the last time its rollup was rebuilt.** The name-the-command rule exists because of exactly this.

## 1. The derived-rollup drift surface (verified live)
Rollup tables dashboards read (rows): `ProjectSeasonTotals` 3,587,425 · `ProposalTotals` 1,245,980 · **`TempProposalTotals` 962,378 (a "Temp" table with ~1M rows)** · `InventoryHitRates` 900,519 · `ProposalOverview` 891,879 · `ProjectSummary` 611,225 · `ProjectLayerSummary` 329,296 · `PayrollPeriodSummary` 183,346 · `ProposalSummary` 169,045 · `SalesRepMarketClassPerformance` 156,492 · `InventorySummary` 121,385 · `PayrollSummary` 78,210 · `WorkOrderSummary` 70,920 · `ProjectTotals` 66,140 · `ProjectPerformanceSummary` 24,191 · `CompanySummary` 12,773 · `ProductionPerformance` 10,805 · `MarketPerformance` 5,607 · … (~28 total).
- **Rule that fixes this class of bug:** [[shared-engine-kills-dashboard-drift]] — factor a duplicated calc into ONE load-guarded shared include; reconcile the spine, keep produced-vs-invoiced as distinct labeled actuals. Already applied on City Budgets/Forecast/Production.

## 2. Which dashboards bind to which mapped stage (our build ↔ the audit)
| Dashboard (ours) | Reads (mapped stage) | Known trap it must respect |
|---|---|---|
| RC-01 Executive Financial · RC-02 Revenue Perf | Invoices/Proposals rollups (S3,S6) | `SUM(Total)` not IsProForma/IsCredit (S6); count-once (RGC) |
| RC-04 SPM | Proposals→GoAheads→WorkOrders→Production (S3–S5) | 2% proposal hit-rate is real (S3); CalDate not WorkDate (S5) |
| BOD Commitment · [[path-to-25m-2026]] | Invoices `SUM(Total)` ÷ clocked payroll (S6, S5) | IsProForma/IsCredit 99.5% NULL (S6); ScheduledHours 90% empty (S5) |
| RGC (Revenue Goal Close) | Proposals/GoAheads/Invoices count-once (S3,S4,S6) | goal-governance drift (SalesGoal vs approved) |
| Production Perf | CrewSheets/InventoryAssignments (S5) | **63% WorkDate≠CalDate** — rebind on CalDate |
| City Budgets/Forecast | Contracts/ContractPeriods (S4) | Brent $178K = hand-typed Excel artifact, not a bug |
| AR report ([[anomaly-monitor-suite]]) | Invoices.InvoiceBalance (S6) | no cash layer — QB owns payments |

## 3. Used vs. dead (reporting layer)
- **Used:** our RC/BOD/SPM/RGC dashboards (documented in [[PROJECTS]]); the rollup tables above; the shared FY engine.
- **Dead / orphan (flagged):** `TempProposalTotals` (~1M-row scratch), the legacy `Exec$Periods$Overview` / `Exec-Performance-Day` (already flagged for hide/rename), the `$dev`/`Test`/date-stamped report twins seen every stage.

## 4. Works vs. broken (reporting layer)
- ⚠️ **Rollup freshness is the recurring defect class** — the future-dated-crewsheet miss, the close-rate drill mis-foot, the RGC em-dash were all "read a stale/derived value" bugs, not logic bugs. Fix pattern: verify the served output + foot the drill to the tile ([[repair-contract]] / `verify-build.sh`).
- ⚠️ **`Temp*` tables in the live read path** (`TempProposalTotals`) blur the line between scratch and source — a dashboard reading a "Temp" table is a smell to chase.

## 5. Cleanup candidates (reporting layer)
- `TempProposalTotals` (962K), `WorkspaceInventorySummary`, and any rollup with no scheduled rebuild job → verify then flag.
- The legacy exec report orphans (M2 hide/rename list in [[PROJECTS]] cleanup flags).

## 6. Knowledge delta
- **Already knew:** all our dashboards ([[PROJECTS]] RC-01..06, [[bod-commitment-dashboard]], [[path-to-25m-2026]]), [[shared-engine-kills-dashboard-drift]], [[dashboard-metric-standards]].
- **NEW this pass:** the explicit **dashboard↔stage↔trap crosswalk** (§2); the ~28-table rollup drift surface quantified; the recognition that reporting-layer bugs are a single class (stale-rollup reads), with one fix pattern.

---

# 🏁 FULL AUDIT SUMMARY — the workflow spine, mapped (Stages 1–7, 2026-08-01)

**Method:** walked the business lifecycle in order, map-only (Skipper "A"), every figure from a live `gsql.sh`
query or play-webroot file read. Full stage tracker + architecture pattern in [[trimit-deep-audit]].

**The spine (each arrow = a confirmed create proc):**
`Company` (`GenerateCompany`) → `Contact`/`Location` (`GenerateContact`/`GenerateLocation`) →
`Proposal` (`GenerateProposal`×153) → `GoAhead` (`GenerateGoAhead(@ProposalID)`) →
`WorkOrder` (`GenerateWorkOrders(@LocationID,@Year)`) →
`CrewSheet` (`GenerateCrewSheetsFromWOCrewCalendar`) → `InventoryAssignments` →
`InvoiceMaster→Invoices→InvoiceLines` (`GenerateInvoiceMaster`) → [dashboards].

**Scale:** **964 tables · 3,628 procs · 29 views.**

**Two write architectures:** CREATE = `Code<Proc>.cfm` → `<CFSTOREDPROC>` (proc-driven). EDIT = inline `UPDATE` in `Synch.*.Update.cfm` (Dreamweaver MM_UpdateRecord) — carries a **blank-overwrite data-loss trap**.

**The cleanup prize (all reversible, rehearse-first):**
- 🥇 **271 dead tables = 20,409,277 rows** (`zDelete*`/`z*Backup`) — the headline reclaim. Biggest single: `zUserCalendarsBackup$11062025` (5.6M) + the calendar/crew backup domain (~7M, Stage 5).
- 🥈 **~65M of 66.3M proposal line-rows belong to never-approved bids** (97.91% never approved, Stage 3) — archivable, keep the Proposals rows for win-history.
- 🥉 **164 dev/test/backup procs** + `$dev`/`_MP_Test`/date-stamped `.cfm` twins in every folder.
- **Contact dedupe:** ~30% dupes (3,830 excess rows, Stage 2) — merge machinery already exists.

**Live data-quality signals worth acting on:** 40 InProcess GoAheads = $415,590 half-finished activations (S4); 63% H1 crew sheets WorkDate≠CalDate (S5); AR open $18.5M (S6); IsProForma/IsCredit 99.5% NULL → use `SUM(Total)` (S6).

**The QB boundary:** TRIM IT has **no cash/payment layer** (`Payments`/`Applied` = 0) — QuickBooks owns payments; `InvoiceLine` (singular) is the QB staging surface.

**Why this matters for arbor-core:** the spine, the two write patterns, the derived-rollup drift class, and the QB boundary are exactly the decisions the strangler-fig rebuild inherits. The dead-data map is the "cleanup by construction" target ([[arbor-core-db-importers]]).

## Resume pointer
**Stage 7 COMPLETE — the 7-stage workflow audit is DONE (map-only, 2026-08-01).** Next moves are the Skipper's
call: (a) pick a cleanup rehearsal to execute on a frozen copy (calendar-backup drop = biggest; contact-dedupe =
safest; proposal-line archive = highest-value) per [[db-repair-contract]]; or (b) go deeper on any single stage's
proc bodies; or (c) feed the spine map into arbor-core. Cleanup EXECUTION still gated on the Skipper's go + a
`GSTS_cleanup` frozen snapshot (play `GSTS` is wiped nightly).
