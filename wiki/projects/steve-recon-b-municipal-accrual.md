---
title: Project B — Municipal Accrual (PercentagePerformed)
type: project
domain: work
track: 1
status: shipped
tags: [steve, reconciliation, municipal, accrual, cfo, stored-proc, shipped, prod]
applies: ["[[db-repair-contract]]"]
links: ["[[steve-recon-a-financial-report]]", "[[steve-recon-c-month-performance]]", "[[rc-03-city-budgets]]", "[[deal-tracker-dashboard]]"]
updated: 2026-07-22
---

# Project B — Municipal Accrual (PercentagePerformed)

**One-liner:** Root-caused + FIXED the phantom municipal accrual on the month-end percentage-of-completion report — CFO used to manually back out municipal accruals every month (~$111K, May 2026 / period 332).
**Status:** 🟢 **SHIPPED — deployed to PRODUCTION** (Skipper confirmed 2026-07-22). Steve confirmed the per-city billing cycles; the billing-cycle-aware fix is live.

## ✅ The fix (confirmed live in `dbo.GetPeriodAccrual`)
Accrual is percentage-of-completion, per active WO per period:
**`Accrual = (WorkOrders.EstValue − PriorBilled) × (ThisMonthHours ÷ WOHours)`**
where `PriorBilled = GetWorkOrderInvoicedAmount$Prior(WO,Period)`, hours via `GetWorkOrderEstHours$Period / GetWorkOrderEstHours`.
**The billing-cycle correction** that kills the phantom muni accrual is the filter **`ISNULL(CrewSheets.BillingPeriodID, @ZPeriodID+1) > @ZPeriodID`** — only accrue work whose *billing period is AFTER the current period* (so arrears/progressively-billed municipal work already invoiced isn't re-accrued). Function is a 2-branch UNION (WO end-date scenarios); also excludes `ProjectID 1096607`, caps at target TPH, requires positive YetToBill.
**Reused by:** the count-once revenue ledger ([[deal-tracker-dashboard]]) pulls current-period − prior-period accrual from this same function for its "Adjusted Actual" bridge — so we did NOT need Brent's manual feed. This is exactly the accrual Herman's spec wanted (and his "don't infer from WO−invoice" warning was against the *un*corrected version — this corrected one is the reconciled answer).
**📁 Location:** `steves-projects/financial-report-reconciliation/` — logic lives in the stored proc (DB object)
**▶️ Resume:** `arbor-stack/steves-projects/financial-report-reconciliation/RECON-02-PercentagePerformed-MunicipalAccrual.md`

## Applies / uses
- [[db-repair-contract]] — fix is in a stored PROC → build+test on play, back up the proc definition first, hand to devs for prod deploy.

## State & flags
- **Root cause:** ONE accrual model applied to TWO billing models. `Accrual = (WOValue − PriorBilled) × (ThisMonthHrs / WOHours)`. Commercial WOs bill at completion (PriorBilled = $0) → accrual correct. Municipal bills progressively/in-arrears (PriorBilled = $718,881, May) → the formula accrues this month's hour-share of the *entire remaining* contract ON TOP of already-recognized revenue → **phantom accrual**.
- ⭐ **CFO input (Steve): CONFIRMED + SHIPPED.** Answer was "**BOTH**", per-city — some bill on completion, others monthly/EOM. Implemented as billing-cycle-aware accrual via **`CrewSheets.BillingPeriodID`** (the per-crewsheet billing period drives whether the work accrues), NOT a blanket "zero municipal." Deployed to production 2026-07-22.
  - **Upon-completion cities:** Aliso Viejo, Anaheim*, Cypress, Fountain Valley, LB Marine, LB Parks, San Clemente, Westminster* (*= No Progress Billing).
  - **Monthly/cycle cities:** Irvine (1st & 15th), Newport Beach (EOM), Stanton (EOM). **TBD:** City of Industry.
- **Code-quality notes:** two result sets duplicate the query (set 2 omits some filters); hard-coded `ProjectID != 1096607` exclusion; municipal-subtotal row only renders on the 1→2 transition (display edge case).

## Related
- [[steve-recon-a-financial-report]] — parent reconciliation umbrella.
- [[rc-03-city-budgets]] — shares the ProjectGroupDef 11 municipal definition and per-city billing map.
