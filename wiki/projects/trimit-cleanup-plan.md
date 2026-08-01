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

## 🛡️ EXECUTION METHOD (per [[db-repair-contract]] — reversible, never a blind DROP)
For every object we remove, the **quarantine → soak → drop** pattern:
1. **Script it out first** — `CREATE` definition + row count → a file in `arbor-stack/cleanup/backups/`. (For the disposable `zDelete*`/`*Backup` data, the definition + count is the backup; the data is already redundant by design.)
2. **Dependency check** — grep every proc/view (`sys.sql_modules`) + the 8,645 `.cfm` for the object name. Nothing references it → safe. (This is the gate that the WorkOrders-cursor bug taught us to respect: code has surprises.)
3. **Quarantine, don't drop** — rename into a `_graveyard` schema (or prefix) so it's invisible to the app but instantly restorable. On play we can skip straight to drop (nightly refresh = undo); on **prod** we quarantine + soak.
4. **Soak** — leave quarantined N days; if nothing breaks, **drop**.
5. **Log every action** to `gsts-ship-log.md`; verify with a stated acceptance check (row/space reclaimed, app still renders).

## 🗺️ PHASED PLAN (by risk × value)
**Phase 0 — Rehearsal harness (do first, on play, this week)**
- Script: enumerate each category into a manifest (name, rows, MB, definition). Build `arbor-stack/cleanup/` with per-phase `.sql`.
- Run a **dependency-reference scan** for categories A/B/C against `sys.sql_modules` + the webroot `.cfm`. Output: "safe to drop" vs "referenced — investigate" lists.

**Phase 1 — Dead tables A (🥇 5.76 GB, lowest risk)** — they're already named `zDelete`/`Backup`.
- Rehearse the quarantine+drop on play; confirm the app still renders (`verify-build.sh`); measure space reclaimed. Package a prod script (batched, biggest-first). **This is the single biggest, safest win.**

**Phase 2 — Dead procs B + empty tables C + dead `.cfm` E** — after the reference scan clears them.
- Batch the confirmed-unreferenced ones; quarantine; soak; drop. Handle `.cfm` per [[repair-contract]] (backup to `\GSTS\Jasonsrepairs\`, verify no inbound links).

**Phase 3 — Proposal-line archive D (🥇 ~65M rows, high care)** — the DB-slimming prize.
- Define "archivable" = proposal is never-approved AND older than a chosen cutoff (e.g. > 2 yrs). **Keep the `Proposals` header rows** (win-rate history); move only `ProposalLines`/`ProposalPageLines` to an archive table/DB, then delete from live. Rehearse on play; reconcile counts; measure. Prove no dashboard breaks (they read approved/live proposals).

**Phase 4 — Data-quality F (operational)** — not a bulk DB op.
- 40 InProcess GoAheads: hand the list to the account owners to finish or void the activation (per [[goahead-status-lifecycle]]). Contact dedupe: rehearse the existing merge machinery on the ~3,830 dupes.

**Phase 5 — Defect fixes G (separate track, ship via dev-handoff)** — one-line cursor rename; add `FK_InvoiceMasters_Companies` WITH CHECK (0 orphans on play, verify prod); the blank-overwrite trap needs a UI/handler decision (preserve-on-blank vs. intended-clear), so scope with the Skipper before touching.

## ✅ THE GATE (what unblocks execution)
1. **Skipper GO** on the plan + the archive cutoff for Phase 3.
2. **Decide the target:** rehearse-only on play (free, self-reverting) first — always. Persist/measure needs a frozen `GSTS_cleanup` copy.
3. **Prod execution** = package scoped scripts for Jordan (prod write still blocked) → he runs → we verify. Nothing touches prod without his run + our acceptance check.

## Resume pointer
Plan compiled 2026-08-01. **NEXT: Skipper picks the entry point** — recommended **Phase 0 (harness) + Phase 1
(dead-table rehearsal on play)** as the safest, highest-value start; it's fully doable now (play write proven,
self-reverting). Phase 3 (proposal-line archive) is the biggest slim but needs the Skipper's cutoff decision.
Defects (Phase 5) can ship independently via the dev-handoff path.
