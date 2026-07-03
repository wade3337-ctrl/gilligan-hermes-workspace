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
- **Brain:** primary = GLM `gpt` via z.ai Anthropic-compat endpoint (`https://api.z.ai/api/anthropic`, subscription, switched 2026-06-30). **Fallback = Codex** (`config.yaml` → `fallback_providers: [{provider: openai-codex, model: gpt-5.5}]`, wired 2026-07-03) — auto-fails-over if z.ai errors/overloads (the 2026-07-02 crash cause). Codex authed by the **ChatGPT OAuth login copied to `/opt/data/.codex/auth.json`**; codex CLI 0.135.0 `npm i -g`'d into the container. ⚠️ **Fragility:** the codex CLI + login live in the container FS — they survive `docker restart` (verified) but a container **RECREATE/image-rebuild would wipe them** → re-install (future: bake into the image or a mounted volume). Crew "Codex" = same tool via `~/.codex` on gilligan (CLI + ChatGPT login, NOT an API key — that's why there's no codex.json in `.secrets/`).
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
