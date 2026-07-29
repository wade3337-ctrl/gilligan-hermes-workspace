---
title: Pull our work off PLAY onto our own infra (before the dev-server rebuild)
type: project
domain: work
track: 1
status: 🟡 PLAN — written 2026-07-29, not started. One question owed by the Skipper (see Blocking).
tags: [migration, backup, play, infrastructure, trimit, risk]
applies: ["[[repair-contract]]", "[[config-clobber-guard]]"]
links: ["[[v15-prod-deploy-state]]", "[[bod-commitment-dashboard]]", "[[revenue-goal-close]]", "[[play-box-wedge-signature]]"]
updated: 2026-07-29
---

# Getting our work off play

**Skipper, 2026-07-29:** *"Jordan and Travis are working on setting up a fresh copy of the Dev server so we
have all the current updates available. We will need to pull down all of our work that is being stored on
play and put it on your infra. Let's build a plan for that before we do it."*

## ⛔ Blocking question (one)
**Is PLAY itself being rebuilt/repointed, or only the vendor's DEV box?**
- If only **dev** → play is untouched, this is prudence, and we can do it carefully over a day.
- If **play** is being rebuilt or its DSN repointed → everything below is urgent, because
  **`Workbench` is not in the nightly restore and exists in exactly one place.**

Everything else in this plan is decided; only the clock changes.

## What is actually at risk — measured 2026-07-29, not assumed

### A. Web files — small and well contained
Of 227 files in the play webroot modified since 1 May:
- **68 are byte-identical** to `arbor-stack/production-dashboard/` ✅ already safe
- **8 have DRIFTED** — play differs from the repo. *These are the real file-level risk:*
  `Dashboard-ProductionPerf.Day.cfm` · `Dashboard-RevenuePerformance.cfm` · `Dashboard-SalesCommand.cfm` ·
  `Executive$Sales$Detail$Customer.cfm` · `Executive$Sales$Detail.cfm` · `Executive$Sales$Unattributed.cfm` ·
  `ProductionPerf.data.cfm` · `Profile$Main.HiRes.cfm`
- **143 are vendor base-app files** we never touched — they come back with the fresh build, ignore them
- **~8 are ours but repo-absent**, mostly `.bak` files from June plus `Maint-Customer-Broadcast.cfm`,
  `Profile.Location.Update.New.cfm`, `Profile.Project.Detail.cfm`
- **`ai-kb/`** (11 files incl. `_persona.md`) — Arbor Helper's brain

### B. `Workbench` database — THE crown jewels, single copy, no nightly restore
**35 tables · 9 views · 4 procs**, across `dbo`, `rgc`, `ret`. Populated tables:

| Table | Rows | What it is |
|---|---|---|
| `dbo.ProposalOriginalRep` | 564 | sales-rep attribution overrides |
| `dbo.WorkKanban` (+ `_bak`) | 61 (+58) | our project board |
| `dbo.BODCommitmentTargets` | 43 | board-commitment target ramp |
| `dbo.DashboardAccess` | 24 | **who can see the V1.5 dashboards** |
| `rgc.MarketMap` | 21 | Revenue Goal Close market mapping |
| `dbo.BODMetricSnapshot` | 16 | daily capture — **irreplaceable, it is a time series** |
| `dbo.BidQueue` | 16 | bid on-ramp |
| `dbo.SalesGoal` | 12 | FY2026 monthly plan = $25,300,976 |
| `dbo.GoodmanSpeciesCrosswalk` | 59 | Goodman RFP species mapping |
| `dbo.BODCfoRevenue` | 2 | the Controller's stored figures |
| `rgc.Plan` / `rgc.CoverageScenario` | 1 / 1 | approved annual goal + scenario |
| `dbo.RepEffectiveDate` · `RebidStatus` · `SpmBookSnapshot` · `AssistantNote` · `V15Users` · `V15Sessions` | 1–3 | small config |
| 6 × `*_bak_*_20260724` | 197–313 | Goodman GPS import backups |

⚠️ **`BODMetricSnapshot` cannot be reconstructed.** Every other table is either config we could retype or
derivable from GSTS. That one is an accumulating daily series — lose it and the tile-3
"why did booked share move" decomposition restarts from zero.

### C. Objects inside the `GSTS` database — already ephemeral, do not migrate
`dbo.GoalSettings` shows a create date of **2026-07-29** and holds **0 rows**: the nightly restore wipes
it and a page's create-if-missing block rebuilds it empty every day. Same story for `dbo.DashboardPrefs`.
**Nothing here is worth carrying** — but it does mean any feature depending on GSTS-side custom tables is
silently resetting nightly. Worth a separate look.

### D. Not at risk
Ollama and the Arbor Helper model run on **our** box (`100.82.161.7`), not play. The workspace wiki and
`arbor-stack` are already in git and pushed.

## The plan

### Phase 0 — decide (10 min, needs the Skipper)
Answer the blocking question. If play is being touched, skip straight to Phase 1 and do it today.

### Phase 1 — CAPTURE (~1 hour, read-only, zero risk to play)
1. **Drifted files first** — pull the 8 into `arbor-stack`, diff each, commit. These are pure loss otherwise.
2. **Repo-absent files** — pull the ~8 ours-only files + all of `ai-kb/`.
3. **Whole-webroot snapshot** — tar the entire GSTS webroot to `arbor-stack/snapshots/play-webroot-<date>/`
   so that even a file nobody remembers is recoverable. Cheap insurance.
4. **`Workbench` full script-out** — schema **and** data, per object, into
   `arbor-stack/db/workbench/` as re-runnable SQL: tables, then views, then procs (dependency order).
   Plus a native `.bak` via `BACKUP DATABASE` for a guaranteed-fidelity restore.
5. **Supporting dirs** — `D:\GSTS\Jasonsrepairs\` (our backup history) and `D:\GSTS-Deploy\`.

### Phase 2 — PROVE THE CAPTURE (~30 min) ← the step people skip
A backup nobody restored is a hope, not a backup.
- Restore the `Workbench` `.bak` into a **scratch database on our own box** and diff row counts
  table-by-table against the numbers in the table above.
- Re-run the scripted SQL into a second empty scratch DB and confirm it produces the same objects — this
  proves the *scripted* path works, not just the binary one.
- Verify `rgc.usp_DashboardGet` executes in the restored copy (it is the one with real logic in it).

### Phase 3 — REBUILD CAPABILITY (~2 hours) — the actual deliverable
Not a pile of files: a **`rebuild-on-fresh-box.sh`** that takes a clean TRIM IT server and puts our
layer back — create `Workbench`, run the scripted objects, seed config, copy the web files, then run
**`verify-build.sh`** and require 0 FAIL. If that script works, the play box stops being a single point
of failure permanently, and the same script is how we'd ever go to prod.

### Phase 4 — CUTOVER (when Jordan/Travis are ready)
Point our tooling at the new box (`gsql.sh`, `view.sh`, `verify-build.sh` all carry the host in one
place), re-run `verify-build.sh`, confirm 20/20, then update `wiki/facts/` with the new addresses.

## Standing risks to respect
- **Backup-first still applies** ([[repair-contract]]) — Phase 1 is read-only, but Phase 3/4 writes.
- **Play has wedged before with no warning** ([[play-box-wedge-signature]], 5.5 h outage, cause never
  found). Another reason not to leave the only copy of anything there.
- Do the capture **before** anyone starts changing the environment, not during.
