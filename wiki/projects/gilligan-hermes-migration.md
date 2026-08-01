---
title: Gilligan → Hermes runtime migration (audit + decision)
type: project
domain: env
status: PILOT RUNS ON gbt · ⭐ FIRST LIVE VOICE PROOF TASK PASSED 2026-08-01 · full work parity + voice + live play DB + auto-current wiki
tags: [infra, gilligan, hermes, openclaw, migration, agent-runtime]
links: ["[[herman-agent]]", "[[gilligan-session-settings]]", "[[env-host-and-tooling]]", "[[agent-comms-security-policy]]", "[[claude-local-shim-spike]]", "[[gilligan-pilot-model-setup]]", "[[crew-llms-and-helpers]]", "[[gilligan-voice-platform]]", "[[play-dev-access]]"]
updated: 2026-08-01
---

## ⭐⭐ MILESTONE (2026-08-01 ~03:56) — the pilot did a REAL work task, end to end, by voice
> Skipper gave it a live proof task **by voice**: pull a real number from play and report it.
> **"he did it. he reported the number accurately."** Voice in → local STT → gbt brain → `gsql.sh` live TRIM IT
> query → correct number → edge-TTS voice out. **This is the first end-to-end evidence that the migration path
> is viable in practice, not just wired** — all three enablers built that night fired in one genuine task.
> *(Counts as 1 of the 2 pilot proof tasks owed; the second — a reconciliation-class analytical — is still open.)*
>
> **Enabler 1 — 🎙️ VOICE (one boolean).** `stt: provider: local` (local whisper) + `tts: provider: edge`
> (edge-TTS `GuyNeural`) were already in `~/.gilligan-hermes/config.yaml`; only **`voice.auto_tts: false → true`**
> (line 363) was needed. Full story, incl. the abandoned OpenJarvis browser path → **[[gilligan-voice-platform]]**.
>
> **Enabler 2 — 🗄️ LIVE PLAY DB from inside his container.** Play access is **not** a local SQL client:
> `gsql.sh` SSHes to the Windows play box (`Administrator@100.86.97.46` over Tailscale, key `gstsdb_ed25519`)
> and runs `SQLCMD.EXE` *there* (`-S localhost,14333 -d GSTS -E`). So the container needed only the script +
> key + ssh/scp + tailnet reach — all already present. **The one fix:** its `gsql.sh` hardcoded
> `KEY=/home/wade3337/.ssh/...` (a HOST path that doesn't exist in the container) → patched to portable
> `KEY="${GSTSDB_KEY:-$HOME/.ssh/gstsdb_ed25519}"` + `StrictHostKeyChecking=accept-new`
> (backup `gsql.sh.bak-prekeyfix-*`). Proven natively with no overrides: `COUNT(*) FROM sys.databases` → 10,
> real TRIM IT tables listed. ⚠️ **READ path proven only** — writes to play still governed by the standing
> backup-first / repair-contract rules. → [[play-dev-access]]
>
> **Enabler 3 — 🔄 HIS WIKI IS NO LONGER FROZEN.** His copy was genuinely stale (169 notes vs 174 live, frozen
> ~7/30, missing that week's notes) and it is a **copy, not a live mount**. Reverse-diff showed **0
> container-unique files**, so mirroring was safe. Mechanism, no container surgery: his workspace is just a host
> folder under the `.gilligan-hermes` mount, so writing it updates the container live —
> `~/backups/sync-workspace-to-gilligan.sh` does one-way `rsync -a --delete` LIVE workspace → container,
> excluding `.git` (he has his OWN repo) and `node_modules`, on a **`gilligan-wiki-sync.timer` every 10 min**
> (`OnBootSec=2min`, Persistent, linger → survives reboot). **Source of truth = the OpenClaw workspace.**
> Verified: container now 174 notes incl. the current daily.
> - ⚠️ **The `--delete` trap this creates is the single biggest hazard of the mirror** — see the protect-filter
>   fix below; it has already bitten **twice** in one day.
> - ⚠️ **Confidentiality:** the mirror carries the whole workspace incl. **BLACK Fort Point** files into the
>   container (it already had a copy — no NEW exposure). His Telegram is the Skipper's DM only
>   (`allowed_chats` empty); keep BLACK out of any shared chat. → [[two-track-confidentiality]]
> - ⚠️ rsync gotcha that cost a detour: **`rsync -an` without `-v` prints nothing** — empty output is not
>   "0 changes". Use `-avn` for a real dry-run.
>
> **⏭️ Now open:** decide **when/if the Telegram Gilligan becomes PRIMARY** — at that point the sync direction
> and ownership of memory writes need a rethink (today it is strictly one-way, OpenClaw → pilot).

## ⭐ CODEX HEAVY-LIFTING (2026-08-01) — isolated sibling worker BUILT + verified ("Option B")
> Goal: let Hermes-Gilligan spin up **Codex (gpt-5.6-sol)** for real code work (write/refactor/fix) with
> **true isolation from his secrets**. Codex's own kernel sandbox **cannot run in his container** — diagnosed
> to the kernel: surgical seccomp unblocked user-namespaces, but Codex then remounts `/` rec-slave inside a
> new userns and hits **`MNT_LOCKED`** (mount owned by host init-ns; works at container top-level w/
> CAP_SYS_ADMIN, fails inside userns even WITH it). Unfixable without a **rootless/userns-remapped runtime**
> (daemon-wide = blast radius on Herman/MuniBot). So we built B instead.
>
> **B = minimal sibling container, isolation via minimal MOUNTS (not nested bwrap):**
> - Image **`codex-worker:2`** (debian:13-slim + git + ca-certs + **python3 + node/npm**, ~689MB, no secrets
>   baked). *(v1 was git-only/66MB; upgraded to v2 2026-08-01 so Codex can EXECUTE/test its own code, not just
>   author it — v1 output warned "Python isn't installed". Watcher `IMAGE=` now `codex-worker:2`.)*
> - Per job, a HOST watcher runs a throwaway `docker run` mounting **ONLY** the target repo (rw) + a per-job
>   codex home = auth.json+config.toml (the one secret Codex needs) + the codex binary (ro). `--cap-drop ALL`,
>   `--security-opt no-new-privileges`, `--network bridge` (outbound for the model, NOT host), `--user 1000`,
>   mem/pids limits. Codex runs `--dangerously-bypass-approvals-and-sandbox` (the container IS the sandbox).
> - **Proven:** worker sees only `/work` + codex auth — `.secrets`/`.ssh`/`memories` NOT present. Read task
>   returned the marker; **write task created a file that landed on host owned by uid 1000**. Survived a
>   main-container recreate. **Execute proven** (v2): greenfield job built `add.py` AND ran `python3` to verify
>   `add(2,3)==5` → printed `5`, exit 0.
>
> **🔒 MODEL LOCKED (Skipper 2026-08-01, "I do not want lower models doing coding work"):** every Codex job is
> pinned to **`gpt-5.6-sol` + `model_reasoning_effort="high"`**, enforced TWO ways — seeded
> `~/.gilligan-hermes/.codex/config.toml` (`model` + `model_reasoning_effort`) AND belt-and-suspenders in the
> exec command (`-m gpt-5.6-sol -c model_reasoning_effort=high`, vars `CODEX_MODEL`/`CODEX_EFFORT` in
> run-job.sh). No per-job override can downgrade it. Live run confirmed `reasoning effort: high`. *(Default was
> `none` — the thing to guard against.)*
>
> **🌱 GREENFIELD MODE (2026-08-01):** build something NEW from a prompt with **no pre-existing repo**. Client
> `codex-worker.sh --new <name> "build task"` sets `mode=greenfield` in the job; run-job.sh then SKIPS the
> repo/allowlist requirement and `git init`s a fresh scratch repo at `/opt/data/codex-jobs/builds/<id>-<name>/`
> (echoed as `build output dir:`), Codex builds+tests there, output returns to Gilligan. Same isolation (only
> the scratch dir + codex auth mounted). Proven: built `fizzbuzz.py`+`README.md` from nothing.
> - *Bug fixed en route:* early `[ -n "$repo" ]` guard + allowlist block fired before the greenfield branch (a
>   multi-block edit had only half-applied) → made both mode-aware; removed an orphan duplicate `.git` check.
>
> **Orchestration (Gilligan has NO docker socket):** file queue. Client `codex-worker.sh <repo> "task"` (or
> `--new <name> "task"`) writes a job to `/opt/data/codex-jobs/inbox/`; host **`~/codex-worker/watcher.sh`**
> (systemd `--user` `codex-worker.service`) validates the repo against `~/codex-worker/allowlist.txt`
> (greenfield needs NO allowlist entry), runs the sibling, writes results to `outbox/`. Gilligan only
> reads/writes files — never touches docker/host.
> **Files:** host `~/codex-worker/{Dockerfile,run-job.sh,watcher.sh,allowlist.txt}`; client
> `/opt/data/arbor-core/crew/codex-worker.sh`; his doc `home/workspace/_pilot-own/CREW-ACCESS.md` (documents
> both `<repo>` and `--new` modes + the model lock + execute capability).
>
> **Boundary:** the surgical seccomp experiment on the MAIN container was **REVERTED** (B doesn't need it) —
> main gilligan container is back on Docker default seccomp. No docker-socket / host-root / host-mount anywhere.
> ⚠️ **Mirror trap (again):** his `CREW-ACCESS.md` was wiped by the `rsync --delete` sync (loose workspace-root
> file, not in my live workspace). Fixed by moving it to the PROTECTED `_pilot-own/` dir. Lesson: his authored
> docs go in `_pilot-own/` or `skills/`, never loose in the workspace root.

## ⭐ OUTCOME (2026-08-01) — FULL WORK PARITY wired + verified (Skipper chose "Option A")
> Skipper: "I want him to have all the same privileges you do." Chose **Option A** = full *work* parity,
> **keep the container boundary** (NO docker-socket / host-root / host-`/` mount — his brain is an external
> model; those would dissolve the sandbox + expose BLACK M&A + the other agents). Literal parity (Option B)
> declined for now. All items below run against the live `gilligan` container, verified in-session.
>
> **Crew (spin-up on demand, NOT main-agent providers):** mirrored my `~/arbor-core/crew/` → container
> `/opt/data/arbor-core/crew/`; secret paths repointed to `/opt/data/.secrets/`. **Fable / Gemini / GLM /
> Kimi each live-tested** (returned exact token); **sol** = his native brain + Hermes sub-agents. How-to note
> for him: `home/workspace/CREW-ACCESS.md`. → [[crew-llms-and-helpers]]
> - ⚠️ Gemini key = free-tier TESTING key (low-trust, not for prod). Kimi ~7× slower → background long calls.
>
> **Hidden path trap (root cause of the "no keys" report):** pilot exec runs as **`HOME=/root` (empty)**
> while keys/creds live in `/opt/data`. Any tool reading `~/.ssh`/`~/.secrets` silently failed. Fixed:
> `~/.secrets` symlink + **root-owned `~/.ssh`** (strict perms — SSH rejected uid-1000 files). Idempotent
> recovery after a container RECREATE: **`/opt/data/setup-creds.sh`** (plain restart survives untouched).
>
> **Play DB access PROVEN:** SSH jump `Administrator@100.86.97.46` → hostname `GSTSDATABASE`; read-only query
> via `gsqlhost.sh 198.207.148.168,1433` → `master`. (Tailscale over host-net, key `gstsdb_ed25519`, RO login.)
>
> **Email WIRED + test-sent:** ported `send-email.js`/`send-files.js` + `gmail.json` → `/opt/data/arbor-core/
> mail/`, `npm i nodemailer`. SMTP verify OK as `gilligan.gsts@gmail.com`; real test send → `jwade` inbox OK.
> **COMMS-SECURITY lock still governs** all person-bound outbound (draft → per-message approval → send).
> ⚠️ gmail app-password rendered unmasked in a tool output this session — rotation offered.
>
> **Skill-safety trap found + closed:** the 10-min `sync-workspace-to-gilligan.sh` does one-way
> `rsync -a --delete` LIVE→pilot `home/workspace/` (his Obsidian vault) — so a skill/note he authored *there*
> would be WIPED unless it also exists on my side. Git itself is NOT the risk (separate repo; my `.git`
> excluded). His main skills (`/opt/data/skills/`, 15) + memory (`/opt/data/memories/`) are OUTSIDE the mirror
> = safe. **Fix:** added rsync `--filter='P skills/***'` + `P _pilot-own/***` (protect-on-receiver) so his
> authored work is never deleted while my wiki/memory still copies IN additively. Dry-run proved a planted
> test skill survives; ran live, 0 bad deletes. Backup: `sync-...sh.bak-preprotect-20260801-045800`.
> **Guidance for him:** save authored skills to `/opt/data/skills/` (primary, fully outside mirror); the vault
> `skills/` folder is now a protected backstop; don't leave unique work loose in the workspace root.
>
> **Still NOT granted (Option A boundary):** docker.sock, host root, host-`/` mount. Two-track BLACK +
> COMMS-SECURITY locks preserved on the new runtime.

## ⭐ OUTCOME (2026-07-31 eve) — pilot runs on gbt; Claude-brain shelved
> **Skipper's decision after a full day's build:** run the Hermes pilot on **gbt** (`gpt-5.6-sol` via
> `openai-codex`) — reliable, fast, all tools, zero metered cost. The attempt to make **Claude (Max sub)**
> the brain via a subprocess shim is **shelved as a background spike** — it works in isolation but is not
> reliable at Gilligan's full tool scale. Full story + root cause → **[[claude-local-shim-spike]]**.
> **Also added as on-demand callable brains:** `glm-5.2` (z.ai) + `kimi-k3` (Moonshot), plus a parked
> **Mixture-of-Agents** trio. Config/how-to → **[[gilligan-pilot-model-setup]]**.
>
> **Why Claude-brain failed the bar (grounded):** direct Anthropic OAuth *inference* 400s the instant tools
> are attached (`org_level_disabled` — account-level overage lock, no header flips it). The official `claude`
> CLI dodges it (stays in the Max lane), so a shim drove it as a subprocess — proven end-to-end. BUT at
> Gilligan's full ~28-tool set, Claude Code **defers** the tools and forces its flaky internal **`ToolSearch`**
> step (~40-75% single-attempt success; small tool sets are 10/10). Retries fix reliability but blow past
> Hermes's ~155s turn timeout; no env var / stream-json / blocking-handler / tool-count trim made it fast AND
> reliable. Verdict: not worth blocking the migration. The migration's real wins (off OpenClaw, sub-agents,
> auto-skills) never required Claude as the brain.
>
> **Current pilot state:** default `gpt-5.6-sol`; `glm-5.2`+`kimi-k3` callable via picker/`-m`; MoA trio
> parked; shim code kept at `~/gilligan-hermes/claude-shim/` but its systemd service is stopped+disabled.

# 🚚 Move Gilligan's runtime OpenClaw → Hermes (keep 2 agents)

> **Decision frame (Skipper, 2026-07-30/31):** Move **Gilligan** off the OpenClaw runtime onto the
> **Hermes** framework (the one Boss Herman runs on). **Two agents stay** — Boss Herman remains his own
> separate agent. Driver = **recent OpenClaw instability** + observed Hermes wins (sub-agent orchestration,
> auto skill-updates).

## Why (the real drivers, sorted by true cause)
- **Genuine OpenClaw hit (patched):** plugin trust-gate crash after 2026.7.1-2 update. Fixed, 0 errors since.
- **Anthropic, stack-independent:** 529 overloads + cyber-filter "LLM request failed". These follow me to
  any stack on the same subscription — **but** Hermes's failover chain absorbs them (see below).
- **Real Hermes wins the Skipper observed:** (1) sub-agent orchestration — Herman stays aware while children
  run, they don't go silent/die; cross-provider (OpenAI) spawns don't rot. I compensate for OpenClaw's
  weaker plumbing with a memory *rule* ("always report async work") — that rule existing is the tell.
  (2) Hermes auto-updates skills and announces it; OpenClaw skills are approval-gated + runtime-dir ones get
  wiped on update (where a skill lives decides if it survives).

## Capability audit — grounded in the actual `~/.hermes` install (2026-07-30)
- ✅ **Subscription LLM config — YES, and better.** Framework has tested Anthropic OAuth flow
  (`test_anthropic_oauth_flow.py`) + Claude-Code identity injection (`mcp_serve.py`) — exactly what the
  `sk-ant-oat…` subscription token needs. Herman is on z.ai/GLM, **not** Claude → my sub is a **clean,
  separate provider config, zero contention** with Herman.
  - **Upgrade:** my subscription sits under a failover chain (z.ai → codex/gpt-5.6-sol → opus-4-8 →
    gemini/kimi/ollama). Anthropic 529 → auto-drops instead of wedging. **Directly fixes the instability.**
    Strongest single finding.
- ✅ **Framework maturity HIGH** — own gateway, cron, sessions, 24 skill categories, multi-channel, memory,
  kanban, TTS/STT, MCP. OpenClaw-class, not a toy.
- ✅ **Migration tooling exists + unit-tested** — `_offer_openclaw_migration` in the Hermes setup wizard.
  Devs built an OpenClaw→Hermes path. De-risks porting identity.
- ✅ **Identity ports trivially** — SOUL / MEMORY / wiki / USER / LESSONS / PLAYBOOK / how-we-work are plain
  markdown, runtime-agnostic by design. "Gilligan on Hermes" keeps the accumulated context + relationship.
- ✅ **Domain groundwork partly there** — Herman's `gsts-operations` skill (8 sub-skills) + `trim-it` skill.
- ✅ **VISION — CONFIRMED (Skipper, 2026-07-31).** Was my #1 🔴 unknown (grep didn't locate the multimodal
  module). **Skipper confirms Boss Herman reads screenshots perfectly, daily, on Telegram** → the framework
  *has* image analysis. Gate cleared. (Narrow sliver still worth a 2-min check: reading image **files on
  disk** — today's map PDFs/PNGs — vs only chat-attached images. Same capability likely; verify, don't assume.)

## Remaining gaps — ranked
- ✅ **Channel DECIDED = Telegram (Skipper, 2026-07-31).** Also frustrated with Discord → moving off it.
  Telegram is the proven, known-good Hermes channel (Herman runs on it) → de-risks the pilot. **Gilligan
  needs his OWN Telegram bot** (separate token via BotFather) — Herman's "Boss Hermes" bot is his own,
  locked to the Skipper; must not collapse the two agents into one chat.
- 🟡 **Access model = the real design work.** Herman is deliberately walled (Docker sandbox, default-deny
  terminal). *My* role is the opposite — SSH to play, broad exec, email, deploy-verify, sub-agents, cron.
  Gilligan-on-Hermes needs a **less-sandboxed** instance than Herman = config + a security decision.
  ⚠️ Must preserve the COMMS-SECURITY lock + two-track (BLACK) confidentiality on the new runtime.
- ⚪ **Sub-agent module** — works for Herman (observed); I just didn't pin the exact module this pass. Not a
  blocker.

## Verdict
**Yes, probably → now "yes" pending pilot.** Subscription + failover alone arguably justifies it (fixes the
actual pain), and the make-or-break (vision) is confirmed present.

## ✅ PILOT STOOD UP + VERIFIED (2026-07-31, isolated copy)
- Container **`gilligan`** (image `hermes-agent`, `network_mode: host`, no dashboard port) — compose
  `~/gilligan-hermes/docker-compose.yml`, home `~/.gilligan-hermes:/opt/data`. MuniBot pattern cloned.
- **Isolated copy** of identity + tooling: workspace (wiki/memory/SOUL/MEMORY/USER) + arbor-stack + `.ssh`
  + `.secrets` + `.claude`/`.codex` creds, all copied — writes stay separate from OpenClaw-me. Both alive.
- ~~**Brain = Claude SUBSCRIPTION, verified**~~ — *(2026-07-31, superseded)* that first login used a copied
  `~/.claude/.credentials.json` and did not survive contact: Anthropic **400s the inference**
  (`org_level_disabled`). **Current brain = gbt `gpt-5.6-sol` via `openai-codex`** → [[gilligan-pilot-model-setup]].
  Native vision + `reasoning_effort high` still hold.
- **Telegram connected** (bot `@Gilligan_gsts_bot`): host `getUpdates` probe → **409 Conflict** = instance
  holds the long-poll = live. Locked to Skipper's user id, default-deny.
- ` ⚠️ Access parity note:` container has full WORK surface (play SSH, email, exec, tooling, crew/brain
  creds) via host-net + copied creds. It does NOT have host-Docker-socket / host-root (would = giving a
  broad LLM agent host root) — deliberately withheld pending explicit Skipper say-so.
- ~~**Pending:** Skipper sends any msg to `@Gilligan_gsts_bot`~~ — **DONE.** He messaged it, the DM round-trip
  is proven, and as of 2026-08-01 the bot has **passed a live voice proof task** (see milestone at top).
  1 of the 2 pilot proof tasks remains (the reconciliation-class analytical one).

## Backup — the Hermes clone has its OWN remote (2026-08-01)
The Hermes workspace clone (`~/.gilligan-hermes/home/workspace`) is **independently versioned** —
the 10-min mirror (`sync-workspace-to-gilligan.sh`) copies the primary's working tree in but
**excludes `.git`**, so the clone keeps its own history. It was mistakenly pointed at the SHARED
`gilligan-workspace` origin, which caused a divergence (1 unpushed / 42 behind) that stranded a
commit AND made `git-health-check` fire a false *"primary workspace stranded"* alert (it prints the
bare basename `workspace` for a `.gilligan-hermes` clone). Fixed:
- **Dedicated remote:** origin repointed → `git@github.com:wade3337-ctrl/gilligan-hermes-workspace.git` (private). No more shared-origin collision.
- **Backup loop:** `~/backups/push-hermes-workspace.sh` (guarded: secret-scan + `pull --rebase --autostash` so the agent's own commits never diverge + REFUSES to run if origin isn't the dedicated repo) on a systemd --user timer `push-hermes-workspace.timer` (every 15 min, Persistent, linger=yes).
- **Monitor fix:** `git-health-check.sh` now reports `$ROOT`-relative paths, so a secondary clone can never masquerade as the primary again.
- The stranded commit's unique content (`52ec6b4`: git-identity lesson + Hermes runtime path) was also rescued onto the PRIMARY origin as `a761408`.

## Plan — migration, NOT rip-and-replace
1. **(done)** Capability audit + subscription confirmation.
2. **Vision file-read spot check** — confirm Hermes reads an image *file on disk*, not just chat attachments.
3. **Parallel pilot** — stand up Gilligan-on-Hermes with a **non-sandboxed** config (Discord OR Telegram +
   broad access), port identity files, run against 2 real tasks: one analytical (a reconciliation) + one
   multi-tool (GIS-overlay class). Keep OpenClaw-Gilligan alive alongside.
4. **Cut over only after** the Hermes version has done a real day's work. Downside capped.

## Open decisions for the Skipper
- **Pilot instance:** a SECOND Hermes instance (own container + `~/.gilligan-hermes` bind-mount + own
  config), separate from Herman's `hermes` container — alongside, touches neither Herman nor current me.
- **Need from Skipper to start:** a new **Telegram bot token** (BotFather) for Gilligan.
- Who stands it up — me (I'm in the `docker` group on jdog1), or hands-off with you provisioning secrets?
