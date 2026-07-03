---
title: ENVIRONMENT — MOC
type: index
domain: env
tags: [index, moc, environment, infra]
links: ["[[HOME]]"]
updated: 2026-07-02
---

# 💻 ENVIRONMENT / INFRA — map
Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`. Atomic notes:

- [[env-host-and-tooling]] — Ubuntu 26.04, Node/Python, headless browser `arbor_browser`, file-reading tools.
- [[crew-llms-and-helpers]] — the 5-lab verification panel + `crew/*-ask.py` helpers + gotchas.
- [[play-dev-access]] — SSH to `gstsdatabase`, `gsql.sh`/`view.sh`, PLAY nightly refresh = DB-only.
- [[prod-db-access-blocked]] — GSTSREADONLY blocked; Jordan/AWS security group + IP `76.32.188.157`.
- [[workbench-play-db]] — side SQL db that survives the nightly GSTS refresh (prototype state).
- [[trimit-db-gotchas]] — dual-webroot shadow (C:\ overrides D:\) + DB-driven menus (AppForms).
- [[email-infrastructure]] — gilligan.gsts sending rules, watchers, ImapFlow uid gotcha.
- [[trimit-web-pull]] — read-only web pull via `gilligan-bot` (UserID 376).
- [[github-offchip-backup]] — nightly off-machine backup + ⏰ PAT rotation ~Sep 15.
- [[disaster-recovery]] — rebuild-from-scratch runbook (`RECOVERY.md`), gpg bundle, USB kit.
- [[herman-agent]] — Arduino companion agent (Herman ≠ decommissioned Hermes laptop).
