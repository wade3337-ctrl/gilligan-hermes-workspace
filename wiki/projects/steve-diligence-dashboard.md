---
title: Steve's Diligence Sales-History Dashboard (Project D)
type: project
domain: work
track: 1
status: active
tags: [dashboard, steve, diligence, win-rate, sales-performance, treatments, city-exclusion]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[steve-recon-a-financial-report]]", "[[rc-01-executive-financial]]", "[[rc-04-spm]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-02
---

# Steve's Diligence Sales-History Dashboard (Project D)

**One-liner:** Financial Report dashboard for Steve's diligence — proposal-grain win% by rep (jobs + $), Invoice Details (+ Direct Costs + Type), a Sales Performance tab, and a 20-col proposal-grain detail table keyed off Proposal#; feeds/aligns the company-wide win-rate fix.
**Status:** 🔵 active — **built + render-verified on PLAY, awaiting Steve's sign-off**; nothing on prod yet. Latest: Steve's feedback build (Tree Health Care rename, proposal detail table, view=2 Columns/Export) done Jul 2.
**📁 Location:** `steves-projects/diligence-sales-history/` + `FinancialReport/FinancialReportDashboard.cfm` + `FinancialReportExport.cfm`
**▶️ Resume:** `arbor-stack/steves-projects/diligence-sales-history/CHECKPOINT-STEVE-DASH.md`

## Applies / uses
- [[dashboard-metric-standards]] — corrected win def (§3/§3b: "won" includes `Complete` go-aheads + Revised dedup; old bug decayed win% with age, 2023 showed 3.78% vs true 84.58%).
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — welcome/pro-tips; UTF-8 BOM; money-format polish (NumberFormat, headless-verified).
- [[repair-contract]] — backup-first + **verify every ssh backup by reading it back** (a silent backup failure once reverted the whole FRD); local scp GOOD copies.

## State & flags
- ⚠️ **Gated on Steve's sign-off** → then package the deploy manifest for **Jordan Kim (IT, $0)**. Until deployed, PROD win-rate dashboards still understate win % badly (historical years several-fold low) — flag leadership not to trust live close-rates.
- **City-work exclusion (Skipper Jun 30):** city/municipal-contract work (Municipal Contracts tag `ProjectGroupDefID=11`) = recurring revenue, not net-new sales → excluded from win-rate. **Propagated to all 7 surfaces** (Steve's Sales Perf + Exec ByRep/Detail/ByMarket + SalesCommand + SPM Pipeline/Drill). ONLY cities (schools/HOAs/university stay).
- **Treatment → "Tree Health Care"** rename (label-only; PHC service-type bin kept). Treatment bin corrected DB-wide: 2025 = $433,361/89 invoices; the $621K accounting figure was BAD (QB shows $418K — reconciles).
- **Proposal detail table (view=2)** reconciles exactly to the summary (1805 rows == SUM(WrittenN), 1429 Won both ways); own Columns + Export-to-Excel (`mode=salesperf`).
- ⚠️ **Dual-webroot shadow risk** on the Executive/SalesCommand files in the deploy batch — deploy to BOTH roots + render-verify.

## Related
- [[steve-recon-a-financial-report]] — the CFO Financial Report reconciliation this dash builds from.
- [[rc-01-executive-financial]] / [[rc-04-spm]] — same close-% shown in other UIs; city-exclusion aligned across all.
