---
title: arbor-core — Crew model integration
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, crew, ai-models, gemini, kimi, glm, confidential]
applies: []
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-arbor-ai-system]]", "[[arbor-core-v15-auth]]", "[[arbor-core-onestop-ui]]"]
updated: 2026-07-03
---

# arbor-core — Crew model integration

**One-liner:** The build-time agent crew — `gemini/kimi/glm` (+ fable) ask/worker/judge scripts — that Gilligan (foreman) orchestrates as scoped, fact-grounded, verified sub-agents to build arbor-core WITH a crew. This is the **how we build** layer (distinct from the runtime Hermes agents).
**Status:** 🔵 active — the crew is the working muscle across every arbor-core session (multi-lab reviews, backtests, georeference vision-match).
**📁 Location:** `arbor-core/crew/`
**▶️ Resume:** `arbor-core/crew/` + `arbor-core/CHECKPOINT.md`

## Applies / uses
- Strategy pillar 4 (build it WITH a crew) + the crew rules "no guesses, based in facts" — every claim cites a real source; verification gate before anything counts; Skipper sign-off on decisions + money-critical code; scoped task-packets (least-privilege).
- Scripts: `gemini-ask.py`, `glm-ask.py` / `glm-judge.py` / `glm-worker.py`, `kimi-ask.py` / `kimi-worker.py`, `fable-ask.py`, `_TEMPLATE-ask.py`.

## State & flags
- ⚠️ **kimi-ask SIGKILLs as a long foreground call** (message preemption) — use glm/gemini, or background kimi.
- **Reporting-design fix:** long crew work runs as **`sessions_spawn` background sub-agents** (survive turn preemption, report through Gilligan).
- Timeouts raised (gemini/kimi 120/180s → 300s + retry).
- **Proven crew work:** multi-lab schema gates (Codex+GLM+Gemini cleared v1.4/v1.6) · V1.5 Auth spec review (Codex APPROVE / GLM cond / Gemini BLOCK-cond → R1–R11) · pricing-plan 4-lab review (unanimous GO-WITH-CHANGES) · One-Stop UI feedback crews (#1 actual-vs-planned, #3 field UX, #4 Risk/TRAQ) · **Gemini 3.1-pro vision landmark-match** powers the legacy-map georeference (`GEMINI_IMAGES=`).

## Related
- [[arbor-core-strategy-foundation]] — pillar 4 (crew) + the "no guesses" build rules.
- [[arbor-core-arbor-ai-system]] — the RUNTIME agent layer (this is the BUILD-TIME crew; keep them distinct).
- [[arbor-core-v15-auth]] — the crew reviewed the auth spec and re-verifies at P2.
- [[arbor-core-onestop-ui]] — crew feedback rounds + the vision-match georeference pipeline.
