---
title: claude-local shim spike (Claude Max as Hermes brain via subprocess) — SHELVED
type: project
domain: env
status: SHELVED (works in isolation; not reliable at full tool scale) — background spike
tags: [infra, gilligan, hermes, claude, shim, mcp, spike, agent-runtime]
links: ["[[gilligan-hermes-migration]]", "[[gilligan-pilot-model-setup]]"]
updated: 2026-07-31
---

# 🧪 claude-local shim — drive Claude (Max sub) as Hermes's brain, at zero metered cost

**Goal (Option A / Model 1):** let Gilligan-on-Hermes reason on **Claude via the Max subscription** with
tools, without paying metered API. **Shelved 2026-07-31** — the mechanism works but isn't reliable at
Gilligan's full tool scale. Pilot runs on **gbt** instead → [[gilligan-hermes-migration]].

## The wall that forced a subprocess
- Direct Anthropic **OAuth inference returns HTTP 400** the instant `tools` are attached:
  `anthropic-ratelimit-unified-overage-disabled-reason: org_level_disabled`. **Account-level** overage lock,
  same on opus-4-8/opus-5 — **no header/fingerprint flips it** (tested UA bump, x-app:cli, oauth beta — all
  no-op). OpenClaw works because it uses Anthropic's first-party SDK OAuth path; Hermes hand-rolls it.
- **The official `claude` CLI stays in the Max lane** (issue #15080 "claude-local"). So: drive `claude -p`
  as a subprocess, expose it as an **OpenAI-compatible HTTP shim**, point Gilligan's model at it via
  `provider: custom, base_url`. No core patch, survives Hermes updates, isolated to gilligan.

## What was BUILT (kept at `~/gilligan-hermes/claude-shim/`)
- `server.py` — OpenAI-compat HTTP (`127.0.0.1:8828`). **Model 1:** Hermes sends messages+tool schemas →
  Claude EMITS tool calls (captured from stream-json, returned as OpenAI `tool_calls`) → HERMES executes →
  result fed back next turn. Native Claude tools disabled so it can only call Hermes's tools.
- `mcp_http.py` — always-on HTTP MCP server (`8829`) exposing Hermes tool SCHEMAS to Claude; per-request
  schema keyed by call_id in the URL path.
- `run-shim.sh` + a **systemd --user** service `gilligan-claude-shim.service` (now stopped+disabled).

## Every wall hit + fixed, in order (all empirical)
1. **429 on OAuth token** — Anthropic 429s any token request whose UA starts `claude-code/` (anti-abuse,
   prefix-based). Fixed by the image built 2026-07-04 (`_OAUTH_TOKEN_USER_AGENT="axios/1.7.9"`); built new
   image `hermes-agent:v2026.7.30`.
2. **400 org_level_disabled on inference** — the account overage lock above → the whole reason for the shim.
3. **ARG_MAX** — passing the SOUL/comms system prompt as a CLI arg hit Linux **MAX_ARG_STRLEN ~128KB per
   single argv** (separate from 2MB total) → `Argument list too long`. Fix: prompt via **stdin**, system
   prompt via **`--append-system-prompt-file`**. (Tiny lab prompts fit → passed tests, broke on first real
   turn.)
4. **MCP cold-start race** — fresh per-call stdio MCP spawn was "pending" when Claude reasoned → it NARRATES
   tool use instead of calling. Fixed the spawn with an always-on HTTP MCP server + `MCP_TIMEOUT` + retries.
5. **⛔ THE WALL THAT SHELVED IT — ToolSearch deferral.** With ~28 tools, Claude Code **defers** them and
   forces its internal **`ToolSearch`** discovery step (raw stream-json proved it: `ToolSearch "select:x" →
   "No matching deferred tools found"` → retry → sometimes calls, sometimes narrates). **~40-75%
   single-attempt** success at full scale; **10/10 with 1 tool**. Tool COUNT is the trigger. Nothing cleanly
   disabled it: 4 env vars, stream-json input, blocking MCP handler, tool-count trim — all partial.
6. **Latency trap** — 6-retry brute-force hit 10/10 but a real Telegram turn stacked retries past Hermes's
   **~155s** turn timeout → "Operation interrupted" + flailing. Reliability vs latency: couldn't get both.

## Key facts learned (reusable)
- **Hermes fallback is NOT a permanent pin** — `agent/conversation_loop.py:838`: fallback "re-activates per
  message while the primary is down" = each turn re-tries primary. So a session on the fallback means the
  primary is failing EVERY turn, not "pinned once." (Chased this as a phantom "stuck pin" for an hour.)
- **`claude -p` reads prompt from STDIN**; system prompt file = `--append-system-prompt-file`.
- **`ToolSearch` must be in `--allowedTools`** — it's Claude's tool DISCOVERY; without it Claude can't reach
  mcp tools and narrates. Only capture `mcp__hermes__*`; let ToolSearch run internally.
- **stream-json INPUT mode** (`--input-format stream-json`, feed a `{"type":"user",...}` line) connects MCP
  before reasoning and keeps a **persistent** process warm across turns — fixed latency, not the ToolSearch
  reliability.
- Long-lived 1-yr token: `claude setup-token` → `~/.secrets-gilligan-hermes/claude-code-oauth.env`.

## If revived later — the only unsolved problem
Make Claude reliably call ONE of many tools at full scale. Real options: (a) find/patch the tool-deferral
threshold in Claude Code settings; (b) expose only a small CORE tool subset to Claude (under the defer
threshold) — reliable but fewer tools/turn; (c) a persistent-session + smarter capture. Until then: **gbt**.
