---
title: Muni Bot — Brent's municipal-work agent
type: project
domain: work
track: 1
status: active
tags: [agent, municipal, brent, muni-bot, hermes, boss-herman-pattern, telegram, po-gated]
applies: ["[[agent-does-its-own-work]]", "[[external-comms-contract]]", "[[two-track-confidentiality]]"]
links: ["[[herman-agent]]", "[[herman-trimit-login]]", "[[arbor-core-crew-infra]]", "[[municipal-budgets-po-gated]]", "[[city-forecasting]]", "[[budget-report-municipal]]", "[[rc-03-city-budgets]]", "[[brent-forecast-178k-artifact]]", "[[arbor-core-municipal-bid-branch]]"]
updated: 2026-07-15
---

# Muni Bot — Brent's municipal-work agent

**One-liner:** Stand up an autonomous agent — working name **"Muni Bot"** — for **Brent Beller (Contract Admin)** to manage and build municipal work, the way Gilligan is to the Skipper. Reuses the **Boss Herman** stack ([[herman-agent]]): its own Hermes runtime, TRIM IT login, email, read-only DB access, and knowledge vault. **The agent does its own work** ([[agent-does-its-own-work]]) — Gilligan builds/wires/verifies; Muni Bot performs.
**Status:** 🟢 active — Phase 1 in progress. **#1 runtime DONE** (container `munibot` up, isolated, brain-verified 2026-07-15); #2 DB / #3 TRIM IT login / #4 vault remaining.
**📁 Location:** TBD (mirror Herman: container on jdog1 + `~/munibot-gateway/` + a `municipal-knowledge` vault).
**▶️ Resume:** this note. Next real step = Phase 1 stand-up (see Build plan).

## Decisions locked (Skipper, 2026-07-15)
- **First job order:** **(4) general muni assistant shell FIRST**, then **(1) budget/PO tracking** as the first real function. (Same come-up path as Herman.)
- **Surface:** **Telegram** — one channel with **Skipper + Brent + Muni Bot** together — **plus its own Gmail**. Brent already uses ChatGPT + Claude, so he talks to it directly (not Gilligan-proxied).
- **Later:** build Muni Bot into **Brent's V1.5 interface** (in-TRIM-IT), once V1.5 lands.
- **Principle:** [[agent-does-its-own-work]] — Muni Bot uses its OWN tools (its DB pull, its email, its Telegram turn). Gilligan enables; the agent performs.

## Who's Brent / the domain
- **Brent Beller** — Contract Admin, owns municipal budgets in TRIM IT.
- **The signature quirk:** he **won't enter a city budget until the PO is issued** → muni totals in TRIM IT trail reality ([[municipal-budgets-po-gated]]; the ~$2.14M gap vs Nate's report). Closing/managing this gap is exactly what function #1 targets.
- We already understand his world deeply: [[city-forecasting]] (replaced his manual Excel), [[budget-report-municipal]] (per-city FY reconciliation), [[rc-03-city-budgets]] (his dashboard + Renewals tab), [[brent-forecast-178k-artifact]] (don't reverse-engineer his hand-typed plugs).

## Build plan (phased)
- **Phase 0 — scaffolding (this session):** project note + PROJECTS pointer + Kanban card. Name/persona for Muni Bot.
- **Phase 1 — shell (general muni assistant):**
  1. Clone Herman's Hermes-container pattern → a second **Muni Bot** instance.
  2. **Telegram channel** — Skipper + Brent + Muni Bot.
  3. **Gmail** for Muni Bot (own mailbox + himalaya client, mirror Herman's email setup; behavioral send-gate → drafts to Skipper first).
  4. **Read-only DB access** via the forced-command gateway (scoped, muni-focused).
  5. **Own TRIM IT (play) login** (mirror [[herman-trimit-login]]).
  6. Seed a **`municipal-knowledge` vault** from what we already know (PO-gated, forecasting, budget-report, 178K artifact, per-city FY).
  7. **Verify:** Muni Bot answers a muni question on its own — its own DB pull, in the Telegram channel — the [[agent-does-its-own-work]] test.
- **Phase 2 — function #1: budget/PO tracking:** watch for POs landing → nudge Brent to enter budgets; surface the PO-gated gap / renewals (reuse Renewals-tab logic).
- **Phase 3 (later):** fold Muni Bot into Brent's **V1.5 interface**. Bid-building (DIR-wage, [[arbor-core-municipal-bid-branch]]) is a separate, later Track-2 branch.

## Flags / open
- **Two-track ([[two-track-confidentiality]]):** the assistant + budget/PO work is Track-1 team-facing (TRIM IT data). The **bid-building** function crosses into arbor-core Track-2 (BLACK) — keep that knowledge in the BLACK vault, not the muni vault.
- **External comms:** Muni Bot emailing Brent/cities is outbound — governed by [[external-comms-contract]] (draft → Skipper OK → send). Its email send-gate is behavioral to start, like Herman's.
- **Infra open Q:** second Hermes container vs. a separate box — decide at Phase 1 start.

## Related
- [[herman-agent]] — the template: how we stood up an autonomous agent for a person.
- [[agent-does-its-own-work]] — the build/test principle this must follow.
- [[municipal-budgets-po-gated]] — the pain point function #1 attacks.
