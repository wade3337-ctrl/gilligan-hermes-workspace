---
title: Data-freshness contract — every automated report states its own data date
type: reference
domain: how-we-work
tags: [standard, contract, reporting, email-automation, staleness, trust]
links: ["[[only-trustworthy-data]]", "[[prod-backup-chain]]", "[[anomaly-monitor-suite]]", "[[async-report-rule]]", "[[external-comms-contract]]"]
updated: 2026-07-25
---

# 📅 Data-freshness contract

**Adopted 2026-07-25 after two failures on the same day** — the play reporting emails silently served 4-day-old data ([[prod-backup-chain]]), and the AR collections emails went to reps **with no date on them at all** because a filename rename broke the regex that produced it.

> ## The rule: an automated report must state the date of the data it is built from, and must refuse to send when that data is stale or its date is unknown.

Extends [[only-trustworthy-data]]: it isn't enough that a number be right — the reader must be able to tell *as of when* it was right.

## The four requirements

1. **Stamp the data date on every message** — subject *and* body. Not the send date; the **date of the underlying data**. Include the age where it helps (`data as of 07/21/26, 4d old`).
2. **Fail loudly when the date is unknown.** Emit an explicit `(DATE UNKNOWN)` and refuse to send. **Never let a missing date render as empty string** — silent-empty looks like a design choice and hides the defect indefinitely.
3. **Refuse to send stale data.** Define a max age per report (AR = 10 days) and exit non-zero past it. Provide an explicit `--allow-stale` override so the bypass is a deliberate, visible act.
4. **Alarm on silent absence.** "No input arrived" must page someone. A healthy job with a dead input produces *silence*, and silence is indistinguishable from "nothing to report." Both failures on 7/25 were this shape.

## Anti-patterns (each one bit us for real)
| Anti-pattern | What happened |
|---|---|
| Parsing a date out of a **filename another stage renames** | `ar-fetch.js` saved `AR-Aging-2026-07-21.xlsx`; the monitor still matched `/(\d{2}\.\d{2}\.\d{2})/` (the sender's original `07.21.26`). Never matched → every AR email shipped undated for weeks. |
| Using the IMAP **`\Seen` flag as a work queue** | Any human opening the inbox — or our own `inbox-recent.js`, which downloads bodies — consumed that week's report. **3 of 6 AR reports were lost.** Track processed items in **our own state file keyed by message-id**, and make inbox-listing tools restore the flags they found. |
| Re-using the last input when none arrives | The play restore re-applies the previous backup forever, so staleness is invisible. Prefer **no output over stale output**. |
| Trusting a **cron comment** as a statement of behaviour | The AR line said "PREVIEW to Skipper while piloting"; it had been `--live` to every rep, Nate and Brent for weeks. Trace cron → wrapper → script → the flag that picks recipients. |
| Unknown CLI flags failing **open** | `--dry-run` (real flag: `--dry`) was ignored and the script sent for real. Validate flags, or reject unrecognised ones. |

## Applies to
[[anomaly-monitor-suite]] (daily anomaly, per-salesperson, Nate rollup, AR collections), every dashboard sourced from play, and any future report an agent sends on our behalf.
