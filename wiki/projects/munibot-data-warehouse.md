---
title: MuniBot data warehouse — Brent's 200GB municipal bid data ingest
type: project
domain: work
track: 1
status: ready-to-run (waiting on office run)
tags: [munibot, brent, data-ingest, rsync, warehouse, transfer, resume]
links: ["[[brent-agent]]", "[[aspen-retention-agent]]", "[[play-dev-access]]"]
updated: 2026-07-16
---

# MuniBot data warehouse — 200GB municipal bid data ingest

**Goal:** get Brent's ~200GB municipal bid folder (`\\gsts-server200\GSTS\Municipal Bid Data\Jason_Compiled`) into MuniBot's brain so it can work the bid pipeline.

## ▶️ RESUME (2026-07-17): TRANSFER RUNNING from Skipper's home laptop
- The ~42GB was **already staged** on the home laptop from an earlier two-hop attempt at `%LOCALAPPDATA%\MuniSync\data` (`C:\Users\JWade\AppData\Local\MuniSync\data`) — 42.6GB / 22,792 files / 2,082 folders. So we skipped the office/VPN/SMB path entirely.
- **Launcher = `SyncMuni-LOCAL.cmd` (v5.1, local-source)** — `~/munibot-gateway/SyncMuni-v5_1-local.zip`. Reads the local `data` folder → rsyncs straight to `/opt/data/municipal-archive/` over Tailscale (`wade3337@100.82.161.7`). Self-contained: no cygpath/chmod (stripped cwRsync bundle lacks them), key bundled. Resumable — re-run anytime.
- **Watchdog armed:** cron `*/30 upload-progress-monitor.sh` emails Skipper on done/stall, self-removes.
- **MuniBot repointed:** SOUL + memory now name `/opt/data/municipal-archive/` (absolute) as raw source; old empty `~/home/municipal-history/` retired.

## ⚠️ KNOWN GAP — 7 `.lnk` shortcut cities did NOT transfer (2026-07-17)
rsync copied the 1,973-byte Windows shortcut stub, not the folder behind it. Missing city data: **Long Beach, Anaheim, Aliso Viejo, Cerritos, Lake Forest, Stanton** (+ a `CustomerInfo (192.168.1.6)` network-share shortcut). **To fix:** on the laptop resolve each shortcut's real target and either copy the real folder into `…\MuniSync\data\<County>\<City>\` or add its path to the sync, then re-run `SyncMuni-LOCAL.cmd`. (Long Beach packet itself is in hand from Brent's 2026-07-16 email; only its warehouse *history* is missing.)

## ✅ Verified contents (2026-07-17): 185 city folders / 5 counties
~3,562 "bid", 1,188 "proposal", 319 "cost", 291 "schedule", 201 "compensation", 210 "award", 7,835 "invoice", 733 "inventory" files + GIS shapefiles. Feeds [[munibot-smart-bidding-tool]] (historical-bids + schedule-of-comp signals).

## Architecture (built + proven end-to-end, receiver side)
- **Warehouse** = `~/.munibot/municipal-archive/` on gilligan = MuniBot container bind-mount `/opt/data/municipal-archive` → MuniBot reads it directly, ZERO duplication. 798GB free.
- **Drop channel** = authorized_keys forced command `command="/usr/bin/rrsync -wo /home/wade3337/.munibot/municipal-archive"` on key `munibot-file-drop` → write-only, resumable rsync (verified: lands + container sees + read-back denied).
- **Transfer = ONE HOP** (v4): rsync reads the SMB share directly (mapped drive `T:` → `/cygdrive/t/...`) → warehouse. NO 200GB local staging. Flags: `-rt --no-perms --partial --whole-file --modify-window=2`.

## Hard-won lessons (this build)
- **Two-hop was the bug:** staging 200GB to the user's C: filled the disk → console died mid-copy at a deterministic point, no readable error. → one-hop. ([[playbook]])
- **SSH key rejected → password fallback BYPASSES the rrsync forced command** (rsync hit `~/` not the warehouse). Fixed client-side: `icacls` key-lock + `PreferredAuthentications=publickey`/`BatchMode`/`NumberOfPasswordPrompts=0` (fail-safe, no password). ([[lessons]])
- ⚠️ **Server hardening owed (flag to Jordan/IT):** box still allows `PasswordAuthentication` → a key-only drop box should set `PasswordAuthentication no` so the forced command can't be bypassed. Needs sudo I don't have.
- Bulk raw data NEVER goes to git/GitHub/Obsidian — on-disk warehouse only; distilled notes ride the vault.
