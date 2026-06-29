# PLAYBOOK.md — What WORKS (proven techniques · self-improvements)

**Purpose:** the **Hermes self-improvement file** — when I figure out how to do something *well*, the technique goes
here so future-me (and the crew) reuse it instead of re-deriving. Paired with `LESSONS.md` (what to avoid).
**🔄 AUTO-UPDATE RULE:** the instant I nail a non-obvious technique, add it here, tagged by domain — in the moment.
In my lookup path via `ROUTING.md` + `MEMORY.md`. Format: `- ✅ <technique> — <how / why it works>. (date)`

## 🤖 Models / crew (cross-model verification)
- ✅ **GLM via direct z.ai API** — `echo "<prompt>" | python3 ~/arbor-core/crew/glm-ask.py` (Bearer →
  `/api/anthropic/v1/messages`). Reliable single-shot; feed DB evidence inline (it can't run tools). (2026-06-21)
- ✅ **Gemini (4th crew member) via direct Google API** — `echo "<prompt>" | python3 ~/arbor-core/crew/gemini-ask.py`
  (key `~/.secrets/gemini.json` 0600; `?key=` param → `generativelanguage.googleapis.com/v1beta/models/<m>:generateContent`).
  Single-shot, **API not CLI** (avoids the Codex/GLM-CLI flakiness — most reliable judge so far); feed evidence inline.
  **PAID tier (billing on 2026-06-25)** → default `gemini-3.1-pro-preview` (top reasoner, reliable; passed live reasoning test). `GEMINI_MODEL` env overrides: `gemini-3.5-flash` (newest but often **503-overloaded**), `gemini-2.5-pro/flash` (fallbacks). Debuted verifying City Budgets FY fix ✅. (2026-06-25)
- ✅ **3-lab verification gate** — Claude produces, **Codex + GLM independently judge** (re-run queries / reason).
  Catches real errors before they ship (caught schema + pricing over-reaches). (2026-06-21)
- ✅ **GLM as an independent TOOL-RUNNING judge** — `python3 ~/arbor-core/crew/glm-judge.py task.txt`: a controlled
  loop where **stable Python runs the read-only queries** and GLM drives (`RUNSQL: <q>`) + reasons (`VERDICT: …`).
  Gives GLM **live-DB verification without the unreliable agentic CLI**. Tested: GLM caught stale counts vs live data. (2026-06-23)
- ✅ **Adversarial review** — tell the judge to *refute*, default-skeptical; it surfaces over-reach a friendly read misses. (2026-06-21)

## 🗄️ DB / data archaeology (TRIM IT)
- ✅ **Population fingerprinting** — infer a field's meaning by matching its populated-count to known funnel anchors,
  then **confirm with co-population** (same rows?). A bare count is a lead, never a verdict. (2026-06-21)
- ✅ **SOURCE-vs-DERIVED via write-path analysis** — read `sys.sql_modules`: a `Generate*` **stub-create**
  (`INSERT…VALUES('** New … **')` the user then edits) = SOURCE; `INSERT…SELECT` copy / Snapshot / Reconcile =
  DERIVED. Triggers via `sys.triggers.parent_id`. (2026-06-21)
- ✅ **Read-only DB:** `echo "SET NOCOUNT ON; SELECT …" | bash ~/arbor-stack/production-dashboard/gsql.sh`, ONE query
  at a time. Column profiler: `arbor-core/reference-maps/_tools/profile-cols.sh`. (2026-06-21)
- ✅ **Persist prototype state on PLAY despite the nightly GSTS refresh** — the refresh restores ONLY the GSTS db, so
  put writable prototype data in a **SEPARATE database on the same SQL instance** (e.g. `Workbench`) and it survives.
  Reach it from ColdFusion through the **existing GSTS datasource using 3-part names** (`Workbench.dbo.Tbl`) — CF
  connects as `sa`, so it already has cross-DB access; **no new CF datasource or grant needed**. Writes via a tiny
  `MERGE`-upsert `.cfm` endpoint (cfqueryparam). The answer to the long-stuck "notes don't save on play." (2026-06-25)
- ✅ **Aggregate-over-subquery workaround** — `SUM(CASE WHEN EXISTS(subquery)…)` throws SQL 130; compute the per-row
  flag in a CTE/derived table first, then `SUM()` the flag. (2026-06-25)

## 🌳 TRIM IT / web inspection
- ✅ **Render a live TRIM IT page (no screenshots):** `bash ~/arbor-stack/production-dashboard/view.sh '<page.cfm?args>'`
  (read-only, bot user 376). Find the real page via `AppForms.ObjectPath`; app endpoints are folder-relative. (2026-06-22)

## 📧 Email
- ✅ **Read my inbox:** Python `imaplib` (stdlib) on `gilligan.gsts@gmail.com` (creds
  `arbor-stack/anomaly-monitor/.secrets/gmail.json`); search `[Gmail]/Sent Mail` by `SINCE "DD-Mon-YYYY"`. Send via
  `anomaly-monitor/send-email.js` (`--html --bodyFile`) or `send-files.js`. (2026-06-22)

## 📄 Files / PDF / image assets
- ✅ **Render a (vector) PDF → crisp PNG with NO poppler/imagemagick/gs** (none on this box): `npm i mupdf` (WASM,
  zero native deps) → ESM script: `doc=mupdf.Document.openDocument(new Uint8Array(buf),"application/pdf")`,
  `page.toPixmap(mupdf.Matrix.scale(4,4), mupdf.ColorSpace.DeviceRGB, /*alpha*/true).asPNG()`. `alpha=true` →
  transparent bg; scale 4 ≈ 288dpi. Tight-cropped to the artbox automatically. Used for the GSTC 50th logo. (2026-06-25)

## 🪟 Windows-over-SSH (Hermes laptop / gstsdatabase)
- ✅ **PowerShell over SSH:** base64 `-EncodedCommand` (UTF-16LE); run a child `ssh` via `Start-Process` not `&`;
  `scp` large scripts (cmd line-length cap).
- ✅ **Deploy GLM to a Windows box (laptop Herman, 2026-06-23):** write `glm.json` to `~/.secrets/` (Python
  `expanduser` resolves it on Windows too), `scp glm-ask.py` over, lock the key with
  `icacls <file> /inheritance:r /grant:r "NT AUTHORITY\SYSTEM:F" "BUILTIN\Administrators:F" "%USERNAME%:F"` (confirm
  no `(I)`), test via the agent's **venv python**. Use a **DEDICATED API key per machine** (blast-radius isolation —
  leak ⇒ revoke just that one). `glm-ask.py`'s Bearer→x-api-key fallback also rode out a transient z.ai 529.

