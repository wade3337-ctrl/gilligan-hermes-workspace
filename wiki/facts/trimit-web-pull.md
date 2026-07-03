---
title: TrimIT read-only web pull
type: fact
domain: env
tags: [infra, trimit, web-pull, gilligan-bot, credentials, db-health]
links: ["[[email-infrastructure]]", "[[anomaly-monitor-suite]]", "[[trimit-db-gotchas]]"]
updated: 2026-07-02
---

# TrimIT read-only web pull

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **`gilligan-bot`** (**UserID 376**) via `anomaly-monitor/trimit-fetch.sh`.
- Creds: `.secrets/gilligan-trimit.json`.
- ⚠️ **TrimIT stores passwords PLAINTEXT** — a DB-health item.

## Related
- [[anomaly-monitor-suite]] — the fetch script lives under the monitor suite.
- [[email-infrastructure]] — companion read-only pull path.
