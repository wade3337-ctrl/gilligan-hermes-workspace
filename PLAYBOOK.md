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
- 🖥️ **Headless runtime harness for a preact/htm single-file app (no browser here):** extract the `<script type="module">`, strip the `esm.sh` imports + final `render()`, inject stubs (`h=()=>({})`, `useState=(i)=>[typeof i==='function'?i():i,()=>{}]`, `useRef=(i)=>({current:i})`, `useEffect=()=>{}`, `html=(s,...v)=>({s,v})` so every `${…}` interpolation still evaluates, `L`=Proxy, stub `localStorage`/`document`/`fetch`), then **CALL each component render body** in try/catch. Catches TDZ / use-before-declare / undefined-ref that `node --check` (syntax only) misses. This is how I isolated the "whole app blank" regression to one line. Run it after every UI edit. (2026-07-01)
- 📐 **Geometry "cleanup" must be fail-safe — attempt + validate + fall back, never worsen input:** for orthogonalize/simplify/snap, compute the candidate then ACCEPT only if it stays sane (`_drop_degenerate` ~0/180° turns · `_simple` no self-intersection via CCW segment test · area-ratio in [0.6,1.7] · ≥4 pts), else return the plain-simplified ring. Verify numerically server-side (pure-Python, curl + a `__main__` self-test measuring turn-angles), since map interactions can't be browser-tested here. `~/arbor-core/app/api/geo.py`. (2026-07-01)
- 🛡️ **Postgres multi-tenant RLS checklist (reuse for arbor-core + any tenant DB):** `FORCE ROW LEVEL SECURITY` + a non-owner/non-BYPASSRLS app role · composite tenant FKs `(tenant_id,id)` so refs can't cross tenants · RLS on the tenant table itself · fail-CLOSED default GUC (`-1`) + `SET LOCAL` from the validated JWT + cast-guard the GUC — ⚠️ `COALESCE(NULLIF(...,'')::bigint,-1)` only catches `''`/NULL; a **non-numeric** GUC still THROWS on `::bigint` and aborts the txn (verified 2026-06-30). Use a **digit-guard**: `CASE WHEN current_setting('app.tenant_id',true) ~ '^[0-9]+$' THEN …::bigint ELSE 0 END` · `USING`+`WITH CHECK` on every policy · EVERY unique constraint scoped to tenant_id (else existence-probing leak) · privileged owner/admin role physically unreachable from tenant-facing pods · no `SECURITY DEFINER` on tenant tables without self-enforced tenant_id. (2026-06-26)

## 🧠 Agent brains / model auth
- 🔑 **Put an OpenClaw-style agent (e.g. Boss Hermes) on a flat-rate Claude SUBSCRIPTION instead of metered API** (proven 2026-06-30, off OpenRouter onto a work Claude Enterprise plan): user runs `claude setup-token` while logged into the target plan (on Windows: PowerShell blocks `*.ps1` → use `npm.cmd`/`claude.cmd`) → pastes the `sk-ant-oat01-…` token. Wire it as the native **anthropic** provider (`base_url https://api.anthropic.com`, token in env `CLAUDE_CODE_OAUTH_TOKEN`/`ANTHROPIC_API_KEY`), NOT a 3rd-party emulation endpoint. ⚠️ **THE GOTCHA that looks like everything else:** Anthropic REJECTS subscription/OAuth tokens (`sk-ant-oat*`) on the raw Messages API with a **misleading `429 rate_limit_error`** UNLESS the request's **first `system` block is the Claude-Code identity** `"You are Claude Code, Anthropic's official CLI for Claude."` (+ a `claude-cli` user-agent + the `oauth-2025-04-20` beta header). Proven by curl: identical request without the identity = 429, with it = 200. Hermes auto-injects this when its `is_oauth` flag is set (`agent/anthropic_adapter.py`, gated on `_is_oauth_token(resolve_anthropic_token())`); its `hermes -z` oneshot CLI path does NOT set the flag → "no final response" (use the gateway path to test, not `-z`). This is what the old "z.ai anthropic-endpoint, no final response" wall actually was. Always validate the token end-to-end through the agent's OWN client, not just curl.

