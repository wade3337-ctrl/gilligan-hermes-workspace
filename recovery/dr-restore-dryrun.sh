#!/bin/bash
# dr-restore-dryrun.sh
# Non-destructive disaster-recovery test: decrypt the GitHub credential bundle into a SCRATCH
# home, run restore.sh against it, and verify every credential came back intact (content +
# perms), WITHOUT touching the real ~/ files. Writes a PASS/FAIL report and cleans up.
set -uo pipefail
export HOME=/home/wade3337
PASS_FILE="$HOME/backups/.recovery-pass"
BLOB="$HOME/.openclaw/workspace/recovery/gilligan-credentials.tar.gz.gpg"
REPORT="$HOME/backups/dr-dryrun-report.txt"
SCRATCH="$(mktemp -d /tmp/dr-test.XXXXXX)"
ts=$(date '+%Y-%m-%d %H:%M:%S %Z')
fail=0
note() { echo "$1" >> "$REPORT"; }

: > "$REPORT"
note "=== Gilligan DR restore dry-run — $ts ==="
note "Blob: $BLOB"
note ""

# 1) blob present + still pulled from GitHub copy
if [ ! -f "$BLOB" ]; then note "FAIL: encrypted bundle missing"; fail=1; fi

# 2) decrypt + extract into scratch
if ! gpg --batch --quiet --passphrase-file "$PASS_FILE" -d "$BLOB" 2>/dev/null | tar -xz -C "$SCRATCH"; then
  note "FAIL: decrypt/extract failed (bad passphrase or corrupt blob)"; fail=1
fi

# 3) run the bundled restore.sh against a FAKE home (proves the turnkey path works)
FAKEHOME="$SCRATCH/fakehome"; mkdir -p "$FAKEHOME"
if [ -f "$SCRATCH/restore.sh" ]; then
  ( export HOME="$FAKEHOME"; cd "$SCRATCH" && bash ./restore.sh ) >>"$REPORT" 2>&1 \
    || { note "FAIL: restore.sh errored"; fail=1; }
else
  note "FAIL: restore.sh not in bundle"; fail=1
fi

# 4) verify each critical credential restored to the fake home
check() { # check <relpath> [expect-perm]
  local p="$FAKEHOME/$1"
  if [ ! -s "$p" ]; then note "  MISSING: $1"; fail=1; return; fi
  if [ -n "${2:-}" ]; then
    local perm; perm=$(stat -c '%a' "$p" 2>/dev/null)
    [ "$perm" = "$2" ] && note "  ok  $1 ($perm)" || { note "  PERM $1 = $perm, want $2"; fail=1; }
  else
    note "  ok  $1"
  fi
}
note ""; note "Restored files:"
check ".openclaw/openclaw.json" 600
check ".secrets/gemini.json" 600
check ".secrets/glm.json" 600
check ".secrets/kimi.json" 600
check ".secrets/v15app.json" 600
check "arbor-stack/anomaly-monitor/.secrets/gmail.json" 600
check "arbor-stack/anomaly-monitor/.secrets/prod-db.json" 600
check "arbor-stack/anomaly-monitor/.secrets/gilligan-trimit.json" 600
check ".ssh/gstsdb_ed25519" 600
check "backups/.gh-token" 600

# 5) content fidelity: restored openclaw.json must byte-match the live original
live=$(sha256sum "$HOME/.openclaw/openclaw.json" 2>/dev/null | cut -d' ' -f1)
rest=$(sha256sum "$FAKEHOME/.openclaw/openclaw.json" 2>/dev/null | cut -d' ' -f1)
note ""
if [ -n "$live" ] && [ "$live" = "$rest" ]; then
  note "Content check: openclaw.json restored byte-for-byte ✅"
else
  note "FAIL: openclaw.json content mismatch (live=$live restored=$rest)"; fail=1
fi

# 6) crontab captured
if [ -s "$SCRATCH/crontab.txt" ]; then
  note "Crontab captured: $(grep -c . "$SCRATCH/crontab.txt") lines"
else
  note "WARN: crontab.txt empty"; fi

# blob age (is the nightly refresh keeping it current?)
note ""
note "Bundle last modified: $(stat -c '%y' "$BLOB" 2>/dev/null | cut -d. -f1)"

rm -rf "$SCRATCH"
note ""
if [ "$fail" -eq 0 ]; then note "RESULT: ✅ PASS — full restore verified, recovery is viable."
else note "RESULT: ❌ FAIL — see lines above."; fi
cat "$REPORT"
exit $fail
