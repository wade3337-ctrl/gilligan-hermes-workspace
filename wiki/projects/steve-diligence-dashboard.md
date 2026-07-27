---
title: Steve's Diligence Sales-History Dashboard (Project D)
type: project
domain: work
track: 1
status: active
tags: [dashboard, steve, diligence, win-rate, sales-performance, treatments, city-exclusion]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[steve-recon-a-financial-report]]", "[[rc-01-executive-financial]]", "[[rc-04-spm]]", "[[dashboard-metric-standards]]", "[[sales-rep-attribution]]", "[[workbench-play-db]]", "[[deploy-playbook]]", "[[trimit-server-topology]]", "[[v15-prod-deploy-state]]"]
updated: 2026-07-27
---

# Steve's Diligence Sales-History Dashboard (Project D)

**One-liner:** Financial Report dashboard for Steve's diligence — proposal-grain win% by rep (jobs + $), Invoice Details (+ Direct Costs + Type), a Sales Performance tab, and a 20-col proposal-grain detail table keyed off Proposal#; feeds/aligns the company-wide win-rate fix.
**Status:** 🟠 **PROD deploy package built + crew-verified + emailed to Jordan Kim (2026-07-21)** — Steve (via Skipper) asked to push it live today; it was NOT in yesterday's V1.5 bundle (siblings were) so it ships separately. Awaiting Jordan to run it. Prior: Win/Loss-by-year attribution fix (2026-07-10, ship #111/#112, Skipper-approved). Prior: Steve's feedback build (Tree Health Care rename, proposal detail table, view=2 Columns/Export) Jul 2.

## 🚚 PROD deploy package → Jordan (2026-07-21)
- **Canonical source** = `winloss-fix/` (Jul 10, ship #111/#112), confirmed **byte-identical to play-live** (no drift).
- **Hidden dep:** the dashboard LEFT JOINs `Workbench.dbo.ProposalOriginalRep` (attribution overrides) — that table exists on play but **NOT prod** → deploy includes a create+seed SQL. (General deploy gotcha: a dashboard joining a `Workbench.dbo.*` side-table needs that table stood up on prod or it silently returns nulls.)
- **Crew review (Kimi K3 + Gemini 3.1 Pro + gpt-5.6-sol) = DO-NOT-SHIP round 1** → hardened: non-atomic reseed → `XACT_ABORT`+tran, `RAISERROR`→`THROW` asserts that actually halt, `UNIQUE` index (no double-count), count assert, `GRANT` for the CF login, AND a real data bug — proposal **396441** override `='UNDEFINED'` would EXCLUDE it (sol caught) → dropped UNDEFINED (**564→563**). Re-validated on a throwaway play table (clean, 563).
- **Package** (5 cfm + hardened SQL + `DEPLOY-INSTRUCTIONS.md` + `CREW-REVIEW.md`) staged on play `D:\GSTS-Deploy\STEVE-FRD-DEPLOY-20260721\` (outside the webroot). Emailed Jordan (jkim) cc Steve (sguzowski@gstsinc.com) + Skipper, framed as Steve's fresh request today (not an add-on). Jordan runs DB-first → files, + supplies the CF-login GRANT.
- **OPEN:** Jordan to execute; play still has the 564/UNDEFINED row (offered to Skipper to clean for parity). See [[deploy-playbook]] (stage-on-play pattern) + [[sales-rep-attribution]] (the override table).

## 🔌 2026-07-27 — it 500'd on PLAY, and the cause was the datasource, not the page
`FinancialReport/FinancialReportDashboard.cfm` died on play with SQL **916** — `GSTSREADONLY` cannot reach the
`Workbench` database. The page carries 3 `LEFT JOIN Workbench.dbo.ProposalOriginalRep`, and **that table lives
on the play box's own SQL instance, not on `.168`.** Play's copy was **not** stale (byte-identical to our
package, `0f4d331d…`) — it simply could not run.
- **Root cause:** the whole play website's `GSTS` datasource pointed at **production** (`.168`), read-only,
  across the lossy Ayera tunnel. **Fixed 2026-07-27 by repointing `GSTS`+`GSTSAPI` to `localhost,14333`**
  (Skipper-authorised) → the dashboard went **500 → 0.8s**, and `view=2` returns 2.1 MB with override rep names
  resolving (Scott Griffiths ×424) = `Workbench` genuinely reachable. Full story → [[trimit-server-topology]].
- ▶️ **Still owed on PROD:** a **GRANT** giving the CF `GSTS` datasource login access to `Workbench` — without
  it this dashboard hits the same 916 on production. **Bundled into the one batched database ask**, not sent on
  its own → [[v15-prod-deploy-state]]. *(Travis created the `Workbench` DB on prod 7/26 13:23 without extending
  the grant — correct hygiene on his part, just not matched to what the page needs.)*
- 💡 **Generalises:** a 916 means the database **exists but you lack rights**; a **208** means it is **not there
  at all.** That one digit tells you whether you are asking for a deploy or a permission.

## 🩹 Win/Loss-by-Year attribution fix (2026-07-10) — see [[sales-rep-attribution]]
Steve (CFO) flagged 2024 "looks off." Two stacked bugs, both historical-years-only:
- **Fix 1 (roster gate):** the SalesPerf **summary AND detail** queries gated the rep list to the current roster (`sr.IsMeasured=1 AND sr.StatusDefID=188`) → departed reps (Chris Mello, IsMeasured=0) erased from past years. Replaced with a junk/system-name exclusion → every rep who sold in the window shows. (Detail query's gate was missed on the first deploy — **render-verify caught it**.)
- **Fix 2 (reassignment drift):** reassigned proposals mis-credited recent hires. Reviewed hire dates (Rebekah Jan 2026, Ethan Aug 2025, Omar Dec 2022/branch-mgr) → `Workbench.dbo.RepEffectiveDate` + per-proposal override `Workbench.dbo.ProposalOriginalRep` (564 overrides: 554 resolved / 10 Former / 9 conflict-flagged). Wired via `COALESCE(ov.OrigRepName, current)` into all 4 surfaces (summary, detail, treatments, salesperf export).
- **Verified:** 2024 → Rebekah 0 / Ethan 0 / **Chris Mello 1,107 ($3.54M won)** restored; 2026 → Rebekah 345 / Ethan 337 (recent work intact); 0 CF errors; salesperf CSV clean. Files: `FinancialReport/FinancialReportDashboard.cfm` + `FinancialReportExport.cfm` (play), backup `Jasonsrepairs\...bak-20260710-010423`.
- Export gotcha: Win/Loss export URL = `FinancialReportExport.cfm?mode=salesperf` (view=2 alone → the separate **Invoice Details** report, which has the same drift, out of scope, offered).
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
