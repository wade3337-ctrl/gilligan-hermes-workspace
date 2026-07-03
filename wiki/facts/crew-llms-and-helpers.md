---
title: Crew — LLMs & helper scripts
type: fact
domain: env
tags: [crew, llm, verification, arbor-core, infra]
links: ["[[arbor-core-crew-infra]]", "[[env-host-and-tooling]]"]
updated: 2026-07-02
---

# Crew — the cross-model verification panel + helper scripts

**Foreman/primary:** Opus 4.8 (me, Gilligan). **5-lab cross-model panel** (different lab = different blind spots, proven):
Claude Opus · **Codex gpt-5.5** (OpenAI, native tool-runner) · **GLM glm-5.2** (Zhipu) · **Gemini 3.1-pro** (Google) ·
**Kimi k2.6** (Moonshot). Full recipes/keys/gotchas → `arbor-core/docs/CREW.md` + `CREW-ONBOARDING.md`.

## How to call
- Direct-API helpers `~/arbor-core/crew/*-ask.py` — single-shot, **feed evidence inline** (agentic CLIs are unstable here).
- `glm-worker.py` = cheap file-editing producer tier. Helpers default **temp 0** (`CREW_TEMP` overrides).
- Also Ollama `llama3.2:3b` (local, backs web search).

## ⚠️ Gotchas (learned)
- **kimi-ask `max_tokens`=40000** — K2 reasoning starves the answer below that; kimi SIGKILLs on long *foreground* calls → run bg or use glm/gemini.
- **gemini/kimi-ask timeouts = 300s + retry** (120/180s was too short → silent TimeoutError).
- **gemini-ask.py arg bug:** sends `argv[1]` as the prompt — call via pure stdin, no positional arg. (see [[LESSONS]])
- Keys `~/.secrets/*.json` (0600, **NOT** backed up; several were Discord-pasted → **ROTATE**).

## Run pattern
Run crew gates **foreground, in-turn** so both the Skipper and I see the result → [[crew-async-comms]].
