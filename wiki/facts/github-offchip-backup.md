---
title: Off-machine backup — GitHub
type: fact
domain: env
tags: [infra, backup, github, secrets, pat-rotation]
links: ["[[disaster-recovery]]", "[[env-host-and-tooling]]"]
updated: 2026-07-02
---

# ☁️ Off-machine backup — GitHub

Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **2 private GitHub repos** under **`wade3337-ctrl`**: `gilligan-workspace`, `gilligan-arborstack`.
- **Nightly** `~/backups/backup-git.sh` at **3:30 AM** with a **secret-guard**; `.secrets/` / keys **excluded**.

## ⏰ PAT rotation
- **ROTATE the PAT before ~Sep 15 2026** or pushes fail.
- Token at **`~/backups/.gh-token`** (0600).

## Related
- [[disaster-recovery]] — the DR bundle (which the 3:30 backup pushes) covers the credentials GitHub excludes.
