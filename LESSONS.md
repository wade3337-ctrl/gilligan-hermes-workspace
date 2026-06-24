# LESSONS.md — What Didn't Work (gotchas · dead-ends · anti-patterns)

**Purpose:** the ONE place I check *before* a task to avoid repeating a known failure. Paired with `PLAYBOOK.md`
(what works). **🔄 AUTO-UPDATE RULE:** the instant something fails or wastes real time, I add a one-line entry here,
tagged by domain — *in the moment*, not "later." Kept **lean** (consolidate, don't pile). In my lookup path via
`ROUTING.md` + `MEMORY.md`. Format: `- ⚠️ <the trap> → <the fix/avoid>. (date)`

## 🤖 Models / CLI tooling
- ⚠️ **GLM (& Codex) agentic `claude -p` CLI is UNRELIABLE here** — it **HANGS (124) OR SIGKILLs (137)** on tool
  loops. Root-caused 2026-06-23: the CLI's **agentic orchestration with the backend** is the broken part, NOT GLM or
  the box (GLM via direct API answers in seconds). → use `~/arbor-core/crew/glm-ask.py` (reasoning) or
  **`glm-judge.py`** (tool-running DB-verification via a stable Python loop). (2026-06-21 / 23)
- ⚠️ **Codex `codex exec` also dies (137) on heavy *nested* runs** — the sandbox kills fat subprocess trees;
  lightweight calls (gsql, GLM-API) are fine. Don't depend on long nested CLI agents. (2026-06-22)
- ⚠️ **Background sub-agents get killed mid-run** (the v1.1 producer was) — the **main session is stable**; do
  consequential long work there, not in detached background agents. (2026-06-22)

## 🗄️ DB / SQL (TRIM IT, sqlcmd via gsql.sh)
- ⚠️ **`gsql.sh` takes a FILE or STDIN, not an inline arg string** (it `cat`s $1) → pipe SQL on stdin. (2026-06-21)
- ⚠️ **`gsql.sh` writes ONE shared remote temp file** → concurrent queries clobber each other → run **sequentially**
  or use a per-process isolated wrapper. (2026-06-21)
- ⚠️ **Reserved words as a column alias break sqlcmd** ("Incorrect syntax near 'proc'") → use a safe alias (`pname`). (2026-06-21)

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
- ⚠️ **`.cfm` with emoji/non-ASCII needs a UTF-8 BOM** or ColdFusion serves mojibake (`ssh type` strips it).
- ⚠️ **Dual-webroot shadow:** `C:\ColdFusion...\GSTS` can OVERRIDE `D:\...\GSTS` → render-verify the *served* output.

## ⚙️ Config / infra
- ⚠️ **`~/.openclaw/openclaw.json` has clobber history** → always back up + merge-patch, never overwrite.
- ⚠️ **Python 3.14 here has no package manager + no passwordless sudo** → use stdlib; Skipper installs system pkgs.
- ⚠️ **No headless browser** → authenticated HTTP fetch (view.sh) for web/ERP pages.

## 🧑‍🤝‍🧑 Working with the Skipper / process
- ⚠️ **Don't let background/inter-session chatter drown the user** (`[[subagent-completion-noise]]`) — surface real
  status; never go silent through a direct question.
- ⚠️ **Don't over-claim beyond the evidence** — GLM caught me twice asserting *behavior* from row-counts (pricing map).
  State only what's proven; flag inferences as inferences. (2026-06-21)
- ⚠️ **"Set up" ≠ working** — laptop GLM was reported "set up" but had **NO key/client/config** at all. Always VERIFY
  the config actually persisted (key present? endpoint right? client runs?) before assuming a setup landed. (2026-06-23)

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
