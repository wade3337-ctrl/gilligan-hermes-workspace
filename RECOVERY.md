# RECOVERY.md — Bring Gilligan back from the dead 🏝️

**Use this when the primary machine is gone (hardware failure, lost, wiped) and you need to
restore Gilligan onto a fresh laptop from the GitHub backups.**

Everything that makes Gilligan *think*, *talk to you*, and *do the job* is recoverable from two
things: **(1)** the private GitHub repos under `wade3337-ctrl`, and **(2)** one **recovery
passphrase** stored in your password manager. You need BOTH. Neither alone is enough — that's the
whole security design.

---

## What you need before you start
- A new machine (Linux or macOS), internet, admin/sudo.
- **Your GitHub login** (the `wade3337-ctrl` account) — browser login is fine.
- **The recovery passphrase** — saved in your password manager as *"Gilligan recovery bundle"*.

---

## Step 1 — Install the runtime
```bash
# Node 24 (use nvm, or your OS package manager). Then:
npm install -g openclaw
openclaw --version          # expect 2026.6.x or newer
```

## Step 2 — Get the repos
> Chicken-and-egg note: the automation's GitHub token is *inside* the encrypted bundle, which
> lives *inside* a repo. So for the FIRST clone you authenticate as **yourself**, not with that
> token. Easiest path: log into github.com in a browser, or `gh auth login`.

Clone all three to these EXACT paths (paths matter — scripts hard-reference them):
```bash
git clone https://github.com/wade3337-ctrl/gilligan-workspace.git   ~/.openclaw/workspace
git clone https://github.com/wade3337-ctrl/gilligan-arborstack.git  ~/arbor-stack
git clone https://github.com/wade3337-ctrl/arbor-core.git           ~/arbor-core
```

## Step 3 — Decrypt + restore the credentials
```bash
cd ~/.openclaw/workspace/recovery
gpg -d gilligan-credentials.tar.gz.gpg | tar xz   # prompts for the recovery passphrase
./restore.sh                                       # copies keys/config into place, fixes perms
```
This restores: `openclaw.json` (Anthropic API key + Discord bot token), all `.secrets/*`
(Gmail, prod-DB, TRIM IT, crew model keys), the `gstsdb` SSH key (play/dev DB access), and the
GitHub automation token. It also drops `crontab.txt` for the next step.

## Step 4 — Restore the scheduled jobs
```bash
crontab ~/.openclaw/workspace/recovery/crontab.txt   # or wherever you extracted it
crontab -l   # sanity check: backups + COO/salesperson/AR monitors + reply/bounce watchers
```
> Heads-up: the cron times are **UTC** on this host but fire against **PT** business hours via
> each script's `--guard-pt-morning` guard. If the new box's timezone differs, the guards still
> gate correctly — but verify the first morning's COO email actually sends.

## Step 5 — Start the gateway + confirm I'm back
```bash
openclaw gateway start
openclaw gateway status
```
Within a minute I should reconnect to **Discord** and you can message me as normal. Say hi — if I
answer and know who you are, recovery worked.

## Step 6 — First-day hygiene (don't skip)
- **Rotate the keys that were ever pasted in chat** (flagged in `MEMORY.md` → ENVIRONMENT): the
  crew model keys and the GitHub PAT. A rebuild is the clean moment to do it.
- Re-run a backup to confirm push works from the new box: `~/backups/backup-git.sh`
- Re-point the **off-machine backup PAT** if it expired (`~/backups/.gh-token`).

---

## How the bundle stays fresh
`~/backups/refresh-recovery-bundle.sh` rebuilds the encrypted blob; it runs nightly right before
the git backup, so GitHub always has the latest credentials. The passphrase it uses lives at
`~/backups/.recovery-pass` (on-machine, 0600) — that copy only matters while THIS machine is alive;
the password-manager copy is what saves you when it isn't.

**If you ever change the passphrase:** update both `~/backups/.recovery-pass` AND your password
manager, then run the refresh script once so the blob matches.
