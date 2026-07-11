---
title: Shared engine kills dashboard drift
type: fact
domain: how-we-work
tags: [pattern, dashboards, dry, reconciliation, drift, shared-include, city-budgets]
links: ["[[city-forecasting]]", "[[rc-03-city-budgets]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-10
---

# Shared engine kills dashboard drift

**The pattern:** when **N dashboards duplicate the same calc/FY logic**, factor it into **ONE load-guarded shared include** so they can't drift apart. Each surface calls the same function; nobody re-implements the math. Proven on the [[city-forecasting]] build — the per-city fiscal-year + budget + monthly-spread math had **3 copies** (City Budgets, the Forecast tab, RC-06 Production, each with a verbatim paste). Factored into `citybudget-fy-helpers.cfm` (5 canonical `cb*` helpers); all three now `<cfinclude>` it behind a load guard (`request.cbHelpersLoaded`) so it loads once per request.

**Reconcile the SPINE, not every number.** The shared engine locks the **budget / FY / spread spine** identical across surfaces (Newport 25/26 = **$2,030,649.30** on all three). But different *actuals* stay **distinct, clearly-labeled** figures — they are NOT forced to be equal:
- **Produced $** (CrewSheets, ~$2,027,793.81) — what crews performed.
- **Invoiced $** (InvoiceMasters, $1,999,929.91) — what was billed.

Trying to force produced == invoiced would be a bug, not a reconciliation. What must tie is the shared spine; the labeled actuals are allowed to differ by design (this was reconcile-**option (a)** in the spec).

**Why it matters:** the legacy failure mode was exactly this — the old Contract Dashboard read a materialized `CompanyYears` layer that lagged/drifted at FY turnover (see [[rc-03-city-budgets]]). Live-computing from ONE source self-heals; three verbatim copies of the same math is three chances to diverge silently.

**How to apply:**
- Spot N pages doing the same calc → extract to one include; delete the copies.
- Guard the include so a page that pulls it twice (e.g. a dual-tab page) doesn't dup-declare.
- Verify **byte-identical before/after** on every consuming page (no calc logic changed, only relocated).
- Keep genuinely-different actuals as separate labeled rows/columns; reconcile only the shared spine.

Cross-links: [[city-forecasting]] (where this was established) · [[dashboard-metric-standards]] (the metric rules the spine obeys).
