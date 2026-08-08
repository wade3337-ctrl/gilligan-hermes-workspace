---
title: MuniBot data warehouse — Brent's 200GB municipal bid data ingest
type: project
domain: work
track: 1
status: LIVE — warehouse complete on-disk (2026-08-08 verified full)
tags: [munibot, brent, data-ingest, rsync, warehouse, transfer, nte, municipal-contracts]
links: ["[[brent-agent]]", "[[aspen-retention-agent]]", "[[play-dev-access]]", "[[aspen-cockpit-to-bigin-push]]"]
updated: 2026-08-08
---

# MuniBot data warehouse — Brent's municipal bid/contract data

## 📍 WAREHOUSE LOCATION (don't re-hunt for this)
**`~/.munibot/municipal-archive/`** on gilligan = MuniBot container bind-mount **`/opt/data/municipal-archive`**.
- Structure: `<County>/<City>/<term> CONTRACT/…` — 5 counties (LA · Orange · Riverside · San Bernardino · San Diego), **185 city folders**, ~52G.
- Contents: contract agreements + amendments (PDF), Schedule of Compensation, pricing, POs, RFPs, inventories, GIS shapefiles, work history.
- **This is where Brent's actual municipal contract files live** — the source of truth for anything TRIM IT can't answer (esp. NTE ceilings). When the Skipper says "the warehouse" / "Brent's muni files" → it's HERE.

## ⭐ NTE lives HERE, not in TRIM IT (2026-08-08 — proven)
- **Municipal NTE (Not-To-Exceed contract ceiling) is stated verbatim in the contract/amendment PDFs in this warehouse.** TRIM IT has NO NTE field — its `CompanyContracts` values = **PO amounts Brent entered** (a number is there only because we hold a PO for it).
- **Proven:** Fountain Valley `Orange County/Fountain Valley/==2021-2027 CONTRACT==/Contract Renewal/FY 25-27/Amend 2 CON-21-19.pdf` → current NTE **$374,487.75/yr base + $25,000 contingency** (history $310,500→$349,334.50→$374,487.75). `pdf-parse` (`arbor-stack/pdf-tools`) reads these cleanly.
- Build spec (NTE extraction → Bigin, NTE − PO-drawn = forward forecast): `aspen-stack/MUNICIPAL-NTE-vs-PO-build-note.md` → [[aspen-cockpit-to-bigin-push]].

**Original goal:** get Brent's municipal bid folder (`\\gsts-server200\GSTS\Municipal Bid Data\Jason_Compiled`) into MuniBot's brain so it can work the bid pipeline.

## ▶️ RESUME (2026-07-17): TRANSFER RUNNING from Skipper's home laptop
- The ~42GB was **already staged** on the home laptop from an earlier two-hop attempt at `%LOCALAPPDATA%\MuniSync\data` (`C:\Users\JWade\AppData\Local\MuniSync\data`) — 42.6GB / 22,792 files / 2,082 folders. So we skipped the office/VPN/SMB path entirely.
- **Launcher = `SyncMuni-LOCAL.cmd` (v5.1, local-source)** — `~/munibot-gateway/SyncMuni-v5_1-local.zip`. Reads the local `data` folder → rsyncs straight to `/opt/data/municipal-archive/` over Tailscale (`wade3337@100.82.161.7`). Self-contained: no cygpath/chmod (stripped cwRsync bundle lacks them), key bundled. Resumable — re-run anytime.
- **Watchdog armed:** cron `*/30 upload-progress-monitor.sh` emails Skipper on done/stall, self-removes.
- **MuniBot repointed:** SOUL + memory now name `/opt/data/municipal-archive/` (absolute) as raw source; old empty `~/home/municipal-history/` retired.

## ✅ GAP CLOSED — the 6 `.lnk` cities are NOW IN the warehouse (verified 2026-08-08)
Previously the 6 shortcut-stub cities hadn't transferred; a later re-run landed them. **All present now:** Long Beach (LA County, 3,935 files/6.4G) · Anaheim (OC, 2,327/1.2G) · Cerritos (LA, 485/1.2G) · Stanton (OC, 855/589M) · Aliso Viejo (OC, 275/256M) · Lake Forest (OC, 122/109M). **Full active municipal book is in the warehouse.** (Historical note: rsync had copied the 1,973-byte shortcut stub, not the folder behind it; resolved by copying the real targets and re-running.)

## ✅ Verified contents (2026-07-17): 185 city folders / 5 counties
~3,562 "bid", 1,188 "proposal", 319 "cost", 291 "schedule", 201 "compensation", 210 "award", 7,835 "invoice", 733 "inventory" files + GIS shapefiles. Feeds [[munibot-smart-bidding-tool]] (historical-bids + schedule-of-comp signals).

## Architecture (built + proven end-to-end, receiver side)
- **Warehouse** = `~/.munibot/municipal-archive/` on gilligan = MuniBot container bind-mount `/opt/data/municipal-archive` → MuniBot reads it directly, ZERO duplication. 798GB free.
- **Drop channel** = authorized_keys forced command `command="/usr/bin/rrsync -wo /home/wade3337/.munibot/municipal-archive"` on key `munibot-file-drop` → write-only, resumable rsync (verified: lands + container sees + read-back denied).
- **Transfer = ONE HOP** (v4): rsync reads the SMB share directly (mapped drive `T:` → `/cygdrive/t/...`) → warehouse. NO 200GB local staging. Flags: `-rt --no-perms --partial --whole-file --modify-window=2`.

## Hard-won lessons (this build)
- **Two-hop was the bug:** staging 200GB to the user's C: filled the disk → console died mid-copy at a deterministic point, no readable error. → one-hop. ([[PLAYBOOK]])
- **SSH key rejected → password fallback BYPASSES the rrsync forced command** (rsync hit `~/` not the warehouse). Fixed client-side: `icacls` key-lock + `PreferredAuthentications=publickey`/`BatchMode`/`NumberOfPasswordPrompts=0` (fail-safe, no password). ([[LESSONS]])
- ⚠️ **Server hardening owed (flag to Jordan/IT):** box still allows `PasswordAuthentication` → a key-only drop box should set `PasswordAuthentication no` so the forced command can't be bypassed. Needs sudo I don't have.
- Bulk raw data NEVER goes to git/GitHub/Obsidian — on-disk warehouse only; distilled notes ride the vault.
