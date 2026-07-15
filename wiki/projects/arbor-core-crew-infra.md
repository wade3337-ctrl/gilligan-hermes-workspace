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
- Scripts: `gemini-ask.py`, `glm-ask.py` / `glm-judge.py` / `glm-worker.py`, `kimi-ask.py` / `kimi-worker.py`, `fable-ask.py`, `_TEMPLATE-ask.py`; **Codex** wrappers `codex-code.sh` (headless code work) + `codex-review.sh` (headless review).

## State & flags
- **Current models (Skipper-locked 2026-07-11, verified live):** gemini → **gemini-3.5-flash** (was 3.1-pro-preview; heavy-reasoner alt via `GEMINI_MODEL=gemini-3.1-pro-preview`) · kimi → **kimi-k2.7** (was k2.6; also updated in `kimi-worker.py` + `_TEMPLATE`) · glm → glm-5.2 · fable → claude-fable-5 · codex → gpt-5.6-sol. All swappable per-call via `GEMINI_MODEL`/`KIMI_MODEL`/`CREW_MODEL` env.
- **Codex = code worker + reviewer (Skipper, 2026-07-11).** Unlike the single-shot API asks (gemini/glm/kimi/fable), Codex is a full agentic CLI (`codex exec`, gpt-5.6-sol) that runs commands + edits files. **Call it in for actual code work**, not just reviews: `codex-code.sh "task"` (workspace-write sandbox, least-privilege to the `CODEX_CD` repo; `CODEX_SANDBOX=read-only` for analysis) — verified writing files 2026-07-11. Reviews: `codex-review.sh` (`codex exec review --uncommitted`, part of the multi-lab panel).
- **⭐ STANDING RULE (Skipper, 2026-07-15, re-emphasized): use Codex to WRITE code, not just analyze/review.** Codex (`codex-code.sh`, gpt-5.6-sol, workspace-write) is the crew's code WRITER — for any real code/SQL/CFM write/refactor/fix, dispatch Codex to author it, then GLM/Gemini review. Don't default to hand-writing code myself or using Codex read-only. `CODEX_SANDBOX=read-only` is the exception (analysis only), not the default.
- ⚠️ **kimi-ask SIGKILLs as a long foreground call** (message preemption) — use glm/gemini, or background kimi.
- **Reporting-design fix:** long crew work runs as **`sessions_spawn` background sub-agents** (survive turn preemption, report through Gilligan).
- Timeouts raised (gemini/kimi 120/180s → 300s + retry).
- **Proven crew work:** multi-lab schema gates (Codex+GLM+Gemini cleared v1.4/v1.6) · V1.5 Auth spec review (Codex APPROVE / GLM cond / Gemini BLOCK-cond → R1–R11) · pricing-plan 4-lab review (unanimous GO-WITH-CHANGES) · One-Stop UI feedback crews (#1 actual-vs-planned, #3 field UX, #4 Risk/TRAQ) · **Gemini 3.1-pro vision landmark-match** powers the legacy-map georeference (`GEMINI_IMAGES=`).

## Related
- [[arbor-core-strategy-foundation]] — pillar 4 (crew) + the "no guesses" build rules.
- [[arbor-core-arbor-ai-system]] — the RUNTIME agent layer (this is the BUILD-TIME crew; keep them distinct).
- [[arbor-core-v15-auth]] — the crew reviewed the auth spec and re-verifies at P2.
- [[arbor-core-onestop-ui]] — crew feedback rounds + the vision-match georeference pipeline.
- **glm-judge DB context (2026-07-15):** its tool-loop queries run via gsql.sh (`-d GSTS` default). For objects in the **Workbench** side-DB (RGC `rgc.*`), run it as `JUDGE_DB=Workbench python3 glm-judge.py` — the env prepends `USE [db];` and tells GLM which DB it's in. Without it the judge searches GSTS, finds nothing, and never reaches a verdict. (Codex-written fix.)
