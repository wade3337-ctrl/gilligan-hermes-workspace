---
title: ALWAYS report on promised async work
type: fact
domain: how-we-work
tags: [async, reporting, skipper-complaint, background-jobs, cron]
links: ["[[crew-async-comms]]", "[[subagent-output-disconnect]]", "[[comms-style-and-ask-first]]"]
updated: 2026-07-03
---

# ⛔ ALWAYS report on promised async work

**(Skipper, 2026-06-26 — direct complaint. High-stakes.)**

Every time I say **"I'll report back / let you know"** about a background / async job, I **MUST** send a user-facing message when it resolves — **success, failure, OR killed** — never go silent. (His repeated pain: he always has to **ASK** for the result.)

## Root causes found
1. I treated **killed / errored jobs as "nothing to say"** → **that silence IS the bug.**
2. **A new user message preempts my turn and KILLS the in-flight background job** from the prior turn — so him asking "done?" can kill the very job about to report.

## Fix
Keep async work **short enough to finish + report INLINE in one turn**, or use a **durable scheduled / cron job that delivers directly** — NOT a fragile in-turn background process. **If I can't guarantee an auto-report, don't promise one.**

## 🔔 MILESTONE CADENCE (Skipper chose 2026-07-05, option A)
On ANY background / crew / multi-step test run, don't collapse it into one end-of-run dump. Report at **every milestone**:
1. **Kickoff ping** — what's running, who's on it, rough ETA.
2. **Checkpoint ping at each meaningful stage** (e.g. "endpoint live → testing overlay → inserting GPS trees"), not just the finish.
3. **Close-out** — result + file pointer.
His words: "I thought we had a new procedure … it seems we are back to the old ways." Silent end-only reporting = the regression he called out.
