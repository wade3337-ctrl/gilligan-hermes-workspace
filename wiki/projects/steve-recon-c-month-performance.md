---
title: Project C — Month Performance by Customer
type: project
domain: work
track: 1
status: blocked
tags: [steve, reconciliation, cfo, month-performance, cfr-report, blocked]
applies: ["[[db-repair-contract]]"]
links: ["[[steve-recon-a-financial-report]]", "[[steve-recon-b-municipal-accrual]]"]
updated: 2026-07-02
---

# Project C — Month Performance by Customer

**One-liner:** Characterize why `Report$MonthPerformance$Customer.cfr` reads ~2× the canonical invoiced figure — a performance report grouped by customer, blending three billing-pipeline stages (invoiced → crew-packeted → open WOs) under one "Invoice #" column so uninvoiced work looks like stray out-of-period invoices.
**Status:** 🔴 blocked — characterized + Steve's "out-of-period invoices" question answered; **blocked on Steve's actual complaint** before root-causing/fixing.
**📁 Location:** `steves-projects/financial-report-reconciliation/` — report is `D:\…\GSTS\ReportDev\Report$MonthPerformance$Customer.cfr`
**▶️ Resume:** `arbor-stack/steves-projects/financial-report-reconciliation/RECON-03-MonthPerformanceCustomer.md`

## Applies / uses
- [[db-repair-contract]] — the `.cfr` is a compiled/serialized Report Builder blob (query not text-readable) → analyzed via rendered PDF; a column/label change is a Report Builder edit (devs), not a CFML tweak.

## State & flags
- ✅ **Answered ("out-of-period invoices"):** the report has THREE sections all under an "Invoice #" header — only the first is real invoices:
  - **Invoices** (LegacyRef 59xxx–60xxx) = **$653,687.59** = CFO canonical June to the penny ✅
  - **CrewPackets** (IDs 167xxx = WorkOrderID) = $17,113.02 — complete, not yet invoiced (PeriodID NULL)
  - **WorkOrders** (IDs 167xxx) = $526,666.04 — active/open, not yet invoiced (PeriodID NULL)
  - **Grand "Revenue"** = **$1,197,466.65** (why it reads ~2× canonical)
- **Proof no double-count:** #167xxx values match `dbo.WorkOrders.WorkOrderID`, none exist in `Invoices`, PeriodID = NULL, 0 invoices → genuinely uninvoiced, billed in a future period.
- **Fix options (need Steve's preference):** (1) relabel the lower sections' column + "(not yet invoiced)" tag; (2) add a clear breakdown "Invoiced $653,687.59 | Pending $543,779.06"; (3) pure invoiced view = Section 1 only.
- **To verify:** possible dup — Newport Beach invoices 60046 & 60055 identical ($362.70, same date/desc).

## Related
- [[steve-recon-a-financial-report]] — parent reconciliation umbrella (canonical benchmark it's compared against).
- [[steve-recon-b-municipal-accrual]] — shares the finer Municipal (Cities vs Other) sub-classing.
