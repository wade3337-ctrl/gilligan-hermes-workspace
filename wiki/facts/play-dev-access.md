---
title: Play/dev access
type: fact
domain: env
tags: [infra, ssh, sqlcmd, play, gstsdatabase, access]
links: ["[[workbench-play-db]]", "[[prod-db-access-blocked]]", "[[trimit-db-gotchas]]", "[[disaster-recovery]]"]
updated: 2026-07-15
---

# 🔑 Direct play/dev access

Full detail: `arbor-stack/gstsdatabase-access.md`. Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **SSH:** `ssh -i ~/.ssh/gstsdb_ed25519 Administrator@100.86.97.46` (host `gstsdatabase`, shell = **cmd.exe**).
- **SQL:** `sqlcmd -S localhost,14333 -d GSTS` — wrapped by `production-dashboard/gsql.sh`.
- **Pages:** `view.sh`.
- **PLAY nightly refresh = DB-ONLY** — procs/data revert; `.cfm/.css/.js` persist.

## ⚠️ It's a SHARED, interactively-used box — schedule heavy work OFF-PEAK (2026-07-15)
`gstsdatabase` is not a quiet dedicated analytics server — people work on it live (SSMS + VS Code open, running heavy queries during the business day). Effect on our jobs:
- A heavy analytical query (e.g. the retention sessionization) ran **<1s when the box was quiet** but **timed out (>4–5 min)** minutes later under daytime load. Same query — so it's contention, not the query.
- `sqlcmd "Timeout expired"` here = a **QUERY** timeout (server too slow), **NOT** a network drop. The tailnet to this host is **direct P2P, ~58ms, 0% loss** — verify with `ping` + `tailscale status`/`tailscale ping` before blaming the link or rebooting. **Don't reboot chasing a network ghost** — you'd also boot whoever's mid-session.
- **Rule:** schedule heavy/analytical runs **off-peak (≈3am PT)**, DST-proof (two UTC fires + PT-hour guard + once-daily stamp — see `PLAYBOOK.md`). The [[aspen-retention-agent]] scoreboard runs 3am PT for exactly this reason.

## Related
- [[workbench-play-db]] — separate side-DB that SURVIVES the nightly refresh.
- [[prod-db-access-blocked]] — the (blocked) prod read-only path vs this play access.
- [[disaster-recovery]] — `gstsdb_ed25519` is in the recovery bundle.
