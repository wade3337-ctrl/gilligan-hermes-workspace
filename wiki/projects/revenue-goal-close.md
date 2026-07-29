---
title: Revenue Goal Close (RGC) Dashboard
type: project
domain: work
track: 1
status: active
tags: [dashboard, revenue, goal, executive, pilot, release-candidate]
applies: ["[[gsts-ui-spec]]", "[[dashboard-metric-standards]]", "[[repair-contract]]", "[[two-track-confidentiality]]"]
links: ["[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[sales-cockpit]]", "[[our-work-kanban]]"]
updated: 2026-07-14
---

# Revenue Goal Close (RGC) Dashboard

**One-liner:** Executive "are we going to close the annual revenue goal?" board. Counts every dollar **once** — Produced (crew-sheeted) + Future Scheduled (booked WOs) = **Hard Coverage**; goal − coverage = **Hard Gap**. Approved/Pending pipeline shown *outside* coverage. Market split + count-once bridge + self-reconciliation controls, all live from TRIM IT.
**Status:** 🟢 **Phase 1 built, crew-reviewed (Hermes+Judge → GO), accepted for the Jason-only pilot on play.** ⏸️ **PINNED 2026-07-14** — pilot-only; prod-deploy timing TBD (Skipper: "deploy RGC later").
**📁 Location:** `production-dashboard/` — `Dashboard-RevenueGoalClose.cfm` (shell) · `RevenueGoalClose.{shared,data,drill,export}.cfm` · SQL engine `revenue-goal-close/sql/*` (`Workbench.rgc.*`)
**▶️ Resume:** `arbor-stack/revenue-goal-close/CHANGELOG.md` + `evidence/phase0-contract.md` + `contracts/endpoint-contract.md`

## Architecture
- **Phase 1A — SQL engine** (in `Workbench` side-DB so it survives the nightly GSTS refresh): 9 config tables (`rgc.[Plan]`, PlanPeriod, PlanBucketGoal, CoverageScenario, MarketMap, …), views (`vCalendarAuthority` = dollar authority, `vCrewAllocationDetail`, `vCurrentYearGoAheadCandidate`), and read-only procs `usp_DashboardGet` / `usp_DrillGet` / `usp_FilterOptionsGet`. Count-once ledger; Hard Coverage = Produced + Future Scheduled ONLY.
- **Phase 1B — CFM layer:** `shared.cfm` (auth + Jason-only pilot gate) → `data.cfm` (summary JSON) · `drill.cfm` (drill JSON, reconciles to the tile) · `export.cfm` (CSV: `view=summary` + per-drill) · `Dashboard-RevenueGoalClose.cfm` (the shell, fetches those client-side). Jason-gated pilot link on `Dashboard-V15Home.cfm` Executive node.

## Applies / uses
- [[gsts-ui-spec]] — **restyled to v1.2** (was a hand-rolled dark theme; Skipper: "doesn't match our style"): shared `Art/gsts-app.css` light theme, app-bar, white KPI tiles, **Pro Tips** (`rgc.*` keys), **required Welcome modal**, §2B KPI drill-down with `Profile.{Project,Proposal}.Detail` source links.
- [[repair-contract]] — backup-first, render-verify the *served* output, log to ship-log.
- [[dashboard-metric-standards]] — TPH/metric bands, welcome, pro-tips.

## Non-negotiables baked in
- **Goal is adjustable for years** (Skipper hard requirement): the annual goal lives in `SalesGoal`/`rgc.[Plan]`, NOT code — change one row next year and the whole board follows. No `$24M`/`2026` literal anywhere in the CFM.
- **Fail-closed** before the pilot gate: no plan → 409, goal not reconciled → 422, bad param → 400, out-of-window as-of → 400, unknown scenario → 400 INVALID_ENUM. Non-pilot/garbage/non-integer cookie → 403/401; shell shows an HTML denial (not raw JSON).
- **Self-reconciliation controls** must all PASS; drills reconcile to their tile to the cent.

## State & flags
- ✅ **Crew review (2026-07-14):** Hermes (adversarial) PASS-WITH-CONDITIONS → all findings fixed; Judge (acceptance) **GO**. Key fix: proc `THROW`s land in `cfcatch.detail`/`.queryError`, not `.message` → error remap now searches the full text. → [[LESSONS]] cfstoredproc entry.
- ⏸️ **Pinned:** pilot-only on play (Jason, ZUserID 9). **Open decision:** when RGC folds into the V1.5 dashboards prod deploy bundle (with RC-02/03/04/06).
- Default as-of = data-through (live); the June-30 fixture ($produced etc.) appears only with `?asOf=2026-06-30`.

