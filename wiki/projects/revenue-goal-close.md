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
