# PROD Deploy — Steve's Financial Report Dashboard (Sales Performance / Win-Loss by Year)

**Requested by Steve (CFO), 2026-07-21.** Built + verified on play; crew-verified (Kimi K3 / Gemini 3.1 Pro /
gpt-5.6-sol) and hardened before handoff. Everything below is dev-ready — exact files, exact SQL, exact order.

## What this is
Steve's diligence dashboard: `FinancialReportDashboard.cfm` (Sales Performance — win% by rep, corrected win
definition, city-work excluded, Tree Health Care bin, Proposal Detail table) + its CSV export. Includes the
Win/Loss-by-Year fixes Steve flagged: departed reps restored to their historical years, and reassigned proposals
re-credited to the **original seller**.

## ⚠️ Order matters — run the DB step FIRST
The dashboard LEFT JOINs `Workbench.dbo.ProposalOriginalRep`. If the `.cfm` is deployed **before** that table
exists, the page errors (missing object). So: **DB step (1) → files (2) → grant (in step 1's SQL, item 4).**

## Step 1 — Database (prod GSTS SQL Server)
Run **`01-Workbench-ProposalOriginalRep-create-seed-PROD.sql`** (as a login with CREATE/DDL rights in `Workbench`).
- Fail-closed + atomic (single transaction, `SET XACT_ABORT ON`); safe to re-run; backs up any pre-existing table.
- Creates `Workbench.dbo.ProposalOriginalRep` (+ **unique** index on ProposalID) if missing, then seeds **563** overrides.
- Ends with a hard assert; expected final output: **`RowCount_expect_563 = 563`**. (If it errors, nothing is committed.)
- **Item 4 in the script (REQUIRED):** grant the **GSTS ColdFusion datasource login** SELECT on the new table:
  `GRANT SELECT ON Workbench.dbo.ProposalOriginalRep TO [<the prod GSTS datasource login>];`
  — the CF app connects as this login; if it's scoped to the `gsts` DB only, the dashboard will get a permission
  error without this. (If that login is db_owner/sysadmin it's already covered — please confirm, don't assume.)

## Step 2 — Files (prod GSTS webroot → `FinancialReport\` folder)
Back up the current prod copies first, then copy these 5 files into `...\wwwroot\GSTS\FinancialReport\` (overwrite):
| File | Note |
|---|---|
| `FinancialReportDashboard.cfm` | the dashboard (win-rate + attribution fixes, city-excl, THC bin, detail table) |
| `FinancialReportExport.cfm` | CSV export (streams via cfcontent — no disk-write needed) |
| `FinancialReportDashboardHeader.cfm` | shared include (shipped for a consistent set) |
| `FinancialReportDashboardNavBar.cfm` | shared include |
| `FinancialReportDashboardJS.cfm` | shared include |
- If prod GSTS uses a dual (C:/D:) or multi-node webroot, copy to **all** served roots so no node serves a stale page.

## Step 3 — Verify
1. Load `…/GSTS/FinancialReport/FinancialReportDashboard.cfm` on prod → Sales Performance renders, 0 CF errors.
2. Historical-year spot check (e.g. 2024): departed reps present (Chris Mello etc.); recent hires not credited with
   pre-hire work; Export downloads the CSV.
3. Our smoke test: `BASE=https://greatscotttreeservice.com/GSTS bash deploy-smoketest.sh FinancialReport/FinancialReportDashboard.cfm`

## Rollback (correct order)
1. **Files first:** restore the backed-up prod `.cfm` copies in every served root; confirm prod serves the old page.
2. **Then DB:** the new table is only read by this dashboard, so once the old `.cfm` is back it's inert. To fully
   revert: `DROP TABLE Workbench.dbo.ProposalOriginalRep;` (a pre-existing copy, if any, is saved as
   `Workbench.dbo.ProposalOriginalRep_bak_predeploy`).

## Notes on data
- Overrides are keyed by ProposalID; play is a ~24h replica of prod, so IDs align. The set is a point-in-time
  snapshot (2026-07-21) of historical attribution — it corrects departed/reassigned reps, not future reassignments.
- One bad override (ProposalID 396441, `OrigRepName='UNDEFINED'`) was **removed** from the seed (it would have
  excluded that proposal). 564 play rows → 563 clean prod rows.
- Dependency check: all CSS/JS/image assets + linked drill pages already resolve on prod (200). Only non-standard
  DB object required = `Workbench.dbo.ProposalOriginalRep`. Everything else is `gsts.dbo.*` (already on prod).