## Related
- [[rc-02-revenue-performance]] — revenue pace vs goal + TPH (RGC is the goal-close companion).
- [[rc-03-city-budgets]] · [[sales-cockpit]] — sibling V1.5 dashboards.
- [[our-work-kanban]] — keep the board current.

## 2026-07-15 — Approved&Unscheduled leak FIXED (crew GO)
- **Bug (Skipper):** the pipeline bucket contained in-progress/completed work — filter only excluded *future* active WOs, not already-started/produced ones. Live: all 132 items ($1,612,544.86) had WOs; 61 ($1.09M) already started + crew-sheeted.
- **Fix (Skipper-approved def):** pipeline = approved work not yet scheduled or started. `IsScheduledOrWorked` flag on `rgc.vCurrentYearGoAheadCandidate` (any dated WO OR any crew sheet; **hardened** to ignore dead statuses 47 Inactive/315 Revised); all 3 pipeline buckets filter `=0`. Deployed to Workbench (play).
- **Verified:** approvedUnscheduled **$1,612,544.86 → $520,080.29**; Produced/FutureScheduled/HardCoverage UNCHANGED; all 4 reconcile controls PASS; served endpoint + shell clean.
- **Crew:** GLM adversarial NO-GO (over-exclusion) → proved non-material in data + hardened → Gemini GO → **GLM judge (JUDGE_DB=Workbench) independently DB-verified → VERDICT PASS**. RGC 'needs work' item CLOSED; ready to rejoin a future deploy. Detail: `revenue-goal-close/CHANGELOG.md`.

## ⛔ LINK PULLED 2026-07-29 — "it doesnt work"
The Skipper had the **Revenue Goal Close link removed from the V1.5 landing page** (Executive node):
*"remove revenue goal because it doesnt work"*. `showRGC` is now hard `false` in `Dashboard-V15Home.cfm`
with a comment; the previous condition was `zuid EQ 9`.

**The page itself is untouched** — `Dashboard-RevenueGoalClose.cfm` still exists and is reachable by
direct URL. Only the entry point is gone. **Do not re-add the link until he says so.**

### ✅ DIAGNOSED same day — it is NOT a code bug, it is goal-governance drift
Symptom: every tile renders as an em-dash. `RevenueGoalClose.data.cfm` returns **HTTP 422
`RECONCILIATION_FAILED`**; the underlying proc `Workbench.rgc.usp_DashboardGet` throws error **50022 —
*"RGC: SalesGoal does not reconcile to the approved annual goal."***

**The mismatch:**
- `Workbench.rgc.Plan.ApprovedAnnualGoal` = **$24,000,000** — approved by jwade **2026-07-13**
- `Workbench.dbo.SalesGoal` FY2026, 12 monthly rows, now sums to **$25,300,976**

The team goal was re-set upward *after* the RGC plan was approved; `SalesGoal` was updated and the plan row
never was. **The page is behaving correctly — it is fail-closed by design and refused to show numbers it
could not stand behind.** That guard did its job.

**Fix proven in a rolled-back transaction:** setting `ApprovedAnnualGoal` to match makes the proc succeed
and **all four self-reconciliation controls PASS** (GOAL_RECONCILE, MARKET_PRODUCED_RECONCILE,
MARKET_SCHEDULED_RECONCILE, COUNT_ONCE_HARDCOVERAGE). Output then reads: produced **$13.34M**, future
scheduled **$2.75M**, hard coverage **$16.09M**, hard gap **$9.21M**.

▶️ **BLOCKED ON A DECISION, not on code.** Which figure is the approved annual goal — **$25,300,976**
(what `SalesGoal` currently sums to), **$25.1M** (the team goal), or another? ⚠️ If it is $25.1M then the
**monthly `SalesGoal` rows must be re-based too**, because the guard compares the plan figure to their
*sum*. Three goals remain in circulation → see [[path-to-25m-2026]]. Changing an `Approved` plan row is a
governance act, so it waits for him. Backup of the landing page before the change:
`D:\GSTS\Jasonsrepairs\2026-07-29-Dashboard-V15Home-preRGCremoval.bak`.
