---
title: TRIM IT database cleanup (structural + stale data)
type: project
domain: work
track: 1
status: PARKED 2026-07-20 (Skipper) · audited · blocked-on-prod-access
tags: [trimit, database, cleanup, dedup, proposals, dead-tables, audit, sql-server]
applies: ["[[repair-contract]]", "[[db-repair-contract]]"]
links: ["[[trimit-db-gotchas]]", "[[prod-db-access-blocked]]", "[[workbench-play-db]]", "[[arbor-core-db-importers]]"]
updated: 2026-07-20
---

# 🗄️ TRIM IT database cleanup

Replaces the devs' ~1yr/$300k quote with an AI-assisted cleanup. **First real quantified audit done 2026-07-20** (4-agent crew). Docs in `arbor-stack/Arbor AI/Trim IT Repairs/`: `DB_CLEANUP_AUDIT_2026-07-20.md` (the audit) · `DB_CLEANUP_GSTS_CLEANUP_STANDUP_PLAN.md` (rehearsal DB) · `DB_CLEANUP_PLAN_AI.md` + `DB_CLEANUP_DROP_PLAN_PHASE2.md` + `dead_candidates_tiered.csv` (structural, June).

## The audit in one screen (2026-07-20 live)
- **Proposals = the real mess:** 266K, **97.9% never approved**; the 2 biggest DB tables (`ProposalLines` 32.5M + `ProposalPageLines` 33.5M) are **~89–91% dead-proposal rows** — but these are **DERIVED/regenerable** (rollups of `InventoryDetail`), so low-risk to archive.
- **Contacts ~30% dupes** (~3,800). **Companies ~6%** (~180) — cleaner than expected; "multiples of the same company" is mostly legit multi-site orgs (Kaiser/Kindercare).
- **Structural: 5.63 GB** in 274 dead tables (59% in 2: `zUserCalendarsBackup$11062025` + `zDelete-TriggerDebugLog`) + 94 empty + **~3.9 GB logs** (retention, not drop). June `dead_candidates_tiered.csv` still accurate — nothing dropped yet.

## Environment (resolved)
Play is the CODE test-bed but its `GSTS` **DB is DROP+RESTORE'd nightly** (`\GSTS DB RESTORE` 3 AM, `GSTS`-name-only). So DB structural work + soak can't live on play `GSTS`. **Fix: a frozen `GSTS_cleanup` copy survives** (differently-named DB is untouched — like `Workbench`). Feasible on the existing box (no new hardware); disk tight (145 GB DB vs 138 GB free → SIMPLE-recovery/shrunk log, or free stale `GSTSBACKUP`). → [[workbench-play-db]].

## Two tools for two problems
- **Structural junk + logs → clean in place** (reversible `_graveyard` quarantine → soak → drop). Rehearse on `GSTS_cleanup`.
- **Stale data (dead proposals, dupes) → the arbor-core "extract only what we need" migration handles it by construction:** the 66M derived proposal-lines are never carried; companies come via **B2 match-or-create (dedup on import)**. So the new builds are junk-free without a risky mass-delete. → [[arbor-core-db-importers]].

## ⏸️ PARKED 2026-07-20 (Skipper's call) — audit + plans done, resume when he says go.

## Blockers / resume
- **Blocked on prod DB write access** (parked Jordan/AWS ask → [[prod-db-access-blocked]]) to EXECUTE on prod — but all scripts can be **built + rehearsed now** on `GSTS_cleanup` (reads from play, no prod access).
- ▶ **Next decisions (Skipper):** (1) stand up `GSTS_cleanup`? (2) confirm "Inactive" proposals = non-convertible (unlocks the 21M-row win). (3) sequence: structural drops → log retention → dead-proposal archive → dedup.
