---
title: ENVIRONMENT — MOC
type: index
domain: env
tags: [index, moc, environment, infra]
links: ["[[HOME]]"]
updated: 2026-07-10
---

# 💻 ENVIRONMENT / INFRA — map
Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`. Atomic notes:

- [[gilligan-session-settings]] — 📸 my runtime dials snapshot (Opus 4.8 · 1M context · reasoning/fast off · elevated) + what's adjustable. Re-run `session_status` for live values.
- [[env-host-and-tooling]] — Ubuntu 26.04, Node/Python, headless browser `arbor_browser`, file-reading tools.
- [[crew-llms-and-helpers]] — the 5-lab verification panel + `crew/*-ask.py` helpers + gotchas. **OpenAI = `gpt-5.6-sol`** (default in `~/.codex/config.toml`, needs codex-cli ≥0.144).
- [[herman-agent]] — 👑 Boss Herman container: now has **direct crew API keys** (`/opt/data/home/.secrets/`) + **Crew Meter** durable URL **`https://gilligan.tail5807bd.ts.net/`** (Tailscale Serve, tailnet-only).
- [[play-dev-access]] — SSH to `gstsdatabase`, `gsql.sh`/`view.sh`, PLAY nightly refresh = DB-only.
- [[prod-db-access-blocked]] — DIRECT SQL to prod still blocked; Jordan/AWS security group + IP `76.32.188.157`.
- [[gstsreadonly-prod-dsn]] — **CF DSN `GSTSREADONLY` on play → prod read-only (Travis 2026-07-14)**; works for CF pages (3/5 monitor feeds), grant+perf pending. The daily-email live-prod path.
- [[workbench-play-db]] — side SQL db that survives the nightly GSTS refresh (prototype state).
- [[trimit-db-gotchas]] — dual-webroot shadow (C:\ overrides D:\) + DB-driven menus (AppForms).
- [[email-infrastructure]] — gilligan.gsts sending rules, watchers, ImapFlow uid gotcha.
- [[trimit-web-pull]] — read-only web pull via `gilligan-bot` (UserID 376).
- [[github-offchip-backup]] — nightly off-machine backup + ⏰ PAT rotation ~Sep 15.
- [[disaster-recovery]] — rebuild-from-scratch runbook (`RECOVERY.md`), gpg bundle, USB kit.
- [[herman-agent]] — Arduino companion agent (Herman ≠ decommissioned Hermes laptop).
