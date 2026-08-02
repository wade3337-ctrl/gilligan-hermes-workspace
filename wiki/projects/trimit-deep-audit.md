---
title: TRIM IT Deep Audit — DB + ColdFusion, workflow-first
type: project
domain: work
track: 1
status: ACTIVE — living master index. ✅ ALL 7 STAGES MAPPED + STAGES 1–6 WRITE-VERIFIED (2026-08-01). Cleanup plan ⏸️ PAUSED by Skipper 2026-08-02. Full audit summary in [[trimit-audit-07-reporting-dashboards]].
tags: [trimit, database, coldfusion, audit, cleanup, workflow, customer-creation, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]", "[[config-clobber-guard]]"]
links: ["[[trimit-db-cleanup]]", "[[trimit-db-gotchas]]", "[[trimit-server-topology]]", "[[trimit-stack-and-tph]]", "[[workbench-play-db]]", "[[arbor-core-db-importers]]", "[[play-gsts-is-ephemeral]]", "[[prod-db-access-blocked]]", "[[coldfusion-2025-upgrade-case]]"]
updated: 2026-08-02
---

# 🔬 TRIM IT Deep Audit — DB + ColdFusion, workflow-first

> **⭐ THIS IS THE MASTER INDEX / SINGLE FRONT DOOR for the whole audit.** Open this note FIRST every
> session. Everything we knew + everything we learn is tracked or linked from here so nothing gets lost
> again. Mission, method, the stage tracker, all knowledge sources, and guardrails are below.

## ✅ DASHBOARD VERIFICATION → [[trimit-audit-dashboard-verification]] (2026-08-02)
"Are our dashboards reading the right things?" — audit's 5 biggest data traps run as a checklist against all 86 dashboard `.cfm`. **Every LIVE dashboard PASSES all 5** (WorkDate→CalDate binding · revenue `SUM(Total)` not the NULL filter · Job-TPH vs True-TPH kept distinct · close-rate counts `Complete` · no stale-rollup reads). Only 3 orphan `ex_*` files carry old patterns (0 inbound refs → cleanup, not a live issue).

## 🧹 CLEANUP PLAN → [[trimit-cleanup-plan]] (compiled 2026-08-01)
**Re-sequenced PROCESSES-FIRST (Skipper 2026-08-01):** dead code before data (code depends on tables, not vice-versa; killing dead procs unlocks more orphan tables). **Proc call-graph DONE via native dependency tracker → 84 TRUE-DEAD procs** (0 proc + 0 `.cfm` callers) ready to quarantine; 13+6 held for investigation. Then dead `.cfm`, then data: **271 dead tables/20.4M rows/5.76 GB · 69 empty tables · ~65M never-approved proposal lines · 40 InProcess GoAheads ($415K) · ~30% contact dupes · 3 defects.** Method: native-tracker dependency check + single-pass `.cfm` grep + quarantine→soak→drop, rehearse on play (self-reverts nightly). **NEXT: Phase 1 = quarantine the 84 dead procs on play + verify-build.**
> ⏸️ **PAUSED by the Skipper 2026-08-02 — "revisit later." Nothing has been executed.** Resume order when he says go: (1) dynamic-SQL sweep + **build the page-crawler smoke test** (the one gap — no automated tests exist across the app, and the crawler is a prerequisite before prod); (2) Phase-1 rehearsal = quarantine the 84 dead procs on play + verify; (3) build the dead-`.cfm` list; (4) data tracks — the proposal-line archive needs the Skipper's age cutoff, the 3 defects ship via [[dev-handoff-contract]]. Artifacts (own repo, pushed): `arbor-stack/cleanup/manifests/{dead-tables-manifest,dead-procs-tight,true-dead-procs-84,referenced-in-cfm-6}.txt` · `cleanup/sql/dep-scan.sql` · `deep-audit/psrun.sh`.

