---
title: TRIM IT accrual = GetPeriodAccrual (% -of-completion, billing-cycle-aware)
type: fact
domain: work
tags: [trimit, accrual, municipal, percentage-performed, steve, formula, stored-fn]
links: ["[[steve-recon-b-municipal-accrual]]", "[[count-once-revenue-ledger]]", "[[deal-tracker-dashboard]]", "[[rc-03-city-budgets]]"]
updated: 2026-07-22
---

# TRIM IT accrual = `GetPeriodAccrual` (%-of-completion, billing-cycle-aware)

**The fact:** TRIM IT computes accrual live in the table-valued function **`dbo.GetPeriodAccrual(@ZPeriodID)`** (behind the PercentagePerformed month-end report). Per active work order, per accounting period:

```
Accrual = (WorkOrders.EstValue − PriorBilled) × (ThisMonthHours ÷ WOHours)
```
- `PriorBilled` = `gsts.dbo.GetWorkOrderInvoicedAmount$Prior(WorkOrderID, PeriodID)` (already invoiced before this period)
- `WOHours` = `GetWorkOrderEstHours(WO)`; `ThisMonthHours` = `GetWorkOrderEstHours$Period(WO, Period)`
- = percentage-of-completion: recognize each WO's still-unbilled value in proportion to hours done this month.

## The billing-cycle correction (kills the phantom municipal accrual)
The fix Steve confirmed + **shipped to prod 2026-07-22** is the filter:
```
AND ISNULL(CrewSheets.BillingPeriodID, @ZPeriodID+1) > @ZPeriodID
```
→ only accrue work whose **billing period is AFTER the current period**. Municipal contracts bill in arrears/progressively, so without this the formula re-accrued already-recognized revenue (~$111K/mo accounting had to back out manually). Per-city cycles: completion-billed (Aliso Viejo, Cypress, San Clemente, Westminster…) vs monthly/EOM (Irvine, Newport, Stanton). Driven by `CrewSheets.BillingPeriodID`. Full root-cause: [[steve-recon-b-municipal-accrual]].

## YTD accrual-basis bridge
`Adjusted actual YTD = Invoiced YTD + current-period accrual − Dec-prior-year accrual`. (Herman's monthly bridge telescopes to this.) Read live via `SELECT SUM(AccrualTotal) FROM dbo.GetPeriodAccrual(@P)`. Snapshot 7/22: July $58K, Dec-2025 baseline $161K → adj ≈ −$103K. **Current period is partial-month → its accrual grows toward month-end.**

## Gotchas
- Fn excludes `ProjectID 1096607`, caps at target TPH, requires positive YetToBill; 2-branch UNION on WO end-date scenarios.
- This is what Herman's "don't infer accrual from WO−invoice" warned against — the *uncorrected* version. The corrected (billing-cycle) version is the reconciled answer, now reused by the [[count-once-revenue-ledger]].
