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
**Status:** 🟢 **PHASE 1 COMPLETE (2026-07-15) — Muni Bot LIVE on Telegram** (@GSTS_MuniBot_bot, group -5529154032, locked to Skipper). All 6 pieces done: runtime + read-only DB + TRIM IT login + vault + **Telegram channel** + brain fixed to GLM-5.2. Capstone passed LIVE in-channel (queried 233 City-of rows, recited PO-gap, now on function #1). **ALL 6 pieces + Gmail DONE.** Email = MuniBot.gsts@gmail.com (himalaya, imap+smtp proven, behavioral send-gate). Only ongoing: Brent's file base syncing in via SyncMuni + Brent joining Telegram later.
**📁 Location:** container `munibot` on jdog1 · mount `~/.munibot` · `~/munibot-gateway/` (dispatch, refresh) · vault `~/municipal-knowledge` · compose `~/munibot/docker-compose.yml`.
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

## File base (Brent's municipal history) — sync design
- Source: GSTS **"200 server"**, reachable only via **OpenVPN Connect → GSTS_VPN** (login+pass). Our DB-box beachhead can't see it (colo box, not on office LAN).
- **Decision (Skipper 2026-07-15):** daily sync run on **Skipper's PC while connected** — uses his existing login (no creds stored on gilligan).
- **Pipeline:** Brent's folder → daily helper on Skipper PC → private repo **`wade3337-ctrl/municipal-history`** (created + cloned `~/municipal-history`) → Muni Bot pulls. Separate from curated `~/municipal-knowledge` vault.
- **RESOLVED (2026-07-15):** path = `\\gsts-server200\GSTS\Municipal Bid Data\Jason_Compiled` (Joseph Young, via email). Work PC allows installs → **SyncMuni** package built (`~/munibot-gateway/SyncMuni.zip`): Tailscale + robocopy + tar/ssh drop-key → gilligan receiver → repo + Muni Bot; daily 6PM schtask. Delivered to Skipper.
- **Brain fixed to GLM-5.2 (2026-07-15):** per Boss Herman's setup doc — custom provider `zai-anthropic` (period-preserving) + base_url; proven with fallback disabled. Was silently on gpt-5.6-sol fallback.

## Brain in Obsidian (two-way sync, 2026-07-15)
- Curated vault pushed to private repo **`wade3337-ctrl/municipal-knowledge`** → Skipper views/edits in Obsidian.
- **Two-way autosync** `~/munibot-gateway/refresh-munibot-vaults.sh` (cron `27 * * * *`): commit local → pull --rebase (Obsidian edits) → push → docker cp into container. Skipper's Obsidian ⇄ GitHub ⇄ Muni Bot. Skipper can teach Muni Bot by editing the vault.

## Session close 2026-07-15
- Muni Bot FULLY built: runtime + GLM-5.2 brain + read-only DB + TRIM IT login + Telegram (@GSTS_MuniBot_bot, group -5529154032) + Gmail (MuniBot.gsts@gmail.com) + knowledge (municipal-knowledge two-way Obsidian sync + trimit-knowledge 108-note ref + PO-location note). Answered a full TRIM IT self-description live from the vault.
- **Brent ONBOARDED (2026-07-15):** Brent's TG id **8689394897** added to `TELEGRAM_ALLOWED_USERS` (now `8975923324,8689394897`); munibot restarted. Brent can now talk to Muni Bot directly in the group. (Captured his id from the gateway 'Blocked unauthorized user' log — the running poller consumes updates so getUpdates was empty; the deny-log is the reliable capture.)
- File base (`Jason_Compiled`, LA County big) still syncing via SyncMuni on Skipper's PC.

## 🧠 Self-improvement loop (STANDING RULE, Skipper 2026-07-15)
- **Muni Bot writes what it learns to its wiki.** SOUL standing rule: whenever it learns something new (muni fact, TRIM IT gotcha/query, correction, process, contact, PO insight) it writes a NEW atomic note into `municipal-knowledge/` (concepts/ or references/) in the moment.
- **Return path (built):** `refresh-munibot-vaults.sh` now RESCUES container-side new notes back to source (`rsync --ignore-existing` container→source) → commit → push → Obsidian, before the docker-cp overwrite. BLACK-leak guard quarantines any Track-2/secret markers. Cron `27 * * * *`.
- **Proven:** Brent's first session had Muni Bot author 8 notes (po-gap-reconciliation, municipal-bid-watch, data-hygiene-pitfalls, workforce-headcount, gps-tree-inventory, oc-public-bid-scan, po-follow-up-identification, cost-estimates-and-contacts). Rescued into source before the refresh clobbered them; vault 8→16 notes.
- ⏳ SOUL rule loads on Muni Bot's next restart; the return path is live NOW so ongoing writes are safe regardless.
