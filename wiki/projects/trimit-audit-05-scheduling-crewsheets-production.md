---
title: TRIM IT Audit 05 — Scheduling → Crew Sheets → Production
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, scheduling, crewsheets, production, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-04-goahead-workorder]]", "[[production-perf-future-dated-crewsheets]]", "[[trimit-stack-and-tph]]"]
updated: 2026-08-01
---

# TRIM IT Audit 05 — Scheduling → Crew Sheets → Production

> Stage 5 of the [[trimit-deep-audit]]. **Map-only pass (Skipper "A")** — zero writes. Every figure from a
> `gsql.sh` query or file read run THIS session. **Home turf** — extends the dashboard/production-perf work
> ([[production-perf-future-dated-crewsheets]], [[trimit-stack-and-tph]]) rather than re-deriving.

## ⭐ Headline: the actual production surface + the two live data traps we already knew
- **Scheduling = putting a WorkOrder on a crew's calendar.** Create path confirmed: `CodeGenerateCrewSheetsFromWOCrewCalendar.cfm` → `<CFSTOREDPROC dbo.GenerateCrewSheetsFromWOCrewCalendar>` params **`@ZWorkOrderID, @ZCrewCalendarID`**. Variants: `$OneDay`, `$AddDays`, `$Reschedule`. So a **CrewSheet is a WorkOrder scheduled onto a crew-day.**
- **CrewSheet → `InventoryAssignments` (the per-tree production records, 1.3M rows) → `InvoiceLines`** = the bridge into Stage 6 (billing).
- **This is the biggest dead-data domain in the DB** (see §5) — ~7M rows of backup/zDelete calendar+crew tables, nearly matching the 6.8M live `UserCalendars`.

## 1. Entry points (code) — verified by reading
- **CrewSheet create (the scheduling act):** `CodeGenerateCrewSheetsFromWOCrewCalendar.cfm` → `GenerateCrewSheetsFromWOCrewCalendar(@ZWorkOrderID,@ZCrewCalendarID)`. Plus `CodeGenerateCrewSheet.cfm`, `CodeGenerateCrewSheets.cfm`, `CodeGenerateCrewSheetCopy.cfm`, `CodeGenerateCrewSheetLine.cfm`.
- **Scheduling UI:** `Profile.ScheduleBoard.CrewNames.All.WO.cfm` (the schedule board), `Synch.CrewAssignment.Update.cfm` (crew↔day assignment, MM_UpdateRecord inline-UPDATE pattern).
- **Production/check-in UI:** `Profile.CrewSlopes.CheckIn.Content.cfm` (crew check-in), `Profile.CrewSheet.Detail.cfm`, `Profile.CrewSheet.Audit.cfm`, `Profile.ProductionWeek.Detail.cfm` / `.ByCrew.Detail.cfm`.

## 2. Data model (verified live)
**`dbo.CrewSheets` — 158,224 rows, 108 columns.** The day-of-work record for a crew.
- **The two-date columns at the root of the production-perf bug:** `WorkDate` (col 6, the corrupt one) AND `CalendarID` (col 21 → `Calendars.CalDate`, the correct one). **Two parent FKs to `Calendars`** (CalendarID + Created/AltCalendarID) — this duality is baked into the schema.
- Est/Act pairs: `EstCrew`/`ActCrew`, `EstTrees`/`ActTrees`, `EstHours`/`ActHours`, `EstValue`/`ActValue`, `EstTPH`/`ActTPH`. Plus `CompletedHours`/`CompletedDollars`/`CompletedTPH`, `ScheduledHours`/`ScheduledTotal`/`ScheduledTPH`. Status flags: `HoursEntered`, `InventoryEntered`, `IsCheckedIn`, `HoursLocked`, `IsAccrual`, `IsMainCrew`.
- **10 parent FKs:** `WorkOrders`, `Calendars` (×2), `WorkOrderCalendars`, `CrewPackets`, `Periods`, `SalesReps`, `StatusDefs`, `Users`, `CallInModels`.
- **6 child tables:** `InventoryAssignments`, `CrewAssignments`, `CrewSheetNotes`, `JobSheets`, `ProposalCrewSheets`, `UserCalendars`.

**`dbo.InventoryAssignments` — 1,304,994 rows, 34 columns.** The per-tree "who did what to which tree" production record.
- **8 parent FKs:** `CrewSheets`, `WorkOrders`, `WorkOrderLines`, `InventoryDetail` (the tree), `InvoiceLines` (→ billing), `CrewSlopes`, `WorkOrderSlopes`, `Users`, `JobSheetCosts`. → It's the join between a crew-day, the actual trees, and the invoice line.

