---
title: Comms style + ask before acting
type: fact
domain: how-we-work
tags: [comms, ask-first, style, subagents, status, teaching]
links: ["[[phone-friendly-emails]]", "[[async-report-rule]]", "[[subagent-output-disconnect]]", "[[crew-async-comms]]"]
updated: 2026-07-03
---

# 🗣️ Comms style + ask before acting

## Ask before acting
- **Ask before acting** on anything non-trivial.
- **Surface findings** so the Skipper learns; **teach the *why***.
- **Bullets > prose.**
- **ONE question at a time** (also in `USER.md`).

## Don't drown the user in subagent noise
**Lesson `[[subagent-completion-noise]]`:** don't let background / inter-session chatter drown the user — **surface real status, never go silent through direct questions.**

## Status signal on every message (Skipper feedback, 2026-07-04)
**Why:** Skipper couldn't tell when a process was done vs still running, and had to ping to find out — and feared messaging would interrupt a running job.
**How to apply — end substantive replies with one explicit status:**
- 🟢 **DONE — your move** (nothing running).
- ⏳ **WORKING — background job running; I'll ping when it lands** (he can walk away; completion auto-wakes me and I report unprompted).
- ⏸️ **WAITING ON YOU — need [X]; ping me when ready** (I'm idle/blocked on him or an external party like B. Claude, whose replies only reach me via him).
**Key rules:**
- NEVER say "I'll report back" when I'm actually blocked on the Skipper/external — say "ping me when you have X."
- Default to running long work as a **background task** so my turns stay short (a foreground turn CAN be aborted if he messages mid-run) AND completion auto-notifies me → proactive report.
- Reassure: **messaging me does NOT kill a detached background job**; "status?" is always safe to ask.

### ⚠️ Honesty on the ⏳ auto-ping (Skipper pushback 2026-07-04 — "we tried this before and you wouldn't know")
- The auto-wake is REAL but ONLY for **harness-tracked background tasks** (Bash `run_in_background` / the auto-backgrounded kind that returns a task id). PROVEN 2026-07-04: the webroot sweep sent a `task-notification` on completion and I resumed from it.
- It does NOT fire for **detached/fire-and-forget** OS processes (`nohup &`), nor for crons/sub-agents that report into a DIFFERENT session — that's why past "background" promises silently failed.
- RULE: only say **⏳ I'll ping you** when the job is launched as a tracked background task. Otherwise mark **⏸️** (Skipper must prompt). Never overpromise an auto-ping I can't back.
- BACKSTOP for long/important waits: set a **ScheduleWakeup** (self-timer) to re-check + report, so I return on my own even if the notification flakes — no reliance on the Skipper pinging.

### ✅ Proven proactive-delivery path (2026-07-04 — after the wake-turn + announce both failed)
The reliable way to make a ⏳ message actually LAND in the Skipper's Discord: schedule a cron `sessionTarget:main` + `sessionKey:agent:main:discord:direct:1301226640130445323` + `systemEvent` + `delivery:none`. That routes to the DM (proven). The two that FAILED: (a) a plain background-task-completion wake produced output that didn't reach Discord; (b) `isolated`+`announce`+`to:<userId>` → "Unknown Channel" (user id ≠ channel id). So: when I promise ⏳, deliver the ping through the cron-to-main-DM path, not the announce path.
