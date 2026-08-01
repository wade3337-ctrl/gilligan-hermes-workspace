---
title: TRIM IT Deep Audit — DB + ColdFusion, workflow-first
type: project
domain: work
track: 1
status: KICKOFF — set up 2026-08-01 for a fresh chat 2026-08-02. Nothing built yet by design.
tags: [trimit, database, coldfusion, audit, cleanup, workflow, customer-creation, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]", "[[config-clobber-guard]]"]
links: ["[[trimit-db-cleanup]]", "[[trimit-db-gotchas]]", "[[trimit-server-topology]]", "[[trimit-stack-and-tph]]", "[[workbench-play-db]]", "[[arbor-core-db-importers]]", "[[play-gsts-is-ephemeral]]", "[[prod-db-access-blocked]]", "[[coldfusion-2025-upgrade-case]]"]
updated: 2026-08-01
---

# 🔬 TRIM IT Deep Audit — DB + ColdFusion, workflow-first

> **Kickoff note. Set up 2026-08-01 by Gilligan for a FRESH chat starting 2026-08-02. DO NOT BUILD YET —
> tomorrow's session decides scope and does the first real pass.** This note is the runway: mission,
> method, what we already know, guardrails, and the first target (customer creation).

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
Setup done 2026-08-01. **Tomorrow (2026-08-02): open THIS note first, then start Stage 1 (customer
creation) using the method above.** Nothing has been built or changed yet — by design.
