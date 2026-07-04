---
title: Boss Herman does his OWN work — no Gilligan proxy
type: feedback
domain: how-we-work
tags: [boss-herman, arbor-ai-system, architecture, testing, separation-of-concerns, principle]
links: ["[[herman-agent]]", "[[two-track-confidentiality]]"]
updated: 2026-07-04
---

# Boss Herman does his own work — build & test it the way it runs in production

**Skipper principle (2026-07-04):** When a capability is meant to be a **Boss Herman function**, **Boss Herman must perform it himself** — do NOT have Gilligan (or a gilligan-side script/cron) do the work on his behalf, not even during testing.

**Why:** a test where Gilligan proxies the work doesn't prove the *real* thing — it proves Gilligan can do it. Prod = Boss Herman doing it. So the test must exercise Boss Herman's own tools/agency, or it's a false pass. Keep a clean **separation of concerns**: Gilligan builds/wires/verifies the plumbing; the *function itself* runs as Boss Herman.

**How to apply:**
- Email **monitoring/reading/sending** = Boss Herman's own tools (his himalaya + his own scheduled agent turn), NOT a gilligan cron reading his inbox. → the gilligan-side `rfp-watcher.py` was PAUSED 2026-07-04 for exactly this reason; later, inbox monitoring becomes Boss Herman's own function.
- **Browser** = Boss Herman driving his own CDP/browser, not Gilligan fetching pages for him.
- General: when building/testing any arbor-ai-system / Boss Herman feature, ask "in prod, WHO does this?" — and make the test run that way.

**Contrast — still fine for Gilligan:** infra setup, wiring, deploys, read-only verification of Boss Herman's plumbing. The line is: **Gilligan enables; the agent performs.**
