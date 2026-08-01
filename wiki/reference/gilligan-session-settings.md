---
title: Gilligan — Session Settings Snapshot
type: reference
domain: environment
updated: 2026-07-31
tags: [settings, config, model, openai, sol, context, session, environment]
links: ["[[env-host-and-tooling]]", "[[crew-llms-and-helpers]]", "[[openclaw-plugin-install-trust-gate]]", "[[gilligan-hermes-migration]]"]
---

# Gilligan — Session Settings Snapshot

> 🚚 **These dials describe the OpenClaw runtime, which is now the one being migrated FROM.**
> A Hermes pilot of me is standing by — different brain config, different channel (Telegram), same
> identity files. → **[[gilligan-hermes-migration]]**

> Snapshot of my runtime/session settings, captured **2026-07-11 ~20:47 UTC** at the Skipper's request. These are the live dials; re-run `session_status` for current values (usage numbers drift every turn).

## Model & reasoning — ⭐ CURRENT as of 2026-07-30 03:00 UTC
- **Default model (`model.primary`): `anthropic/claude-opus-5`** — set back to Opus 5 at the Skipper's request 2026-07-30 02:29 UTC (it had been flipped to `openai/gpt-5.6-sol` earlier that night). Backup: `~/.openclaw/openclaw.json.bak-preopus5switch-20260730-022912`.
- **`agents.defaults.thinkingDefault: "high"`** — unchanged, standing preference.
- ✅ **GPT-5.6 Sol WORKS and is the `openai/` ref, not the `codex/` one.** Allowlisted as
  **`openai/gpt-5.6-sol`** with alias **`sol`**. Verified live this session:
  `openclaw infer model run --gateway --model sol --prompt "Reply with exactly: SOL_OK"`
  → `provider: openai · model: gpt-5.6-sol · SOL_OK`.
- ⚠️ **`codex/gpt-5.6-sol` returns *"Model override not allowed for agent main"* — that is the
  allowlist working as intended, NOT a fault.** The `codex/` route may inspect fine via the Codex
  app-server catalog but can fail on run; the `openai/` route is the one that actually runs. Both
  rows appear in `openclaw models list`; only the `openai/` one is configured.
- **Reasoning visibility:** `stream`. **Fast mode:** off.

## 💳 Auth & billing — subscription, NOT metered API (verified 2026-07-30)
**The Skipper is on his Claude SUBSCRIPTION. The `2026.7.1-2` upgrade changed the ROUTE, not the wallet.**
- Active profile: **`anthropic:manual`, `mode=token`, `oauth=0`** — credential prefix **`sk-ant-oat…`** (an OAuth *subscription* token from `claude setup-token`), **expires in ~334d**.
- A metered pay-as-you-go key looks like **`sk-ant-api…`** and does not carry that kind of expiry. Check with **`openclaw models status`**.
- ⚠️ **Do NOT infer billing from a cron run's `provider:` field.** Runs through 2026-07-29 recorded `provider: "claude-cli"`; runs from 2026-07-30 record `provider: "anthropic"`. That is only the transport — the `claude-cli` OAuth profile is now **expired (0m)**, so the same subscription token goes straight to `api.anthropic.com`. I misreported this to him as "we're on API now"; he was right to push back.
- 🔻 **Why the `Overloaded` (HTTP 529) bursts appeared now:** per `docs/providers/anthropic.md`, `service_tier` **only applies to direct API-key requests — OAuth/subscription-token requests never get one**, so subscription traffic has no priority lever when Anthropic sheds load. The old `claude-cli` path also absorbed those retries invisibly. Same weather, umbrella gone.
- 🧯 **`Fallbacks (0)` at the config level** — a single transient 529 kills a job outright. The nightly wiki-distill cron now carries an explicit `fallbacks: ["anthropic/claude-sonnet-5"]` and `timeoutSeconds: 600` (was 360, while real runtimes were 200–308s and had already blown it three times).

## Execution & context
- **Execution mode:** `direct` · **elevated** (fewer permission prompts).
- **Runtime:** OpenClaw Default. **OpenClaw version:** **2026.7.1-2 (0790d9f)** — CLI and gateway matched.
- **Context window:** **1.0M tokens.**
- **Queue:** steer (depth 0).

## ⚠️ Restarting the gateway from inside a session kills that session's turn
If I run `openclaw gateway restart` (or anything that trips a restart) **from an exec call**, I am
running *inside* the gateway — my own turn is torn down and the Skipper sees:
> *"I was interrupted by a gateway restart and couldn't safely resume the previous turn."*

That message is **self-inflicted, not a new fault**. Expect it, and tell him so rather than letting
it read as another crash. The exec call also returns `Command aborted by signal SIGTERM` — also
expected. Re-check with `openclaw gateway status` after ~20–30s.

## The adjustable dials (quick reference)
- **Per-session (cheap, reversible):** model (opus48 / sonnet / haiku) · reasoning on-off · fast on-off · verbose · elevated/execution mode.
- **Durable config (`openclaw.json`, back-up + merge-patch, never clobber):** models & routing · channels · heartbeat cadence · cron/scheduled jobs · memory · permissions/allowlists · tools policy.

## Notes
- Aliases (live, `openclaw models status` 2026-07-30): `opus48` = anthropic/claude-opus-4-8 · `opus5` = anthropic/claude-opus-5 · **`sonnet` = anthropic/claude-sonnet-5** · **`sol` = openai/gpt-5.6-sol** (the `openai/` ref runs; the `codex/` ref is refused by the allowlist, by design — see above).
- Runtime verification 2026-07-30: `codex debug models` lists slug `gpt-5.6-sol` / display `GPT-5.6-Sol`; `openclaw models status` allows `codex/gpt-5.6-sol`; live gateway call fails on `codex-cli 0.144.1` with `requires a newer version of Codex`. `openclaw update --dry-run` targets OpenClaw `2026.7.1-2`.
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
