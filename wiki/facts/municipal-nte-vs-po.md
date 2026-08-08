---
title: Municipal NTE vs PO — and where Brent's muni files live
type: fact
domain: work
track: 1
tags: [municipal, nte, po, brent, warehouse, munibot, contracts, forecasting]
links: ["[[munibot-data-warehouse]]", "[[aspen-cockpit-to-bigin-push]]", "[[budget-report-municipal]]", "[[brent-agent]]"]
updated: 2026-08-08
---

# Municipal NTE vs PO — and where Brent's muni files live

**One-liner:** The true municipal contract ceiling (NTE) lives in Brent's contract PDFs in the MuniBot warehouse — NOT in TRIM IT. TRIM IT only holds PO amounts.

## 📍 The warehouse (don't re-hunt for it)
- **`~/.munibot/municipal-archive/`** on gilligan = MuniBot container bind-mount **`/opt/data/municipal-archive`**.
- `<County>/<City>/<term> CONTRACT/…` — 5 counties (LA · Orange · Riverside · San Bernardino · San Diego), **185 city folders**, ~52G. Verified COMPLETE 2026-08-08 (the 6 previously-missing .lnk cities — Long Beach, Anaheim, Aliso Viejo, Cerritos, Lake Forest, Stanton — are all in now).
- Contents: contract agreements + amendments (PDF), Schedule of Compensation, POs, RFPs, inventories, GIS.
- **When the Skipper says "the warehouse" or "Brent's muni files" → it is HERE.** Pointer note: [[munibot-data-warehouse]].

## The NTE vs PO rule
- **NTE (Not-To-Exceed)** = the city's full contract ceiling. Stated verbatim in the contract/amendment PDFs in the warehouse.
- **TRIM IT has NO NTE field.** Its `CompanyContracts` table (`TotalPrice`, `HTDBilled`, `AmountRemaining`, `Year01Budget`..`Year05Budget`) holds **PO amounts Brent entered** — a number is there only because we physically hold a PO for it. Cities **drip-feed POs** against the ceiling, so TRIM IT usually shows LESS than the NTE.
- Brent's City Budgets dashboard "budget" = these PO amounts (not NTE).

## Proven example — Fountain Valley (2026-08-08)
- File: `Orange County/Fountain Valley/==2021-2027 CONTRACT==/Contract Renewal/FY 25-27/Amend 2 CON-21-19.pdf`
- Current NTE = **$374,487.75/yr base + $25,000 contingency**. History: $310,500 (2021) → $349,334.50 (FY23-25) → $374,487.75 (FY25-27).
- TRIM IT `CompanyContracts` Year budget for FV = $374,335 ≈ the NTE (this city cut a full-year PO; a coincidence, not the rule).
- `pdf-parse` in `arbor-stack/pdf-tools` reads these PDFs cleanly.

## Why it matters (build + FPC)
- **The forward municipal forecast** = NTE (warehouse PDF) − POs drawn (TRIM IT `CompanyContracts`) = true remaining ceiling.
- The FPC sales-report "Municipal Sold $5.06M" = a budget/NTE-based forecast (annual ÷ 12), not booked WOs — lives outside TRIM IT by design.
- **Bigin build task:** AI-parse each active city's Contract Agreement + latest Amendment → structured {NTE, contingency, term, escalation} record. Spec: `aspen-stack/MUNICIPAL-NTE-vs-PO-build-note.md`.
