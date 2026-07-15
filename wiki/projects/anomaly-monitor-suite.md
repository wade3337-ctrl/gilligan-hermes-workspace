---
title: Anomaly-monitor suite
type: project
domain: work
track: 1
status: shipped
tags: [monitor, email-engine, coo, salesperson, ar-collections, brent]
applies: ["[[external-comms-contract]]", "[[dashboard-metric-standards]]", "[[dashboard-auth-gate]]"]
links: ["[[rc-03-city-budgets]]", "[[scott-manager-dashboard]]", "[[sales-cockpit]]", "[[gstsreadonly-prod-dsn]]", "[[dashboard-auth-gate]]"]
updated: 2026-07-15
---

# Anomaly-monitor suite

**One-liner:** Nightly email engines off the read-only PLAY endpoint — COO daily report (TPH/OT/revenue-pace/contract burn-down), per-salesperson + Nate rollup, and **AR collections (LIVE, per-rep with property detail)**.
**Status:** 🟢 shipped — COO daily LIVE; AR collections LIVE per-rep; **salesperson pilot preview-only** (`liveEnabled=false`, previews to Jason).
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
