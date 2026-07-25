---
title: Env — host & tooling
type: fact
domain: env
tags: [infra, host, os, node, python, browser, file-reading]
links: ["[[crew-llms-and-helpers]]", "[[github-offchip-backup]]", "[[disaster-recovery]]", "[[gilligan-session-settings]]"]
updated: 2026-07-24
---

# Env — host & tooling

Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

## 🧠 Brain (current)
- **Claude Opus 5** — `anthropic/claude-opus-5`, alias **`opus5`**, claude-cli backend. Released 2026-07-24, verified reachable, registered in `openclaw.json` as `model.primary` (+ provider def), then `openclaw gateway restart` to make it the **system-wide default for all sessions / crons / subagents**. Rollback: `openclaw.json.bak-preopus5-20260724T200145Z`.
- ⚠️ Changing `model.primary` does **not** move an already-running session (sticky per-session binding) — use a session override or start fresh. See [[gilligan-session-settings]].

## Host
- **Ubuntu 26.04**, kernel **7.0.0-22**; **OpenClaw 2026.6.1**.
- **Node 24.16 / npm 11** = scripting.
- **Python 3.14 has NO pkg mgr + NO passwordless sudo** — the Skipper installs system/py pkgs.

## Headless browser (NEW 2026-07-01)
- `arbor_browser` = **browserless/chrome** container on the `arbor-stack_default` net, **`localhost:3010`** (reaches the app at `http://arbor_api:8088`), `--restart unless-stopped`.
- Drive via **`~/arbor-core/tools/ui-shot.sh`** (screenshot + JS-error count; can seed localStorage to jump to a step) or **raw `/function` HTTP**.
- → I + the crew can SEE the UI + catch JS errors before handing to the Skipper.
- Doc: **`arbor-core/tools/README-browser.md`**.
- (Plain web/ERP page pulls: authenticated HTTP fetch still fine.)

## File reading
- `arbor-stack/pdf-tools/` — `node pdf2txt.js`.
- `xlsx2csv`.
- docx/pptx via raw XML.

## Related
- [[crew-llms-and-helpers]] — the LLM crew runs on this host.
- [[github-offchip-backup]], [[disaster-recovery]] — how this box is backed up / rebuilt.
