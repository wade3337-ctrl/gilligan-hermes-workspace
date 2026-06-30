#!/bin/bash
# refresh-recovery-bundle.sh
# Rebuilds the ENCRYPTED disaster-recovery credential bundle and drops it into the
# gilligan-workspace repo (recovery/gilligan-credentials.tar.gz.gpg) so the nightly
# git backup pushes the latest copy off-machine.
#
# WHY this is safe to commit to GitHub: the blob is AES-256 symmetric-encrypted with
# a passphrase that is NOT in any repo. GitHub + passphrase are both required to open it.
#
# The passphrase lives at ~/backups/.recovery-pass (0600, gitignored). Storing it on the
# machine adds ZERO marginal risk: anyone who can read it already has the plaintext
# secrets sitting right next to it. Its only job is to protect the blob once it is OFF
# the machine. The Skipper keeps the SAME passphrase in his password manager -- that copy
# is the real recovery anchor for when this machine is gone.
set -euo pipefail
export HOME=/home/wade3337
PASS_FILE="$HOME/backups/.recovery-pass"
OUT_DIR="$HOME/.openclaw/workspace/recovery"
OUT="$OUT_DIR/gilligan-credentials.tar.gz.gpg"
LOG="$HOME/backups/backup-git.log"
ts=$(date '+%Y-%m-%d %H:%M:%S')

[ -f "$PASS_FILE" ] || { echo "$ts RECOVERY-BUNDLE FAIL: no passphrase file" >>"$LOG"; exit 1; }
mkdir -p "$OUT_DIR"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/files"

# --- copy each live credential, preserving a HOME-relative path under files/ ---
copy() { # copy() <abs-source>  -> staged at files/<home-relative>
  local src="$1" rel="${1#"$HOME"/}"
  [ -e "$src" ] || { echo "  (skip missing: $src)"; return; }
  mkdir -p "$STAGE/files/$(dirname "$rel")"
  cp -p "$src" "$STAGE/files/$rel"
}
copy "$HOME/.openclaw/openclaw.json"
for f in "$HOME"/.secrets/*; do copy "$f"; done
for f in "$HOME"/arbor-stack/anomaly-monitor/.secrets/*; do copy "$f"; done
copy "$HOME/.ssh/gstsdb_ed25519"
copy "$HOME/.ssh/gstsdb_ed25519.pub"
copy "$HOME/backups/.gh-token"

# --- crontab + a manifest describing the restore mapping ---
crontab -l > "$STAGE/crontab.txt" 2>/dev/null || echo "# (no crontab)" > "$STAGE/crontab.txt"
cat > "$STAGE/MANIFEST.md" <<'EOF'
# Gilligan recovery bundle
Extract `files/` back into $HOME (paths are HOME-relative), restore perms, then load crontab.
A turnkey `restore.sh` is included -- run it from the extracted bundle root.
EOF

# --- restore.sh: turnkey credential restore on the NEW machine ---
cat > "$STAGE/restore.sh" <<'EOF'
#!/bin/bash
# Run from the extracted bundle root. Restores all credentials into $HOME with safe perms.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cp -rp "$HERE/files/." "$HOME/"
chmod 600 "$HOME/.openclaw/openclaw.json" "$HOME"/.secrets/* \
  "$HOME"/arbor-stack/anomaly-monitor/.secrets/* "$HOME/.ssh/gstsdb_ed25519" \
  "$HOME/backups/.gh-token" 2>/dev/null || true
chmod 644 "$HOME/.ssh/gstsdb_ed25519.pub" 2>/dev/null || true
echo "Credentials restored. Review crontab.txt, then: crontab crontab.txt"
EOF
chmod +x "$STAGE/restore.sh"

# --- tar + encrypt (AES-256), verify roundtrip, then publish ---
TAR="$STAGE/../bundle.$$.tar.gz"
tar -C "$STAGE" -czf "$TAR" .
gpg --batch --yes --passphrase-file "$PASS_FILE" -c --cipher-algo AES256 -o "$OUT.tmp" "$TAR"
# verify it decrypts + untars before replacing the live blob
gpg --batch --yes --passphrase-file "$PASS_FILE" -d "$OUT.tmp" 2>/dev/null | tar -tz >/dev/null
mv "$OUT.tmp" "$OUT"
rm -f "$TAR"
echo "$ts RECOVERY-BUNDLE OK ($(du -h "$OUT" | cut -f1))" >>"$LOG"
echo "Bundle written: $OUT"
