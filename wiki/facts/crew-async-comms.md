---
title: Crew / async comms — run gates foreground, in-turn
type: fact
domain: how-we-work
tags: [crew, async, comms, foreground, subagents, verification]
links: ["[[crew-llms-and-helpers]]", "[[subagent-output-disconnect]]", "[[async-report-rule]]"]
updated: 2026-07-03
---

# 🛰️ CREW / ASYNC COMMS — run crew gates FOREGROUND, IN-TURN

**(Skipper, 2026-06-28; proven.)**

The visibility trap:
- **Background-shell runs** = **I** see the result but the **SKIPPER doesn't** (report doesn't push to his chat).
- **`sessions_spawn` sub-agents** = **he** sees it but **I** don't (output never lands in my context).
- **Foreground in-turn = BOTH see it** (result is a normal reply + in my context).

## Rule
Run the crew **blocking, in the same turn**, and report there. **Finish line = he confirms he got it; if a result never lands, re-send.** Very-long runs may still auto-background → **chunk into in-turn pieces.**

Use the crew **LIBERALLY** (his call — it gets us right the first time).
