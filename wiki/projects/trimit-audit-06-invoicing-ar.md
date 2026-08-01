---
title: TRIM IT Audit 06 — Invoicing / AR
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, invoicing, ar, billing, quickbooks, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-05-scheduling-crewsheets-production]]", "[[bod-commitment-dashboard]]", "[[anomaly-monitor-suite]]", "[[monthly-cfo-reconciliation]]"]
updated: 2026-08-01
---

# TRIM IT Audit 06 — Invoicing / AR

> Stage 6 of the [[trimit-deep-audit]]. **Map-only pass (Skipper "A")** — zero writes. Every figure from a
> `gsql.sh` query or file read run THIS session. Closes the workflow spine: production
> ([[trimit-audit-05-scheduling-crewsheets-production]]) → invoice → AR.

## ⭐ Headline: TRIM IT invoices, but does NOT do cash — payments live in QuickBooks
- **`dbo.Payments` = 0 rows AND `dbo.Applied` (payment→invoice application) = 0 rows.** TRIM IT issues invoices and tracks `InvoiceBalance`, but **cash receipt / payment application is not in this system** — it's in QuickBooks. This is why `CompareInvoicesToQB` tooling exists and why AR "collections" work reads balances, not payments.
- **`dbo.InvoiceLine` (singular, 25,669 rows, 101 cols) is a QuickBooks staging table, NOT legacy TRIM IT** — its columns are QB SDK/qbXML fields (`TxnID`, `TimeCreated`, `EditSequence`, `TxnNumber`, `CustomerRefListID`). Don't confuse it with `InvoiceLines` (plural, 1.4M, the real line items). This is the QB integration surface.
- **The invoice hierarchy is 3 levels:** `InvoiceMaster` (2,327 — the customer-facing billing document) → `Invoices` (50,314 — one per project/work order) → `InvoiceLines` (1,419,345 — line items) [+ `InvoicePageLines` 1.26M for the printed layout].

## 1. Entry points (code) — verified by reading
- **Create starts at the master:** `CodeGenerateInvoiceMaster.cfm` → `<CFSTOREDPROC dbo.GenerateInvoiceMaster>`; variant `CodeGenerateInvoiceMaster$Contract.cfm`. Then `CodeGenerateInvoice$ProForma.cfm` / `$Credit.cfm` for the special invoice types; `CodeGenerateInvoiceLine$Add.cfm` / `$Copy.cfm` for lines. **34 `GenerateInvoice*` procs** total.
- **Edit UI:** `Synch.Invoice.Update.cfm`, `Synch.Invoice.Hours.Update.cfm` (MM_UpdateRecord inline-UPDATE pattern), `Profile.Invoice.Detail.cfm`, `Profile.InvoiceMaster.Detail.cfm`.
- **AR/collections:** `Dev-Collection.cfm`, `Sales.Proposal.Collection.cfm` (thin — the real AR reporting is our [[anomaly-monitor-suite]] AR report, which reads `InvoiceBalance`).
- **Upstream link:** `InventoryAssignments` (Stage 5) → `InvoiceLines` — the per-tree production record becomes the invoice line.

## 2. Data model (verified live)
**`dbo.Invoices` — 50,314 rows, 83 columns.** The per-project invoice.
- Money cols: `InvoiceSubTotal`, `Discount`, `InvoiceAdjustment`, `StateTaxes`/`LocalTaxes`, `Total`, **`InvoiceBalance`** (the AR figure), `SurchargeTotal`, `PerformedDollars`, `DirectCosts`, `NetTotal`, `TPH`/`TotalHours`.
- Type/state: `IsProForma`, `IsCredit`, `IsDelayedInvoice`, `IsServiceRequest`, `InvoiceType`, `StatusDefID`, `Exported` (to QB), `InvoiceMasterID` (→ parent master).
- **15 parent FKs:** `Companies`, `Projects`, `Proposals`, `RFPs`, `Contracts`(via), `StatusDefs`, `SalesReps`, `ProjectContacts`, `ProjectYears`, `ProjectMonths`, `ProjectSeasonDetails`, `BlanketOrders`, `InvoiceClasses`, `Periods`(×2), `PayrollCommission*`.
- **9 child tables:** `InvoiceLines`, `InvoicePageLines`, `InvoiceSections`, `InvoiceLocationServiceTypes`, `InventoryConfirmations`, `InventoryHitRates`, `InventoryPlots`, `ProjectHistory`, **`Applied`** (payment application — empty).

