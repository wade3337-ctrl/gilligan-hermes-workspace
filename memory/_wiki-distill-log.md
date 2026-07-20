# Nightly wiki-distill ledger

Running log of the nightly wiki-distill maintenance job (learns → LESSONS/PLAYBOOK → atomic wiki dedup/freshness → orphan reconnection). Conservative edits only; git history + weekly _backups are the rollback.

## 2026-07-19 (first run)
- **Learns captured:** 2 durable threads from today's notes (`2026-07-19.md`, `2026-07-19-0411.md`).
  1. 🔒 Fort Point M&A + GSTS growth plan (BLACK) — already fully saved by tonight's session (fort-point cluster + EBITDA/earnout notes all stamped 2026-07-19). No wiki changes needed.
  2. Kimi K2.7 → **K3** crew upgrade (Moonshot 2.8T MoE, 1M ctx, released 7/16; validated 100%/100% blind vs gpt-5.6-sol, ~7× slower).
- **Notes updated (2):** `wiki/facts/crew-llms-and-helpers.md` (kimi k2.6→k3 + validation/latency callout; date→7/19) · `wiki/projects/arbor-core-crew-infra.md` (kimi k2.7→k3 in Current-models + validation sub-bullet; added [[crew-llms-and-helpers]] link; date→7/19).
- **Notes created:** none (K3 facts folded into the existing crew notes — no near-duplicate).
- **LESSONS.md:** +1 (Kimi K3 ~7× slower than gpt-5.6-sol despite equal quality → route latency-sensitive/agentic coding to Codex).
- **PLAYBOOK.md:** +1 (validate a crew model upgrade with a blind hidden-test duel vs a trusted peer before trusting it).
- **Archived:** none.
- **Orphans:** full wiki scan (excl. _archive/index) → 0 orphans; all notes have in- or out-links.
- **Left for the Skipper:** nothing outstanding.

## 2026-07-20 (covers PT 2026-07-19)
- **Learns reviewed:** the two threads added to `2026-07-19.md` AFTER the first run (which fired ~06:43 UTC 7/19): (1) 🔒 Phantom stock + Key-Employee Incentive Plan (BLACK), (2) 🚀 V1.5 dashboards → PROD handoff (permission-driven menu, realuser-gate, pre-deploy leak sweep, staging-on-play).
- **Verified already-distilled (session did its own wiki work):**
  - `wiki/facts/fort-point-phantom-stock.md` — net-proceeds formula (Net Proceeds − $10M)/30, ~$1.17–1.40M range, amendment/vesting, 3 outbound question emails sent. Current (2026-07-19).
  - `wiki/projects/key-employee-incentive-plan.md` — forfeited 3.3333% → hybrid Pool A/B, full roster, open items. Current (2026-07-19).
  - `wiki/reference/dashboard-auth-gate.md` — single-source `dashboard-access-check.cfm`, permission-driven menu, 23-user seed, `realuser-gate.cfm`, pre-deploy leak sweep. Current (2026-07-20).
  - All three referenced from `wiki/index/WORK.md` + cross-linked (fort-point-acquisition, anomaly-monitor-suite). No orphans.
- **LESSONS.md:** already carries the matching entries (deploy-manifest misses shared libs / un-gated children 2026-07-20; Gmail .js-in-zip block 2026-07-20). +0.
- **PLAYBOOK.md:** already carries single-source-of-truth gate + realuser-gate + stage-on-play + pre-deploy-crew entries (2026-07-19/20). +0.
- **Notes created/updated:** 0 (session already captured everything; no near-duplicates to fold).
- **Archived:** none.
- **Orphans:** full wiki scan → 0 true orphans (every note has in- or out-links or an index-MOC pointer).
- **Left for the Skipper:** nothing outstanding.
