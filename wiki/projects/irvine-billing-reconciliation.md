---
title: Irvine Billing Reconciliation
type: project
domain: work
track: 1
status: proposal
tags: [billing, reconciliation, irvine, municipal, celeste, contract-lineitems, arbor-core-proving-ground]
applies: ["[[db-repair-contract]]"]
links: ["[[budget-report-municipal]]", "[[rc-03-city-budgets]]"]
updated: 2026-07-03
---

# Irvine Billing Reconciliation

**One-liner:** Automate the monthly Irvine billing check Celeste (Contracts) does by hand — (1) reconcile invoices to the billing period, then (2) validate each invoice's line items against the contract — and output an exceptions list. V1 proving ground for the arbor-core estimating/billing framework.
**Status:** 📝 proposal — Step 1 proven live on real data; Step 2 (line-item validation) data-path scouted, awaiting 3 answers from Celeste to scope.
**📁 Location:** `arbor-stack/billing-reconciliation/`
**▶️ Resume:** `arbor-stack/billing-reconciliation/PROJECT-irvine-billing-recon.md`

## Applies / uses
- [[db-repair-contract]] — read-only DB analysis on play (`production-dashboard/gsql.sh`); build WITH Celeste from her real workflow.
- Key IDs: City of Irvine = CompanyID 295926; Contract 1242, ProjectID 1105030 (2022-09-01 start, $5,258,621.18, 5-yr).

## State & flags
- ✅ **Step 1 (period reconciliation) — PROVEN LIVE** at the 2026-06-24 meeting. Celeste's rule = **bin by InvoiceDate**; 8 months (Oct'25–May'26) tie to the penny. The 4 flagged months = a calendar-date vs fiscal-year-label binning difference at the July-1 fiscal flip (NOT lost money). Finding worth fixing: `CompanyPeriods.InvoiceTotal` bins by FY label, not date.
- 🔜 **Step 2 (line-item ↔ contract validation) — NEXT.** Invoice chain confirmed end-to-end: `InvoiceMasters → Invoices` (on `InvoiceMasterID`) → **`InvoiceLines`** (on `InvoiceID`). Use `InvoiceLines` (plural); `InvoiceLine` singular = QuickBooks mirror, ignore.
- ⏳ **Contracted unit rates live in the PRICING layer** (`PricingGroups`/`PricingGroupRates`/`PricingModels`/`PricingSizes`…) — NOT yet pinned which pricing group Irvine maps to (the key join to confirm).
- **3 open questions for Celeste unlock the build:** which line items she checks, where she looks up the correct contracted rate, and what counts as a mismatch.

## Related
- [[budget-report-municipal]] — sibling municipal invoice/contract analysis.
- [[rc-03-city-budgets]] — shares the municipal invoice-masters data path.
