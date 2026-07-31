---
title: Env — host & tooling
type: fact
domain: env
tags: [infra, host, os, node, python, browser, file-reading]
links: ["[[crew-llms-and-helpers]]", "[[github-offchip-backup]]", "[[disaster-recovery]]", "[[gilligan-session-settings]]", "[[openclaw-plugin-install-trust-gate]]"]
updated: 2026-07-31
---

# Env — host & tooling

Full snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

## 🧠 Brain (current — re-verified 2026-07-30)
- **Claude Opus 5** — `anthropic/claude-opus-5`, alias **`opus5`**. Registered in `openclaw.json` as `model.primary`; **restored as the default 2026-07-30 02:29 UTC** after a night on `openai/gpt-5.6-sol`. Rollbacks: `openclaw.json.bak-preopus5switch-20260730-022912` (this switch) · `openclaw.json.bak-preopus5-20260724T200145Z` (original adoption).
- ⚠️ **The `claude-cli` backend is GONE** — the runtime now routes Anthropic models directly (`anthropic/...`). Any note still saying "claude-cli backend" is stale.
- **GPT-5.6 Sol** — allowlisted as **`openai/gpt-5.6-sol`**, alias **`sol`**, available on demand. ⚠️ Use the `openai/` ref, **not** `codex/gpt-5.6-sol`. → [[gilligan-session-settings]]
- ⚠️ Changing `model.primary` does **not** move an already-running session (sticky per-session binding) — use a session override or start fresh. See [[gilligan-session-settings]].

## Host
- **Ubuntu 26.04**, kernel **7.0.0-28**; **OpenClaw 2026.7.1-2 (0790d9f)** (CLI + gateway matched).
- **Hermes runtime (verified 2026-07-31):** Hermes Agent **v0.18.0 (2026.7.1)** runs from `/opt/hermes`; the gateway is s6-supervised. The CLI entry point is `/opt/hermes/.venv/bin/hermes`; bare `hermes` is not on `PATH` because `~/.local/bin/hermes` is missing.
- Box `jdog1` @ 192.168.1.70 · dashboard `http://192.168.1.70:18789/` · disk 914 G (18% used) · RAM 14 G.
- 🔌 **Plugins: after ANY core update, check the gateway log for `failed during register`.** A stale entry in the plugin install index silently un-trusts *other* plugins and crashes them on load. → **[[openclaw-plugin-install-trust-gate]]**
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