## ✅ WRITE-VERIFICATION PASS — stages 1–6 proved with REAL writes (2026-08-01, Skipper-directed)
*"Go back to the findings and test each with a real write."* Method: **play only** (prod write blocked), every write wrapped `BEGIN TRAN … EXEC/INSERT … SELECT-to-observe … ROLLBACK` so procs execute and triggers fire but **nothing persists**; every proc/trigger body read before executing ([[db-repair-contract]] rule 1); tables re-counted after each run → **zero residue** (only identity counters tick, and play's nightly refresh wipes those). What it changed — a read tells you what the code *says*, a rolled-back write tells you what the system *does*:
- ⭐ **Creation is a CASCADE, invisible to map-reading** — `GenerateCompany` INSERT → `CompaniesPostInsert` trigger → `UpdateNewCompany` → `GenerateCustomerNumber` (adds a `CustomerNumbers` row) **+** `UpdateCompanyGateway` (sets a deep-link URL with the new ID). Only surfaced by executing it.
- ❌ **CORRECTED (Stage 1):** `GenerateCompany`'s `@ZCompanyID` param is **declared but IGNORED** — passed 999999, the proc still inserted a blank shell. The map-only pass had assumed it drove creation.
- ✅ **CONFIRMED (Stage 2):** the blank-overwrite data-loss trap is real — a blank field on save wiped a real email (rolled back). ❌ **REFUTED:** FullName-drift — it is auto-maintained.
- 🔎 **REFINED (Stage 3):** the base `GenerateProposal` spawns **ZERO** line-rows and is born unapproved (→ the 97.91% pattern); the 66M lines come from **inventory-driven variant procs** — it is a two-phase create.
- ✅ **(Stage 4):** `GenerateGoAhead` creates a Pending GoAhead **and cascades 40 GoAheadLines** (contrast: the proposal base is header-only).
- 🐛 **NEW BUG FOUND (Stage 4/5):** `GenerateWorkOrders` inserts 11 monthly WOs + 287 crew sheets from `CalendarTemplates`, then **throws error 16916 on every run** — a misnamed cursor (`CLOSE WorkOrders` vs `WorkOrderCursor`) — *after* the inserts complete, leaking the cursor.
- ✅ **(Stage 5):** the `WorkDate` corruption write-demonstrated — an injected bad `WorkDate` mis-bins production to the wrong month while `CalDate` stays correct; caught a live-corrupted sheet in the wild (541600). ⚠️ The create cascade was deliberately **NOT** fired at scale: `GenerateCrewSheetsFromWOCrewCalendar` ran **72s on a ONE-TREE project** — the cost is the sub-proc chain, not inventory size. On a shared box, say so rather than firing it.
- ✅ **(Stage 6):** `GenerateInvoiceMaster` creates a Pending master; the `IsProForma`/`IsCredit` NULL trap write-demonstrated (no default constraint → a filter silently drops NULL-flag invoices). **NEW:** `InvoiceMasters.CompanyID` has **no FK** (the child `Invoices` does).
- ✅ FK enforcement verified at every stage (bad parent values rejected by constraint). ✅ New contacts default **Active**, new locations **Pending** → the "72% NULL-status contacts" is **legacy** data, not what the create path produces today.
- ▶️ **OPEN:** the Skipper may want the same write-verification run against the remaining paths (edit/inline-UPDATE handlers) — creates are done.

## 🗂️ STAGE TRACKER (the spine — one row per workflow stage, update as we go)
Each stage gets its own note `wiki/projects/trimit-audit-NN-<stage>.md` (template: [[deep-audit-stage-template]]).

| # | Stage | Status | Note | Key result so far |
|---|-------|--------|------|-------------------|
| 1 | Customer / Account creation | ✅ mapped + **write-verified** | [[trimit-audit-01-customer-creation]] | customer=`Company`; create path `Profile.Company.Focus.cfm`→`Synch.CodeGenerateCompany.cfm`→proc `GenerateCompany`; `Companies`=133 cols/3,203 rows, 31 FK children |
| 2 | Contact / Location setup | ✅ mapped + **write-verified** | [[trimit-audit-02-contact-location]] | Contacts=34 cols/12,827 rows (~30% dupes confirmed); Locations=123 cols/30,708 rows (40 map-render cols, 40 FK children); **2 write patterns: proc create vs inline-UPDATE edit**; blank-overwrite data-loss trap |
| 3 | Lead → Proposal / Bid | ✅ mapped + **write-verified** | [[trimit-audit-03-lead-proposal-bid]] | Proposals=**221 cols**/267,128 rows; **153 GenerateProposal\* procs** (polymorphic, 1/bid-type); **97.91% never approved**; **66.3M line-rows** (ProposalLines+PageLines) = the marquee cleanup |
| 4 | Go-Ahead / activation → Work Order | ✅ mapped + **write-verified** | [[trimit-audit-04-goahead-workorder]] | chain `GenerateGoAhead(@ZProposalID)`→`GenerateWorkOrders(@ZLocationID,@ZYear)`; GoAheads=54 cols/94,291 rows; WorkOrders=**168 cols**/52,680 rows, 21 parent FKs; **40 InProcess=$415,590** half-finished activations |
| 5 | Scheduling → Crew Sheets → Production | ✅ mapped + **write-verified** | [[trimit-audit-05-scheduling-crewsheets-production]] | scheduling=`GenerateCrewSheetsFromWOCrewCalendar(@ZWorkOrderID,@ZCrewCalendarID)`; CrewSheets=108 cols/158k (2 FKs to Calendars); InventoryAssignments=1.3M; **63% H1 WorkDate≠CalDate**; **~7M-row dead backup domain** = biggest cleanup |
| 6 | Invoicing / AR | ✅ mapped + **write-verified** | [[trimit-audit-06-invoicing-ar]] | hierarchy InvoiceMaster(2,327)→Invoices(50,314)→InvoiceLines(1.42M); **no cash layer** (`Payments`/`Applied`=0 → QuickBooks); `InvoiceLine` singular=QB staging; IsProForma/IsCredit 99.5% NULL (use SUM(Total)); AR open **$18.5M** |
| 7 | Reporting / dashboards | ✅ done (consolidation) | [[trimit-audit-07-reporting-dashboards]] | dashboard↔stage↔trap crosswalk; ~28-table rollup drift surface; bugs = one class (stale-rollup reads). **Contains the FULL AUDIT SUMMARY.** |

## 🧭 TRIM IT architecture pattern (discovered Stage 1 — reuse every stage)
- **`Profile.<Entity>.Focus.cfm`** = the edit/detail UI form.
- **`Synch.Code<ProcName>.cfm` / `Code<ProcName>.cfm`** = a thin page that runs ONE stored proc via `<CFSTOREDPROC>` then reloads the parent frame — the **CREATE** path.
- ⚠️ **BUT edit/save is a SECOND pattern** (found Stage 2): `Synch.<Entity>.Update.cfm` does an **inline `UPDATE dbo.<Table> SET …`** right in the .cfm (Dreamweaver `MM_UpdateRecord` forms), NOT a proc. **Audit both paths per entity — create-proc AND inline-update — they can disagree.**
- 🐛 **Blank-overwrite trap** in those MM_UpdateRecord edit forms: a blank field saves as `''`/`NULL`, wiping stored data. Confirmed in Contacts + Locations edit handlers.
- **Business logic lives in the ~3,600 stored procs, not the `.cfm` files** — but writes split between procs (create) and inline SQL (edit). No inline `INSERT INTO Companies` exists in any of the 8,645 `.cfm`.
- ⚠️ `$dev`/`$dev2`/`.Dev` twins = dead copies. ⚠️ but a `_MP_Test`/`$2` file can be wired into a LIVE page — check inbound refs before flagging drop (repair-contract).

## 🗺️ Where the app lives (verified 2026-08-01 — burn this in)
- **Real TRIM IT app = `D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\` on the play box (100.86.97.46) — 8,645 `.cfm`.**
- ⚠️ NOT `C:\ColdFusion2023\cfusion\wwwroot\GSTS\` (that's our 11-file dashboard drop). Vendor SaaS lives at `D:\home\arbortools.net\wwwroot\`. Color folders (Steel/Tan/Water…) are NOT full app copies.
- **Local audit working copies** of pulled files: `arbor-stack/deep-audit/stage-NN-*/src/`.

## 🎯 The mission (Skipper, 2026-08-01 06:52)
We've done a **high-level** pass on the TRIM IT database + ColdFusion and recorded a lot of knowledge.
Now go **DEEP**: really understand what everything does, **what is used vs. not, what works vs. broken**,
and **start cleaning things up.** Attack it **in line with our actual business workflow** — not table-by-
table alphabetically, but the way the company actually uses the system, stage by stage.

- **Start at the beginning of the workflow = CUSTOMER CREATION.** First audit target.
- **Pull in everything we've already learned** and add to it (don't re-derive — extend).
- **We may do REAL cleanup on the database as testing** — a live proving ground for what the full
  going-forward cleanup will look like. (Governed by the cleanup guardrails below.)

## 🧭 Method — how we'll attack it (workflow-first)
Walk the business lifecycle in order, auditing each stage as a unit (code + data + DB objects together):

1. **Customer / Account creation** ← START HERE (stage 1)
2. Contact / Company / Location setup
3. Lead → Proposal / Bid
4. Go-Ahead / activation → Work Order
5. Scheduling → Crew Sheets → Production
6. Invoicing / AR
7. Reporting / dashboards (the layer we've mostly touched)

**For each stage, produce a stage-audit note answering:**
- **Entry point(s):** which `.cfm` page(s) + which proc(s)/query(ies) drive it.
- **Data model:** the tables/views/columns it reads + writes (the real ones, verified live).
- **Used vs. dead:** which objects are actually exercised vs. orphaned/legacy.
- **Works vs. broken:** defects, dead code paths, data-integrity gaps (backup-first before any fix).
- **Cleanup candidates:** stale rows, dupes, dead columns/tables — flagged, not dropped, until rehearsed.
- **Knowledge delta:** what we already had (link it) + what's NEW this pass.

Suggested template lives at `wiki/reference/deep-audit-stage-template.md` (created with this kickoff).

## 📚 What we ALREADY know (pull from these first — don't re-derive)
- **`~/trimit-knowledge/`** — **708 files.** The recorded corpus: `procedures/` (how subsystems work),
  `query-playbook/` (validated SQL recipes + the safe-query rules), `references/`. Start at
  `~/trimit-knowledge/index/HOME.md` and `query-playbook/00-how-to-query-safely.md`.
- **[[trimit-db-cleanup]]** — the parked structural-cleanup project. **A real quantified audit was already
  done 2026-07-20** (4-agent crew): proposals = 97.9% never-approved (66M derived rows in
  `ProposalLines`/`ProposalPageLines`), contacts ~30% dupes, 5.63 GB in 274 dead tables. Audit docs in
  `arbor-stack/Arbor AI/Trim IT Repairs/` (`DB_CLEANUP_AUDIT_2026-07-20.md`, `dead_candidates_tiered.csv`,
  drop-plan phase 2). **This deep audit SUPERSEDES/absorbs that** — reuse its findings, go finer + workflow-first.
- **[[trimit-db-gotchas]]** · **[[trimit-server-topology]]** · **[[trimit-stack-and-tph]]** — DB traps, box
  topology, the CF/SQL stack.
- **[[workbench-play-db]]** · **[[arbor-core-db-importers]]** — the `Workbench` override DB + the
  "extract only what we need" migration (the cleanup-by-construction path).
- **[[coldfusion-2025-upgrade-case]]** + `wiki/reference/mcpcfc-coldfusion-mcp-server.md` — CF platform context.

## 🖥️ Access + tooling (ready to use tomorrow)
- **Read the play DB:** `arbor-stack/production-dashboard/gsql.sh` — SSHes into the Windows play box
  (`Administrator@100.86.97.46` over Tailscale) and runs `SQLCMD` there against `GSTS`. **Read-only.**
  Rules: `wiki/facts/gstsreadonly-prod-dsn.md` + `query-playbook/00-how-to-query-safely.md` (NOLOCK,
  `SET NOCOUNT ON`, cap rows, three-part names, `flow.*` vs `dbo.*`).
- **Live catalog lookup** for the ~800 tables / ~3,628 procs the vault doesn't cover yet (query
  `sys.tables`/`sys.columns`/`sys.sql_modules` — recipe in `00-how-to-query-safely.md`).
- **ColdFusion source:** `~/arbor-stack/` has 131 `.cfm` (mostly dashboards/repairs we've built). ⚠️ **The
  CORE create/transaction forms are NOT local** — they live on the **play webroot** and must be pulled from
  the play box (SSH/SMB) when we audit each stage. Stage 1 to-do: pull the real customer-create `.cfm`.
- **Codex heavy-lifting** (isolated, gpt-5.6-sol/high) is available for grinding through code if useful.

## ⚠️ Environment realities (these shape the cleanup plan)
- **Play `GSTS` DB is DROP+RESTORE'd nightly from prod** ([[play-gsts-is-ephemeral]]) — so any DB
  structural cleanup / soak **cannot live on play `GSTS`**; it gets wiped. A **differently-named frozen
  copy survives** (like `Workbench`). Cleanup rehearsal needs a `GSTS_cleanup` snapshot. Web/UI files on
  play persist; the DB does not.
  - ⚠️ **CONFIRMED 2026-08-01: the refresh reverts PROCEDURES too, not just data.** `GSTS`'s `create_date`
    rolls to that morning (08:47) while `Workbench` (06-25) and `GSTSBACKUP` (05-18) persist; the 3,628
    procs still carry prod authoring dates. A restore replaces the **whole database including all code** —
    so quarantining or dropping a proc on play **self-reverts overnight**, exactly like a deleted row.
    **Any soak that must survive more than one night needs the frozen `GSTS_cleanup` copy.**
- **Prod DB write access is BLOCKED** ([[prod-db-access-blocked]]) — we can build + rehearse cleanup now,
  but EXECUTING on prod needs a grant (parked Jordan/AWS ask).
- **Play is ~24h behind prod** (nightly refresh) — numbers are "as of last night."

## 🛡️ Guardrails for the "real cleanup as testing" part
Any write to live TRIM IT data is governed by our contracts — this is not a free-for-all:
- **Backup-first** ([[repair-contract]] / [[db-repair-contract]]): snapshot before any change, reversible
  `_graveyard` quarantine → soak → drop; never a blind mass-delete.
- **Reversible + reviewable batches**, logged to the ship-log. Rehearse on a frozen copy, not live prod.
- **Only trustworthy data to the team** ([[only-trustworthy-data]]); flag anything wonky.
- **Name-the-command rule:** every figure reported comes from a query I ran THIS session.

## ▶️ First-session targets (Stage 1 — Customer Creation)
1. **Find the real entry point:** pull the customer/account **create** `.cfm` from the play webroot (local
   arbor-stack only has the *dashboard/export* customer pages: `Dashboard-CustomerLeads.cfm`,
   `Export-CustomerList.cfm`, `Executive$Sales$Detail$Customer.cfm` — not the create form).
2. **Map the write path:** what tables/columns a new customer touches (`Customers`, `Contacts`,
   `Companies`, `Locations`, and their FKs) — verified live via `gsql.sh`.
3. **Used vs. dead / works vs. broken** for that stage; reconcile against the 2026-07-20 audit findings
   (dupes in Contacts ~30%, Companies ~6%).
4. **Write `wiki/projects/trimit-audit-01-customer-creation.md`** (stage note) + flag cleanup candidates.
   *(Prior context: the 2026 "customer-verifier" task verified CustomerList 414/414 — a starting data set.)*

## Resume pointer
**As of 2026-08-02:** all 7 stages are mapped, stages 1–6 are write-verified, the dashboard-correctness
check passed, and the cleanup plan is compiled with the 84-proc removal set built — then **⏸️ PAUSED by the
Skipper ("revisit later")**. Nothing has been executed against any database.
**On resume, open this note first, then → [[trimit-cleanup-plan]] and start at its resume order** (dynamic-SQL
sweep + page-crawler smoke test → Phase-1 proc quarantine on play → dead-`.cfm` list → data tracks).

## Superseded / historical
- *(2026-08-01, superseded)* Original resume pointer: *"Setup done 2026-08-01. Tomorrow (2026-08-02): open
  THIS note first, then start Stage 1 (customer creation) using the method above. Nothing has been built or
  changed yet — by design."* — all 7 stages were completed on 2026-08-01; the ▶️ First-session targets
  section above is kept as the record of how Stage 1 was scoped, and is now **done**.
- *(2026-08-01, superseded)* The stage tracker read **"done (map-only)"** for every stage before the
  write-verification pass landed; stages 1–6 are now write-verified (see the section above).
