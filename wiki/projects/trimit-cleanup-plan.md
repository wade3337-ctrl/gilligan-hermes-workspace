---
title: TRIM IT Cleanup Plan — inventory + phased execution
type: project
domain: work
track: 1
status: PLAN (execution gated on Skipper go + rehearsal)
tags: [trimit, cleanup, database, plan, dead-tables, db-repair]
applies: ["[[db-repair-contract]]", "[[repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-db-cleanup]]", "[[trimit-audit-01-customer-creation]]", "[[trimit-audit-03-lead-proposal-bid]]", "[[trimit-audit-05-scheduling-crewsheets-production]]", "[[play-gsts-is-ephemeral]]", "[[prod-db-access-blocked]]"]
updated: 2026-08-01
---

# TRIM IT Cleanup Plan

> Compiled 2026-08-01 from the completed 7-stage [[trimit-deep-audit]] (map-only + write-verified). **Every
> figure below is from a live `gsql.sh` query run THIS session.** Execution is gated on the Skipper's go +
> rehearsal; governed by [[db-repair-contract]] (backup-first, reversible, rehearse, hand devs scoped steps).

## 📋 THE INVENTORY (live counts, 2026-08-01)
| # | Category | Size | Risk | Value | Notes |
|---|----------|------|------|-------|-------|
| **A** | **Dead tables** (`zDelete*` / `*Backup`) | **271 tables · 20.4M rows · 5,764 MB** | 🟢 low (already named for deletion) | 🥇 huge | biggest: `zUserCalendarsBackup$11062025` 2.1GB · `zDelete-TriggerDebugLog` 1.2GB · `zDelete-Backup_UserSelections` 5.0M rows. ⚠️ CORRECTED: earlier 416/44M was inflated by an `allocation_units` join fan-out (LOB/overflow units); clean distinct-table count = 271/20.4M. The 5.76 GB size was always correct. |
| **B** | **Dead procedures** (`$dev`/`test`/`BK`/date-stamped) | **160 procs** | 🟡 med (dependency-check first) | med | e.g. `GetEmployeesWorkingHours_..._BK*2019` ×11, `GenerateProposal$dev$03182010`, `test1/2/3` |
| **C** | **Empty tables** (0 rows, non-zDelete) | **69 tables** | 🟡 med (some may be live-but-unused) | low | dead structures: `Payments`, `Applied`, `ProjectSchedules`, `GSTSArborNote*`… |
| **D** | **Never-approved proposal LINES** | **261,543 proposals → 32.6M `ProposalLines`** (+~33M `ProposalPageLines`) | 🔴 high (keep headers!) | 🥇 huge | archive lines for never-approved+aged proposals; KEEP the `Proposals` rows for win-history |
| **E** | **Dead `.cfm`** on the play webroot | ~dozens (`$dev`, `_MP_Test`, `$2`, date-stamped, per-client-ID) | 🟢 low | low | ⚠️ verify inbound refs first (a `_MP_Test` file was wired into a LIVE page) |
| **F** | **Data-quality (operational, not schema)** | 40 InProcess GoAheads = **$415,590** · ~3,830 excess dupe Contacts (~30%) | 🟡 med | med | finish/void the go-aheads (account owners); Contacts merge machinery already exists |
| **G** | **Code/schema DEFECTS** (fixes, not deletions) | 3 | varies | med | `GenerateWorkOrders` misnamed-cursor (throws err 16916 every run) · `InvoiceMasters.CompanyID` has NO FK · blank-overwrite data-loss trap in `Synch.*.Update.cfm` |

**Headline: A + D together = ~5.8 GB of tables + ~65M line-rows of dead weight — the bulk of TRIM IT's bloat.**
*(A = 271 tables / 20.4M rows / 5.76 GB, clean distinct-table counts 2026-08-01.)*

## 🌍 Environment realities that SHAPE the plan (non-negotiable)
- **Play `GSTS` is DROP+RESTORE'd from prod every night** ([[play-gsts-is-ephemeral]]). Two consequences:
  1. ✅ **Play GSTS is the PERFECT free rehearsal ground** — run the whole cleanup on it, measure, and the nightly refresh is a guaranteed undo. No separate backup needed to *rehearse*.
  2. ❌ A cleanup can't *persist/soak* on play GSTS across days — for a multi-day soak we'd need a frozen `GSTS_cleanup` copy (survives the refresh, like `Workbench` does).
