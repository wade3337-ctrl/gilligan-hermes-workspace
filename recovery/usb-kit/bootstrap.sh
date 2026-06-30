#!/bin/bash
# ============================================================================
#  GILLIGAN RECOVERY — one-script bring-back (Linux / macOS)
#  Plug in this USB, open a terminal in this folder, and run:   bash bootstrap.sh
#  It installs OpenClaw, pulls Gilligan's brain from GitHub, restores the keys,
#  and starts him talking to Discord again.
# ============================================================================
set -uo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
BUNDLE="$KIT/gilligan-credentials.tar.gz.gpg"
H="$HOME"
say() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
die() { printf '\n\033[1;31mSTOP: %s\033[0m\n' "$1"; exit 1; }

say "Gilligan recovery starting. This takes a few minutes."

# --- 1. prerequisites ------------------------------------------------------
command -v git >/dev/null || die "git is not installed. Install git, then re-run."
if ! command -v node >/dev/null; then
  die "Node.js is not installed. Install Node 24+ (https://nodejs.org), then re-run this script."
fi
if ! command -v gpg >/dev/null; then
  die "gpg is not installed. Install gnupg (mac: 'brew install gnupg'), then re-run."
fi
say "Installing OpenClaw (this needs internet)..."
npm install -g openclaw >/dev/null 2>&1 || die "OpenClaw install failed. Check internet, then re-run."

# --- 2. unlock the credential bundle --------------------------------------
[ -f "$BUNDLE" ] || die "Credential bundle missing from the USB."
if [ -f "$KIT/passphrase.txt" ]; then
  PASS="$(tr -d '\r\n' < "$KIT/passphrase.txt")"
  say "Using passphrase from the USB (plug-and-go mode)."
else
  printf '\nEnter the Gilligan recovery passphrase (from your password manager): '
  read -rs PASS; echo
fi
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
echo "$PASS" | gpg --batch --quiet --passphrase-fd 0 -d "$BUNDLE" 2>/dev/null | tar -xz -C "$TMP" \
  || die "Wrong passphrase or corrupt bundle. Double-check the passphrase and re-run."
say "Credential bundle unlocked."

# --- 3. clone the 3 repos using the bundled GitHub token ------------------
PAT="$(tr -d '\r\n' < "$TMP/files/backups/.gh-token" 2>/dev/null)"
[ -n "$PAT" ] || die "GitHub token not found in bundle."
clone() { # clone <repo-name> <dest>
  local name="$1" dest="$2"
  if [ -d "$dest/.git" ]; then say "$name already present, skipping clone."; return; fi
  say "Cloning $name ..."
  git clone --quiet "https://${PAT}@github.com/wade3337-ctrl/${name}.git" "$dest" \
    || die "Could not clone $name (check internet / token)."
}
clone gilligan-workspace  "$H/.openclaw/workspace"
clone gilligan-arborstack "$H/arbor-stack"
clone arbor-core          "$H/arbor-core"

# --- 4. restore credentials into place ------------------------------------
say "Restoring credentials..."
if [ -f "$TMP/restore.sh" ]; then ( cd "$TMP" && bash ./restore.sh ); else
  cp -rp "$TMP/files/." "$H/"
fi
# safe perms
chmod 600 "$H/.openclaw/openclaw.json" "$H"/.secrets/* \
  "$H"/arbor-stack/anomaly-monitor/.secrets/* "$H/.ssh/gstsdb_ed25519" \
  "$H/backups/.gh-token" 2>/dev/null || true

# --- 5. scheduled jobs (Linux/mac with cron) ------------------------------
if command -v crontab >/dev/null && [ -f "$TMP/crontab.txt" ]; then
  crontab "$TMP/crontab.txt" 2>/dev/null && say "Scheduled jobs restored." || say "Skipped crontab (load manually from the bundle if needed)."
fi

# --- 6. light up ----------------------------------------------------------
say "Starting Gilligan's gateway..."
openclaw gateway start || die "Gateway failed to start — run 'openclaw gateway status' to see why."
printf '\n\033[1;32m============================================================\n'
printf '  DONE. Watch Discord — Gilligan should reconnect within a minute.\n'
printf '  Say hi. If he answers and knows who you are, you are fully back.\n'
printf '============================================================\033[0m\n\n'
printf 'First-day tip: rotate the chat-pasted keys (see MEMORY.md) and\n'
printf 'delete passphrase.txt from the USB if you added it.\n\n'
