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
