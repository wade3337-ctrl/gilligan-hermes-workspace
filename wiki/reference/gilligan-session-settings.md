---
title: Gilligan — Session Settings Snapshot
type: reference
domain: environment
updated: 2026-07-11
tags: [settings, config, model, opus, context, session, environment]
links: ["[[env-host-and-tooling]]", "[[crew-llms-and-helpers]]"]
---

# Gilligan — Session Settings Snapshot

> Snapshot of my runtime/session settings, captured **2026-07-11 ~20:47 UTC** at the Skipper's request. These are the live dials; re-run `session_status` for current values (usage numbers drift every turn).

## Model & reasoning
- **Model:** `claude-cli/claude-opus-4-8` (Opus 4.8 — Anthropic flagship). Auth: token (anthropic:manual).
- **Default model:** `anthropic/claude-opus-4-8`.
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
- Aliases: `opus48` = anthropic/claude-opus-4-8 · `sonnet` = anthropic/claude-sonnet-4-6.
- OpenAI/Codex calls default to `gpt-5.6-sol` (crew code+review).
- Knowledge cutoff: **January 2026** — newer facts require live lookup.
- To change a dial I can set it directly (e.g. model via `session_status`); config-file edits go through the `gateway` tool (backup + merge-patch).
