# LESSONS.md — What Didn't Work (gotchas · dead-ends · anti-patterns)

**Purpose:** the ONE place I check *before* a task to avoid repeating a known failure. Paired with `PLAYBOOK.md`
(what works). **🔄 AUTO-UPDATE RULE:** the instant something fails or wastes real time, I add a one-line entry here,
tagged by domain — *in the moment*, not "later." Kept **lean** (consolidate, don't pile). In my lookup path via
`ROUTING.md` + `MEMORY.md`. Format: `- ⚠️ <the trap> → <the fix/avoid>. (date)`

## 🤖 Models / CLI tooling
- ⚠️ **OpenClaw generic Discord error after Opus stops can be Claude Code auth, not Discord/OpenClaw** — logs showed `claude-cli` returning `401 Invalid authentication credentials` while `claude auth status` still said logged in. → check `journalctl --user -u openclaw*` / `/tmp/openclaw/openclaw-YYYY-MM-DD.log`; fix by refreshing Claude CLI auth (`claude auth login`, then `claude setup-token` if needed). (2026-06-29)
- ⚠️ **Opus can have two simultaneous auth blockers** — Claude CLI may be stale (`claude -p` returns `401` even when `claude auth status` says Max/loggedIn), while OpenClaw manual Anthropic token may be valid but blocked by Claude's "third-party apps draw from extra usage" billing gate. → test both paths separately: direct `claude -p` for CLI, `openclaw agent --model anthropic/...` for manual token; fix CLI with `claude auth login`, fix manual token by adding extra usage at `claude.ai/settings/usage` or using a fresh setup token with available balance. (2026-06-29)
- ⚠️ **Ollama `llama3.2:3b` at 131k context can effectively wedge the laptop** — logs showed CPU runner allocating ~14GB KV cache on a 15GB box after Claude/OpenClaw fallback, followed by Docker/Discord timeouts and stuck OpenClaw runs. → keep Ollama CPU-only for the unsupported GTX 1050 Ti and cap local model context around 4k/8k unless intentionally running a memory test. (2026-06-30)
- ⚠️ **GLM (& Codex) agentic `claude -p` CLI is UNRELIABLE here** — it **HANGS (124) OR SIGKILLs (137)** on tool
  loops. Root-caused 2026-06-23: the CLI's **agentic orchestration with the backend** is the broken part, NOT GLM or
  the box (GLM via direct API answers in seconds). → use `~/arbor-core/crew/glm-ask.py` (reasoning) or
  **`glm-judge.py`** (tool-running DB-verification via a stable Python loop). (2026-06-21 / 23)
- ⚠️ **Codex `codex exec` also dies (137) on heavy *nested* runs** — the sandbox kills fat subprocess trees;
  lightweight calls (gsql, GLM-API) are fine. Don't depend on long nested CLI agents. (2026-06-22)
- ⚠️ **Background sub-agents get killed mid-run** (the v1.1 producer was) — the **main session is stable**; do
  consequential long work there, not in detached background agents. (2026-06-22)
- ⚠️ **Kimi empty/truncated output = the HELPER `max_tokens` cap, NOT the account** — K2 is a reasoning model and burns the budget *thinking* before it emits the answer, so "ran out of budget" was `kimi-ask.py`'s cap (raised 8k→16k→**40k**) while the Skipper's Kimi account was ~1% used. Raise `max_tokens` before suspecting billing. (2026-06-28)

## 🗄️ DB / SQL (TRIM IT, sqlcmd via gsql.sh)
- ⚠️ **`gsql.sh` takes a FILE or STDIN, not an inline arg string** (it `cat`s $1) → pipe SQL on stdin. (2026-06-21)
- ⚠️ **`gsql.sh` writes ONE shared remote temp file** → concurrent queries clobber each other → run **sequentially**
  or use a per-process isolated wrapper. (2026-06-21)
- ⚠️ **Reserved words as a column alias break sqlcmd** ("Incorrect syntax near 'proc'") → use a safe alias (`pname`). (2026-06-21)
- ⚠️ **`SUM(CASE WHEN EXISTS(subquery)…)` / aggregate over a subquery → SQL error 130** → compute the per-row flag in a CTE/derived table, then `SUM()` it. (2026-06-25)
- ⚠️ **A literal `#` in ANY double-quoted CFML string = "missing ending #" / interpolation error — NOT just inside `<cfoutput>`** (also `<cfset x="...#77...">`, array literals, etc.). Bit me twice in one day (inline `color:#fff`, then `#77` inside a `cfset` repairRows array). → escape as `##`. (2026-06-25)
- ⚠️ **Don't BATCH the live `Reference-RepairsAndScheme.cfm` sync** — update its `repairRows`/`buildRows` when you write each `gsts-ship-log.md` row, not "later." Let it drift 13 entries behind once (Skipper caught it). Edit it byte-level (ASCII-only inserts after a newline) since it's UTF-8 + may have a BOM. (2026-06-25)

## 🗺️ Leaflet / maps
- ⚠️ **Leaflet CANVAS renderer (`preferCanvas:true`): the DOM `pointer-events:none` trick to make an overlay click-through is a NO-OP** — canvas paths have no own DOM element, so `layer.getElement()` returns nothing and the style never applies. A filled *interactive* polygon then swallows clicks meant for markers underneath (bit the workbench lasso twice — #77 "fixed" it this wrong way). → set **`interactive:false`** on the overlay so Leaflet skips it in JS hit-detection; the shape still renders. (2026-06-25)

## 📧 Email (gilligan.gsts gmail)
- ⚠️ **Self From=To lands in Sent, not Inbox** → keep From≠To.
- ⚠️ **Rep daily emails are plain-text only (no HTML part)** → extract `text/plain` when copying/forwarding; grabbing
  the HTML part returns BLANK (I sent the Skipper an empty copy once). (2026-06-22)
- ⚠️ **ImapFlow by-UID lookup** needs `{uid:true}` in the OPTIONS (3rd) arg of `fetchOne`/`fetch`, NOT the query — a
  bare number is a *sequence* number → silent false→crash. (2026-06-20)
- ⚠️ **I can read `gilligan.gsts@gmail.com` only — NOT `jwade@gstsinc.com`** (no M365). Inbound to jwade must be forwarded. (2026-06-22)

## 🌳 TRIM IT / web (ColdFusion)
- ⚠️ **The GSTS app's `.cfm` files aren't in `C:\...\wwwroot\GSTS`** (near-empty) — they serve from the **D: webroot**.
  Don't conclude "missing" from the C path. (2026-06-22)
- ⚠️ **Menu "window" names ≠ filenames** — resolve the real page via `dbo.AppForms.ObjectPath`; an app's JS endpoints
  are **relative to that app's folder** (e.g. `FieldApp/...`), so root-level fetch 404s. (2026-06-22)
- ⚠️ **`.cfm` with emoji/non-ASCII needs a UTF-8 BOM** or ColdFusion serves mojibake (`ssh type` strips it). **Cleaner alt: use HTML numeric entities** (`&#NNNN;`) → ASCII source, no BOM. CF only treats `#` special *inside* `<cfoutput>` → single `#` in static HTML, **double `##` inside cfoutput** (collapses to one on render). (2026-06-25)
- ⚠️ **Substring role-matching trap:** CFML `CONTAINS "coo"` matched "**coo**rdinator" → Sales/Production *Coordinators* mis-tagged as exec. Use **padded whole-word checks** (` coo `/` ceo `) for short tokens; avoid over-broad keywords like bare "director". Always test role logic against real users. (2026-06-25)
- ⚠️ **Dual-webroot shadow:** `C:\ColdFusion...\GSTS` can OVERRIDE `D:\...\GSTS` → render-verify the *served* output.

## ⚙️ Config / infra
- ⚠️ **`~/.openclaw/openclaw.json` has clobber history** → always back up + merge-patch, never overwrite.
- ⚠️ **Python 3.14 here has no package manager + no passwordless sudo** → use stdlib; Skipper installs system pkgs.
- ⚠️ **No headless browser** → authenticated HTTP fetch (view.sh) for web/ERP pages.
- ⚠️ **MEMORY.md silently clipped at ~20k** → `agents.defaults.bootstrapMaxChars`/`bootstrapTotalMaxChars` were UNSET in `~/.openclaw/openclaw.json` (bootstrap truncated). Set them (40000 / 160000), back up the config first, and restart to apply. (2026-06-28)

## 🧑‍🤝‍🧑 Working with the Skipper / process
- ⚠️ **Don't let background/inter-session chatter drown the user** (`[[subagent-completion-noise]]`) — surface real
  status; never go silent through a direct question.
- ⚠️ **Don't over-claim beyond the evidence** — GLM caught me twice asserting *behavior* from row-counts (pricing map).
  State only what's proven; flag inferences as inferences. (2026-06-21)
- ⚠️ **"Set up" ≠ working** — laptop GLM was reported "set up" but had **NO key/client/config** at all. Always VERIFY
  the config actually persisted (key present? endpoint right? client runs?) before assuming a setup landed. (2026-06-23)
- ⚠️ **Don't run a crew gate where only ONE of us can see the result** — a background-shell run leaves the Skipper blind to it; a `sessions_spawn` sub-agent leaves ME blind to it (supersedes the 06-26 "spawn a sub-agent for long crew work" note). → run gates **FOREGROUND, in-turn**; confirm the Skipper got it, re-send if it doesn't land. (2026-06-28)

## 🪟 Windows / SSH (Hermes laptop)
- ⚠️ **Recursive `dir /s` / `findstr /S` over the user profile or a venv HANGS the SSH session** (timed out 3× in a
  row) → keep Windows recon **NON-recursive**; target specific files/dirs. (2026-06-23)
- ⚠️ **My laptop SSH key can get de-authorized** (it was removed from `administrators_authorized_keys` during a
  Herman setup) → if `Permission denied (publickey)` but host key matches, my key was dropped; have Herman re-add it. (2026-06-23)
- ⚠️ **`icacls … /inheritance:r` may not stick if chained loosely** — run it cleanly and CONFIRM with a follow-up
  `icacls <file>` (look for `(I)` = still inherited). (2026-06-23)
- ⚠️ **Laptop Herman brain = GLM is UNRESOLVED (2026-06-23):** Hermes's built-in **z.ai provider uses the METERED
  `/paas/v4`** (blocked on the coding plan → "insufficient balance"); forcing `glm-5.2` via Hermes's **anthropic**
  provider + the z.ai **anthropic** endpoint produced **"no final response"** (Hermes↔z.ai coding-endpoint
  compatibility gap — needs `hermes` debug-log analysis). Herman was ALREADY pre-set to glm-5.2/metered (= the
  original "GLM not working"); its model config is **NOT** in `~/.hermes/config.yaml`. GLM-as-a-TOOL works (`glm-ask.py`).
- ⚠️ **ColdFusion: literal `#` inside `<cfoutput>` errors** — a hex color (`color:#ffe08a`) or any `#...#` in cfoutput is read as a CF variable → "An error occurred" with debug off. **Escape as `##` (`##ffe08a`)** or move the literal outside cfoutput. Cost ~2 deploys to spot (2026-06-23, ZTest-SiteMap).
- ⚠️ **CF dynamic SQL: avoid `--` line comments inside `<cfquery>`** — if the newline collapses, `--` comments out the rest of the query. Use `/* ... */` block comments. (2026-06-23)
- 💡 **TrimIT geo data has bad geocodes** — active job sites include sign-flipped longitudes (+117 vs -117 → Asia) and mis-geocodes (UK/NM/ID). Any map MUST bound to a SoCal sanity box (lat 32–35.5, lng -121 to -114) and *count+flag* the strays, never silently fit-to-all (4/2906 active blew the view worldwide). Fixable in the geocode backfill pass. (2026-06-23)
- ⚠️ **Leaflet canvas (preferCanvas): don't `removeLayer`/`addTo` circleMarkers to filter** — they fail to repaint on re-add (filter down works, clearing the filter leaves them gone). Instead keep all markers on the map and toggle visibility with `setStyle({radius:0,opacity:0,fillOpacity:0})` for hidden / real style for shown — `setStyle` repaints reliably both directions, and radius:0 = visually off the map + no overlap. (2026-06-23, ZTest-SiteMap)
- ⚠️ **Don't trust a "model X is flaky" verdict without a repeat test.** Codex was written off as flaky (Jun 25 City Budgets, exit143) — re-tested Jun 26, 8/8 clean incl. a heavy 3-query verify. The real causes were (a) a transient blip and (b) MY prompt leaking a sentence period as a shell arg (`gsql.sh .` → cat-ed a dir → empty → model reported "0"). Check ground truth + prompt hygiene before blaming the tool; one bad run ≠ broken. (2026-06-26)
- ⚠️ **Shell-wrapper scripts should fail loudly on a stray/garbage arg**, not silently return empty. `gsql.sh` used `cat "${1:-/dev/stdin}"` → a `.` arg cat-ed a directory → empty SQL → a model misread the blank as a real `0`. Guard: if `$1` is set and not a readable file, error+exit. (2026-06-26)
- ⚠️ **dbo.SalesRepPerformance is a SNAPSHOT, not a source** — populated by `GenerateAllSalesRepPerformance` (INSERT…SELECT from other tables), per-period rollup (PeriodID + InvoiceTotal/NetTotal/TPH cols), 0 triggers. Do NOT build arbor-core sales attribution/perf on it; use dbo.SalesReps (base entity: SalesRepID/IsMeasured/StatusDefID) + transactional sources. Verified by Codex lineage judge 2026-06-26. (2026-06-26)
- ⚠️ **Crew HTTP helpers must use a generous timeout + catch timeouts, not just HTTPError.** `gemini-ask.py` had `timeout=120` and only caught `HTTPError` → big reasoning prompts (3.1-pro on a full schema-gate dump) took ~121s and died with a raw `TimeoutError` traceback (silent `[gemini 1]`, empty output) — looked like "Gemini is down" but the API + key were fine. Fixed: 300s default (`GEMINI_TIMEOUT`) + retry loop catching `URLError`/`TimeoutError`/5xx/429. Apply the same pattern to every `*-ask.py` helper. (2026-06-26)
- ⚠️ **Always feed the crew the CURRENT artifact — stale-prompt = wasted run + muddled report (2026-06-26).** Ran a Kimi schema judge but pointed it at the OLD v1.2 review prompt (a leftover lens file), so it judged v1.2 while the live schema was v1.6 → most of its 12 findings were already fixed (e.g. it flagged the per-entity-transition issue we'd resolved in v1.4). Had to cross-check every finding against current to separate stale from live. Rebuild the evidence bundle from the CURRENT version before every (re-)gate; never reuse an old lens file. (Bright side: it still caught 1 real live gap — an undefined `agent` table — proving the value, but that was luck, not hygiene.)
- ⚠️ **HTML numeric entities (e.g. `&#127807;` 🌿) inside `<cfoutput>` BREAK ColdFusion** — the `#` starts a CF expression, so `&#127807;...$#NumberFormat(...)#` gets parsed as one giant expression → COMPILE error → whole page dies with a generic "error occurred". Cost ~40 min mis-blaming a SQL query (which was fine). **Fix: escape as `&##127807;`** (CF `##`→literal `#`) or paste the raw emoji char. Named entities (`&mdash; &amp;`) are safe (no `#`). When a cfquery page dies and the SQL runs clean standalone, suspect a `#` in the cfoutput HTML before the query. (2026-06-26, FinancialReportDashboard treatment line.)
- ⚠️ **Verify every SSH `copy` backup actually wrote** (read it back / check size) — a chained `if not exist ... & copy` or a bad path fails SILENTLY on cmd.exe; I restored from a "backup" that was actually the original and reverted a dashboard's whole feature set. Always `dir`/`type | grep` the backup after copying, and keep a local `scp`-down copy of anything important. (2026-06-26)

## 🧠 Agent brains / model auth
- ❌ **Don't run an OpenClaw-style agent's brain on a Claude SUBSCRIPTION token (work Enterprise / Max) for real agent work** — Anthropic now meters third-party apps separately: plain chat passes, but a full tool-using request → **HTTP 400 "Third-party apps now draw from your extra usage, not your plan limits."** Hermes's Claude-Code disguise (identity + ua + `mcp_`→`mcp__`) clears the 429 identity wall but NOT the billing classifier. Chasing it = fragile + ToS-gray. Use a sanctioned flat-rate provider (GLM/z.ai sub) instead. (2026-06-30)
- ❌ **z.ai SUBSCRIPTION only authorizes the Anthropic-compat endpoint** (`/api/anthropic` or `open.bigmodel.cn/api/anthropic`), NOT the OpenAI endpoint (`/api/paas/v4` → "Insufficient balance"). So Hermes's *native* `zai` provider (which uses paas/v4) fails on a sub — use `provider: anthropic` + `base_url` override to the z.ai anthropic endpoint. (2026-06-30)
- ❌ **Dotted model ids get mangled under `provider: anthropic`** — Hermes's `normalize_model_for_provider("glm-5.2","anthropic")` → `glm-5-2` (dot→hyphen), which z.ai rejects (`1211 Unknown Model`). Fix: use the **non-dotted alias** (`glm-5` → resolves to glm-5.2). ALWAYS check the model id the GATEWAY actually sends (log `model=…`), not a hardcoded client repro — the repro hid the bug. (2026-06-30)

## 🖥️ Frontend / preact single-file app (arbor-core one-stop UI)
- ❌ **TDZ crash blanks the WHOLE preact app + `node --check` won't catch it** — a `useState` var referenced in a `useEffect(cb,[x])` **dependency array placed ABOVE** its `const [x]=useState()` line throws "Cannot access 'x' before initialization" at RENDER (the dep array is evaluated during render, even though the callback is lazy). One component throwing → entire app renders blank → "nothing loads, clicks do nothing." Syntax-check passes because TDZ is a *runtime* error; symptom was masked because the app resumed on the broken step via localStorage. Fix: declare state BEFORE any effect/expr that names it; catch headlessly with the PLAYBOOK render-harness. (2026-07-01)
- ❌ **Polygon orthogonalize (square-to-axis) SPIKES irregular/concave shapes** — forcing every edge to H/V makes consecutive same-orientation edges collapse into ~0°/~180° "spike" vertices or self-intersections. Looked like "tidy worked on zone 1, broke zone 2" (zone 1 was rectangle-ish, zone 2 wasn't). Any geometry "cleanup" must **validate + fall back** so it never worsens input (drop degenerate turns · reject self-intersection · area-ratio guard · else keep the simplified ring). (2026-07-01)

## 🗄️ Legacy-DB → Postgres pipeline + pricing engine (2026-07-01)
- ❌ **Windows `sqlcmd` output is CRLF → breaks Postgres `\copy … FORMAT csv`** with "unquoted newline found in data" (the trailing `\r` corrupts the last field / row boundary). Always `tr -d '\r'` between the gsql pull and the COPY. (Cost one failed load before spotting it.)
- ❌ **Postgres has NO `round(double precision, int)`** — only `round(numeric, int)`. `ROUND(col * %s, 4)` where `%s` is a Python float makes the product `double` → "function round(double precision, integer) does not exist". Cast: `ROUND((col * %s)::numeric, 4)`. (Python-side `round()` before insert sidesteps it.)
- ❌ **browserless `/function` returns an EMPTY 200 unless the module returns `{data, type}`** (a bare object/value serializes to nothing). And `page.waitForTimeout` is gone in newer Puppeteer → `await new Promise(r=>setTimeout(r,ms))`.
- ❌ **Substring checks on human-readable labels collide.** Fallback-tier logic keyed on `"species" in label` wrongly fired for the label `"size (any species)"` (contains "species"), so a species-agnostic aggregate mislabeled itself with a random `MIN(species)`="Acacia". Use explicit boolean flags per tier, never substring-match a display string for control flow.

## 🖥️ ColdFusion / TrimIT dashboards (2026-07-02)
- ❌ **`NumberFormat(v,'___,___')` emits LEADING SPACES for small numbers** ("$   135"), and in a narrow HTML table cell those spaces are line-break points → the `$` wraps ONTO ITS OWN LINE ABOVE the number (Skipper reported it on a TPH column). For HTML money use `NumberFormat(v,',')` → clean "$135"/"$196,343" (comma grouping, no width padding). Belt-and-suspenders: also `white-space:nowrap` the numeric cells. The `'___,___'` mask is for monospaced/`<pre>` alignment, not HTML.
- ❌ **`crew/gemini-ask.py` arg-handling is broken** — it sends `argv[1]` as the prompt (so a file path or a `max_tokens` digit becomes the literal prompt) instead of reading the file / stdin like the template. **Call it via pure stdin with NO positional arg:** `cat prompt.txt | python3 gemini-ask.py`. (GLM/Kimi honor the `file [max_tokens]` convention; Gemini doesn't.)

## 🌙 Overnight Herman KB build (2026-07-02)
- ❌ **`cmd &` background jobs in a Bash tool call get KILLED when the tool returns** — launched 3 crew asks with `&`; only the one that finished before the shell exited survived, the other two were orphaned/killed (0 bytes, no done-flag). Run crew/long jobs FOREGROUND (blocking) or use the Bash tool's `run_in_background`, never bare `&` in a call that returns immediately.
- ❌ **A crew *read-through* review missed a SQL bug the crew's own FIX introduced** — the fix aliased a column `AS Current` (a T-SQL reserved word) → syntax error. Caught only because I RAN every recipe against the live DB. Lesson: for a query playbook, EXECUTE the SQL — don't trust prose review. `Current`/reserved words need `[brackets]`.
- ❌ **`kimi-ask.py` SIGKILLs/times out on long review prompts** (exit 143) — failed both attempts on an 85KB bundle even at 20-40k tokens. For big-context reviews use GLM + Gemini; keep Kimi for short prompts or expect it to drop.
