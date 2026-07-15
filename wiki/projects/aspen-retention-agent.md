---
title: Aspen — retention / marketing / BD agent (repurposed Arduino Herman)
type: project
domain: work
track: 1
status: planning
tags: [agent, aspen, retention, marketing, business-development, arduino, hermes, self-learning, planning]
applies: ["[[agent-does-its-own-work]]", "[[two-track-confidentiality]]", "[[external-comms-contract]]", "[[repair-contract]]"]
links: ["[[herman-agent]]", "[[brent-agent]]", "[[arbor-core-crew-infra]]", "[[dashboard-metric-standards]]", "[[sales-rep-attribution]]"]
updated: 2026-07-15
---

# Aspen — retention / marketing / BD agent

**One-liner:** Repurpose the **Arduino Herman** board into **"Aspen"** — a Great Scott customer-**retention, marketing, and business-development** agent. Full teardown + rebuild of memories/vault; **keep the board + Hermes runtime + GPT brain**. Same self-learning loop as [[brent-agent|Muni Bot]]. Comes up retention-first; grows into a "master" of all three via crew-driven best-practices research.
**Status:** 🟢 **PHASE 1 SHELL DONE (2026-07-15) — Aspen REBORN on the Arduino board.** Teardown+rebuild complete: fresh brain (state.db wiped/recreated), Aspen identity (SOUL), knowledge (aspen-knowledge + trimit-knowledge 109), **on Telegram** (@GSTS_Aspen_Bot, locked to Skipper), **TRIM IT read-only DB access** (customer data pulled; arbor DENIED), **self-learning return path** wired. Kept Hermes+GPT-5.5. Remaining: Telegram GROUP (Skipper+Nate) + capstone + Phase 2 retention function.
**▶️ Resume:** this note.

## 🌲 Why "Aspen"
An aspen grove is ONE organism — every tree shares a single connected root system. That's the mission: the whole GSTS customer base held together as one living, connected thing. Retention = keep the roots healthy; Marketing/BD = grow the grove.