- **Prod DB WRITE is BLOCKED** ([[prod-db-access-blocked]]). We can build + rehearse fully now; **EXECUTING on prod requires a dev grant** (Jordan/AWS) OR handing Jordan exact scoped scripts to run (the [[db-repair-contract]] path).
- **So the plan is: BUILD + REHEARSE on play now → PACKAGE exact scripts → devs run on prod → verify.**

## 🧭 SEQUENCING DECISION (Skipper, 2026-08-01): PROCESSES FIRST, then DATA
**Why (dependency logic):** code depends on tables; tables never depend on code. A proc is the *dependent*, a table is the *depended-upon*. Safe teardown removes **dependents before dependencies** → remove procs/pages BEFORE tables. Removing a proc can't break a table; removing a table CAN break a proc (the `GenerateWorkOrders` cursor-bug class). Bonus: killing a dead proc that *writes to* a dead table (e.g. a dead trigger feeding `zDelete-TriggerDebugLog`, 1.2 GB) leaves that table cleanly orphaned → **processes-first unlocks more tables as safe-to-drop** and shrinks the risky table-dependency question to "referenced by *live* code?".

## 🛡️ EXECUTION METHOD (per [[db-repair-contract]] — reversible, never a blind DROP)
For every object we remove, the **quarantine → soak → drop** pattern:
1. **Script it out first** — `CREATE` definition + row count → a file in `arbor-stack/cleanup/backups/`. (For the disposable `zDelete*`/`*Backup` data, the definition + count is the backup; the data is already redundant by design.)
2. **Dependency check — the EFFICIENT way (learned 2026-08-01):** use SQL Server's **native dependency tracker `sys.sql_expression_dependencies`** (indexed, instant, 26,214 edges) for in-DB callers — NOT a brute-force `LIKE` over `sys.sql_modules` LOB definitions (that timed out the shared box). Then cross-check the **8,645 `.cfm`** in a SINGLE pass (concatenate content, in-memory `Contains` per name). A proc/table is safe only when BOTH come back empty. ⚠️ Residual blind spot: **dynamic SQL** (`EXEC(@sql)`) is invisible to both — the soak window catches it (a dynamic call to a quarantined object errors on play before prod).
3. **Quarantine, don't drop** — rename into a `_graveyard` schema (or prefix) so it's invisible to the app but instantly restorable. On play we can skip straight to drop (nightly refresh = undo); on **prod** we quarantine + soak.
4. **Soak** — leave quarantined N days; if nothing breaks, **drop**.
5. **Log every action** to `gsts-ship-log.md`; verify with a stated acceptance check (row/space reclaimed, app still renders).

## 🔬 PROC CALL-GRAPH RESULTS (built 2026-08-01 — the foundation for processes-first)
Artifacts in `arbor-stack/cleanup/manifests/`. The funnel from name-flagged → truly dead:
- **164** procs matched dead-marker names → **INFLATED** by loose patterns (caught live procs like `EvaluateStumpCrew`, which we watched run in the Stage-5 cascade). Tightened to high-confidence markers (`Backup$` prefix, `$dev` SUFFIX, date-stamped `201x`, `TRAVISBACKUP`, `test1/2/3`) → **103**.
- Of 103: **13 have in-DB callers** → NOT dead. The trap the Skipper predicted: `$Dev`-suffixed procs wired into live code (`InsertCrewAssignments$Dev` called 5×, the `MoveCrewSheet*$Dev` family). → `dead-procs-tight.txt`.
- Remaining **90 have no proc caller** — but that ≠ dead (pages call procs directly; the whole `Generate*` create pattern has 0 proc callers). Cross-checked all 90 vs the 8,645 `.cfm`: **6 are referenced by pages** (`DeleteWorkOrderLine$dev`, `GenerateWorkOrderLine$AdHoc$dev`, `test1`, `test2`, `Bump$AssignInventory$Flag$User$dev`, `CU$MoveRFPActionToOtherObject$FromSchedule$dev`).
- **➡️ 84 procs = TRUE DEAD (0 proc callers + 0 `.cfm` callers)** → `true-dead-procs-84.txt`. The Phase-1 removal set. Examples: `Backup$GenerateGoAheadLines`, `Backup$GenerateInvoicePageLines$08012016`, `CleanUp$ProposalTotals$dev`, the `Backup$MoveCrewSheet*` + `CURSOR$*$Dev` families.
- **Lesson proven live:** name-matching alone would have "removed" live procs. The call graph IS the safety net — and it's the dependency map that makes the later table cleanup tractable.

