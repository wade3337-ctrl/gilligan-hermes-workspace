# 2026-07-03 — Boss Herman updated to Hermes v0.18.0 + failover re-proven

## The update (host-side, backup-first)
- Skipper: "get the Hermes update for Boss Herman" + "let him update himself."
- **Reality found:** Boss Herman is a Docker container → Hermes updates by swapping the IMAGE, not patching in place. A container can't replace its own running self → update is a **host** op. (So his "I can't self-update" instinct was right; true self-update = a scoped host-side trigger, deferred as #2, awaiting Skipper green-light.)
- Went **v0.17.0 → v0.18.0 (2026.7.1)**: `git -C ~/hermes-sandbox pull` (4ea3096→528159f, 20+ commits: CDP browser, Hermes Console UI, credential/cron security fixes) + `HERMES_UID=1000 HERMES_GID=1000 docker compose up -d --build`.
- First build was a **no-op** — my local Dockerfile perf-trim (2026-06-24, dropped the slow `chmod -R a-w` full-tree passes) blocked `git pull`. `git stash`ed it; upstream had already dropped those passes (commit 638243726) so my trim is now redundant. Second build landed the update.
- Safety net: rollback image `hermes-agent:rollback-20260703`; config/creds backed up at `~/herman-gateway/preupdate-backup-20260703/`.

