---
title: Anomaly-monitor suite
type: project
domain: work
track: 1
status: shipped
tags: [monitor, email-engine, coo, salesperson, ar-collections, brent]
applies: ["[[external-comms-contract]]", "[[dashboard-metric-standards]]", "[[dashboard-auth-gate]]", "[[data-freshness-contract]]"]
links: ["[[rc-03-city-budgets]]", "[[scott-manager-dashboard]]", "[[sales-cockpit]]", "[[gstsreadonly-prod-dsn]]", "[[dashboard-auth-gate]]", "[[prod-backup-chain]]", "[[data-freshness-contract]]", "[[prod-db-access-blocked]]"]
updated: 2026-08-03
---

# Anomaly-monitor suite

## 🟢 2026-08-03 — LIVE-PROD INTERIM PULSE shipped (Skipper unblinded) + prod deploy pkg to Jordan
**Context:** emails dark since 7/25 (below) = Skipper "flying blind." Tonight proved prod is an open read source and split the fix into two tracks.
- **The key distinction (finally clear):** the prod **Revenue-Performance dashboard reads the LIVE prod DB**; only the token'd JSON **endpoint** is stuck on play. So scraping the prod *dashboard* = genuinely live production numbers (NOT the play mirror). The 7/14 revenue-timeout/`flow`-schema blockers below were about repointing *play's* DSN — a different, harder path than just running the endpoint ON prod.
- **Interim LIVE pulse — BUILT + LIVE, Skipper-only** (honors distribution choice **A**): `prod-pulse.js` scrapes the prod dashboard → headline pulse (produced $, tracking-to-goal, TPH productive+true, gap, pace, N/S, volume). Wrapper `run-prod-pulse.sh` → `send-email.js` (defaults to jwade only, no team CC). **Cron: 13:30+14:30 UTC + `--guard-pt-morning`** = one 6:30am PT send year-round (crontab backed up `logs/crontab.bak-*`). Validated to the cent on July (produced $2,078,762.87 · Prod TPH $137.02 · True $132.89 · gap -$121,237 / 94.5%).
  - ⚠️ **Limits:** dashboard exposes the headline only. **Overtime-by-person, contracts, salesperson_jobs still need the JSON endpoint** (wait for deploy). Early-month: the `jobs/hrs` VOLUME line = *scheduled* scope while TPH counts *completed* hrs only — don't read produced÷hrs as TPH until month matures.
