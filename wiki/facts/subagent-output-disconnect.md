---
title: Sub-agent output disconnect (write-to-file + short pointer)
type: fact
domain: how-we-work
tags: [subagents, sessions-spawn, output, background, fix]
links: ["[[crew-async-comms]]", "[[async-report-rule]]", "[[comms-style-and-ask-first]]"]
updated: 2026-07-03
---

# 🔌 SUB-AGENT OUTPUT DISCONNECT

**(Skipper caught 2026-06-26.)**

A `sessions_spawn` sub-agent's final report **auto-announces straight to the USER's chat but does NOT land in MY (main-session) context** — I get at most a tiny "child done" ping, so when the user asks about it I don't know what posted (once had to dig a blind-spot review off the child's transcript jsonl on disk).

## STANDARD FIX (adopted)
Every background sub-agent must:
1. **WRITE its full output to a file** in the repo, **and**
2. **return only a SHORT pointer** ("done — report at `<path>`"), never a big raw dump.

Then **I read that file and present / digest in MY voice, in MY context** → one coherent Gilligan who knows the result; the user never sorts raw replies.

**Also:** proactively **check for outstanding background output** (subagents list + read the file) **BEFORE answering** anything related.
