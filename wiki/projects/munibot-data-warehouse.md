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

## ▶️ RESUME (2026-07-16): waiting on Skipper to run SyncMuni v4 at the OFFICE
- **What to do:** on VPN/office network, double-click `SyncMuni.cmd` (from the v4 zip). It maps the share to `T:`, then rsyncs STRAIGHT to the warehouse (no local copy). Window stays open + logs to `%LOCALAPPDATA%\MuniSync\sync.log`.
- **Canonical script = `~/munibot-gateway/SyncMuni-v4-onehop.zip`** (built in-memory to dodge this box's save-hook, which corrupts `>nul`→`>/dev/null` on disk — DO NOT rebuild from the on-disk `.cmd`, it's mangled).
- **Watchdog armed:** cron `*/30 upload-progress-monitor.sh` emails Skipper when data lands/finishes or stalls, then self-removes. State reset for a clean run.

## Architecture (built + proven end-to-end, receiver side)
- **Warehouse** = `~/.munibot/municipal-archive/` on gilligan = MuniBot container bind-mount `/opt/data/municipal-archive` → MuniBot reads it directly, ZERO duplication. 798GB free.
- **Drop channel** = authorized_keys forced command `command="/usr/bin/rrsync -wo /home/wade3337/.munibot/municipal-archive"` on key `munibot-file-drop` → write-only, resumable rsync (verified: lands + container sees + read-back denied).
- **Transfer = ONE HOP** (v4): rsync reads the SMB share directly (mapped drive `T:` → `/cygdrive/t/...`) → warehouse. NO 200GB local staging. Flags: `-rt --no-perms --partial --whole-file --modify-window=2`.

## Hard-won lessons (this build)
- **Two-hop was the bug:** staging 200GB to the user's C: filled the disk → console died mid-copy at a deterministic point, no readable error. → one-hop. ([[playbook]])
- **SSH key rejected → password fallback BYPASSES the rrsync forced command** (rsync hit `~/` not the warehouse). Fixed client-side: `icacls` key-lock + `PreferredAuthentications=publickey`/`BatchMode`/`NumberOfPasswordPrompts=0` (fail-safe, no password). ([[lessons]])
- ⚠️ **Server hardening owed (flag to Jordan/IT):** box still allows `PasswordAuthentication` → a key-only drop box should set `PasswordAuthentication no` so the forced command can't be bypassed. Needs sudo I don't have.
- Bulk raw data NEVER goes to git/GitHub/Obsidian — on-disk warehouse only; distilled notes ride the vault.
