---
title: Play/dev access
type: fact
domain: env
tags: [infra, ssh, sqlcmd, play, gstsdatabase, access]
links: ["[[workbench-play-db]]", "[[prod-db-access-blocked]]", "[[trimit-db-gotchas]]", "[[disaster-recovery]]"]
updated: 2026-07-21
---

# 🔑 Direct play/dev access

Full detail: `arbor-stack/gstsdatabase-access.md`. Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **SSH:** `ssh -i ~/.ssh/gstsdb_ed25519 Administrator@100.86.97.46` (host `gstsdatabase`, shell = **cmd.exe**).
- **SQL:** `sqlcmd -S localhost,14333 -d GSTS` — wrapped by `production-dashboard/gsql.sh`.
- **Pages:** `view.sh`.
- **PLAY nightly refresh = DB-ONLY** — procs/data revert; `.cfm/.css/.js` persist.

## ⚠️ This is a WRITE path — play is NOT read-only (2026-07-21)
My `gstsdb_ed25519` key logs in as **Administrator** → I have **full write** on play: push files to the webroot `D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\...` via `scp`, and run **write** SQL on GSTS via `gsql.sh` (SQLCMD `-E` integrated auth = full perms). The read-only things are *separate accounts*: `HermanRO`/`GSTSREADONLY` query logins + the `gilligan-bot` (376) view-only web login used by `view.sh`. **Don't reflexively say "play is read-only"** — I once refused to install a profile pic for that reason and was wrong (cost a round-trip). Still follow [[repair-contract]] (backup-first + verify), but know the write path is mine.

## ⚠️ It's a SHARED, interactively-used box — schedule heavy work OFF-PEAK (2026-07-15)
`gstsdatabase` is not a quiet dedicated analytics server — people work on it live (SSMS + VS Code open, running heavy queries during the business day). Effect on our jobs:
- A heavy analytical query (e.g. the retention sessionization) ran **<1s when the box was quiet** but **timed out (>4–5 min)** minutes later under daytime load. Same query — so it's contention, not the query.
- `sqlcmd "Timeout expired"` here = a **QUERY** timeout (server too slow), **NOT** a network drop. The tailnet to this host is **direct P2P, ~58ms, 0% loss** — verify with `ping` + `tailscale status`/`tailscale ping` before blaming the link or rebooting. **Don't reboot chasing a network ghost** — you'd also boot whoever's mid-session.
- **Rule:** schedule heavy/analytical runs **off-peak (≈3am PT)**, DST-proof (two UTC fires + PT-hour guard + once-daily stamp — see `PLAYBOOK.md`). The [[aspen-retention-agent]] scoreboard runs 3am PT for exactly this reason.

## Related
- [[workbench-play-db]] — separate side-DB that SURVIVES the nightly refresh.
- [[prod-db-access-blocked]] — the (blocked) prod read-only path vs this play access.
- [[disaster-recovery]] — `gstsdb_ed25519` is in the recovery bundle.
