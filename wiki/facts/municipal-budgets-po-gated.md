---
title: Municipal budgets in TRIM IT are PO-gated (entered late)
type: fact
domain: work
tags: [municipal, city-budgets, trimit, data-quality, brent, reconciliation, po]
links: ["[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[budget-report-municipal]]", "[[revenue-goal-close]]", "[[only-trustworthy-data]]"]
updated: 2026-07-14
---

# Municipal budgets in TRIM IT are entered LATE (PO-gated)

**Not all municipal contract budgets are in TRIM IT.** Brent (Contract Admin) **does not enter a municipal budget until the city issues the PO** — so a contract we've effectively won/renewed but whose PO hasn't landed yet has **no budget row** in TRIM IT (or a stale/zero one).

**Consequence — municipal totals in any TRIM-IT-sourced view UNDERSTATE reality** until the POs come in:
- Confirmed 2026-07-14 (Skipper): SPM Results **Classic View** municipal book = **$6.62M** (sum of *entered* municipal contract allocations) vs **Nate's Sales Report $8.75M** → a **~$2.14M gap that is entirely unbudgeted/PO-pending municipal work.** Nate tracks the not-yet-issued work manually; TRIM IT can only count what's entered. **Commercial reconciled to the dollar** — the gap was 100% this.
- This is **not a dashboard bug and not Nate over-counting** — it's a deliberate data-entry policy.

## Where this shows up / how we handle it
- **SPM Results Classic View** now carries a ⚠️ note: "Municipal reflects only budgets entered in TRIM IT… trails reports that include not-yet-issued work." Points readers to the Renewals tab.
- **City Budgets → Renewals tab** ([[rc-03-city-budgets]], ship #166) is exactly the surfacing of this: it lists municipal (and commercial) accounts with **no current-FY budget yet** — i.e., the PO-pending renewals. The City of Stanton case (expired contract, no budget → vanished from Forecasting) is the same phenomenon.
- **[[revenue-goal-close]]** municipal (produced/crew-sheet, not budget) is less exposed to this, but municipal *goal/budget* comparisons inherit it.

## Rule of thumb
When a municipal number is **lower than an outside report** (Nate, Brent's Excel), suspect **un-entered PO-pending budgets FIRST** before assuming a code bug. Flag it + point to Renewals; don't "fix" the dashboard to invent budget that isn't in the system. ([[only-trustworthy-data]] — omit + flag, don't fabricate.)
