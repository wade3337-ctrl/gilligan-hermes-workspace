---
title: Contract Dashboard Fix (Long Beach FY26/27)
type: project
domain: work
track: 1
status: shipped
tags: [contract-dashboard, long-beach, municipal, db-repair, company-periods, runbook]
applies: ["[[db-repair-contract]]"]
links: ["[[rc-03-city-budgets]]", "[[budget-report-municipal]]"]
updated: 2026-07-03
---

# Contract Dashboard Fix (Long Beach FY26/27)

**One-liner:** Fix the Contract Dashboard's bad `CompanyPeriods` / contract-period data for companies with overlapping fiscal calendars (Long Beach FY26/27, Anaheim East/West) — repair the generation procs + relink, so per-city budget periods stop merging/duplicating.
**Status:** 🟢 shipped — read-only impact analysis complete, production runbook ready; **ready to deploy** (RC-03 Bucket C waits on it).
**📁 Location:** `arbor-stack/contract-dashboard-fix/`
**▶️ Resume:** `arbor-stack/contract-dashboard-fix/impact-analysis-2026-06-12.md` (+ `Production-Deployment-Runbook.html`)

## Applies / uses
- [[db-repair-contract]] — analysis was strictly read-only (no data-changing SQL, one findings file); every write target must preview at `@Commit=0` with backups/rollback before `@Commit=1`.
- Changed procs: `dbo.GenerateContractPeriod`, `dbo.GenerateCompanyPeriods$YearID`. Fix = attach the generated contract period to the `CompanyPeriodID` whose `CompanyYearID` matches — kills `CompanyID + PeriodID` ambiguity.

## State & flags
- ⚠️ **Must land on PRODUCTION/source, not just play** — the nightly prod→play refresh (~midnight) reverts play-only repairs.
- ⚠️ **SQL-side gaps still open** (need read-only prod SQL access before commit): proc-caller `CompanyYearID` derivation, **SQL Agent jobs** that could regenerate bad rows, `CompanyPeriods` index/constraint state (must allow duplicate `CompanyID+PeriodID` across `CompanyYearID`), live null/cardinality counts, group-code table (`11=Municipal`, `14=Commercial`).
- HIGH-risk legacy readers still omit `CompanyYearID`: `Contracts-Company-Overview-Content-Periods.cfm`, `Companies-Company-Overview-Content-Periods.cfm` (+ `-Slim`) — test Anaheim East/West 26/27.
- Municipal remediation script also writes `dbo.Invoices.ProjectYearLabel` (Anaheim East) — confirm invoice/report consumers before commit.
- `spUpdateContractDashboard.cfm` reset endpoint is confirm-token guarded + auth-excluded in `Application.cfc` — carry that exact guard to prod.

## Related
- [[rc-03-city-budgets]] — Bucket C (LB 2nd contract / Newport carryover) depends on this fix.
- [[budget-report-municipal]] — same GenerateContractPeriod / contract-calendar layer.