- **DEPLOY PKG → Jordan (Skipper forwarded 8/3):** `arbor-stack/anomaly-monitor/deploy-monitordata-prod/` (+ `MonitorData-prod-deploy-20260803.tgz`, md5 `10f2d2b76fd9dd32b5260e6f53883afe`). One read-only `.cfm` + `START-HERE.md` (install to prod `\GSTS\api\`, confirm line-6 `dsn="GSTSREADONLY"` resolves to live prod, verify curl). **Why deploy vs repoint:** on the play box the nightly webroot refresh reverts the DSN back to the play copy (that's why the endpoint still returns play-mirror data despite the "live prod" label — accrued $277,442 matches play to the cent). On the **prod box the prod DSN sticks.** The JSON endpoint is **404 on prod today** (only ever deployed to play) = the real blocker to a pure host-flip.
- ▶️ **FULL-LIVE sequence when Jordan confirms deploy:** drop endpoint on prod → flip `monitor.js` `S.host` play→prod → **un-hold all 3 team crons** → Skipper + team on complete live data → **retire this interim pulse.**
- 📁 `memory/2026-08-03.md` has the full three-way July reconciliation (invoiced $1.738M vs produced $2.079M vs earned $2.18M) + both prod-read paths.

**One-liner:** Nightly email engines off the read-only PLAY endpoint — COO daily report (TPH/OT/revenue-pace/contract burn-down), per-salesperson + Nate rollup, and **AR collections (LIVE, per-rep with property detail)**.
**Status:** 🟢 shipped — COO daily LIVE; AR collections LIVE per-rep; **salesperson pilot preview-only** (`liveEnabled=false`, previews to Jason).

## ⏸️ 2026-07-25 — ALL TEAM-FACING EMAILS HELD (Skipper)
Play was stuck on **7/21 data** ([[prod-backup-chain]]) — no point pushing 5-day-old numbers at the people we're trying to win onto the tools. **Paused 6 cron lines (3 jobs × 2 DST fires):** `run-and-email.sh`, `run-salesperson-live.sh`, `run-nate-rollup.sh` — commented in place with a `# HELD 2026-07-25 …` prefix, nothing deleted (backup `~/crontab.bak-preholdemails-20260725T161427Z`). **Left running** (Skipper-only/internal): bounce + reply watchers, AR weekly, retention scoreboard.
▶️ **TO RESUME:** uncomment when a fresh backup lands, or when the `GSTSREADONLY` grant makes reporting live-prod and independent of the copy chain ([[prod-db-access-blocked]]). **The team is currently getting nothing — this state does not exit itself.**

## 🛠️ 2026-07-25 — AR collections pipeline: 3 defects found, 4 fixes shipped
Skipper asked a simple question — *"is the team getting THIS week's AR data, or a 3-week-old report?"* — and the answer was worse than stale:
- **Dimitry is reliable**: 6 reports, every Monday (6/16 → 7/21). **We produced output twice.** Only 3 xlsx ever saved; `logs/ar-weekly.log` had 2 entries total. **~3 of 6 weekly reports silently lost.**
- **Cause of the losses:** `ar-fetch.js` searched `{seen:false}` — any human opening the inbox, or our own `inbox-recent.js` (downloads bodies → sets `\Seen`), consumed that week.
- 🔴 **Headline defect: AR emails carried NO DATE AT ALL.** `wk` was parsed with `/(\d{2}\.\d{2}\.\d{2})/`, matching Dimitry's *original* attachment name (`AR Aging 07.21.26.xlsx`) but not the name `ar-fetch.js` saves it under (`AR-Aging-2026-07-21.xlsx`). Never matched → `wk=''` → every `(week of …)` silently vanished from subject **and** body.
**Fixes (backups `*.bak-arfix-20260725T162918Z`):** ① date parse handles ISO + legacy · ② staleness guard `MAX_AGE_DAYS=10`, exits non-zero, `--allow-stale` override (tested: 6/30 file refused, "25 days old") · ③ `dateTag()`/`subjTag()` stamp *"— data as of 07/21/26"* on all 5 send paths, `(DATE UNKNOWN)` if unparseable · ④ `ar-fetch.js` now tracks processed reports by **message-id** in `ar-report/ar-fetch-state.json` (seeded with all 6), and `inbox-recent.js` restores the flags it found.
→ generalised into the standard: **[[data-freshness-contract]]**
- ⚠️ Also corrected: the crontab comment said AR was *"PREVIEW to Skipper while piloting"* — it had been `--live` to every rep + Nate + Brent for weeks. **Don't trust a cron comment; trace to the flag.**
**📁 Location:** `arbor-stack/anomaly-monitor/`
**▶️ Resume:** `arbor-stack/anomaly-monitor/CHECKPOINT.md`
**⏭️ NEXT (Skipper, 2026-07-15):** he wants to **change how some numbers in the COO daily email present** (which ones TBD — he'll specify). Report body = `monitor.js` sections 1–4 (Daily Job TPH · Overtime · Monthly Revenue · Municipal burn-down); numbers follow [[dashboard-metric-standards]]. Just fixed the forward-pace 403 → [[dashboard-auth-gate]].

## Applies / uses
- [[external-comms-contract]] — untrusted inbound (reads a play endpoint; watcher ingests Brent's external municipal doc) → validate before trusting.
- [[dashboard-metric-standards]] — the numbers emailed (TPH, revenue pace, contract burn-down) follow the same metric rules as the dashboards; multi-crew TPH reconciles to the penny vs the Production-Day page.
- Data source = read-only endpoint `MonitorData.ReadOnly.cfm` on **PLAY** (token + IP allowlist) — a nightly restore, so it LAGS prod.

## State & flags
- **What's live (daily, both inboxes):** COO report 6:30am PT (`run-and-email.sh`); salesperson + Nate PREVIEWS 6:35am (`run-salesperson-preview.sh`). System crontab, DST-proof, `--guard-pt-morning`.
- **AR collections = LIVE per-rep with property detail** (`ar-report/rep-emails.json` maps reps).
- ⚠️ **brent-citybudgets-check cron** (`brent-citybudgets-check.js`, 9am/3pm PT, Jul 8-20) auto-reconciles Brent's verified municipal doc vs the RC-03 play dashboard, then disables. Feeds [[rc-03-city-budgets]].
- Sender = `gilligan.gsts@gmail.com` (From≠To so it inboxes).
- **Pending go-live:** live-prod data · IT allowlist `gilligan.gsts@gmail.com` on M365 · flip `config.liveEnabled=true`.
- 🐛 **Silent 403 fixed (2026-07-15):** the V1.5 [[dashboard-auth-gate]] (deployed Jul 12) started 403-ing the monitor's UNauthenticated POST to `Dashboard-RevenuePerformance.cfm` → COO email showed *"Forward pace unavailable (HTTP 403)"* for days; same bug in `revenue-block.js` (salesperson + Nate revenue snapshot). Root cause = our own security hardening blocked our own automation. Fix = send the Arbor Helper bot identity `Cookie: ZUserID=376` in `monitor.js` + `revenue-block.js` (verified HTTP 200 + real produced/scheduled figures). Lesson captured: **when you gate a surface, re-authorize every headless fetch of it** → [[dashboard-auth-gate]]. (`m2-revenue.js` = unused legacy, same pattern, left as-is.)
- 🔄 **LIVE-PROD cutover attempt (2026-07-14) — BLOCKED, reverted.** Travis's [[gstsreadonly-prod-dsn]] lets the play endpoint read prod (unblocks the old "deploy to prod" hold). Flipped the endpoint's one `dsn` var → **3/5 feeds work live** (contracts/overtime/tph); **revenue times out** (>120s, likely linked-server) + **salesperson_jobs errors** (`flow.Users` — login lacks the `flow` schema grant). Reverted to `dsn="GSTS"` (emails intact; backups `Jasonsrepairs\MonitorData.ReadOnly.cfm.bak-20260714-pre-golive`). **Note sent** gilligan→Travis+Jordan, cc Jason (grant `db_datareader` on GSTS / ≥`flow` + fix heavy-query timeout); draft `anomaly-monitor/email-travis-jordan-gstsreadonly-DRAFT.txt`. Once cleared → **one-line flip** (proven), relabel emails "live production", send Jason tests.

## Related
- [[rc-03-city-budgets]] — the Brent watcher cron feeds it.
- [[scott-manager-dashboard]] — Garrett's salesperson-email buckets seeded that build's My Jobs view.
