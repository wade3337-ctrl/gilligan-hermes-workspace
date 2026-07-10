---
title: Crew — LLMs & helper scripts
type: fact
domain: env
tags: [crew, llm, verification, arbor-core, infra]
links: ["[[arbor-core-crew-infra]]", "[[env-host-and-tooling]]", "[[herman-agent]]"]
updated: 2026-07-10
---

# Crew — the cross-model verification panel + helper scripts

**Foreman/primary:** Opus 4.8 (me, Gilligan). **5-lab cross-model panel** (different lab = different blind spots, proven):
Claude Opus · **Codex/Sol `gpt-5.6-sol`** (OpenAI, native tool-runner) · **GLM glm-5.2** (Zhipu) · **Gemini 3.1-pro** (Google) ·
**Kimi k2.6** (Moonshot). Full recipes/keys/gotchas → `arbor-core/docs/CREW.md` + `CREW-ONBOARDING.md`.

> [!important] **OpenAI model = `gpt-5.6-sol` (Skipper pref, 2026-07-10).** The "codex" model *names* are retired (API rejects `gpt-5.6-codex`/`gpt-5.6` on a ChatGPT account). Set as the **default** in `~/.codex/config.toml` (`model = "gpt-5.6-sol"`) — no per-call `-m` needed. Needs **codex-cli ≥ 0.144** (older builds error "requires a newer version of Codex" → `codex update`). Fall back to 5.5 only if 5.6 unavailable. This model earned its keep twice on 2026-07-10 (Steve Win/Loss): adversarially **refuted** a wrong "unrecoverable" call, then **blocked** a naive Fix-2 boundary — see [[sales-rep-attribution]].

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
