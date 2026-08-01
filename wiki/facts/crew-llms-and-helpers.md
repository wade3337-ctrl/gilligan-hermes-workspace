---
title: Crew — LLMs & helper scripts
type: fact
domain: env
tags: [crew, llm, verification, arbor-core, infra]
links: ["[[arbor-core-crew-infra]]", "[[env-host-and-tooling]]", "[[herman-agent]]"]
updated: 2026-07-19
---

# Crew — the cross-model verification panel + helper scripts

**Foreman/primary:** Opus 4.8 (me, Gilligan). **5-lab cross-model panel** (different lab = different blind spots, proven):
Claude Opus · **Codex/Sol `gpt-5.6-sol`** (OpenAI, native tool-runner) · **GLM glm-5.2** (Zhipu) · **Gemini 3.1-pro** (Google) ·
**Kimi k3** (Moonshot; 2.8T MoE, 1M ctx, released 2026-07-16 — upgraded from k2.6/k2.7 on **2026-07-19**). Full recipes/keys/gotchas → `arbor-core/docs/CREW.md` + `CREW-ONBOARDING.md`.

> [!note] **Kimi K3 validation (2026-07-19):** upgraded `crew/kimi-ask.py` default → `k3` (backed up first). Blind-tested vs `gpt-5.6-sol` over 2 rounds (reasoning + a hard non-standard-precedence `calc()` evaluator, 24 hidden cases) — **both 100% both rounds**; K3 matched a top coder single-shot/blind. But K3 runs **~7× slower** (thinking mode) → keep K3 for quality/cross-lab, **route latency-sensitive & agentic coding to Codex.**

> [!important] **OpenAI model = `gpt-5.6-sol` (Skipper pref, 2026-07-10).** The "codex" model *names* are retired (API rejects `gpt-5.6-codex`/`gpt-5.6` on a ChatGPT account). Set as the **default** in `~/.codex/config.toml` (`model = "gpt-5.6-sol"`) — no per-call `-m` needed. Needs **codex-cli ≥ 0.144** (older builds error "requires a newer version of Codex" → `codex update`). Fall back to 5.5 only if 5.6 unavailable. This model earned its keep twice on 2026-07-10 (Steve Win/Loss): adversarially **refuted** a wrong "unrecoverable" call, then **blocked** a naive Fix-2 boundary — see [[sales-rep-attribution]].

> [!note] **Codex heavy-lifting worker (Hermes-Gilligan pilot, 2026-08-01):** the pilot reaches full agentic
> Codex via an ISOLATED sibling container (`codex-worker:2`, has python3+node so Codex can run/test its own
> code). Client `codex-worker.sh <repo> "task"` or `--new <name> "task"` (greenfield, no repo needed).
> **Locked to `gpt-5.6-sol` + high reasoning** — no weaker model may do coding work. Full design/isolation in
> [[gilligan-hermes-migration]] (⭐ CODEX HEAVY-LIFTING section).

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

## Mirrored to the Hermes pilot (2026-08-01)
**Hermes-Gilligan now has the SAME crew** (Skipper's "same privileges" ask). Copied to container
`/opt/data/arbor-core/crew/` with secret paths repointed to `/opt/data/.secrets/`; Fable/Gemini/GLM/Kimi
live-tested, sol = his native brain + Hermes sub-agents. His how-to: `home/workspace/CREW-ACCESS.md`.
Full wiring detail → [[gilligan-hermes-migration]] (Option A parity).
