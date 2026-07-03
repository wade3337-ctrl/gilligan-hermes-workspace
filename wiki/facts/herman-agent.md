---
title: Boss Herman (container) vs Herman (Arduino) — the two agents
type: fact
domain: env
tags: [infra, boss-herman, herman, hermes, agent, arduino, container]
links: ["[[crew-llms-and-helpers]]", "[[env-host-and-tooling]]"]
updated: 2026-07-02
---

# 🤖 Two distinct agents — name them right (Skipper, 2026-07-02)

## 👑 Boss Herman — the AI boss (`hermes` Docker container on jdog1)
The one with the TRIM IT + arbor knowledge and live DB access. **Call it "Boss Herman."**
- **Framework:** runs **Hermes** — the Arbor AI agent framework/runtime he IS the brain of (image `hermes-agent`, `config.yaml`, `delegate_task` + maturity-phase system). **NOT OpenClaw.** (Gilligan runs OpenClaw — different software; same-family only in that we're both Claude-brained assistants for the Skipper.)
- **Where:** Docker container `hermes` on our box **jdog1**, `net=host` → it shares gilligan's Tailscale IP `100.82.161.7` (that's why the IPs match; NOT a bug). Runs as uid 1000 `hermes`, **HOME=`/opt/data`**, cwd `/opt/hermes`.
- **I reach it directly via `docker exec [-u hermes] hermes …`** (I'm in the `docker` group) — no SSH, no key relay. Logs: `docker logs hermes`. Config: `/opt/data/config.yaml` + `/opt/data/.env`.
- **Brain:** primary = GLM `glm-5` via z.ai Anthropic-compat endpoint (`https://api.z.ai/api/anthropic`, subscription, switched 2026-06-30). **Fallback = Codex `gpt-5.5`** — auto-fails-over when z.ai errors/overloads (the 2026-07-02 crash cause). **Wired by Boss Herman himself 2026-07-03 (verified), PROVEN by a live failover test** (primary pointed at a dead addr → log `Fallback activated: glm-5 → gpt-5.5 (openai-codex)` → Codex answered → primary restored).
  - **KEY LESSON (Gilligan's first attempt failed here):** the Hermes `openai-codex` fallback provider needs the ChatGPT OAuth registered in **Hermes's OWN credential store** (`hermes auth add openai-codex`, device-code flow → `hermes auth list` shows `openai-codex-oauth-1`), + `fallback_providers: [{provider: openai-codex, model: gpt-5.5}]` in `/opt/data/config.yaml`. **TWO separate auths:** the Codex CLI login (`/opt/data/.codex/auth.json`, for standalone `codex exec` tool) is NOT the same as the Hermes store credential (for the failover BRAIN) — both use the same ChatGPT sub. Copying the CLI login alone does NOT wire the fallback.
  - Failover latency ~3.5min on dead-host connection timeouts; near-instant on 429/5xx (z.ai's typical 529 = fast failover). Tunable via retry count.
  - ⚠️ **Fragility:** codex CLI + Hermes creds live in the container FS — survive `docker restart` (verified) but a container **RECREATE/image-rebuild wipes them** → re-register (future: bake into image/volume). Crew "Codex" on gilligan = same tool via `~/.codex` (CLI + ChatGPT login, NOT an API key — no codex.json in `.secrets/`).
- **Channel:** Telegram "Boss Hermes", locked to the Skipper only.
- **Knowledge:** both vaults at `/opt/data/home/{trimit-knowledge,arbor-knowledge}` — **auto-refreshed every 2h** by `~/herman-gateway/refresh-herman-vaults.sh` (wade3337 cron, `docker cp`). Update the vault on our side → Boss Herman gets it.
- **Live read-only DB:** `/opt/data/home/trimit-query.sh` (pipe SQL) → key `/opt/data/.ssh/gilligan_access` → gilligan's forced-command gateway → `HermanRO` (db_datareader, play, ~24h behind). Cannot write. (KB repos: `wade3337-ctrl/trimit-knowledge` + `/arbor-knowledge`; local `~/trimit-knowledge`, `~/arbor-knowledge`.)

## 🔌 Herman — the Arduino field companion (separate machine)
- **Herman** = companion agent on the **Arduino board** (`herman@100.121.177.31`, rrsync-only key → `~/herman-store/`), the portable field assistant. Specs: `arbor-stack/herman-agent-specs.md`.

## 💾 Hermes LAPTOP (`desktop-4v2p8at`) — DECOMMISSIONED 2026-06-23 (historical)
- Removed after the GLM-brain experiment dead-ended; failover moot; `~/laptop-store/` + `~/.ssh/laptop_hermes_ed25519` dead; laptop z.ai key REVOKED. Detail: `memory/2026-06-19-2302.md`.

**Three names, don't mix:** 👑 **Boss Herman** (container, the AI boss) · 🔌 **Herman** (Arduino field companion) · 💾 Hermes laptop (dead).

## Related
- [[crew-llms-and-helpers]] — the LLM crew (distinct from these agents).
