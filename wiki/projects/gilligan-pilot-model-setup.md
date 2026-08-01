---
title: Gilligan Hermes-pilot — model setup (gbt default · GLM+Kimi callable · MoA trio)
type: project
domain: env
status: LIVE — default gbt; glm-5.2 + kimi-k3 callable; MoA parked
tags: [infra, gilligan, hermes, models, gbt, glm, kimi, moa]
links: ["[[gilligan-hermes-migration]]", "[[claude-local-shim-spike]]", "[[herman-agent]]"]
updated: 2026-07-31
---

# 🧠 Gilligan-on-Hermes — the model lineup

Pilot container `gilligan` (`~/gilligan-hermes/docker-compose.yml`, home `~/.gilligan-hermes:/opt/data`,
Telegram `@Gilligan_gsts_bot`). Config `~/.gilligan-hermes/config.yaml`, keys in its `.env`.

## The lineup
- **Default brain = gbt** — `gpt-5.6-sol` via `openai-codex` (ChatGPT/Codex subscription, flat cost). All
  tools, fast, reliable. `model.default: gpt-5.6-sol / provider: openai-codex`, `fallback_providers: []`.
- **On-demand callable** (primary stays gbt):
  - **GLM 5.2** → built-in provider **`zai`** (key `ZAI_API_KEY`), routes to `api.z.ai/api/coding/paas/v4`.
  - **Kimi K3** → built-in provider **`kimi-coding`** (key `KIMI_API_KEY`), routes to `api.kimi.com/coding`.
  - Both are **coding-plan / subscription** endpoints (same flat-cost style as gbt). ⚠️ The `sk-kimi-`/z.ai
    keys **401 on the PUBLIC Moonshot/z.ai APIs** — they only work via Hermes's built-in providers' internal
    coding endpoints. Do NOT hand-roll the endpoint.
  - Keys were sourced from `~/.secrets/glm.json` + `~/.secrets/kimi.json` → added to gilligan's `.env`.
- **Mixture of Agents (MoA) — parked** (`moa.presets.default`): references = `gpt-5.6-sol`(openai-codex) +
  `glm-5.2`(zai) + `kimi-k3`(kimi-coding); **aggregator = `gpt-5.6-sol`** (the one that acts + holds tools).
  Fire with **`/moa <prompt>`** for a 3-brain panel; "Active in config: off" is correct (only on `/moa`,
  not every turn — it's 3-5x cost/latency). See [[moa-mixture-of-agents]].

## How to switch models (the Skipper's ask: "call them whenever")
- **Model picker / model command** in a Telegram session — GLM models list under **`zai`**, Kimi under
  **`kimi-coding`** (NOT a custom "zai-anthropic" — that was a redundant empty duplicate, removed).
- CLI: `hermes -m glm-5.2 ...` / `-m kimi-k3 ...`. Default (no `-m`) = gbt.
- Correct ids: **`glm-5.2`**, **`kimi-k3`** (kimi-k3-preview/-0925 are NOT valid; `kimi-k2-thinking` works).

## Gotchas baked in (so future-me doesn't re-derive)
- **Model picker "no models under z.ai":** caused by adding a **custom** `zai-anthropic` provider that
  shadowed the **built-in `zai`** (which already has glm-5.2..glm-4.6 in `/opt/data/provider_models_cache.json`).
  Fix = delete the custom block; use built-ins. Herman uses `zai-anthropic` custom; the built-in `zai` works
  fine on this image, so don't copy his custom block.
- **A callable model that shows "no models" in the picker** = the provider's `/v1/models` isn't reachable
  (z.ai Anthropic endpoint has none); the **built-in** providers are pre-populated in the picker cache.
- **`gpt-5.6-sol-pro`** exists in the codex list (higher "Pro" tier of Sol). Before defaulting to it, confirm
  it's covered by the flat subscription vs a pricier tier — NOT verified yet.

## Verification commands (grounded — used this session)
- Route proof: run a turn, then read `session_model_usage` (model → billing_provider → billing_base_url).
- Picker models: `python3 -c "import json;d=json.load(open('/opt/data/provider_models_cache.json'));print(d['zai']['models'])"`.
- MoA preset: `hermes moa list`.
