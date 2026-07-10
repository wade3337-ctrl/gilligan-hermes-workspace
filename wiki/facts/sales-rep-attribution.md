---
title: Sales-rep attribution = actual managing rep
type: fact
domain: work
tags: [sales-rep, attribution, metric, dashboards, reassignment-drift, historical]
links: ["[[rc-04-spm]]", "[[steve-diligence-dashboard]]", "[[dashboard-metric-standards]]", "[[workbench-play-db]]"]
updated: 2026-07-10
---

# Sales-rep attribution = actual managing rep

**Sales-rep attribution = the actual managing rep** (`Projects.SalesRepID`), **NOT** Brent's legacy Jason/Scott rollup.

- Dashboards show **Jaime Meza** & **Raudel Gutierrez** as themselves.
- Commercial **total** still reconciles (~0.8%).
- **Apply to all sales panels.**

## ⚠️ HISTORICAL ATTRIBUTION DRIFT — the structural gap (found 2026-07-10, CFO Steve)

**TRIM IT has NO immutable "who originally sold this" field.** When an account/customer is reassigned to a new rep, TRIM IT **overwrites `Proposals.SalesRepID` to the current owner** and keeps **no history** — the `Created`/`ProposalDate` stay, so old bids now show under whoever holds the account *today*, including reps hired *after* the bid. This silently corrupts any historical by-rep report.

**Symptom (Steve's Win/Loss-by-Year):** 2024 showed recent hires (Rebekah, Ethan) who didn't work here then, and **hid the real 2024 producers** (Chris Mello etc.) — because those pages *also* filtered the rep list to the **current active roster** (`IsMeasured=1 AND StatusDefID=188`), dropping departed reps entirely.

**Sources that do / don't recover the original seller** (all verified):
- ❌ `Projects`/`ProjectReps` (empty), `zDelete-InsiderepChanges` audit (sparse, 4 rows), `Proposals.InsideRepID` (= inside/support staff, not seller), creating `UserID` (unresolved), `DailyProposalLogs`/`UserProposalLogs`/`UserWeeks` (0/NULL).
- ⚠️ `zDelete-SalesReport*` **dated snapshots** (2023-10 … 2025-01) = frozen copies of the report; `SalesRep` col = **project ACCOUNT-OWNER, not proposal seller** → would mis-move 35k of Scott Griffiths' own proposals if used blindly. **Only safe to fill AFTER reassignment is independently confirmed.**
- ✅ `RFPs.SalesRepID` + `SaleRepCommissionInvoices.SalesRepID` (commission is paid to who sold it) = the trustworthy **proposal-grain** evidence — but must be a *single* non-current rep (multi-rep = flag, not first-row-wins). Commission CAN drift too (a 2026 row on a 2024 proposal), so don't derive a rep's start date from it.

## ✅ The fix pattern (crew-vetted by [[crew-llms-and-helpers|gpt-5.6-sol]], which blocked a naive derived-boundary version)
1. **Reviewed effective/hire dates** per inheritor rep (HR knowledge from Skipper — NOT derived from drifting artifacts; SalesReps has no hire column) → `Workbench.dbo.RepEffectiveDate`.
2. A proposal attributed to a rep but dated **before that rep's effective date** = reassigned → re-credit to the original seller by precedence **RFP → commission → snapshot(HistoricalProjectOwner) → "Former (reassigned)"**; **flag** multi-rep/no-evidence rather than guess → `Workbench.dbo.ProposalOriginalRep` (per-proposal override map, survives nightly refresh, static/reviewed — NOT auto-regenerated).
3. Report shows **every rep who sold in the window** (drop the current-roster gate; keep only a junk/system-name exclusion) and uses `COALESCE(ov.OrigRepName, currentRep)`.
- **Go-forward cure:** snapshot the writer at proposal creation so reassignment can never erase credit again (arbor-core capability).
- First applied on [[steve-diligence-dashboard]] (Win/Loss, ship #111/#112). The same drift affects **any** historical by-rep surface (RC-01, RC-04, SPM, Invoice Details view=1) — apply there when they go to prod.
