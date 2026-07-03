---
title: Project B — Municipal Accrual (PercentagePerformed)
type: project
domain: work
track: 1
status: blocked
tags: [steve, reconciliation, municipal, accrual, cfo, stored-proc, blocked]
applies: ["[[db-repair-contract]]"]
links: ["[[steve-recon-a-financial-report]]", "[[steve-recon-c-month-performance]]", "[[rc-03-city-budgets]]"]
updated: 2026-07-02
---

# Project B — Municipal Accrual (PercentagePerformed)

**One-liner:** Root-cause + fix the phantom municipal accrual on the month-end percentage-of-completion report (`Exec$PercentagePerformed2.cfm` → proc `dbo.Report$PercentagePerformed_npr2`) — CFO says accounting has to manually back out municipal accruals every month (~$111K, May 2026 / period 332).
**Status:** 🔴 blocked — analyzed + root-caused; **blocked on Steve's accounting rule** (per-city billing cycle, zero vs 1-mo-arrears). HOLD the build until he confirms.
**📁 Location:** `steves-projects/financial-report-reconciliation/` — logic lives in the stored proc (DB object)
**▶️ Resume:** `arbor-stack/steves-projects/financial-report-reconciliation/RECON-02-PercentagePerformed-MunicipalAccrual.md`

## Applies / uses
- [[db-repair-contract]] — fix is in a stored PROC → build+test on play, back up the proc definition first, hand to devs for prod deploy.

## State & flags
- **Root cause:** ONE accrual model applied to TWO billing models. `Accrual = (WOValue − PriorBilled) × (ThisMonthHrs / WOHours)`. Commercial WOs bill at completion (PriorBilled = $0) → accrual correct. Municipal bills progressively/in-arrears (PriorBilled = $718,881, May) → the formula accrues this month's hour-share of the *entire remaining* contract ON TOP of already-recognized revenue → **phantom accrual**.
- ⭐ **CFO input (Steve):** answer is "**BOTH**", per-city — some cities bill on completion, others monthly/EOM. Not a blanket "zero municipal." Correct model = **billing-cycle-aware accrual** driven by a per-city/per-project billing-cycle attribute TRIM IT lacks today (Steve's "selectable billing tab") → likely a schema/UI field + accrual logic, a long-term problem.
  - **Upon-completion cities:** Aliso Viejo, Anaheim*, Cypress, Fountain Valley, LB Marine, LB Parks, San Clemente, Westminster* (*= No Progress Billing).
  - **Monthly/cycle cities:** Irvine (1st & 15th), Newport Beach (EOM), Stanton (EOM). **TBD:** City of Industry.
- **Code-quality notes:** two result sets duplicate the query (set 2 omits some filters); hard-coded `ProjectID != 1096607` exclusion; municipal-subtotal row only renders on the 1→2 transition (display edge case).

## Related
- [[steve-recon-a-financial-report]] — parent reconciliation umbrella.
- [[rc-03-city-budgets]] — shares the ProjectGroupDef 11 municipal definition and per-city billing map.
