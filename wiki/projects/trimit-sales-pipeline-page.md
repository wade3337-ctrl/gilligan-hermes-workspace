---
type: project
status: active-paused
domain: work
created: 2026-08-04
updated: 2026-08-04
applies:
  - "[[repair-contract]]"
  - "[[only-trustworthy-data]]"
  - "[[rc-02-revenue-performance]]"
tags: [trimit, dashboard, sales, pipeline, municipal, investor]
---

# TRIM IT Sales Pipeline page (Dashboard-PipelineCoverage.cfm)

**One-line:** an investor/board-ready **Sales Pipeline** page on play — new-business bid pipeline, capture rate, municipal contract book, and coverage-to-goal — every figure reconciles to an existing dashboard (no "fourth number").

- **File:** `arbor-stack/production-dashboard/Dashboard-PipelineCoverage.cfm` (NEW, built 2026-08-04).
- **Live (play):** https://play.greatscotttreeservice.com/GSTS/Dashboard-PipelineCoverage.cfm — behind the V1.5 dashboard gate (`dashboard-auth-gate.cfm` / DashboardAccess).
- **Play webroot:** `D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\` (single root for this file — no C:\ shadow). Backups in `...\Jasonsrepairs\`.
- **Status (2026-08-04): PAUSED / pinned.** Municipal panel finished + verified. NOT committed to git, NOT run through `verify-build.sh` yet, one coverage open item.

## The four panels
1. **New-business bid pipeline** — **$9.17M / ~360 open bids**. Def = latest proposal per project, `Proposals.StatusDefID IN (41,106)`, `ProposalSentDate >= DATEADD(month,-6)`, project status `InProcess/Pending` (same as Sales Cockpit "open bid"). Segments by `Companies.MarketID`.
   - Breakdown: **HOA $4.64M (135)** · Commercial $2.00M (47) · **Unassigned $1.49M (105)** · Retail $0.43M · Other $0.32M · Municipal-Cities $0.25M · Municipal-Other $0.05M.
   - Top bids: Action Property Mgmt **$954,575** (proj 1096695 / prop 799879 / LegacyRef 426155 = "Mission Viejo Environmental Assoc 3-Yr Plan"); Keystone Pacific **$895,302** (proj 1100843 / prop 793338, sent 2/9 — **aging**, its 15 other bids are all <$54K); Powerstone **$208,634** (proj 1105432 / prop 801789 / LegacyRef 428061 = "Northpark Square Pine Removals").
   - ⚠️ **Unassigned $1.49M = accounts with `MarketID = NULL`** — mostly property managers (PMP, Mgmt Trust, Greystar, Revolve, Bentley, Prof Community Mgmt) = really **HOA**; a few Commercial/Retail (Macerich, Lucky Strike, Moog, Gothic). **None municipal.** So HOA is understated. Gothic Landscape $241K (sub work).
2. **Capture rate** — FY2026 ≈ **79%** company. Same cohort as `Executive$ClosePercentage` (proposals written in-window, decided statuses, EXCLUDE the ProjectGroupDefID=11 inventory-QC re-bid loop; won = converted to a GoAhead EXISTS, ANY date — NOT ApprovedDate which is NULL ~94%).
3. **Municipal contract book** — see the municipal saga below.
4. **Coverage-to-goal** — invoiced YTD $12.88M / goal $25.30M ([[revenue-goal-close]] authoritative). New-biz pipeline coverage ratio. ⏸️ **OPEN: fold municipal forward ($3.23M) in as a 2nd live coverage source** (no double-count — invoiced is already in actuals). Skipper's call, still pending.

## 🏛️ The municipal saga (the whole point of this note) → see also [[municipal-budgets-po-gated]]
Municipal went through 4 revisions; the final basis and WHY it's right:

- **v1 (WRONG):** headline = `SUM(Contracts.Year01Budget)` = **$10.77M** full annual budget on a to-date page → overstated + double-counts the already-invoiced part vs goal.
- **v2 (option A, invoiced fiscal-YTD):** reused Brent's `CityBudgets.data.cfm` engine → **$4.41M**. Fixed two bugs while building: (a) summing the engine's **`otherSummary`/o\* bucket** inflated it to $7.21M and drove remaining NEGATIVE — that bucket is NON-municipal approved contracts (commercial/HOA), not other cities → use **cities bucket `g*` only** (Brent's "GRAND TOTAL (Cities)"). (b) —
- **The clock bug (found via Nate's report):** Brent's engine scopes each city to its **own fiscal-year window** (many start July 1), but the whole page is **calendar 2026**. So municipal sat on a different clock. Same 11 cities on the calendar clock = **$4.67M**, not $4.41M.
- **v3 FINAL (decisions (i)+B):** municipal on the **page's calendar clock**:
  - **Earned = invoiced CALENDAR-YTD (PGD=11 cities) = $4.67M** (≈ Nate's completed $4.20M; consistent with page's invoiced-vs-goal).
  - **Forward = contract-book remaining = annual book − earned = $3.23M** (annual book $7.90M from Brent's `gB`).
  - Total municipal book **$7.90M** (ties to Brent) vs Nate's **$9.26M** — the ~$1.36M gap = Nate's manual forward exceeds the ENTERED contract book (PO-pending budgets not in TRIM IT).

### Why we did NOT match Nate's "sold" exactly
Nate's `Sales_Report_2026_Completed+Scheduled.xlsx` (his weekly manual report, current sheet `07.29.2026`) shows municipal **Completed YTD $4.20M · Sold $5.06M · Total $9.26M**. His "sold" is a **manual spread/forecast** (repeating $876,082 monthly values), NOT reproducible live — municipal is recurring **call-in** work, and future calls aren't cut as WOs yet, so live WO-based sold (SPM recipe: Active WOs, EndDate this yr) is only **~$1.9M**. So "sold" can't be both live AND tie to Nate. Skipper chose **B = contract-book remaining** as the honest live proxy.

## Reusable recipes captured here
- **Reuse Brent's engine:** set `URL.ZProjectID="all"; URL.ZFY="current"` then `<cfinclude "CityBudgets.data.cfm">`; read `gB` (cities budget), `gI` (invoiced fiscal-YTD), `gRemaining`, `ArrayLen(citySummary)`. **o\*/otherSummary = non-municipal — never add it.**
- **SPM completed/sold by market:** completed = `EstValue` on `sd.Desc1='Complete'` WOs by `DateCompleted` (calendar yr); sold = `EstValue` on `Active` WOs (not completed) by `YEAR(EndDate)`. Markets: `MarketID` 7=Cities, 8/13/15=Muni-Other, 6=HOA, 5/19=Commercial, 10=Retail.
- **TRIM IT view links:** `Profile.Proposal.Detail.cfm?ZProposalID=<id>` (the bid) · `Profile.Project.Detail.cfm?ZProjectID=<id>` (account/project). **Proposal number people see = `Proposals.LegacyRef`**, not the internal `ProposalID`.

## Open items (resume here)
1. **Coverage panel:** add municipal forward $3.23M as 2nd coverage source (Skipper's call).
2. **Unassigned $1.49M:** reclassify NULL `MarketID` accounts (mostly → HOA) OR display-side name-pattern re-bucket. Draft mapping for review first (data change → backup-first).
3. **Commit to git** (arbor-stack is its OWN repo — `gilligan-arborstack`) + run `verify-build.sh` before calling it verified.

🔗 [[rc-02-revenue-performance]] · [[revenue-goal-close]] · [[municipal-budgets-po-gated]] · [[sales-cockpit]] · [[dashboard-auth-gate]]