## 🧑‍🤝‍🧑 Working with the Skipper
- ✅ **Strawman-to-react beats blank-page interview** — he steers fastest off a concrete draft. One question at a
  time; bullets > prose; teach the *why*.
- ✅ **Distinguish necessary vs accidental complexity** — keep the real business variability, kill only the bad
  *implementation* (e.g. per-contract pricing must stay; the hardcoded city procs go). (2026-06-22)
- 🎨 **WIP / "Arbor Helper" status convention (reuse on every sales dashboard):** WIP = the project/customer has an **Active or InProcess WorkOrder** (NOT just an active project — too broad). Visuals: green row tint `#eef7e6` + left accent `inset 3px 0 0 #5C743D`; **happy** Arbor Helper = active, **sad** = lead/follow-up. Icons via shared `css/gsts-icons.css` (`<span class="arbor-helper happy|sad [sm|lg]">`; PNGs in `assets/icons/`). Link the shared CSS, don't re-draw. Map markers: green WIP / gray lead. Established Clusters page; ported to ZTest pipeline tool 2026-06-23. (2026-06-23)
- 📊 **TPH target + color bands (reuse everywhere):** company target = **`dbo.GoalSettings.TargetTPH`** (currently 130) — pull it LIVE, do NOT hardcode (auto-follows if Scott changes the goal). `Projects.TargetTPH` is per-project but ~empty (6/3317) — don't rely on it. Standard 3-tier bands relative to target: **good** >= target `#d1fae5`/`#047857`, **warn** >= target-10 `#fef3c7`/`#92400e`, **bad** < target-10 `#fee2e2`/`#991b1b`, na `#eef0ee`/`#999`. Matches the Executive$Sales dashboards. (2026-06-23)
- 🤝 **Cheap-model tool tier = "harness drives, model steers"** (CREW): models that can't run tools (GLM, Gemini) still do real work if a stable Python harness performs the ops and the model emits one action per turn. `glm-judge.py` (read-only SQL) and `glm-worker.py` (file edits via exact SEARCH/REPLACE, WORKER_ROOT confinement + backups + end-of-run diff) prove it. Reliable + flat-rate; reuse this pattern before reaching for a flaky agentic CLI. (2026-06-26)
- 🧬 **Cloning a worker to a new lab is turnkey** (CREW): `kimi-worker.py` = 1:1 copy of `glm-worker.py`, ONLY the model-call function swapped. Two gotchas: (1) OpenAI-compat endpoints (Kimi) have no separate `system` field → prepend SYSTEM as a `role:"system"` message (GLM/Anthropic-compat passes it separately); (2) Kimi is a reasoning model → `max_tokens` generous (4000) or `content` is empty. Bench (2026-06-26, same 2-edit CFML fix): GLM vs Kimi = byte-identical correct diffs; GLM faster (3 rounds/~10s) vs Kimi (4 rounds/~27s, self-verifies). Default=GLM, Kimi=cross-lab/fallback. See `arbor-core/docs/WORKER-BENCH.md`. NB: report mailer lives at `~/arbor-stack/anomaly-monitor/send-email.js` (NOT under `.openclaw/workspace`); `--subject`/`--body`, defaults From gilligan.gsts→To jwade@gstsinc.com. (2026-06-26)
- 🌡️ **Pin temperature 0 for SQL/schema/grounding** crew calls (`CREW_TEMP` env on all helpers) — stops "creative" SQL hallucination on delicate DB ops; only raise temp when you actually want divergent brainstorming. (2026-06-26)
- 🏁 **Crew gate PROVEN to have teeth (plant test, 2026-06-26):** authored a producer packet with 2 deliberate plants (a wrong count 16-vs-14, and a snapshot table claimed as a "live source"), ran 3 judges on 3 different labs blind/parallel — ALL three independently BLOCKED, each plant caught in its own lane (GLM grounding re-queried→14; Codex lineage read the Generate proc's INSERT…SELECT; Gemini flagged both by reasoning). Cross-lab independence is real, not rubber-stamp. Reuse the plant-an-error design to validate any new verification harness before trusting it. (2026-06-26)
- 🔬 **3rd lab earns its seat on isolation/security gates — fan ALL labs even if 2 already passed.** On the arbor-core tenant gate, Codex PASS + GLM PASS-w-fixes looked done — then Gemini (once its timeout bug was fixed) caught 2 MAJOR neither saw: natural-key probing (UNIQUE is checked OUTSIDE Postgres RLS → scope every unique to tenant_id) and SQLi→`SET LOCAL` GUC-spoof. Different lab = different blind spots, especially on Postgres-specific RLS edge cases. For security-critical gates, don't stop at 2 green. (2026-06-26)
- 🛰️ **Run crew gates FOREGROUND, in-turn (comms rule, proven 2026-06-28)** — the result then lands as a normal reply (Skipper sees it) AND stays in my context (I digest it in my voice). Background-shell hides it from him; a `sessions_spawn` sub-agent hides it from me. Finish line = Skipper confirms receipt; re-send if it doesn't land. Very-long runs may auto-background → chunk them into in-turn pieces. (2026-06-28)
- 🛡️ **Postgres multi-tenant RLS checklist (reuse for arbor-core + any tenant DB):** `FORCE ROW LEVEL SECURITY` + a non-owner/non-BYPASSRLS app role · composite tenant FKs `(tenant_id,id)` so refs can't cross tenants · RLS on the tenant table itself · fail-CLOSED default GUC (`-1`) + `SET LOCAL` from the validated JWT + `COALESCE(NULLIF(...,'')::bigint,-1)` · `USING`+`WITH CHECK` on every policy · EVERY unique constraint scoped to tenant_id (else existence-probing leak) · privileged owner/admin role physically unreachable from tenant-facing pods · no `SECURITY DEFINER` on tenant tables without self-enforced tenant_id. (2026-06-26)
