# PLAYBOOK.md — What WORKS (proven techniques · self-improvements)

**Purpose:** the **Hermes self-improvement file** — when I figure out how to do something *well*, the technique goes
here so future-me (and the crew) reuse it instead of re-deriving. Paired with `LESSONS.md` (what to avoid).
**🔄 AUTO-UPDATE RULE:** the instant I nail a non-obvious technique, add it here, tagged by domain — in the moment.
In my lookup path via `ROUTING.md` + `MEMORY.md`. Format: `- ✅ <technique> — <how / why it works>. (date)`

## 🤖 Models / crew (cross-model verification)
- ✅ **GLM via direct z.ai API** — `echo "<prompt>" | python3 ~/arbor-core/crew/glm-ask.py` (Bearer →
  `/api/anthropic/v1/messages`). Reliable single-shot; feed DB evidence inline (it can't run tools). (2026-06-21)
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

## 🌳 TRIM IT / web inspection
- ✅ **Render a live TRIM IT page (no screenshots):** `bash ~/arbor-stack/production-dashboard/view.sh '<page.cfm?args>'`
  (read-only, bot user 376). Find the real page via `AppForms.ObjectPath`; app endpoints are folder-relative. (2026-06-22)

## 📧 Email
- ✅ **Read my inbox:** Python `imaplib` (stdlib) on `gilligan.gsts@gmail.com` (creds
  `arbor-stack/anomaly-monitor/.secrets/gmail.json`); search `[Gmail]/Sent Mail` by `SINCE "DD-Mon-YYYY"`. Send via
  `anomaly-monitor/send-email.js` (`--html --bodyFile`) or `send-files.js`. (2026-06-22)

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
