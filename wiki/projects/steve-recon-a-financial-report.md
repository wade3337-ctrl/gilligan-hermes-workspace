---
title: Project A — Financial Report Reconciliation
type: project
domain: work
track: 1
status: active
tags: [steve, reconciliation, cfo, financial-report, canonical, ground-truth]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[steve-recon-b-municipal-accrual]]", "[[steve-recon-c-month-performance]]", "[[steve-diligence-dashboard]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-02
---

# Project A — Financial Report Reconciliation

**One-liner:** Establish the CFO's Financial Report as the canonical revenue ground truth and validate every dashboard's numbers against it — invoice-centric `SUM(Invoices.Total)`, status-filtered, anchored on the accounting period.
**Status:** 🔵 active — canonical definition + 2026 benchmark established (Jun 18). `Exec$Periods$Overview` **CONFIRMED WRONG** (stale period-close); fixes pinned by the Skipper. Umbrella for RECON-02 (B) and RECON-03 (C).
**📁 Location:** `steves-projects/financial-report-reconciliation/` (canonical source in `financial-report-truth/src/`)
**▶️ Resume:** `arbor-stack/steves-projects/financial-report-reconciliation/CANONICAL-DEFINITION.md`

## Applies / uses
- [[dashboard-metric-standards]] — the canonical revenue definition every dashboard reconciles to.
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — any dashboard fix under this umbrella follows the UI standards.
- [[repair-contract]] — backup-first, penny-reconcile, render-verify; **decide first** whether a dashboard is *supposed* to equal invoiced revenue before "fixing" it.

## State & flags
- **The definition:** source `dbo.Invoices`, `SUM(Invoices.Total)`, invoice status ∈ (InProcess/Pending/Open/Paid/Locked), date anchor = accounting period (`Invoices.PeriodID` → `Periods.StartDate`); required joins WO/Proposals/Projects/Companies (drop 0 invoices in 2026); anti-fan-out on Location via MIN(LocationID).
- **2026 benchmark (verified on play):** YTD thru ~Jun 18 = 1,363 invoices / **$9,734,618.63**.
- ⚠️ **Reconciliation caution:** COO monitor / Revenue Performance measure *scheduled/earned* production (Calendars), NOT invoiced $ — reconcile conceptually, not to the penny. Exec Periods/Performance SHOULD match exactly (flagged Invoices-vs-Calendars + period double-count).

## Related
- [[steve-recon-b-municipal-accrual]] — Project B, phantom municipal accrual.
- [[steve-recon-c-month-performance]] — Project C, month-performance-by-customer 2× canonical.
- [[steve-diligence-dashboard]] — the win-rate/sales dash built off this ground truth.