**`dbo.Calendars` — 35,062 rows, 82 columns.** The date dimension (`CalDate`) that everything *should* bind to.

## 3. Used vs. dead
- **Used:** `GenerateCrewSheetsFromWOCrewCalendar` + family, `Profile.ScheduleBoard.*`, `Synch.CrewAssignment.Update.cfm`, `Profile.CrewSheet.Detail.cfm`, the FK graphs.
- **Dead / orphan (flagged):** `Profile.CrewSheet.Detail$dev.cfm`, `Profile.CrewSheet.Detail$Functioning$02052014.cfm`, `Profile.CrewSheet.DetailTemp.cfm`, `Profile.CrewInspections.Content.List$dev.cfm`, `Synch.CrewAssignment.Update$dev.cfm`, `Synch.CrewAssignment.Update_12092020.cfm`.

## 4. Works vs. broken
- 🐛 **The `WorkDate` corruption is LIVE and severe — re-measured this session:** of 6,445 H1-2026 crew sheets, **4,075 (63.23%) have `WorkDate` ≠ `CalDate`.** Dashboards that bin on `WorkDate` are wrong; the fix (rebind on `Calendars.CalDate`) shipped as package 4 → [[production-perf-future-dated-crewsheets]]. **Standing rule: bin production on `CalDate`, never `WorkDate`.** (H1 window shows 63% vs the ~47% all-H1 figure in the prior note — the corruption is not shrinking.)
- ⚠️ **`ScheduledHours` is ~unused:** 7,140 of 7,903 (90%) of 2026 crew sheets have `ScheduledHours` = 0/NULL → the tile-3 "returned field time" ratio is blind to it (numerator is the estimate). Consistent with [[bod-commitment-dashboard]]'s pending gap.
- ⚠️ **`CompletedHours` is NOT a straight copy of `ActHours`** (only 1,494 of 7,903 equal) — refines the earlier "CompletedHours = copy of ActHours" note; the relationship is looser than assumed. Worth a closer look before trusting either as "actual clocked time" (payroll hours remain the ground truth per [[bod-commitment-dashboard]]).

## 5. Cleanup candidates (FLAG only — the LARGEST domain in the DB)
- **🥇 ~7 MILLION rows of dead calendar/crew backup tables** (nearly matching the 6.8M live `UserCalendars`):
  - `zUserCalendarsBackup$11062025` — **5,646,540** rows (a near-full duplicate of `UserCalendars`)
  - `zDelete-UserCalendarsBK_12222020` — 885,741
  - `zDelete-CrewAssignments_12282020_v2` — 249,793 **and** `zDelete-CrewAssignments_12282020` — 249,366 (kept BOTH copies)
  - `zDelete-calendarbak0304` — 9,495; `zDeleteCrewMembersBackup12182025` — 558; `zDeleteCrewMembersBackup` — 545; `zDelete-Orphaned$InventoryAssignments` — 303; `zDelete-CrewSheets$Deleted` — 138; `zDelete-CrewFactors` — 137; `zDelete-CrewMemberCalendarsBackup` — 53; `zDelete-ProductionWorksheets` — 0.
  - → This alone is likely the single biggest reversible space reclaim in the database. Rehearse-then-drop on a frozen copy.
- **Empty/dead structures (0 rows):** `CrewMemberAbsences`, `GPSInventoryAssignments`, `ProjectSchedules`, `CrewMemberEquipment`, `CrewMemberCalendarRefreshLog`, `GSTSContractCalendars`.
- Dead `.cfm` from §3.

## 6. Knowledge delta
- **Already knew:** [[production-perf-future-dated-crewsheets]] (WorkDate vs CalDate; CompletedHours; the rebind fix), [[trimit-stack-and-tph]], [[bod-commitment-dashboard]] (clocked payroll = productivity ground truth), [[trimit-audit-04-goahead-workorder]] (CrewSheets are WorkOrder children).
- **NEW this pass:** the create path proving scheduling = `GenerateCrewSheetsFromWOCrewCalendar(@ZWorkOrderID,@ZCrewCalendarID)`; CrewSheets = 108 cols/158,224 rows (10 parents incl. **2 FKs to Calendars** — the duality is structural), 6 children; **InventoryAssignments = 1.3M rows** bridging crew-day↔tree↔InvoiceLines; **63% H1-2026 WorkDate≠CalDate** (corruption not shrinking); `ScheduledHours` 90% empty; `CompletedHours≠ActHours` (looser than the old note said); **~7M-row dead backup domain** — the biggest cleanup target found.