## Decisions LOCKED (Skipper, 2026-07-15)
1. **Mission = 3 co-equal pillars, built in sequence:** ① **Customer Retention** → ② **Marketing** → ③ **Business Development.** (Option B.)
2. **Retention first.** It's TRIM-IT-measurable and becomes the scoreboard the other two aim at.
3. **Headline metric = churn / at-risk:** a rolling list of customers *past their typical service interval* who haven't returned (actionable — flag → re-engage). **Repeat-customer rate** = the trend gauge.
4. **Name = Aspen.** Rebranded off "Herman" (collided with Boss Herman + old field role).
5. **Channel = Telegram** (move him off Discord; consistent with Muni Bot).
6. **Audience, phased:** **Skipper + Nate (Sales, owns the Sales Report) first** → whole sales + marketing team later.
7. **Wipe = archive-first, never hard-delete.** Snapshot current memories/vault to a dated archive; **preserve the personal RC-jet / FrSky hobby data** off to the side (out of Aspen's work brain).
8. **Keep:** the Arduino board + Hermes runtime + GPT brain. **Wipe:** memories, vault, old field-companion identity.
9. **Come-up = shell-first** (fresh agent + wiki + TRIM IT retention data), THEN function #1.
10. **Build with the crew** (research/design/build); **Codex writes the code.**

## The board (what we're working with)
Arduino UNO Q Linux board — ARM64, 4 cores, 3.6 GB RAM, 18 GB disk, Debian 13. Hermes gateway (systemd, currently Discord). `ssh arduino@100.121.177.31` (tailnet member). Vault currently syncs to gilligan `~/herman-store/herman-workspace` → GitHub. Recovery snapshots at `~/herman-store/hermes-recovery-default-*`.
⚠️ **Constraint:** it's a small board. Heavy lifting (best-practices web research, wiki authoring, DB-heavy analysis) is done by **Gilligan + the crew**; the board hosts the Aspen *agent* + its knowledge and reasons over it. Keep the board's job light.

## PROPOSED build plan (phased — for approval)

### Phase 0 — Plan sign-off (this note)
Skipper approves scope + phases. Optional: crew pressure-test of the plan before build.

### Phase 1 — Teardown + fresh shell
- **Archive-first:** snapshot the board's current `~/.hermes` (memories/skills/state) + `herman-workspace` vault to a dated archive on gilligan; move the RC/FrSky hobby data to a preserved location. Verify archives before wiping.
- **Wipe** the old memories/vault/identity on the board; **keep** Hermes + GPT + services.
- **New identity:** Aspen SOUL (retention/marketing/BD mission, Track-1, warm+data-driven persona).
- **Telegram:** new bot (@…Aspen…), group = Skipper + Nate + Aspen (allowlisted). Move off Discord.
- **Fresh wiki** `aspen-knowledge` (new private repo → Skipper's Obsidian), scaffolded with the domain structure below.
- **TRIM IT read-only DB access** via the same forced-command gateway pattern as Muni Bot (scoped; **no arbor/BLACK**). + the shared **trimit-knowledge** vault as read-only reference (108 notes — customer/job/retention schema).
- **Self-learning loop** (same as Muni Bot): SOUL standing rule + vault return-path so Aspen's learnings flow to Obsidian.
- **Verify:** Aspen answers a retention question on its own, from its own DB pull, in Telegram (the agent-does-its-own-work test).

### Phase 2 — Function #1: measure retention (the scoreboard)
- Define **"typical service interval"** — segment-aware (residential ≠ commercial/HOA ≠ recurring accounts have very different cadences). Derive per-customer expected return window from TRIM IT job history.
- Build the **at-risk / churn list**: customers past their interval with no return → ranked by value/recency. Plus **repeat-rate** trend.
- Deliver it where the team acts on it (Telegram digest + later a dashboard, reusing our dashboard kit).
- Crew-verify the metric to the customer (adversarial + judge, like RGC).

### Phase 3 — Make Aspen a *master* of retention (best-practices research)
- **Crew + deep-research** scrape/curate customer-retention best practices **as they apply to a ~$25M OC tree-care company** (residential + commercial + municipal): re-engagement cadences, win-back offers, service reminders, review/referral loops, at-risk playbooks. Curate into `aspen-knowledge`.
- Aspen reasons from this to *recommend actions* on the at-risk list.

### Phase 4 — Skills for the team
- Aspen develops **skills** = reusable playbooks + tools that help marketing/sales/COO **measure and improve** retention + customer service (e.g., "monthly retention scorecard", "at-risk re-engagement list for a rep", "win-back campaign brief"). Decide skill form at build time (SOP notes vs. generated reports/dashboards vs. Skill Workshop skills).

### Later pillars (repeat the Phase 3–4 pattern)
- **Pillar 2 — Marketing:** best-practices research + skills (lead-gen, local SEO/brand, review generation, seasonal campaigns) aimed at the retention scoreboard.
- **Pillar 3 — Business Development:** commercial/HOA prospecting, partnerships, new-market expansion (there's already a `market-expansion-prospecting` skill to build on).

## Knowledge structure (the fresh `aspen-knowledge` wiki)
- `00-start-here/` · `retention/` (metric defs, at-risk logic, playbooks) · `marketing/` · `business-development/` · `best-practices/` (curated external research, sourced) · `references/` (GSTS context: ~$25M, OC CA, residential/commercial/municipal mix) · `skills/`.
- Reads the shared **trimit-knowledge** vault for the customer/job/retention schema (no duplication).

## Confidentiality / guardrails
- **Track-1** internal team agent. TRIM IT read-only; **no arbor-core/BLACK** (gateway denies it, like Muni Bot).
- Outbound comms (emailing customers/team) = [[external-comms-contract]] (draft → Skipper OK). Retention re-engagement that touches customers is **draft-for-approval**, never auto-send.
- Customer data stays internal; best-practices research is public sources.

## Open items to resolve at build time (not blockers)
- Exact **service-interval-by-segment** definition (the crux of the churn metric) — derive from data + confirm with Skipper/Nate.
- Does Aspen get its own **email** (like Muni Bot) — likely yes for team digests / drafts.
- Board capacity check under the new load; if too heavy, mirror Aspen as a container on jdog1 (like Muni Bot) and keep the board as the field face. **Decide at Phase 1.**

## Related
- [[brent-agent]] (Muni Bot) — the just-proven template for standing up an agent-for-a-team (reuse its infra patterns).
- [[herman-agent]] — the Boss Herman stack this all descends from.
- [[arbor-core-crew-infra]] — the crew doing research/design/build; Codex writes code.

## ⏳ Build progress (2026-07-15)
- ✅ **Pre-wipe archive:** board's last-synced recovery snapshot (memories/skills/state) + vault → `~/aspen-archive/pre-wipe-20260715/`; RC-jet/FrSky/arbor-helper hobby data preserved → `~/aspen-archive/PRESERVED-hobby/`. (Will pull a FRESH board snapshot once I have SSH access, before wiping.)
- ✅ **aspen-knowledge repo** created + scaffolded (retention/marketing/business-development/best-practices/references/skills) + pushed → Skipper's Obsidian.
- 🔴 **BLOCKER 1 — board SSH access:** gilligan has NO inbound SSH to the Arduino board (sync is one-way board→gilligan). Need gilligan's pubkey authorized on the board to do the teardown/rebuild. Pubkey: `~/.ssh/gilligan_to_aspen.pub` (`ssh-ed25519 AAAA…KoaXIS gilligan-to-aspen-board`). Grant: on the board as `arduino`, append it to `~/.ssh/authorized_keys`.
- 🔴 **BLOCKER 2 — Telegram bot:** need a new bot via BotFather (name "Aspen"), token to Gilligan (like Muni Bot).
- **Next once unblocked:** fresh board snapshot → wipe old memories/vault/identity (keep Hermes+GPT) → Aspen SOUL + self-learn loop → Telegram (Skipper+Nate) → TRIM IT read-only DB → seed knowledge → verify.

## ✅ Phase 1 build — DONE (2026-07-15)
- **Access:** gilligan→board SSH via `~/.ssh/gilligan_to_aspen` (Skipper authorized). Board = `arduino@100.121.177.31`, service `hermes-gateway` (Restart=always; relaunch via ending the arduino-owned process — no sudo).
- **Archives (3 safety nets):** `~/aspen-archive/{pre-wipe-20260715 (last synced), fresh-board-20260715 (236M brain + vault), PRESERVED-hobby (RC/FrSky/arbor-helper)}` + on-board `~/_aspen-wiped-20260715`.
- **Wiped:** state.db/snapshots/skills/SOUL/logs/recovery-backups + herman-workspace vault. **Kept:** hermes-agent runtime, node/bin/lsp/venv, auth.json (GPT-5.5 brain), config.yaml.
- **Identity:** Aspen SOUL (retention/marketing/BD, Track-1, self-learn standing rule). Channel switched Discord→**Telegram** via `.env` (token `8967961095:…`, allowlist Skipper `8975923324`, GATEWAY_ALLOW_ALL_USERS=false). `.env.bak-discord-20260715` kept.
- **Knowledge:** `~/aspen-knowledge` (repo `wade3337-ctrl/aspen-knowledge`) + `trimit-knowledge` (109) on the board.
- **DB access:** board key → gilligan `~/aspen-gateway/aspen-dispatch.sh` (RO query + get-vault + search; **get-arbor + crew DENIED**). Proven: pulled real customers; arbor denied. Board tool `~/trimit-query.sh`.
- **Self-learn return path:** `~/aspen-gateway/refresh-aspen-vault.sh` (cron `52 * * * *`) — rsync board's new notes → source → GitHub → Obsidian → back to board. BLACK-leak guard.
- **REMAINING (need Skipper):** create Telegram group (Skipper+Nate+Aspen), make Aspen admin, capture Nate's TG id → allowlist. Then capstone (Aspen answers a retention Q on its own) + Phase 2 (churn/at-risk function).
