---
title: V1.5 Landing Assistant
type: project
domain: work
track: 1
status: scaffold
model: llama3.2:3b (Ollama, localhost:11434)
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[only-trustworthy-data]]"]
links: ["[[v15-landing-page]]", "[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[sales-cockpit]]", "[[arbor-core-arbor-ai-system]]"]
updated: 2026-07-11
---

# V1.5 Landing Assistant

**One-liner:** Turns the V1.5 landing page's "in-house lite-LLM AI chat" placeholder into a real assistant — local **llama3.2:3b** (Ollama, already on this box), grounded on **live** TRIM IT data but scoped to **only pages reachable from the landing page** (so it inherits the existing role-gate and adds no new data/security surface).
**Status:** 🟡 wire built — Obsidian brain-vault + `AI-Chat.cfm` deployed & render-verified on play (2026-07-11, ship-log #118). **⛔ blocked on one Skipper action:** a Tailscale ACL grant `gstsdatabase(100.86.97.46) → gilligan(100.82.161.7):11434` (the tagged CF server can't yet reach the model port). Add it → page goes green, no code change.
**📁 Vault (the assistant's brain):** `landing-assistant/` → open `landing-assistant/HOME.md`
**▶️ Resume:** `landing-assistant/open-questions.md` (decisions owed) → then `landing-assistant/architecture.md` build order.

## The idea in one breath
The chat box is a UI shell with no brain. We give it a brain (llama3.2) + a wire (a server-side CF page) + grounding. Because a 3B model knows nothing about GSTS, it **only ever speaks from data injected at query-time** — which is exactly the Skipper's scope rule: reuse the *same queries* the landing-page dashboards already run. The model narrates; SQL is the truth.

## Scope contract (the heart of it)
- **Landing-page-reachable data only.** If a user couldn't click to it from the landing page, the assistant can't say it. → `landing-assistant/data-scope-contract.md`
- Inherits the page's role-gate (`COOKIE.ZUserID → Users.Title`): a rep can't pull exec figures via chat.
- In-scope set is finite + listed: Revenue Performance, City Budgets, SPM, Sales Cockpit, Arborist Workbench/My Jobs, Executive Review → `landing-assistant/scope-map.md`.

## State & flags
- ✅ Local model confirmed live: `llama3.2:3b` on Ollama `localhost:11434` (3B Q4 — fast, tiny → grounding is mandatory).
- ✅ Vault written (8 notes): HOME · identity · data-scope-contract · scope-map · architecture · guardrails · capabilities-v1 · open-questions.
- Guardrails bake in the GSTS data-quality traps: **invoiced≠paid**, **TPH target 130**, fuzzy manager identity, `Locations` not `Projects.Lat/Long`, only-trustworthy-data-leaves.
- ⏭️ **Next:** answer open-questions (name; Ollama box location vs CF server; play-first) → build `AI-Chat.cfm` smoke-test → ground ONE page (rec: Revenue Performance) → add role check → widen.
- Follows [[repair-contract]]: `AI-Chat.cfm` is a NEW file on play, backup-first, render-verify, log to ship-log.

## Related
- [[v15-landing-page]] — the host page; this fills its lite-LLM chat placeholder.
- [[arbor-core-arbor-ai-system]] — the graduation target: swap the brain from llama3.2 to Hermes for tool-use/actions.
