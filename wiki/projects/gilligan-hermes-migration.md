---
title: Gilligan → Hermes runtime migration (audit + decision)
type: project
domain: env
status: audit-done · pilot-next
tags: [infra, gilligan, hermes, openclaw, migration, agent-runtime]
links: ["[[herman-agent]]", "[[gilligan-session-settings]]", "[[env-host-and-tooling]]", "[[agent-comms-security-policy]]"]
updated: 2026-07-31
---

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
