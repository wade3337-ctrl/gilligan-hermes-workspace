---
title: ENVIRONMENT — MOC
type: index
domain: env
tags: [index, moc, environment, infra]
links: ["[[HOME]]"]
updated: 2026-07-30
---

# 💻 ENVIRONMENT / INFRA — map
Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`. Atomic notes:

- [[gilligan-session-settings]] — 📸 my runtime dials snapshot. **⭐ Current: default = `anthropic/claude-opus-5`, thinking `high`, OpenClaw 2026.7.1-2; `sol` = `openai/gpt-5.6-sol` (NOT `codex/`) and is verified working.** Re-run `session_status` for live values.
- [[openclaw-plugin-install-trust-gate]] — 🔌 **after ANY OpenClaw core update, check the gateway log for `failed during register`.** A stale row in the plugin install index un-trusts other plugins → `openSyncKeyedStore` undefined → crashed turns + "couldn't safely resume" messages. The *"conflicting plugin install metadata"* doctor notice IS the bug, not noise. Fix + one-command diagnostic in the note.
- [[env-host-and-tooling]] — Ubuntu 26.04, Node/Python, headless browser `arbor_browser`, file-reading tools.
- [[crew-llms-and-helpers]] — the 5-lab verification panel + `crew/*-ask.py` helpers + gotchas. **OpenAI = `gpt-5.6-sol`** (default in `~/.codex/config.toml`, needs codex-cli ≥0.144).
- [[herman-agent]] — 👑 Boss Herman container: now has **direct crew API keys** (`/opt/data/home/.secrets/`) + **Crew Meter** durable URL **`https://gilligan.tail5807bd.ts.net/`** (Tailscale Serve, tailnet-only).
- [[play-dev-access]] — SSH to `gstsdatabase`, `gsql.sh`/`view.sh`, PLAY nightly refresh = DB-only.
- [[play-gsts-is-ephemeral]] — 🧨 the `GSTS` db on play is SCRATCH; the restore erases whole projects. Durable work → `Workbench` + an idempotent replay script.
- [[prod-backup-chain]] — prod→play backups **fail ~weekly**; play silently re-restores a stale file. Check `restorehistory` before trusting any play number.
- [[prod-db-access-blocked]] — DIRECT SQL to prod still blocked; Jordan/AWS security group + IP `76.32.188.157`.
- [[gstsreadonly-prod-dsn]] — **CF DSN `GSTSREADONLY` on play → prod read-only (Travis 2026-07-14)**; works for CF pages (3/5 monitor feeds), grant+perf pending. The daily-email live-prod path.
- [[workbench-play-db]] — side SQL db that survives the nightly GSTS refresh (prototype state).
- [[trimit-db-gotchas]] — dual-webroot shadow (C:\ overrides D:\) + DB-driven menus (AppForms).
- [[gstscalendars-stale-cache]] — accounting's daily production report reads a CACHED day total that only refreshes when a human clicks "Update". Stale by $17,281 in July 2026. The dashboard is the accurate one.
- [[email-infrastructure]] — gilligan.gsts sending rules, watchers, ImapFlow uid gotcha.
- [[trimit-web-pull]] — read-only web pull via `gilligan-bot` (UserID 376).
- [[github-offchip-backup]] — nightly off-machine backup + ⏰ PAT rotation ~Sep 15.
- [[disaster-recovery]] — rebuild-from-scratch runbook (`RECOVERY.md`), gpg bundle, USB kit.
- [[herman-agent]] — Arduino companion agent (Herman ≠ decommissioned Hermes laptop).
- [[kling-ai]] — 🎬 video/image generation (`kling/kling_gen.py`, key `~/.secrets/kling.json`); two-wallet gotcha (sub ≠ API prepaid pack); ffmpeg compress for Discord's 8MB cap.
- [[herman-trimit-login]] — Boss Herman's TRIM IT (play) web login.
- [[trimit-server-topology]] — which box is which; **my analysis runs on a daily prod restore (isolated); the play WEBSITE uses a different DB (198.207.148.168)**; the 21s connect blackhole.
- [[play-box-wedge-signature]] — 🔴 play box froze hard 5.5h on 2026-07-27 (Jordan hard-rebooted; **cause undiagnosed**). **Fast TCP connect + ZERO bytes = frozen, NOT down**; an **empty event log** is the tell. If it recurs: IPMI SEL + screenshot before power-cycling. **Travis holds the Nocix account — get the Skipper added.**
