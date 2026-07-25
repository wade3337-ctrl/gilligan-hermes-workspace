---
title: Play/dev access
type: fact
domain: env
tags: [infra, ssh, sqlcmd, play, gstsdatabase, access]
links: ["[[workbench-play-db]]", "[[prod-db-access-blocked]]", "[[trimit-db-gotchas]]", "[[disaster-recovery]]"]
updated: 2026-07-21
---

# 🔑 Direct PLAY access

## 🚨 THREE SEPARATE ENVIRONMENTS — do not conflate (corrected 2026-07-24)
| Hostname | IP | What it is | My access |
|---|---|---|---|
| `play.greatscotttreeservice.com` | **173.208.162.142** | **OUR sandbox.** Everything in this note. | ✅ SSH (tailnet **100.86.97.46**, Administrator) + HTTP |
| `dev.greatscotttreeservice.com` | **198.207.148.188** | **THE VENDOR'S dev server** (Travis/Jordan build the sales-workflow / Field App here) | ❌ no SSH · ✅ **HTTP reachable** (`view.sh` with `BASE=https://dev.greatscotttreeservice.com/GSTS`) |
| `www.greatscotttreeservice.com` | 198.207.148.169 | **PROD** (AWS; same /24 as dev) | ❌ none — see [[prod-db-access-blocked]] |

⚠️ **THE TRAP THAT FOOLED ME:** the play box's IIS webroot folder is *named* **`D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS`** — so the word "dev" appears in our own paths while pointing at PLAY. I concluded "dev and play are the same server" and assessed the vendor's output from the wrong machine. **They are different hosts.** Quick check: `getent hosts dev.greatscotttreeservice.com play.greatscotttreeservice.com` — different IPs. A page 404-ing on play but rendering on dev proves it.

## Play access (this note's subject)

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
