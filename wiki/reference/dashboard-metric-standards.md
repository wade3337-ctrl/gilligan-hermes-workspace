---
title: Dashboard Metric Standards
type: reference
domain: how-we-work
tags: [metrics, dashboard, standard, applies-target, close-rate, tph]
links: ["[[canonical-definition]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
updated: 2026-07-03
---

# Dashboard Metric Standards

**What it is:** The 6 CANONICAL metric definitions every GSTS dashboard, report, and monitor must follow (established 2026-06-19 from the SPM board tuning). Any sales/production build or repair conforms to this doc; cross-refs [[canonical-definition]] (CFO ground truth).
**📁 Source:** `arbor-stack/DASHBOARD-METRIC-STANDARDS.md`

**Used by (must follow):** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]], [[anomaly-monitor-suite]] — **any dashboard/monitor touching these metrics.**

## Key rules
1. **Measured salesperson** = `SalesReps.IsMeasured = 1` AND `StatusDefID = 188` (active) only. Managers excluded via the flag — never hardcode names. (Prod data-fix pending: 4 mis-flagged managers → `IsMeasured=0`.)
2. **Close rate = COHORT, 1-to-1** — of proposals WRITTEN in the window, the share that have SINCE won a GoAhead (each tracked to its own outcome). Can't exceed 100%. By Jobs = won÷written; By Dollars = proposed$ won÷total proposed$. Never cross-cohort (go-aheads-created-in-window).
3. **"Won" = EXISTS a GoAhead** with status ∈ ('Active','Pending','InProcess','Locked','Revised','Closed','Complete'). **`Complete` is mandatory** (omitting it made win% decay with age — a major 2026-06-26 bug). NEVER use `LastGoAheadDate` (unreliable/null). `Locked` proposal = WON. Excluded from won: `Expired`, `Inactive`, `Lost`, `Archived`.
   - **3b. DEDUP:** exclude superseded `Revised` (StatusDefID 334) proposals from BOTH numerator and denominator (a revision spawns a new row + flips the old to Revised, double-counting + scoring a loss).
4. **Aged = ASSUMED LOST at 180 days.** Written = Won + Lost + Open. Lost = status `Lost` (StatusDefID 141 for proposals) OR open 180+ days with no go-ahead. Open = not won, not Lost, sent within 180 days. Same threshold as `dbo.ArchiveStaleProposals`.
5. **TPH = CREW-LABOR ONLY** — numerator counts completed work with `CompletedHours > 0` only. Exclude zero-crew-hour work (treatments/subcontracted/material-only — it inflates the ratio). Show **Treatments** (`WorkOrders.Desc1 LIKE '%treatment%'`) in their own tile ($ + count), not folded into TPH. "Jobs under target" also requires `CompletedHours > 0`.
6. **Municipal vs Commercial = ProjectGroupDef 11.** Municipal = `EXISTS (ProjectGroups WHERE ProjectGroupDefID = 11)`; Commercial = NOT EXISTS. List work as Municipal + Commercial + Both.

**Note:** Scheduled-revenue date basis (per-calendar-day vs WO-by-end-date vs by-start-date) diverges materially by month; authoritative basis is a PENDING Skipper decision. Any NEW dashboard builds to this doc from the start.