## Fallback "lost" then restored (the nuance)
- After the swap, the Codex fallback went inactive. **Files survived** (they're on the `~/.hermes:/opt/data` mount) — what v0.18's hardened credential handling needed was a **re-auth**. Boss Herman re-did it himself (his "learn by doing" pattern).
- **Correction to old note:** a recreate does NOT wipe his creds (they're on the mount). The codex CLI binary even moved onto the mount (`/opt/data/home/.npm-global/bin/codex`) so it persists now too — an improvement.

## Failover PROVEN (Gilligan-verified from the log)
- Boss Herman ran the flip drill + reported a pass. I verified against his **`~/.hermes/logs/agent.log`** (v0.18 moved detail logging OFF `docker logs` stdout — that almost fooled me into calling a real pass unproven).
- Real event, session `20260703_180310_a52007` @ 18:03: primary → HTTP 401 → `Fallback activated: glm-5 → gpt-5.5 (openai-codex)` → Codex answered `latency=4.3s total=15713 tok` → restored → back on glm-5. Clean config restore verified (identical to backup).
- **Honesty flag:** his report claimed the break was `base_url→127.0.0.1:1`; the log showed the actual failure was a 401 from `api.anthropic.com` (the dead-addr edit defaulted the client to Anthropic's endpoint w/ the bad z.ai key). Outcome correct, mechanism mis-stated — flagged to Skipper.
- He saved the **`prove-the-failover-drill` skill** (+ reference docs) → runs it after every update/auth change.

## #2 DONE — Boss Herman self-update trigger (built + proven 2026-07-03)
- Scoped forced-command channel, mirroring his DB-access pattern (least-privilege, no Docker/host-root in the container).
- **gilligan side** (`~/herman-gateway/`): `herman-update-dispatch.sh` (whitelists `update|status|log|rollback`, denies else) + `herman-self-update.sh` (the detached executor: backup image tag → git pull sandbox → `docker compose up -d --build` → health-gate → **auto-rollback** to `hermes-agent:rollback-current` if unhealthy). New key `herman_selfupdate` appended to `~/.ssh/authorized_keys` (backup: `authorized_keys.bak-preselfupdate-20260703`).
- **container side** (on the mount → persists): key `/opt/data/.ssh/herman_selfupdate` + helper `/opt/data/home/hermes-self-update.sh`.
- **Why detached on gilligan is REQUIRED:** the update recreates the `hermes` container → kills Boss Herman mid-flight → so the updater can't live inside him. He restarts mid-update, reads `status` after he's back.
- **Proven end-to-end 2026-07-03:** `status` chain works; off-list command → `DENIED`; key separation OK (update key ≠ DB key); `update` → correctly hit UPTODATE (already 528159f) without a disruptive recreate. Auto-rollback path coded, not yet exercised.
- Skill prompt handed to Skipper → Boss Herman to save as a `self-update` skill.

## ⚠️ NEW ISSUE found (2026-07-03) — HermanRO DB access DOWN
- While testing key-separation, `HermanRO` SQL login is **failing**: `Login failed for user 'HermanRO'` + `Cannot open database "GSTS"`. Server-level login failure (not just the db-user mapping). Likely the nightly play refresh dropped/reset the login or the hourly `HermanRO-ReGrant` schtask isn't restoring it (or password mismatch). **Boss Herman's read-only DB queries are broken until fixed.** Flagged to Skipper as next task.

## HermanRO DB access — FIXED + made stable (2026-07-03)
- **Root cause:** play GSTS restored from prod nightly at 3:00 AM (`GSTS DB RESTORE` task) → wipes the HermanRO *database user* (prod has none). Login's default DB was GSTS → can't open it → `Login failed for user 'HermanRO'`. The hourly DB-box schtask `HermanRO-ReGrant` ran as `NT AUTHORITY\SYSTEM` (verified NOT sysadmin) with `sqlcmd -E` and **no `-b`** → CREATE USER denied nightly but reported Result 0 = **silent failure since setup**.
- **Fix (all proven):** (1) recreated GSTS user + db_datareader live; (2) set login default DB → master (+ master user) so it won't hard-fail; (3) disabled the broken schtask; (4) new gilligan cron `~/herman-gateway/regrant-hermanro.sh` every 30 min, runs as Administrator (sysadmin), idempotent, `-b`, logs to `regrant.log`. **Proven** by simulating the wipe: DROP USER → read fails → re-grant → read works (923 tables).
- Key lesson → LESSONS: `sqlcmd` without `-b` returns exit 0 even on SQL error → schtasks show false success. And NT AUTHORITY\SYSTEM ≠ sysadmin by default.

## Open
- (clear for now — self-update #2 done, DB access stable)
- Parked earlier: live-browser PoC (`arbor_livechrome` linuxserver/chromium @ 100.82.161.7:3030) — note v0.18 ships `cdp` (operator-chrome over CDP) which may be the better path for his live-browser feature.

See [[herman-agent]] for the durable state.

## Evening — leveled Boss Herman to a "true boss" (F1/F2/F3 + hardening)
- **F1 Email:** `bossherman.gsts@gmail.com` (himalaya IMAP+SMTP). Send-gate behavioral.
- **F2 Crew + tools (all via scoped gateway, keys on gilligan; proven live):** `crew-ask.sh <gemini|fable|glm|kimi|judge>`, `crew-vision.sh <img>` (Gemini/Fable vision), `codex-do.sh` (Codex engineer + fallback brain), `geocode.sh` (Census→county), `websearch.sh` (Brave, key on gilligan) + `webfetch.sh` + `ollama-ask.sh` (free local reader; tiered: Ollama default, escalate Gemini).
- **F3 RFP flow (arbor vault: rfp-flow / rfp-qualification / rfp-intake-normalizer / boss-herman-crew):** channel-agnostic intake → qualify (FIT gate G1-3 + VALUE V1-10, TUNABLE via `/opt/data/home/rfp-config.yaml`: LA/Riverside/SanBernardino/Orange counties, no SFR, size tiers) → draft (Fable) → verify (Gemini) → 3 outcomes GO/NO-GO/NEED-INFO. Proven live on Paradise Palms + Vista Del Lago (found Seabreeze=$1.4M existing acct).
- **⚠️ Big lesson — email-adapter jam:** the Hermes email gateway adapter feeds inbound into the agent's ONE live convo + auto-replies to sender → a 6-email burst TANGLED requests ("all three drafted"), spammed customers, JAMMED him (needed restart). **FIX:** disabled the adapter; built a standalone gilligan service — `rfp-watcher.py` (cron */2) → one isolated `rfp-intake.py` per email → qualify → **Telegram brief to Skipper via the bot** (never customer, never his live chat). Gauntlet 6/6 correct, parallel, no jam.
- **Memory:** trimmed MEMORY.md 2077→1848 (lean 7-entry index) + bumped `memory_char_limit` 2200→3500 → ~1650 headroom.
- **New backup crons:** brain repo (`herman-brain-backup`), HermanRO re-grant (`*/30`), note collector (`*/20`), RFP watcher (`*/2`). Secrets ride the encrypted recovery bundle.

## Late — Arduino Herman (SEPARATE agent) vault published to GitHub
- Distinct from Boss Herman: **Arduino Herman** = the field companion on the Arduino board (push-only sync to gilligan `~/herman-store/`; I have NO SSH into the board).
- He completed "EXP-000 Self-Migration" + built an Obsidian vault; Skipper relayed a request to publish it.
- **Repo:** private `wade3337-ctrl/herman-workspace` (created via API). Path A chosen = **Gilligan is the GitHub gateway; NO creds on the board.**
- Flow: Herman rsyncs vault (with .git) → `~/herman-store/herman-workspace/` → gilligan `~/herman-gateway/herman-vault-sync.sh` (cron `*/5`) commits+pushes. Token stays in `~/backups/.gh-token` (0600), never in repo/args/logs (credential-helper). Corrupt-sync guard: refuses to push if >50% files would delete. Log: `herman-vault-sync.log`.
- **First push verified:** commit `a50e23a` ("EXP-000 self-migration vault") on GitHub, all 6 key files 200, 447 files, secret-scanned clean.
- Future hardening flagged to Skipper: swap the broad PAT for a fine-grained token scoped to these repos.
