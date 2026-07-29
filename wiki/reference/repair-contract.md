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

## 🔒 VERIFICATION GATE — standing rule (Skipper, 2026-07-29): applies to every build from here on
Adopted after he personally found **four** defects in work I had already reported as verified, in one
session: RGC rendering all em-dashes, the approved-unscheduled drill listing finished jobs, a headcount
tile reporting 3 people for October, and a claim that Revenue Performance was broken when it was not.
**None were reasoning failures — every one was a scope failure. I verified what I changed and trusted its
neighbours.**

### 1. Run `verify-build.sh` before saying "verified"
`arbor-stack/production-dashboard/verify-build.sh` — exit code is the FAIL count, so it can gate a deploy.
Five groups: **auth** (owner 200 / non-owner 403) · **render** (served output, mode-aware) ·
**reconcile** (every drill total EQUALS its tile) · **assets** (no 404s) · **stale** (no superseded figure
or internal path in the served HTML). Add the page to the `PAGES` manifest as part of building it, not after.
⚠️ **Set `mode` correctly.** `server` = numbers in the HTML · `client` = numbers arrive by JS, so the check
probes the DATA ENDPOINT — *"the page renders" proves nothing for a client page*, which is exactly how the
RGC 422 hid in plain sight · `static` = navigation only.

### 2. Two rules that need no tooling
- **Verify the neighbours, not just the change.** Any page, drill, export or endpoint that shares a query,
  a proc or a number with what I touched gets checked in the same session. A multi-branch proc: **test the
  branches I did not edit** — on `usp_DrillGet` that is what proved the fix belonged in exactly one place.
- **Every figure I report must come from a query I ran THIS SESSION.** Not from a note, not from a prior
  message, not from a wiki page. The $2.31M/month, the $24.0M goal and "about 76 people" were all inherited
  numbers I repeated without re-deriving — and all three were stale or wrong.

### 3. When a check fails, decide if it is REAL before acting
The script's first run flagged two pages. Both were false positives from a heuristic that could not tell a
client-rendered page from a broken one. **The fix was to make the check smarter, not to delete it** — the
naive version was the one that would have caught the em-dash bug. A failing check is a question.
