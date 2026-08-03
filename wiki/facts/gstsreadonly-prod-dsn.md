---
title: GSTSREADONLY — read-only DSN to PRODUCTION (on play)
type: fact
domain: environment
tags: [trimit, coldfusion, dsn, production, read-only, data-access, travis]
links: ["[[email-infrastructure]]", "[[trimit-stack-and-tph]]", "[[revenue-goal-close]]", "[[prod-db-access-blocked]]", "[[anomaly-monitor-suite]]", "[[trimit-server-topology]]", "[[prod-web-read-access]]"]
updated: 2026-08-03
---

# GSTSREADONLY — read-only DSN to PRODUCTION (on the play server)

> **vs [[prod-db-access-blocked]]:** that note = **direct SQL** to prod from our box (still blocked, AWS/Jordan). THIS = a **CF datasource on play** that reaches prod read-only from inside the allowed network — so CF pages on play can query prod even though our box can't. Same login name, different path.

**Travis Walters (Data Processing, LLC) set this up 2026-07-14** (email "FW: Play Server Update", fwd by Jason). On the **play** ColdFusion server there is now a DSN **`GSTSREADONLY`** that connects to the **production** SQL Server database with a **read-only** login.

- Normal pages use the **`GSTS`** datasource = the **play** copy (nightly-refreshed from prod; can be ~24h stale). `GSTSREADONLY` = **live prod, read-only.**

> ⚠️ **CORRECTION 2026-07-27 — that first bullet was NOT true between ~7/14 and 7/27.** Play's `GSTS` datasource
> was itself pointed at **`198.207.148.168` = PRODUCTION** (proven by a controlled write), so everyone treating
> play as a sandbox was reading live prod data across the lossy Ayera tunnel. `GSTS`+`GSTSAPI` were repointed to
> the play box's own `localhost,14333` on 2026-07-27 (Skipper-authorised) and the bullet is true again.
> **`GSTSREADONLY` is left as the deliberate remote read-only link, and it is scoped to `GSTS` ONLY** — on `.168`
> it cannot open `Workbench` (916) or `ARBORTOOLS`. Full topology + the proof → **[[trimit-server-topology]]**.
> 🔎 **208 vs 916 tells you which problem you have:** 208 = the database/object is **not there**; 916 = it **is
> there and you lack rights**. Deploy vs GRANT.
- Test page: `https://play.greatscotttreeservice.com/zDBTest.cfm` (root, NOT under `/GSTS/`). Verified 2026-07-14: dumps `SELECT TOP 1 * FROM GSTS.dbo.InventoryDetail` from prod. ✅
- Usage: `<cfquery name="x" datasource="GSTSREADONLY">SELECT ... FROM GSTS.dbo.Table</cfquery>`
- **First query is slow (20–30s cold warm-up), then fast.** Don't put it on a hot path uncached; best for specific live lookups.
- Travis explicitly framed it for **"building an AI Assistant that wants to query the production server (read-only)"** → intended for our Arbor AI / dashboard work.

## 🚨 2026-08-03 — the LABEL lies on the play box: it still serves PLAY data
`/GSTS/api/MonitorData.ReadOnly.cfm` line 6 reads `dsn = "GSTSREADONLY"` with the comment *"LIVE PRODUCTION
(Travis read-only DSN, 2026-07-14)"* — **and it still returns play-mirror figures.** Proven by matching a
figure that must differ: accrued **$277,442** ties to the play DB **to the cent**, and its July invoiced
$1.69M sits below prod's $1.74M.
- **Why:** the file lives on the **play box**, and play's **nightly webroot refresh reverts the DSN back to the
  play copy**. The setting doesn't survive the night.
- **On the PROD box the prod DSN sticks** — nothing reverts nightly. **That is why deploying the endpoint to
  prod is the durable fix, not repointing it on play.** The endpoint is **404 on prod today** (only ever
  deployed to play) = the actual blocker to a pure host-flip. Deploy package built → [[anomaly-monitor-suite]].
- 🔑 **Method worth keeping:** a DSN comment is documentation, not instrumentation. Prove which source a page
  reads by pulling one figure that must differ between the candidates (a partial-month accrual, a row count)
  and seeing which it matches to the cent.
- ⚠️ Note this is a *different* problem from the 7/14 cutover below (which was about play's DSN + grants).
  Meanwhile the prod **dashboard** was live-readable the whole time → [[prod-web-read-access]].

## Nuances / when to use
- **Read-only → safe** (no prod-write risk).
- ⚠️ **Play-only side tables are NOT on prod.** The refresh-proof **`Workbench`** DB (SalesGoal, `rgc.*`, DashboardAccess, WorkKanban) lives on the **play** SQL Server. `GSTSREADONLY` reaches **prod's `GSTS`** db only — a page can't 3-part-JOIN across the two different servers. So a dashboard that mixes GSTS operational data + Workbench config (e.g. [[revenue-goal-close]]) can't just swap the DSN; adopting live-prod there needs design.
- Good immediate fit: one-off live figures (inventory, a live customer number) where the ~24h play staleness matters.

## Cutover attempt for the daily emails (2026-07-14) — BLOCKED, reverted
Tried to point the daily-email endpoint (`/GSTS/api/MonitorData.ReadOnly.cfm`, one var `dsn`) at GSTSREADONLY. Result: **3 of 5 metrics work live-prod instantly** (contracts, overtime, tph_day); **2 fail:**
- **salesperson_jobs → hard DB error** ("Error Executing Database Query", ~35s). Query joins `flow.Users` — the read-only login almost certainly lacks the **`flow` schema** grant on prod.
- **revenue → times out** (>120s, never returns). Heavy month-aggregate CTE; likely GSTSREADONLY is a **cross-server/linked** hop that stalls on heavy queries (light ones are fine).
- **Reverted** to `dsn="GSTS"` (play) — verified both feeds return real data again; daily emails intact. Backups: `Jasonsrepairs\MonitorData.ReadOnly.cfm.bak-20260714-pre-golive` (the working GSTS version).
- **Note sent** (from gilligan → Travis + Jordan, cc Jason, 2026-07-14): asks Travis to (a) grant the login `db_datareader` on GSTS (or ≥ SELECT on `flow`), and (b) explain/fix the heavy-query timeout (linked-server?). Draft: `anomaly-monitor/email-travis-jordan-gstsreadonly-DRAFT.txt`.
- **Once Travis clears both → the flip is one line** (proven), then relabel the emails "live production" + send Jason tests. ⚠️ deliverability: gilligan.gsts may hit Jordan's M365 Junk (allowlist still pending).
