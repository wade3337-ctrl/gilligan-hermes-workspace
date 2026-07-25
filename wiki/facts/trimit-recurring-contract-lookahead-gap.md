---
title: TRIM IT recurring-contract look-ahead gap
type: fact
domain: work
track: 1
tags: [trimit, contracts, sales-cockpit, data-model, running-dry, backlog]
links: ["[[sales-cockpit]]", "[[aspen-retention-agent]]"]
created: 2026-07-17
updated: 2026-07-25
---

# TRIM IT recurring-contract look-ahead gap

**The gap (Skipper flagged 2026-07-17):** TRIM IT has no reliable place recording our **recurring commercial maintenance contracts**, so any "forward look-ahead / running-dry" signal is blind to multi-year commitments.

## Evidence that surfaced it
- Sales Cockpit flagged **Newport Coast Shopping Center (Coastal)** as "running dry." It isn't — it's Proj **1103500** under Company **301642 "Irvine Company – Retail"**: **~40 shopping centers, all active, 34 future WOs, work completed last month.** A big, healthy recurring account.
- Its work is booked **~1 month ahead** (recurring maintenance cadence); furthest booked WO anywhere in the company = **Nov 12 2026**.
- **`dbo.Contracts` has only two rows for the whole portfolio, both Approved but EndDate 2021-08-30 (expired), old 18/19 budgets.** There is **no current contract row** representing the ongoing relationship.

## Why it matters
- Because the commitment isn't in `dbo.Contracts` with a real future term, **no dashboard can compute a correct forward book** for these accounts. We patched running-dry to lean on the recurring *cadence* (recent completions + a booked next WO) instead — a proxy, not the real look-ahead. See [[sales-cockpit]] running-dry def (Skipper 2026-07-17).
- The same blind spot hits Aspen's retention signals ([[aspen-retention-agent]]) and any renewal/rebid forecasting.

## The fix (future work, not yet built)
- Represent recurring commercial maintenance agreements somewhere durable in TRIM IT (current `dbo.Contracts` rows with real future EndDate + per-year budget, or an equivalent recurring-agreement record), so forward look-ahead is data-driven rather than cadence-inferred.
- Once that exists: fold true contract coverage back into the Cockpit running-dry / forward-book logic and re-sync Aspen.
