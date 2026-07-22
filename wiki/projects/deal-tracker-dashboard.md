---
title: Deal Tracker — live private dashboard + 2026 re-goal
type: project
domain: work
status: active — LIVE; pending Skipper "tune-up" (see Resume)
confidential: black
applies: ["[[fort-point-confidentiality]]"]
links: ["[[fort-point-acquisition]]", "[[gsts-growth-plan-fort-point]]", "[[gsts-adjusted-ebitda]]", "[[gsts-2026-earnout]]", "[[segment-margin-analysis]]"]
updated: 2026-07-22
---

# 🔒 Deal Tracker — live private dashboard + 2026 re-goal

Applies [[fort-point-confidentiality]]. Skipper-only glanceable view of the numbers the $55M Fort Point deal rides on. Built 2026-07-21.

## The dashboard
- **File:** `business-plan/deal-tracker-dashboard.html` — regenerated from LIVE TRIM IT by `business-plan/refresh-deal-dashboard.py` (**cron every 2h**; data is daily-fresh — play DB is a nightly prod mirror).
- **Shows (6 cards):** TTM Adj EBITDA $3.80M/$4.8M (floor $4.1M, red) · 2026 Adj GP ~$10.7M/$11.4–12.5M band · **2026 Revenue LIVE** (from TRIM IT) /$25.1M · 2026 Earnout est ~$2.7M/$5M · Net proceeds @ close ~$33.4M (Jason ~$1.0M placeholder) · Rollover @ exit $27M. Plus the defend-the-EBITDA play + a crew-hours-to-close table.
- **Live vs static:** ONLY 2026 revenue is live (TRIM IT invoiced, `refresh-deal-dashboard.py` query). Deal constants (EBITDA/AGP/proceeds) are hardcoded in the script's `DEAL` dict — **update when a new financials deck / add-back bridge lands** (source: Cam datapack 7/21, FTI QoE).

## Access (Tailscale/LAN, no login)
- **URL:** `http://100.82.161.7:8091/<token>` (token in `~/.secrets/deal-dash-auth.json`). Also LAN `http://192.168.1.70:8091/<token>`.
- **Served by Docker container `deal-dash`** (image `arbor-core-api`, `-p 8091:8091`, mounts the HTML ro + `DASH_TOKEN` env, `--restart unless-stopped`). Server script `~/deal-dash-server/serve-container.py`.
- ⚠️ **Why Docker, not a host process:** host-bound ports are blocked by the box firewall (no root to open them); **Docker-publish manages its own iptables via the daemon** = reachable, same as the arbor kanban :8088. The old `systemd --user deal-dash.service` (host-bound) is **stopped+disabled** — don't revive it. → [[PLAYBOOK]] infra/network.
- Secret-URL token = the key (no basic-auth prompt); bare paths 404. Tailnet-only (box has no public IP).

## 2026 re-goal (team) — $25.1M, front-loaded
- Skipper (7/21): **max the earnout** → raised the team goal $24M → **$25.1M**. The **Revenue Performance / Sales Goals dashboards read `Workbench.dbo.SalesGoal`** (edited via `Dashboard-SalesGoals.cfm`; survives nightly refresh). **NOT** `GoalSettings` (a secondary per-user flat monthly override in RevPerf — don't confuse them).
- Front-loaded H2 (Aug–Oct heavy for daylight): Aug $2.30M · Sep $2.35M · Oct $2.30M · Nov $1.90M · Dec $1.91M; Jan–Jul unchanged; annual $25.1M. Backup: `recovery/salesgoal-2026-backup-20260721.sql`.
- Reality: YTD ~$12.1M (through Jul), ~$13.0M remaining → to actually LAND $25.1M (recovering the H1 miss), the 5 remaining months avg ~$2.60M = **~56 hr/wk/person** (Saturdays/OT). Above the ~$24.8M weekday-only modeled capacity.

## ▶️ RESUME (next session) — Skipper wants to TUNE the dashboard
He said "not sure I understand how it works, let's tune it up." I explained the 6 cards + colors + live-vs-static. **He hasn't picked a tune direction yet.** Options I offered:
1. **Simplify** — fewer tiles / plainer labels.
2. **More live** — pull TPH + profit live too (not just revenue).
3. **Fix the crew-hours math** — it currently averages the remaining $13M *evenly*; make it match the **front-loaded** Aug–Oct plan (heavier hours Aug–Oct, lighter Nov–Dec).
4. **Add/remove metrics.**
→ Ask which, then edit `refresh-deal-dashboard.py` (the HTML is generated there; the container serves it fresh each request — no container rebuild needed for content changes).

## Other open threads (Skipper's court)
- Confirm **Jason's $1.0M closing payout** base with **Gary** (phantom formula ≈ $0.8M).
- **Defend-the-EBITDA** narrative for diligence (H2 recovery = price defense). → [[gsts-growth-plan-fort-point]] §9e.
