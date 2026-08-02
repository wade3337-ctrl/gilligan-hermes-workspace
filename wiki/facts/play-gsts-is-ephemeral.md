---
title: Play GSTS is EPHEMERAL — never build multi-day work in it
type: fact
domain: env
tags: [infra, play, database, restore, workbench, build-discipline, gotcha]
links: ["[[play-dev-access]]", "[[prod-backup-chain]]", "[[goodman-rfp-bid]]", "[[trimit-db-gotchas]]", "[[repair-contract]]", "[[trimit-cleanup-plan]]"]
updated: 2026-08-02
---

# 🧨 The `GSTS` database on play is EPHEMERAL — treat every row in it as temporary

The nightly prod→play restore ([[prod-backup-chain]]) **replaces the entire `GSTS` database**. Not just data drift — *whole objects we created disappear*, including projects, locations and inventories.

> **2026-07-25:** the 04:49 restore (of a 7/22 backup) erased **all three Goodman builds** — projects 1105465 (Fullerton pilot), 1105467 (Eastvale, 313 trees), 1105468 (El Monte, 298 trees) and LocationIDs 1285095/96/97, plus Herman's in-flight fixes. `MAX(ProjectID)` was back to 1105464. **Three days of work, gone overnight.** → [[goodman-rfp-bid]]

## What survives vs what doesn't
| Survives the restore | Does NOT survive |
|---|---|
| `Workbench` database (separate DB — SalesGoal, `rgc.*`, DashboardAccess, WorkKanban, all our `*_bak_*` snapshots) | **Anything in `GSTS`** — rows, projects, locations, procs |
| Web files on disk (`.cfm/.css/.js`) | DB-level users/grants (→ regrant crons) |
| `GSTSBACKUP` (create_date 05-18) | **All 3,628 stored PROCEDURES** — see below |
| Anything in flat files / git | App-account rows (e.g. the bot login → self-heal cron) |

## ⚠️ It reverts CODE too, not just data (confirmed 2026-08-01)
The refresh is a full **DROP + RESTORE**, so it replaces the **whole database including every stored procedure** — not merely the rows. Evidence: `GSTS`'s `create_date` rolls to that morning (**2026-08-01 08:47**) while `Workbench` (06-25) and `GSTSBACKUP` (05-18) persist untouched, and the 3,628 procs carry prod authoring dates because they came down with the restore.
- **Consequence for cleanup work:** quarantining, renaming or dropping a proc on play **self-reverts overnight**, exactly like a deleted row. So does any proc *fix* you apply there.
- **Anything that must soak for more than one night needs a frozen, differently-named `GSTS_cleanup` copy** (the `Workbench` pattern) — not play's `GSTS`. → [[trimit-cleanup-plan]]
- Same-night rehearsals are still ideal here: a `BEGIN TRAN … ROLLBACK` write test leaves zero residue, and even identity-counter ticks are wiped by the next refresh.

## ✅ The rules
1. **Treat `GSTS` on play as scratch.** Fine for a same-day experiment; never for anything that must exist tomorrow.
2. **Durable work lives in `Workbench` or in flat files**, with a **scripted, idempotent replay** into `GSTS`. The replay script is the deliverable — not the rows.
3. **Back up before mutating** (standing rule, [[repair-contract]]) — this is what saved the Goodman tree data: the `Workbench.dbo.*_bak_*` snapshots were in a different database and survived.
4. **Re-verify before reporting anything "done" in `GSTS`.** A build verified yesterday may not exist today. Check `msdb.dbo.restorehistory` first.
5. A replay script also **turns a wipe into a 10-minute re-run** and is the same tool needed to scale (e.g. the remaining 26 Goodman properties).

## Why this bit us
The restore was a *known* fact ([[play-dev-access]]: "PLAY nightly refresh = DB-ONLY — procs/data revert"). What was missing was the **consequence for multi-day construction work**: we hand-built three properties directly into `GSTS` over three days. It would have failed at property 12 instead of property 3 — the wipe just surfaced it early.

## Superseded / historical
- *(2026-07-25, superseded)* The "survives vs doesn't" table listed only *"anything in `GSTS` — rows, projects, locations, procs"*. That was right but under-read: the 2026-08-01 confirmation above establishes it applies equally to objects we **remove** and code we **change**, which is what governs the cleanup rehearsal design.
