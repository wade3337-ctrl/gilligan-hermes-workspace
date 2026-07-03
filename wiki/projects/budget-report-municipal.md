---
title: Budget Report (municipal)
type: project
domain: work
track: 1
status: active
tags: [analysis, municipal, budget-report, city-budgets, brent, newport, anaheim]
applies: ["[[db-repair-contract]]"]
links: ["[[rc-03-city-budgets]]", "[[contract-dashboard-fix-longbeach]]", "[[completed-vs-sold]]"]
updated: 2026-07-03
---

# Budget Report (municipal)

**One-liner:** Reverse-engineered Contract-Admin Brent's per-city fiscal-year Municipal Budget Report (Budgeted / Invoiced / Call-Ins / Scheduled / Remaining, month-by-month + Work-at-Hand WOs) into direct DB queries — the analysis that feeds the [[rc-03-city-budgets]] dashboard.
**Status:** 🔵 active — Newport reconciled to the penny on play; methodology validated; per-city FY alignment (Anaheim/Irvine/LB/Newport) in progress.
**📁 Location:** `arbor-stack/budget-report/`
**▶️ Resume:** `arbor-stack/budget-report/PROCESS.md`

## Applies / uses
- [[db-repair-contract]] — read-only DB reconciliation on play; look-first, backup/preview before any write.
- Two-tab Excel structure decoded (Budget Summary FY + Workorders); every cell mapped to a DB source.

## State & flags
- ✅ **Newport validated (Jun 16, play):** Project 1097860 / Company 295963. BUDGETED = `Contracts` ContractID 449 `Year04Budget` (label 25/26) = 2,030,649.30 (exact). INVOICED = Σ monthly `InvoiceMasters` (exclude "Homeowner Paid City Trees" + NULL drafts) = 1,800,911.92 (exact to Brent).
- CALLINS = Σ WO accruals (progress − invoiced); SCHEDULED = Σ (Total − progress); REMAINING = Budget − Invoiced − Callins − Scheduled. WOs: `WorkOrders` scoped by ProjectID+ContractID+ProjectYearLabel, exclude 'Revised'.
- ⚠️ **Anaheim GenerateContractPeriod fix** done on play → handed to **Travis** ($75/hr dev); overlaps the [[contract-dashboard-fix-longbeach]] `GenerateContractPeriod`/contract-calendar data.
- Budget I19 = same Contract-Scope-per-FY data as the Contract Dashboard repair — reconcile there, don't diverge.
- Open Qs for Skipper: which WOs belong on the Workorders tab; FY boundary/roll rule; scope (Newport-only vs all cities from the start). Sample-file accrual drift (I16 vs I22) is a stale two-tab snapshot — single live pull removes it.

## Related
- [[rc-03-city-budgets]] — the dashboard this analysis feeds.
- [[contract-dashboard-fix-longbeach]] — shared GenerateContractPeriod / contract-calendar layer.
- [[completed-vs-sold]] — shares the municipal burn-down question.