## 🗺️ PHASED PLAN — PROCESSES FIRST, THEN DATA (re-sequenced 2026-08-01)
### 🔹 TRACK 1 — PROCESSES (dead code, do first)
**Phase 1 — Dead procs (84 TRUE DEAD)** ✅ *call-graph complete* → `true-dead-procs-84.txt`.
- Script out each `CREATE` → `arbor-stack/cleanup/backups/procs/`. Quarantine (rename to a `_graveyard` schema) on play → run `verify-build.sh` + smoke the served app → self-reverts nightly. Package a prod `DROP`/quarantine script for Jordan. **13 (in-DB callers) + 6 (`.cfm` callers) are HELD for investigation — do NOT drop.**
- ⚠️ Before drop: note the dynamic-SQL blind spot — the soak window is the catch.

**Phase 2 — Dead `.cfm` pages E** — the app-layer twins (`$dev`, `_MP_Test`, `$2`, date-stamped, per-client-ID).
- Same funnel as procs but for pages: enumerate candidates, check inbound links (a `_MP_Test` was wired live once!), back up to `\GSTS\Jasonsrepairs\` per [[repair-contract]], quarantine, verify render, remove. Build the candidate list next.

### 🔸 TRACK 2 — DATA (do AFTER processes; now a cleaner dependency question)
**Phase 3 — Dead tables A (🥇 271 tables / 20.4M rows / 5.76 GB)** — already named `zDelete`/`Backup`.
- With dead procs gone, the table check is "referenced by *live* code?" — and some tables become newly-orphaned (their only writer was a removed dead proc/trigger). Webroot grep already clean for the top tables (0 `.cfm` refs). Re-run the in-DB reference check via the native tracker for the full 271, quarantine+drop on play biggest-first, measure space, package for prod. **The single biggest space win.**

**Phase 4 — Empty tables C (69) + confirmed-orphan structures** — low value, batch with Phase 3.

**Phase 5 — Proposal-line archive D (🥇 ~65M rows, high care)** — the DB-slimming prize.
- "Archivable" = proposal never-approved AND older than a Skipper-set cutoff (e.g. > 2 yrs). **Keep the `Proposals` header rows** (win-rate history); move only `ProposalLines`/`ProposalPageLines` to an archive, then delete from live. Rehearse on play; reconcile counts; prove no dashboard breaks. **Needs the Skipper's cutoff decision.**

### 🔸 TRACK 3 — OPERATIONAL / DEFECTS (independent, any time)
**Phase 6 — Data-quality F** — 40 InProcess GoAheads ($415K): account owners finish/void per [[goahead-status-lifecycle]]. Contact dedupe: rehearse the existing merge machinery on ~3,830 dupes.

**Phase 7 — Defect fixes G (ship via dev-handoff)** — one-line cursor rename in `GenerateWorkOrders`; add `FK_InvoiceMasters_Companies` WITH CHECK (0 orphans on play, verify prod); the blank-overwrite trap needs a UI decision (preserve-on-blank vs intended-clear) — scope with the Skipper first.

## ✅ THE GATE (what unblocks execution)
1. **Skipper GO** on the plan + the archive cutoff for Phase 5 (proposal lines).
2. **Decide the target:** rehearse-only on play (free, self-reverting) first — always. Persist/measure needs a frozen `GSTS_cleanup` copy.
3. **Prod execution** = package scoped scripts for Jordan (prod write still blocked) → he runs → we verify. Nothing touches prod without his run + our acceptance check.

## 📁 Artifacts (in `arbor-stack/cleanup/`)
- `manifests/dead-tables-manifest.txt` — 271 dead tables (name|rows|MB)
- `manifests/dead-procs-tight.txt` — 103 high-confidence dead-marked procs + in-DB caller counts
- `manifests/true-dead-procs-84.txt` — ⭐ the 84 TRUE-DEAD procs (Phase 1 removal set)
- `manifests/referenced-in-cfm-6.txt` — the 6 held (page-referenced)
- `sql/dep-scan.sql` — the (slow) brute-force scan, superseded by the native-tracker method
- `deep-audit/psrun.sh` — SSH+PowerShell helper (holds the key path)

## Resume pointer
Plan re-sequenced **processes-first** 2026-08-01; proc call-graph DONE (84 true-dead procs ready). **NEXT:
Phase 1 rehearsal — quarantine the 84 dead procs on play + `verify-build.sh` (self-reverts nightly).** Then
Phase 2 (build the dead-`.cfm` candidate list). Data tracks (3–5) follow; Phase 5 (proposal-line archive)
needs the Skipper's age cutoff. Defects (Phase 7) ship independently via dev-handoff.
