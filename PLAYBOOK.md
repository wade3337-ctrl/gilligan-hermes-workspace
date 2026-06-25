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
