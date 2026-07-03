---
title: Repair Contract
type: reference
domain: how-we-work
tags: [contract, repair, workflow, backup, blast-radius]
links: ["[[db-repair-contract]]", "[[deploy-playbook]]", "[[dev-handoff-contract]]"]
updated: 2026-07-03
---

# Repair Contract

**What it is:** The contract for any fix or change to a GSTS/TRIM IT page, query, proc, or data — root-cause it, map the blast radius, propagate to siblings, back up first, verify the served output, and log it. The base workflow every dashboard repair follows.
**📁 Source:** `contracts/repair-contract.md`

**Used by:** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]], [[anomaly-monitor-suite]], [[completed-vs-sold]] — **any TRIM IT repair.**

## Key rules
- **UI vs DB (decide first):** UI = page's query/logic wrong, data fine → we fix ourselves (`.cfm/.css/.js`), persists on play. DB = rows/proc/schema wrong (revert on nightly refresh) → build+test on play, devs deploy to prod (see [[db-repair-contract]]).
- **1. Root-cause, not bandaid** — trace symptom → originating data/logic/schema; fix the cause, not another workaround layer.
- **2. Map the blast radius** — triggers (`sys.triggers`), procs/views (`sys.sql_modules`), other pages reading the same data. **🔁 PROPAGATE THE FIX:** when you fix a bug, repair the same fault in EVERY page that links to/from or shares the query/pattern — in the same session (grep the web root + walk in/out links). A fix isn't done until its siblings are clean.
- **3. Backup-first → `\GSTS\Jasonsrepairs\` on PLAY** (timestamped `.bak` of every touched `.cfm`/proc/rows). Never overwrite/delete originals. **Jasonsrepairs is PLAY-ONLY — never tell devs to use it on prod.**
- **4. Build + verify on play** — render-verify the SERVED output (not just the file on disk). Check the dual-webroot shadow copy (`C:\ColdFusion2023\…` can override `D:\…`).
- **5. Log it** — row in `gsts-ship-log.md` + `ship-log/YYYY-MM-DD-slug.md` detail (with actual code mods) + update `repairRows` on `Reference-RepairsAndScheme.cfm` and redeploy. NEW page built → also add to `buildRows` (Pages Built).
- **Acceptance:** renders clean (0 CF errors) · reconciled to source-of-truth · blast-radius checked · same fault fixed in every sibling · backed up · logged + live Reference page current.
