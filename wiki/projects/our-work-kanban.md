---
title: Our-Work Kanban (two boards)
type: project
domain: how-we-work
track: both
status: active
tags: [kanban, project-management, workflow, board, drag-drop, two-track]
applies: ["[[two-track-confidentiality]]", "[[async-report-rule]]"]
links: ["[[PROJECTS]]", "[[repair-contract]]", "[[workbench-play-db]]"]
updated: 2026-08-04
---

# Our-Work Kanban

**One-liner:** Two drag-and-drop Kanban boards that replace the repairs-screen tabs as our shared source of truth for what we're building — the Skipper drags a card to its column, Gilligan reads the moves and keeps the boards current.

**Why (Skipper 2026-07-04):** the sales-cockpit kanban rebuild sparked it — a board he can drag projects on, where "you can see when I move something," is far more productive than tabs on the repairs screen (and stops Gilligan forgetting things).

## Spec (Skipper 2026-07-04)
- **Columns (both boards):** Backlog · Repairs · **Database cleanup** (added 2026-07-22, TRIM IT board) · New builds · Alpha build · Beta build · Waiting on others · Release candidates · Shipped · **Abandoned prototypes** (keep, don't delete; out of the stack — supersedes the old "Prototypes tab on Reference page" idea).
- **TWO separate boards** (separate projects, some intersection = mostly TRIM IT -> arbor-core **migration**):
  1. **TRIM IT board** -> on **play** (Track-1, team-safe). Persist to the refresh-proof `Workbench` DB; Gilligan reads moves via SSH+sqlcmd. *(Build first — proven pattern from `ZTest-SalesPipeline.cfm`; Skipper already reaches play in his browser.)*
  2. **arbor-core board** -> on the **in-house secure server** (Track-2 BLACK, Skipper-eyes-only — see [[two-track-confidentiality]]). Persist to the `arbor_core` Postgres DB. **Migration plans live HERE** (on the arbor-core board), not on the TRIM IT one. ⚠️ arbor-core has no running web UI yet -> serving + Skipper-access must be set up.
- **Card = a repair/project/build item.** Seed both from existing tracking: `repairs-needed.md`, `wiki/index/PROJECTS.md`, `gsts-ship-log.md`.

## 🔄 2026-08-04 — boards were 7+ days stale, caught up
Honest state when Skipper asked: **NO, we'd dropped the standing rule during the week's crunch** — TRIM IT board last touched 2026-07-27, arbor-core last 2026-07-23. Both caught up:
- **TRIM IT board** (`Workbench.dbo.WorkKanban`, 63 cards): +7 — **rc:** Invoiced tab ([[rc-02-revenue-performance]]), BOD Commitment Dashboard · **shipped:** crew-audit bugfix batch (to Jordan 7/28) · **waiting:** Prod live-read (MonitorData→prod), Daily-emails un-hold · **dbcleanup:** TRIM IT deep audit+cleanup, Future-dated crew sheets. Backup `arbor-stack/backups/play-workbench/WorkKanban-backup-20260804-0037.txt`.
- **arbor-core board** (Postgres `arbor_core` table `kanban`): +1 — **waiting:** "Migration: get our work OFF play onto our own infra" (card 30). ⚠️ **Write via `docker exec -i arbor_postgres psql -U arbor -d arbor_core`** — needs `-i` for stdin.
- 🚨 **`arbor_api` container is EXITED** → the arbor board UI at `http://100.82.161.7:8088/kanban` is NOT serving (DB writes still land fine). To VIEW it: `docker start arbor_api` (or restart). `arbor_postgres` container is Up/healthy. *(100.82.161.7 = THIS box's own Tailscale IP.)*
- **GOING FORWARD:** card work as it ships — the lapse is exactly the anti-pattern the standing rule below (Skipper 2026-07-04) exists to prevent.

## STANDING RULE (Skipper 2026-07-04) — keep the boards live
When we work a project and Gilligan **saves / updates progress**, Gilligan must also **keep the relevant Kanban current — including creating new cards** for new work, and moving cards to the right column. The board update is part of "save progress," not an afterthought. (Cross-links the ship-log/save-progress discipline.)

## Status / plan
- 🟢 **TRIM IT board LIVE on play 2026-07-04** — `ZTest-WorkKanban.cfm` (+ `ZTest-WorkKanban-Save.cfm` endpoint). HTML5 drag-drop, persists to `Workbench.dbo.WorkKanban` (refresh-proof); Gilligan reads moves via SQL. Seeded 27 current Track-1 cards. Move→save→persist round-trip verified. Files also in `sales-engine/cockpit-src/`. **2026-07-22: added a "Database cleanup" column** (teal, after Repairs) for [[trimit-db-cleanup]] items — first card = stale GoAheads (~$2.88M/413). Backup `Jasonsrepairs\kanban-dbcleanup-<ts>\`.
- 🟢 **arbor-core board LIVE 2026-07-04** — served by the running `arbor_api` FastAPI app (port 8088) at **`http://100.82.161.7:8088/kanban`** (Tailscale, box=`gilligan`, Skipper-eyes-only). Isolated router `arbor-core/app/api/kanban_api.py` + `kanban.html` (dark/CONFIDENTIAL theme); include added to `main.py` (backed up `main.py.bak-20260704-kanban`). Persists to `arbor_core` Postgres table `kanban` (owner `arbor`, granted `arbor_app`, no RLS). Seeded 20 arbor-core + **migration** cards. Move→persist verified; live estimator untouched (GET / still 200).
- Card table survives restores, but the **login/reseed** that lets Gilligan read it is via [[ensure-gilligan-bot]] (self-heal cron).
- ⚠️ "RC" on the board = **Release Candidate** (TRIM IT dashboards), NOT radio-control. Hobby/personal work = a separate third board, never on play or arbor-core (two-domain separation).
