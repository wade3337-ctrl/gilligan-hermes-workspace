---
title: TrimIT read-only web pull
type: fact
domain: env
tags: [infra, trimit, web-pull, gilligan-bot, credentials, db-health]
links: ["[[email-infrastructure]]", "[[anomaly-monitor-suite]]", "[[trimit-db-gotchas]]"]
updated: 2026-07-04
---

# TrimIT read-only web pull

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **`gilligan-bot`** (**UserID 90376** — high/synthetic; was 376, which the nightly restore reassigned to a real employee) via `anomaly-monitor/trimit-fetch.sh`.
- Creds: `.secrets/gilligan-trimit.json` (fresh 24-char pw; **`flow.Users.Password` is varchar(50)** so a longer secret silently never matches).
- ⚠️ **Play-only login rows are WIPED by every prod→play restore** → self-heal cron `anomaly-monitor/ensure-gilligan-bot.sh` (every 3h) re-creates it if missing; log = restore-wipe monitor. See [[LESSONS]] / [[PLAYBOOK]].
- ⚠️ **TrimIT stores passwords PLAINTEXT** — a DB-health item.

## Related
- [[anomaly-monitor-suite]] — the fetch script lives under the monitor suite.
- [[email-infrastructure]] — companion read-only pull path.
