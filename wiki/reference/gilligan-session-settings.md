---
title: Gilligan — Session Settings Snapshot
type: reference
domain: environment
updated: 2026-07-29
tags: [settings, config, model, openai, sol, context, session, environment]
links: ["[[env-host-and-tooling]]", "[[crew-llms-and-helpers]]"]
---

# Gilligan — Session Settings Snapshot

> Snapshot of my runtime/session settings, captured **2026-07-11 ~20:47 UTC** at the Skipper's request. These are the live dials; re-run `session_status` for current values (usage numbers drift every turn).

## Model & reasoning
- **Default model as of 2026-07-29:** `openai/gpt-5.6-sol` (alias `sol`) via OpenAI/Codex OAuth.
- **Correct direct Codex CLI call:** `codex --model gpt-5.6-sol ...` (or omit `--model` because `~/.codex/config.toml` already sets `model = "gpt-5.6-sol"`).
- **OpenClaw selectable model ref:** `openai/gpt-5.6-sol`; configured in `~/.openclaw/openclaw.json` under `agents.defaults.models`, and set as `agents.defaults.model.primary`.
- **Reasoning / thinking effort:** **off** (direct-answer mode; toggle `/reasoning`).
- **Fast mode:** **off** (speed boost available on Opus 4.8/4.7/4.6; toggle `/fast`).

## Execution & context
- **Execution mode:** `direct` · **elevated** (fewer permission prompts).
- **Runtime:** OpenClaw Default. **OpenClaw version:** 2026.6.1 (2e08f0f).
- **Context window:** **1.0M tokens.** At snapshot: 215k used (20%), **0 compactions**, cache 100% hit.
- **Queue:** steer (depth 0).

## The adjustable dials (quick reference)
- **Per-session (cheap, reversible):** model (opus48 / sonnet / haiku) · reasoning on-off · fast on-off · verbose · elevated/execution mode.
- **Durable config (`openclaw.json`, back-up + merge-patch, never clobber):** models & routing · channels · heartbeat cadence · cron/scheduled jobs · memory · permissions/allowlists · tools policy.

## Notes
- Aliases: `sol` = openai/gpt-5.6-sol · `opus48` = anthropic/claude-opus-4-8 · `sonnet` = anthropic/claude-sonnet-4-6.
- Runtime verification 2026-07-29: `codex debug models` listed slug `gpt-5.6-sol` / display `GPT-5.6-Sol`; `openclaw models status --plain` returned `openai/gpt-5.6-sol`; Discord picker recent list puts it first for the Skipper DM.
- Knowledge cutoff: **January 2026** — newer facts require live lookup.
- To change a dial I can set it directly (e.g. model via `session_status`); config-file edits go through the `gateway` tool (backup + merge-patch).

## 🔎 Reading the `/status` card — four independent axes on one line (2026-07-25)
`⚙️ Execution: direct · Runtime: OpenClaw Default · Think: off · Fast: off · Reasoning: on · elevated`

| Field | Command | What it actually controls |
|---|---|---|
| `Think:` | `/think` | **Thinking EFFORT** (off/low/medium/high/max). Sent to the Claude CLI backend as `--effort`. |
| `Reasoning:` | `/reasoning` | **Visibility only** — whether the thinking is shown. Appears on the card only when ON. |
| `Fast:` | `/fast` | Faster output on Opus (not a smaller model). |
| `elevated` | `/elevated` | **Tool/command PERMISSIONS.** Nothing to do with reasoning — it just sits next to it on the line and reads as "reasoning elevated". |

**Thinking resolution order** (`docs/tools/thinking.md`): inline directive → **session override** → per-agent default → `agents.defaults.thinkingDefault` → fallback (**medium** for reasoning-capable models).
- ⚠️ Config defaults govern **new** sessions; a long-running session can sit on the fallback (`medium`) while config says `high`.
- ✅ Authoritative check: send **`/think`** alone. `/think high` pins the session; `/think default` clears the override and inherits config.
- 🤖 **Spawned sub-agents and cron jobs resolve their own level** — fresh sessions, so they inherit `agents.defaults.thinkingDefault` (currently `high`) regardless of what the main session is on. Claude Code `Agent`-tool sub-agents instead inherit the **parent's** resolved model.

### 🎚️ Standing preference: thinking = `high` (re-confirmed 2026-07-25)
- `agents.defaults.thinkingDefault: "high"` (= OpenClaw's "ultrathink"). Applies to **all new sessions, crons and spawned sub-agents**.
- ✅ **`high` is a CEILING, not a floor** — a budget the model *may* use, not one it must spend. A trivial question doesn't burn max reasoning just because the ceiling is high. That is what makes `high` a low-regret everyday default rather than a blanket cost.
- ⚠️ **A long-running session can be stranded below it** (this one sat on the `medium` fallback all day). Fix must come **from the Skipper** — thinking directives are stripped before I see them, so I cannot set my own level. He sends `/think high` (pin) or `/think default` (inherit config).
- 🧭 Counterweight worth keeping: thinking improves *reasoning*, not *facts*. The two best catches of 2026-07-25 (the dead backup chain, the undated AR emails) came from **running a query** and **testing a regex** — verification, not deliberation. → [[data-freshness-contract]]
