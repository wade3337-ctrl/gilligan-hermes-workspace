---
title: Revenue Goal Close (RGC) Dashboard
type: project
domain: work
track: 1
status: active
tags: [dashboard, revenue, goal, executive, pilot, release-candidate]
applies: ["[[gsts-ui-spec]]", "[[dashboard-metric-standards]]", "[[repair-contract]]", "[[two-track-confidentiality]]"]
links: ["[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[sales-cockpit]]", "[[our-work-kanban]]", "[[path-to-25m-2026]]", "[[bod-commitment-dashboard]]", "[[v15-landing-page]]"]
updated: 2026-07-29
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
direct URL. Only the entry point went. **↩️ Restored the same day once the cause was found and fixed —
see the bottom of this section.**

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

### ✅ FIXED 2026-07-29 — the Skipper set the approved annual goal to **$25,300,976**
`Workbench.rgc.Plan` PlanID 1: `ApprovedAnnualGoal` **24,000,000 → 25,300,976**, `ApprovedAt` restamped,
`ApprovedBy` = jwade. Prior row saved to
`arbor-stack/backups/play-workbench/rgc-Plan-before-goal-rebase-20260729.txt`.
**⚠️ `Workbench` is NOT in the nightly restore — that backup file is the only copy of the old row.**

**Verified live:** `RevenueGoalClose.data.cfm` now returns **HTTP 200**, `ok: true`, and all four controls
**PASS**. Figures as of 2026-07-28, scenario PROTECTED:
annual goal **$25,300,976** · produced **$13,343,214** · future scheduled **$2,748,430** ·
hard coverage **$16,091,644** · **hard gap $9,209,332** · approved-unscheduled $234,711 ·
pending current-year $10,043,741 · future-year pending excluded $21,354,539.

🔑 **This also settles which goal is authoritative: $25,300,976**, matching the live `dbo.SalesGoal` rows.
That retires the $24.0M figure. The team's $25.1M and the deal dashboard's $25.05M are still adrift →
[[path-to-25m-2026]].

✅ **The landing-page link was RESTORED the same day (2026-07-29)** to the V1.5 Executive tab, once the page
returned real numbers — `showRGC` back to `zuid EQ 9` plus the `<li>` → [[v15-landing-page]]. Backup taken
before the removal: `D:\GSTS\Jasonsrepairs\2026-07-29-Dashboard-V15Home-preRGCremoval.bak`.
*(2026-07-29, superseded: "the link is still pulled pending his say-so" — true only for the ~2 hours between
the pull and the fix.)*

## 🐛 FIXED 2026-07-29 — APPROVED drill did not match its own tile
The *Approved · unscheduled* drill listed go-aheads that were already scheduled or finished (**GA 214331,
Newport Beach: 29 completed crew sheets, $78,118 produced**). `rgc.usp_DrillGet`'s APPROVED branch omitted
**`IsScheduledOrWorked=0`**; `usp_DashboardGet` applies it, so **the tile was right and the drill was wrong**
— 82 rows / $713,281.37 vs the tile's 21 / $234,711.16.
Added the predicate; drill now equals the tile exactly and the surviving 21 have zero crew sheets.
The other three drill types already reconciled to the cent and were left untouched.
Backup: `arbor-stack/backups/play-workbench/usp_DrillGet-before-approved-fix-20260729.sql`.
**Hard coverage was never affected** — that stage carries `inHardCoverage=0`.
