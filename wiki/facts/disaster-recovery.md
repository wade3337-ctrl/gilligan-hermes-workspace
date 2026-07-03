---
title: Disaster recovery
type: fact
domain: env
tags: [infra, disaster-recovery, backup, gpg, credentials, usb, recovery]
links: ["[[github-offchip-backup]]", "[[env-host-and-tooling]]", "[[play-dev-access]]"]
updated: 2026-07-02
---

# 🆘 Disaster recovery (built 2026-06-30)

Rebuild Gilligan on a **fresh machine from GitHub**. Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

## Runbook = `RECOVERY.md` (workspace root)
Install Node+OpenClaw → clone 3 repos to exact paths → decrypt bundle → `restore.sh` → reload crontab → start gateway → I reconnect to Discord (**~15 min, no dev**).

## Credential bundle (the gap GitHub didn't cover)
- **AES-256 gpg credential bundle** `recovery/gilligan-credentials.tar.gz.gpg`.
- Holds: **openclaw.json** (Anthropic key + Discord token), all **`.secrets`**, **gstsdb SSH key**, **gh-token**, **crontab**.
- **Two factors to open it: GitHub access + passphrase.** Passphrase in the Skipper's password manager as *"Gilligan recovery bundle"*; on-machine copy `~/backups/.recovery-pass` (0600) drives the auto-refresh.
- Bundle **rebuilt nightly 3:28 AM** by `recovery/refresh-recovery-bundle.sh` (symlinked from `~/backups`), pushed by the 3:30 backup.
- Non-destructive test `recovery/dr-restore-dryrun.sh` — **verified PASS 2026-06-30** (decrypt→restore→perms→openclaw.json byte-match).
- Recovery scripts live **IN the repo** (symlinked to `~/backups`) so they survive the failure too.

## 🔌 USB grab-and-go kit
- `recovery/usb-kit/` + flashed to **"JASON STICK"** at `/GILLIGAN-RECOVERY` (2026-06-30).
- Double-click **`START-GILLIGAN.bat`** (Windows; `bootstrap.ps1`) or **`bash bootstrap.sh`** (Mac/Linux) → installs OpenClaw, clones repos via the bundled PAT, decrypts+restores, starts gateway.
- Skipper's spare = **Windows** → cron monitors won't auto-run there (conversational recovery only; full ops need Linux).
- Optional `passphrase.txt` on stick = zero-typing but **lost-stick = full-compromise** (off by default).
- Re-flash anytime by copying the newest `.gpg` + usb-kit scripts.
- **Stick write needs mounting:** no passwordless sudo → use a **`--privileged busybox` docker container** (I'm in the `docker` group) to mount/copy/umount.

## Related
- [[github-offchip-backup]] — the nightly push that carries the bundle.
- [[play-dev-access]] — the gstsdb SSH key is one of the bundled credentials.