## 🌐 UI self-verification + arbor-core pricing engine (2026-07-01)
- 🖥️ **Headless browser I + the crew can drive (closes "needs Skipper click-test"):** run `browserless/chrome` as a Docker container on the app's network (`arbor_browser`, `localhost:3010`, `--restart unless-stopped`). Screenshot + JS-console-error count via `~/arbor-core/tools/ui-shot.sh [path] [out.png] '<localStorage-seed-json>'` (seed `arbor_session` to JUMP to a step/proposal instead of clicking through; `WAIT_TEXT=…` waits for render). Raw Puppeteer via `POST /function` (Content-Type `application/javascript`, MUST `return {data,type}`) — click/type/evaluate then screenshot base64. Then `Read` the PNG. Add a `/favicon.ico`→204 route so error count is a true 0 baseline. Doc: `arbor-core/tools/README-browser.md`. **Build UI → self-verify in-browser → THEN hand to the Skipper.**
- 🔑 **Cross-vocabulary entity match = sorted-token key.** Two systems named the same tree "Oak - Coast Live" (Genus-Variety) vs "Coast Live Oak" (natural). A Postgres IMMUTABLE `species_key(text)` = lowercase → non-alnum→space → split → **sort tokens** → join, used as a GENERATED column + in the lookup, makes them match regardless of word order/punctuation. Reuse for any messy legacy-vs-clean name join.
- 🔌 **Keep the clean app decoupled from the legacy DB via nightly MATERIALIZE.** arbor-core's API container can't (and shouldn't) reach TRIM IT's SQL Server. A host-side cron pulls the aggregated grain (price_history ~2.8k rows; site_rebid_history per linked site) → `TRUNCATE`+`\copy` into arbor-core Postgres in one txn. API only ever reads its own DB → fast, offline-safe, decoupled. Constant-size summaries, not raw rows (1.4M invoice lines → ~20k combos).
- 💵 **Price FORWARD as hours×target to get cost-model distribution for free.** Backtest (25 real jobs) proved distributing a job total by *size* misallocates ~13% of dollars (indefensible unit prices), while distributing by crew-hours reproduces actual prices near-perfectly. So build the reconciler as `unit_price = est_hours × target_TPH` per line (blended TPH = Σrevenue/Σhours; non-tree charges EXCLUDED) — the "rubber-band" distortion literally can't occur, and it's municipal-audit defensible.

## [arbor-core / georeference] Legacy base-map PDF -> real-GPS work-zone (PROVEN 2026-07-02, ~5.6m RMS)
No CV libs / no pip on this box, and old TRIM IT base maps store NO coordinates. Solved fully automatically:
render PDF headless (pdfjs-dist + browserless, `URL.parse` polyfill for old Chrome) -> extract the yellow zone
by color-threshold + **largest connected component** (kills the legend's yellow cell) -> geocode the site
address (Nominatim) -> pull live **Esri World Imagery** via headless Leaflet so every pixel's lat/lng is exact
Web-Mercator math -> **Gemini 3.1-pro vision-matching** (extended `crew/gemini-ask.py` with `GEMINI_IMAGES=a,b`
-> inlineData parts; ask for >=8 shared permanent landmarks as normalized [y,x] in BOTH images) -> old-fraction
<-> GPS control points -> solve affine with plain 3x3 normal equations (no numpy) -> project the polygon.
Overlay landed tight on the complex. Keep a one-drag nudge for the ~few-meter residual. The browser container
is my image toolkit here (canvas pixel-ops, tile stitching via Leaflet, PNG export) since PIL/poppler/OpenCV
aren't installed.

## [arbor-core / crew] Fable 5 added — and which model wins the georeference vision-match (2026-07-02)
Added crew member #6: `crew/fable-ask.py` = Claude Fable 5 (Anthropic's most-capable tier; `claude-fable-5`;
vision via `FABLE_IMAGES=`; adaptive-thinking always-on so DON'T set temperature; key `~/.secrets/fable.json`).
**Head-to-head on the Greenwood georeference landmark-match (same PDF/esri, swap only the matcher via
`GEOREF_MATCHER=gemini|fable`): Gemini 3.1-pro RMS 0.2–3.8 m vs Fable 5 RMS 12 m.** → For PRECISE pixel/spatial
grounding (pointing at the same corner in two aerials), **Gemini clearly wins** (Google's native grounding). Keep
Gemini as the georeference matcher. Fable's value is elsewhere: deep reasoning, hard code, plan/architecture
review, adversarial verification — call it deliberately (2× Opus 4.8 cost). One-sample but a wide, non-noise gap.

## 🌐 Headless browser can render + auth the TrimIT PLAY site (not just arbor-core) (2026-07-02)
The `arbor_browser` browserless container can drive a REAL click-through of ColdFusion play pages, giving me + the crew actual screenshots + JS-error counts before the Skipper ever clicks. Play's TLS cert is VALID (`curl` `ssl_verify=0`), so no ignore-HTTPS needed. Auth = the same `ZUserID` cookie gate view.sh uses. Puppeteer via `/function`:
`await page.setCookie({name:'ZUserID',value:'376',domain:'play.greatscotttreeservice.com',path:'/'});` then `page.goto('https://play.greatscotttreeservice.com/GSTS/<path>')`. To verify a specific column: `page.evaluate` the cell's `getComputedStyle(...).whiteSpace`, sample texts, then set the wrapping `overflow-x` div's `scrollLeft` to reveal a far-right column before the viewport screenshot. (Template script: `steves-projects/diligence-sales-history/work/shot-tph.js`.) Closes the "needs Skipper click-test" gap for TrimIT repairs too.

## 📊 AR digest: property from the invoice Memo + safe per-rep routing (2026-07-02)
- **Property/community hides in the invoice-level sheet, not the summary.** Dimitry's AR-Aging workbook summary is
  PM-company-grain (no property). The **"AR Aging Subtotals"** sheet is invoice-level: col Memo carries the community
  (e.g. "2026 - (AprJun) Creekside Village - (3 Year Plan)"), + per-invoice Aging days + Open Balance. Parse the memo
  (strip leading "[TAG]"/"N%?"/"(N)"/year/"(SEASON)"; iteratively strip trailing "(3 Year Plan)/(CO ####)/(Revised…)"
  but KEEP "(Tract ####)"); raw-memo fallback when thin. Anchor account totals on the reviewed **summary** sheet;
  the parsed property lines reconcile to it (29/31 within $2; Powerstone tied to the $). Cap sub-lines (8 + "+N more").
- **Per-rep email routing safely:** addresses in a JSON (`ar-report/rep-emails.json`) editable w/o code; a `--live`
  flag (default preview), a `--dry` flag that prints the recipient plan, and a HARD GUARD that SKIPS any blank address
  (never guess-sends). Go-live = fill addresses + add `--live` to the cron runner. This let the Skipper confirm exact
  addresses from a dry-run before a single real email went out.

## 🔐 Give another agent/box its OWN read-only DB access, safely (2026-07-02)
Wanted: Herman queries the live SQL Server himself, read-only, without spreading admin keys. Pattern that worked:
1. **Dedicated read-only SQL login** — `CREATE LOGIN HermanRO ... ; CREATE USER FOR LOGIN; ALTER ROLE db_datareader ADD MEMBER`. Verify BOTH ways (SELECT works, CREATE/INSERT denied). Enforces read-only AT THE DB.
2. **Forced-command SSH gateway on the RECOVERABLE box (mine, not the DB server)** — a wrapper script that reads SQL on stdin and runs `sqlcmd -U HermanRO`, plus an authorized_keys line `command="…wrapper",no-pty,no-port-forwarding,… <herman-pubkey>`. The agent's key can ONLY run the wrapper (tested: `cat /etc/passwd` is ignored, read query runs). Back up authorized_keys first; put the gateway on a box you can fix, not the DB server.
3. **Persistence:** the play DB reverts nightly → an hourly `schtasks` runs an idempotent re-grant so the read role self-heals.
- **When `gh` is absent, create GitHub repos via the API:** `curl -H "Authorization: token $PAT" https://api.github.com/user/repos -d '{"name":"…","private":true}'` then `git remote add origin https://<user>:$PAT@github.com/<user>/<repo>.git && git push`. (PAT at ~/backups/.gh-token.)
- **Build an agent KB "map, not cache":** pre-document the ~100 core tables + decoders (live-pulled: sys.columns, sys.foreign_keys, StatusDefs, ProjectGroupDefs) + a vetted query playbook; leave the long tail for live `sp_helptext`/catalog lookup. An agent with DB access needs the MAP + recipes, not a data dump.

## 🧠 Wiring a Hermes agent's auto-failover brain (2026-07-03)
Goal: when Boss Herman's primary model (z.ai/GLM) errors, Hermes auto-switches his OWN thinking to a backup mid-session. TWO things required (a Codex CLI login alone is NOT enough — that's only the `codex exec` *tool*):
1. **Register the fallback provider in Hermes's OWN credential store:** `hermes auth add openai-codex` (ChatGPT OAuth **device-code** flow — headless-friendly: prints a URL + code the human opens) → confirm with `hermes auth list` (shows `openai-codex-oauth-1`).
2. **Set the fallback in config:** `/opt/data/config.yaml` → `fallback_providers: [{provider: openai-codex, model: gpt-5.5}]` (prefer `hermes fallback add`, which validates), restart the gateway.
- **PROVE it fires — don't trust a doctor/tool check:** point the primary `base_url` at a dead addr (192.0.2.1), send a prompt, grep the log for `Fallback activated: <primary> → <fallback>`, then restore the primary. (Failover ~3.5min on dead-host timeouts; near-instant on 429/5xx.)
- Docs: `hermes-sandbox/website/docs/user-guide/features/fallback-providers.md`. `openai-codex` uses the ChatGPT subscription; fallback provider must differ from primary (z.ai fallback wouldn't survive a z.ai outage).

## 🔎 Verify an agent's self-report against its PRIMARY log — and know WHERE that log is (2026-07-03)
Boss Herman reported a passed failover drill. His summary was accurate on the *outcome* but wrong on the *method* (claimed `base_url→127.0.0.1:1 connection-refused`; the log showed the real failure was a **401 from `api.anthropic.com`** — the dead-addr edit made the client default to Anthropic's endpoint with the bad key). Lesson: **read the primary log, confirm both the machine event AND the fallback's actual answer** (`Fallback activated: …` + `API call #1: model=<fallback> latency=…`), not just the agent's prose.
- **The trap that almost made me call a REAL pass "unproven":** after a version update the log can MOVE. Hermes **v0.18 writes detailed model/fallback events to `~/.hermes/logs/agent.log` (file), NOT `docker logs` (stdout)** — stdout looked empty. Before ruling a failover unproven, `grep -rl` the agent's whole data dir for the evidence strings; check file logs + `state.db`, not just container stdout.

## 🐳 Updating a containerized Hermes agent (host-side image swap, NOT in-container) (2026-07-03)
A Docker-deployed Hermes updates by **swapping the image**, not patching files in place — a container can't replace its own running self, so it's a **host** op. Recipe for Boss Herman (local fork built from `~/hermes-sandbox`): `git -C ~/hermes-sandbox pull --ff-only` → `HERMES_UID=$(id -u) HERMES_GID=$(id -g) docker compose up -d --build`. Backup-first: `docker tag hermes-agent hermes-agent:rollback-<date>` (instant revert) + copy `config.yaml`/`auth.json`/`.codex` off-mount. **State survives** because it's all on the `~/.hermes:/opt/data` bind mount; only in-image code is replaced. Gotchas: a dirty local file (our Dockerfile perf-trim) silently blocks `git pull` — `git stash` it first, and check if upstream already made your customization redundant; a version bump may force a credential **re-auth** even though the cred files persist.

## 🌳 RFP intake→draft pipeline (Boss Herman, 2026-07-03)
- ✅ Full v1 proven on a real request (Paradise Palms HOA): normalizer (geocode + Brave web + TRIM IT DB match) → qualified `intake_record` (GO, tier, land-and-expand signal: PM co was an existing *contact* w/ no billing) → **Fable** drafted a send-ready proposal (flagged pricing + rep placeholder, invented nothing) → **Gemini** verified.
- ⚠️ **Verifier calibration:** give the "does the draft invent facts?" checker the company's OWN identity (GSTS/Great Scott Tree Care) as a KNOWN CONSTANT — else it false-flags the sender's own name as "unsupported." Only flag unsupported CUSTOMER/SITE/SCOPE facts.