**`dbo.InvoiceMasters` — 2,327 rows, 21 columns.** The top-level customer-facing invoice document (a billing run can group many `Invoices`). Read by `Client.ControlPanel.Master.cfm` (Stage 1).
**`dbo.InvoiceLines` — 1,419,345 rows, 29 columns.** The line items (from `InventoryAssignments`).

## 3. Used vs. dead
- **Used:** `GenerateInvoiceMaster` + family, `Invoices`/`InvoiceMasters`/`InvoiceLines`, `Synch.Invoice.Update.cfm`, `Profile.Invoice.Detail.cfm`, the QB export path.
- **Dead / orphan (flagged):** `Profile.Invoice.Detail$dev.cfm`, `Synch.Invoice.Detail.Dev.cfm`, `Profile.InvoiceMaster.Detail$dev.cfm`, `Profile.Invoice.CrewRental.Backup$dev.cfm` / `$dev$Save.cfm` / `$temp.cfm` (4 backup variants of one page), `Dev-Collection.cfm` (a "Dev-" prefixed page in production).

## 4. Works vs. broken
- 🐛 **The BOD revenue-filter trap CONFIRMED + refined:** the documented "real revenue" filter `IsProForma=0 AND IsCredit=0` returns near-nothing because the columns are almost entirely NULL — **`IsProForma` NULL on 50,084/50,314 (99.5%)**, only 211 set to 1; **`IsCredit` NULL on 50,289 (99.95%)**, only 25 set to 1. NULL≠0, so the filter excludes all rows. → **Use `SUM(Invoices.Total)` (per [[bod-commitment-dashboard]] / [[monthly-cfo-reconciliation]]); never the IsProForma/IsCredit filter.**
- 🐛 **`Exported` (to QuickBooks) flag is effectively unused:** only **64 of 50,314** invoices are `Exported=1`. Either the QB export doesn't stamp it back or it's abandoned — do NOT use `Exported` to reason about what's in QB. (The real QB reconciliation is `InvoiceLine` staging + `CompareInvoicesToQB`.)
- ⚠️ **AR balance lives here, cash does not:** `InvoiceBalance` is the only receivable signal in TRIM IT; without `Payments`/`Applied`, aging/collection status depends on QB sync. Any "AR" figure is issuance-minus-QB-payments, not a native ledger.

