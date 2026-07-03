---
title: Play/dev access
type: fact
domain: env
tags: [infra, ssh, sqlcmd, play, gstsdatabase, access]
links: ["[[workbench-play-db]]", "[[prod-db-access-blocked]]", "[[trimit-db-gotchas]]", "[[disaster-recovery]]"]
updated: 2026-07-02
---

# 🔑 Direct play/dev access

Full detail: `arbor-stack/gstsdatabase-access.md`. Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **SSH:** `ssh -i ~/.ssh/gstsdb_ed25519 Administrator@100.86.97.46` (host `gstsdatabase`, shell = **cmd.exe**).
- **SQL:** `sqlcmd -S localhost,14333 -d GSTS` — wrapped by `production-dashboard/gsql.sh`.
- **Pages:** `view.sh`.
- **PLAY nightly refresh = DB-ONLY** — procs/data revert; `.cfm/.css/.js` persist.

## Related
- [[workbench-play-db]] — separate side-DB that SURVIVES the nightly refresh.
- [[prod-db-access-blocked]] — the (blocked) prod read-only path vs this play access.
- [[disaster-recovery]] — `gstsdb_ed25519` is in the recovery bundle.
