---
title: Canonical Revenue Definition (CFO ground truth)
type: reference
domain: work
tags: [revenue, canonical, cfo, reconciliation, ground-truth, applies-target]
links: ["[[dashboard-metric-standards]]", "[[steve-diligence-dashboard]]"]
updated: 2026-07-03
---

# Canonical Revenue Definition (CFO ground truth)

**What it is:** Steve's (CFO) blessed definition of "correct revenue" from the Financial Report Dashboard — the ground truth to validate ALL our dashboards' numbers against (established Jun 18 2026).
**📁 Source:** `arbor-stack/steves-projects/financial-report-reconciliation/CANONICAL-DEFINITION.md` (prod page `/gsts/FinancialReport/FinancialReportDashboard.cfm`)

**Used by:** [[steve-diligence-dashboard]] (Project D), [[rc-01-executive-financial]], [[rc-02-revenue-performance]] — **any dashboard reconciled to CFO revenue.**

## Key rules
- **Source table:** `dbo.Invoices` — invoice-centric (NOT Calendars, NOT WorkOrders.EstValue).
- **Dollar:** `SUM(Invoices.Total)`.
- **Status filter:** the INVOICE's status (`Invoices.StatusDefID` → `StatusDefs.Desc1`) ∈ **('InProcess','Pending','Open','Paid','Locked')** (excludes Deleted/Void).
- **Date anchor (default/CFO normal use):** the **accounting period** — `Invoices.PeriodID` → `Periods.StartDate`, filtered by `YEAR()/MONTH()` of that StartDate (an invoice belongs to its assigned period's month, NOT necessarily its InvoiceDate calendar month). **Optional override:** explicit start/endDate filters by `Invoices.InvoiceDate` instead.
- **Required joins (all must exist or the invoice is excluded):** WorkOrders, Proposals, Projects, Companies. (Verified: drops ZERO invoices in 2026.)
- **Anti-fan-out:** Location joined via `LocationID = MIN(LocationID) per Project`; no fan-out in the $ sum. TPH/Hours columns are display only, not the revenue figure.
- **⚠️ Reconciliation caution:** don't "fix" a dashboard to a number it never meant. Some dashboards deliberately measure a DIFFERENT metric (COO daily / Revenue Performance = scheduled/earned production from Calendars, anchored on work day — expected to differ; reconcile conceptually). First step: decide whether the dashboard is SUPPOSED to equal invoiced revenue (then match exactly) or measures earned/scheduled (then explain the gap).
- **Benchmark:** 2026 YTD (thru ~Jun 18) = 1,363 invoices, **$9,734,618.63**. Canonical SUM query is in the source doc.