## 5. Cleanup candidates (FLAG only — map-only pass)
- **`zDelete-*` in the invoice/AR domain:** `zDelete_Invoices_SurchargeRollback` (14,343), `zDelete-TempInvoiceSummary` (4,489), `zDelete-ISInvoice` (139), `zDelete-Invoice_Summary_ImportErrors` (2), plus city-import temps (`zDelete-LagunaWoodsVillageDataCompareTemp` 39,715, `zDelete-CarsonTreeInventory` 28,354, `zDelete-LB$Park*`, `zDelete-LoaraHSDataImportTemp`, etc.).
- **Customer-named tables loose in `dbo`:** `Carson` (28,570), `Billing` (1,076) — confirm whether live or one-off import scratch.
- **Empty structures (0 rows):** `Payments`, `Applied`, `InvoiceMaps`, `InvoiceLocationServiceTypes`, `GSTSArborNote*` (4 empty ArborNote import tables).
- **`InvoiceLine` (singular, QB staging, 25,669)** — keep (it's the QB integration surface) but document so it's never mistaken for dead.
- Dead `.cfm` from §3.

## 6. Knowledge delta
- **Already knew:** [[bod-commitment-dashboard]] + [[monthly-cfo-reconciliation]] (the IsProForma/IsCredit-NULL trap → use `SUM(Total)`; H1 revenue basis), [[anomaly-monitor-suite]] (AR report reads InvoiceBalance), [[trimit-audit-05-scheduling-crewsheets-production]] (InventoryAssignments→InvoiceLines bridge).
- **NEW this pass:** **TRIM IT has no cash/payment layer** (`Payments`=0, `Applied`=0 → QuickBooks owns it); **`InvoiceLine` singular = QB staging table** (TxnID/EditSequence), not legacy; the 3-level `InvoiceMaster→Invoices→InvoiceLines` hierarchy with live counts (2,327 / 50,314 / 1.42M); the IsProForma/IsCredit NULL trap quantified exactly (99.5% / 99.95%); `Exported`=1 on only 64 invoices (flag unusable); AR open balance **$18.5M across 3,633 invoices** (live 2026-08-01); create path `GenerateInvoiceMaster` (34-proc family).

## ✅ WRITE-TEST VERIFICATION (2026-08-01, Skipper-directed)
**Method:** PLAY only, `BEGIN TRAN … ROLLBACK`, zero residue. `GenerateInvoiceMaster` is a light single INSERT (safe to fire). Created InvoiceMasterID 4394; NULL-trap tested on real invoice 483265.

| # | Finding (map-only claim) | Write-test | Verdict |
|---|---|---|---|
| 1 | `GenerateInvoiceMaster(@ZProjectID)` creates the master header | S6-T1: EXEC’d → `*** New Invoice Master ***`, Pending, seeded from project (Total NULL) | ✅ CONFIRMED |
| 2 | `IsProForma`/`IsCredit` 99.5% NULL → documented filter `=0 AND =0` returns near-zero; use `SUM(Total)` | S6-T2: real invoice with NULL flags **fails** the documented filter (0 rows); after `SET IsProForma=0,IsCredit=0` it **passes** (1 row). Schema confirms **no default constraint** on either column → new rows default NULL | ✅ **CONFIRMED — write-demonstrated the filter silently drops every NULL-flag invoice; the trap is baked in at the schema (no default)** |
| 3 | Parent-FK enforcement | S6-T3: `SET CompanyID=-99999` on InvoiceMasters was **ACCEPTED** | 🚨 **NEW FINDING — `InvoiceMasters.CompanyID` has NO foreign key** (the table’s ONLY FK is `FK_InvoiceMasters_Contracts`). The child `Invoices` DOES enforce `FK_Invoices_Companies` (trusted). So the master is LESS protected than its children. 0 orphans exist today, but nothing prevents them. |
| 4 | No cash layer (`Payments`/`Applied` = 0 → QuickBooks owns payments) | S6-T4: live counts | ✅ CONFIRMED — `Payments`=0, `Applied`=0 |
| 5 | AR open $18.5M | S6-T4: live | ✅ CONFIRMED — **3,633 open invoices / $18,506,866.00** |

**New integrity gap to log:** `InvoiceMasters` lacks FKs on `CompanyID` (and `ProjectID`) — the invoice *master* trusts the app to write valid keys; the DB won’t reject garbage. Candidate to add-with-check during any cleanup (rehearse first; verify 0 orphans on prod before adding, which play shows = 0). Residue: identity ticks only; master reverted, invoice flags back to NULL.

## Resume pointer
**Stage 6 COMPLETE (map-only, 2026-08-01).** Invoice hierarchy, create path, FK graph, the QB boundary, and the
BOD revenue-filter trap all confirmed live. **Next = Stage 7: Reporting / Dashboards** — the layer we've built most
in (RC-01..06, SPM, BOD, RGC). Stage 7 should be a *consolidation/reconciliation* pass (which dashboards read which
of the now-mapped tables; where derived-rollup drift risk concentrates) rather than fresh discovery. Deferred: read a
`GenerateInvoiceMaster` body for how invoices roll up from crew sheets. Cleanup execution deferred (map-first).