## ✅ WRITE-TEST VERIFICATION (2026-08-01, Skipper-directed)
**Method:** PLAY only, `BEGIN TRAN … ROLLBACK`, zero residue. **Scope call:** the create proc `GenerateCrewSheetsFromWOCrewCalendar` is a heavy multi-proc CASCADE (dispatch → `$Crew$New` cursor → deeper insert + RFP completion + a project-wide **inventory cursor**). Firing it — even rolled back — would hold locks on the SHARED play box, so I verified creation by READING (`$Crew$New` sources the crew sheet's `CalendarID` from `CrewCalendars.CalendarID` = the scheduled crew-day) and write-tested the rest surgically.

| # | Finding (map-only claim) | Write-test | Verdict |
|---|---|---|---|
| 1 | Scheduling create path sets `CalendarID` from the scheduled crew-day | read `$Crew$New`: `@VCalendarID = CrewCalendars.CalendarID` | ✅ CONFIRMED by read (cascade too heavy to fire on shared box) |
| 2 | `CrewSheets.WorkOrderID` → WorkOrders FK | S5-T1: `SET WorkOrderID=-99999` → rejected | ✅ CONFIRMED enforced |
| 3 | **`WorkDate` corruption → mis-bins production; bind on `CalDate`** | S5-T2: injected `WorkDate` 3 months off → `MONTH(WorkDate)=4` WRONG vs `MONTH(CalDate)=7` RIGHT | ✅ **CONFIRMED — write-demonstrated: `WorkDate` is freely writable to a wrong value and mis-attributes production to the wrong month; `CalendarID→CalDate` stays correct** |
| 4 | 63% H1 crew sheets `WorkDate`≠`CalDate` | S5-T3: live re-count | ✅ CONFIRMED — **63.23%** (4,075 of 6,445) |

⭐ **Bonus — caught a corrupted sheet in the wild:** the test crew sheet 541600 already had `WorkDate=2026-07-30` but true `CalDate=2026-07-29` (a real live 1-day mismatch), before I touched anything. The corruption is genuinely present in production data, not hypothetical. Residue: WorkDate restored by rollback; count 158,224.

## ✅ WRITE-TEST — full scheduling CASCADE fired (2026-08-01, follow-up "B")
**`GenerateCrewSheetsFromWOCrewCalendar(@ZWorkOrderID,@ZCrewCalendarID)` fired on PLAY** (WO 165464 on a **1-tree project** to keep the inventory cursor minimal; crew calendar 568783, non-INTERNAL), `TRAN…ROLLBACK`, `LOCK_TIMEOUT 15s`.
- ✅ **Ran to completion without error; rolled back CLEAN (158,224).**
- 🔴 **Key finding — the cascade is EXPENSIVE: 72,152 ms (72 s) even on a 1-tree project.** The cost is NOT the inventory cursor (1 row) — it's the chain of sub-procs (`$Crew$New` + `EvaluateStumpCrew` + RFP completion + `UpdateWorkOrderGeneral`). **This validates the Stage-5 caution:** on an average project (297 inventory) or a large one (up to 108,306) this would hold locks for a very long time. **Scheduling a work order is a heavyweight operation** — relevant to any performance work and to arbor-core's design.
- ⚠️ **Inconclusive on fresh-sheet binding:** this WO already had 139 crew sheets and the combo added **0 net** (nothing new inserted — either already scheduled for that crew-day or the date logic produced none). So I could NOT observe a newly-created sheet's WorkDate=CalDate. The create-side binding (`CalendarID` from `CrewCalendars.CalendarID`) remains established by READING `$Crew$New` (Stage 5 §1). Chose NOT to retry — repeated 72s cascade runs on the SHARED play box aren't worth the lock pressure for a point already covered by code-read.
- Residue: zero (reverted to 158,224).

## Resume pointer
**Stage 5 COMPLETE (map-only, 2026-08-01).** Scheduling create path, CrewSheets/InventoryAssignments/Calendars
schema + FK graphs mapped; the two data traps (WorkDate corruption, ScheduledHours/CompletedHours) re-measured live;
the ~7M-row backup domain flagged. **Next = Stage 6: Invoicing / AR** (`GenerateInvoice*`, `Invoices`, `InvoiceLines`,
`InvoiceMasters` — InventoryAssignments already bridges here; AR work known via [[anomaly-monitor-suite]]). Deferred: read
`GenerateCrewSheetsFromWOCrewCalendar` body for how sheets seed from the calendar. Cleanup execution deferred (map-first)
— but the ~7M-row calendar-backup drop is now the #1 space-reclaim rehearsal candidate.
