---
title: PROJECTS — Master Registry (MOC)
type: index
domain: how-we-work
status: living
updated: 2026-07-02
tags: [index, projects, registry, moc]
links: ["[[PROPOSAL]]", "[[ROUTING]]"]
---

# 🗂️ PROJECTS — Master Registry

Phase-1 audit output (Gilligan-synthesized 2026-07-02 from a full sweep of `arbor-stack/`, `arbor-core/`, workspace).
**One line per project.** Fields: **📁** main location · **▶️** resume pointer · **🔗** key deps/standards · **⚠️** flag.
Legend: 🟢 shipped/live · 🔵 active · ⏸️ parked · 🔴 blocked-on-external · 📝 proposal · 📚 reference/standard · 🗄️ archived.
*This is a first pass — correct any status/pointer that's off; it becomes the source of truth for "what are we working on."*

---

## 🛠️ WORK — Track 1 (TRIM IT / play · team-facing)

### Dashboards (release-candidate → prod)
- 🟢 **RC-01 Executive Financial Overview** — 5-tab exec suite (Sales by Rep/Market, Closing %, Crew Perf). 📁 `production-dashboard/Executive$*.cfm` ▶️ `release-candidates/RC-01-*.md` 🔗 [[dashboard-metric-standards]], [[gsts-ui-spec]] ⚠️ prod-ready, gated on whole-dashboard review.
- 🟢 **RC-02 Revenue Performance** — revenue pace vs goal + TPH, drill-through. 📁 `Dashboard-RevenuePerformance.cfm`(+.Export) ▶️ `release-candidates/RC-02-*.md` 🔗 metric-standards, ui-spec ⚠️ **dual-webroot deploy (D:\ + C:\)**; 4-lab cleared.
- 🔵 **RC-03 City Budgets** — municipal budget tracking by city/FY. 📁 `Dashboard-CityBudgets.cfm`+`CityBudgets.data.cfm` ▶️ `release-candidates/RC-03-*.md` 🔗 metric-standards, GenerateContractPeriod proc ⚠️ **awaiting Brent sign-off**; watcher armed Jul 8-20.
- 🔵 **RC-04 SPM (Sales Production Meeting)** — funnel by stage (Pipeline/Sold/Production/Results). 📁 `SalesProductionMeeting$*.cfm` ▶️ `release-candidates/RC-04-*.md` 🔗 metric-standards, ui-spec, `csv-export-include.cfm` ⚠️ **5 prod asset 404s** must ship with .cfm; 4-lab green.
- 🔵 **RC-05 Arborist Workbench** — map + work sheet + My Jobs/Re-bid Radar. 📁 `production-dashboard/ZTest-*.cfm` ▶️ `release-candidates/RC-05-*.md` 🔗 **Workbench PLAY DB** (survives refresh) ⚠️ not review-approved; ships with a new DB; preserved separate from Cockpit.
- 🔵 **Steve's Diligence Sales-History dash (Project D)** — proposal-grain win% by rep. 📁 `steves-projects/diligence-sales-history/` + `FinancialReport/FinancialReport{Dashboard,Export}.cfm` ▶️ `…/CHECKPOINT-STEVE-DASH.md` 🔗 canonical-definition, [[gsts-ui-style-guide]] ⚠️ **built on play, awaiting Steve sign-off**; city-excl propagated to 7 surfaces.

### Steve — Financial reconciliation (CFO ground-truth)
- 🔵 **Project A — Financial Report Reconciliation** — validate all dashboards vs CFO Financial Report. 📁 `steves-projects/financial-report-reconciliation/` ▶️ `CANONICAL-DEFINITION.md` ⚠️ Exec$Periods$Overview CONFIRMED WRONG (stale period-close); **fixes pinned by Skipper**.
- 🟡 **Project B — Municipal Accrual (PercentagePerformed)** — phantom muni accrual. ▶️ `RECON-02-*.md` ⚠️ **UNBLOCKED (Steve answered Jul 4):** accrue performed-but-unbilled at close; cycle/EOM municipal (Irvine/Newport/Stanton/Industry) → $0 (killed ~$95K May phantom). Built + 3-agent crew-verified on play (`Exec$PercentagePerformed2$NEW.cfm` full report + `$TEST.cfm` summary, CSV export); review email handed to Skipper to forward to Steve; **awaiting sign-off → proc `Report$PercentagePerformed_npr2` to devs for prod.** Billing-cycle relabel deferred (shared type, 2,250 projects — asked Steve).
- 🔴 **Project C — Month Performance by Customer** — report ~2× canonical. ▶️ `RECON-03-*.md` ⚠️ **blocked — need Steve's actual complaint**.

### Monitors / email engines
- 🟢 **Anomaly-monitor suite** — COO daily · per-salesperson+Nate rollup · **AR collections (LIVE per-rep w/ property detail)**. 📁 `anomaly-monitor/` ▶️ `anomaly-monitor/CHECKPOINT.md` 🔗 METRICS_SPEC, metric-standards, `ar-report/rep-emails.json` ⚠️ COO live; salesperson pilot preview-only; AR live; **brent-citybudgets-check** cron Jul 8-20.

### Project-management tooling (cross-track)
- 🟢 **Our-Work Kanban (two boards, drag-to-move)** — replaces the repairs-screen tabs as our shared source of truth. TRIM IT board on play (`ZTest-WorkKanban.cfm`, Workbench DB) · arbor-core board on the secure box (`http://100.82.161.7:8088/kanban`, Postgres, BLACK). ▶️ [[our-work-kanban]] ⚠️ **standing rule: keep the boards current when saving/updating (create cards + move columns).**

### Sales engine (Track-1 prototypes → become arbor-core framework)
- ⏸️ **Sales Cockpit** — unified CRM front door (folds Workbench+Market Clusters+Customer Leads+My Jobs). 📁 `sales-engine/SALES-COCKPIT-spec.md` + `ZTest-Cockpit*.cfm` ▶️ spec ⚠️ **P0-P2 done, parked mid-P3** (bid on-ramp); 4 old pages not yet retired.
- ⏸️ **Bid Process Re-engineering (FLAGSHIP)** — redesign the traveler workflow (Skipper #1). 📁 `bid-process-reengineering/` ▶️ `FUTURE-STATE-v0.1.md` ⚠️ **parked pending a process-walkthrough session**.
- 🔵 **Pricing Guide → History-Aware Bid Prefill** — Price Buddy → bid-sheet prefill. 📁 `pricing-guide/PROJECT-pricing-bid-prefill.md` 🔗 [[gsts-ui-style-guide]], arbor-core pricing engine ⚠️ Ph1/2 done+live; **5 defects flagged (backwards TPH filter etc.) to fix on BOTH V1 + arbor-core**; Ph3 (AI species) deferred.
- 📝 **Sales Engine Prototypes** — RFP intake / e-traveler / live inventory spikes. 📁 `sales-engine/` ▶️ `phase1-recon.md` ⚠️ recon only, no builds.
- 🔵 **Scott's Manager Dashboard** — per-manager portfolio view (feeds Cockpit List/Book). 📁 `pipeline-tool/PROJECT-scott-manager-dashboard.md` 🔗 Apple-Contacts reconciler (feed).
- 📝 **Apple Contacts ↔ TRIM IT Reconciler** — vCard match/diff. 📁 `pipeline-tool/PROJECT-apple-contacts-reconciler.md` ⚠️ 2 sub-projects (read-only diff first, write-back later); awaiting Scott's vCard export.

### Other analyses / builds
- 🔵 **Completed-vs-Sold** — reconcile completed vs sold/invoiced. 📁 `completed-sold/` ▶️ `CHECKPOINT.md` ⚠️ muni section needs direction.
- 🔵 **Budget Report (municipal)** — per-city FY alignment (Anaheim/Irvine/LB/Newport). 📁 `budget-report/` ▶️ `PROCESS.md` ✅ Anaheim GenerateContractPeriod fix **DEPLOYED to prod (Travis) — verified 2026-07-04** (live proc has the fix + #71 comment; Anaheim rolls up $81,004.95).
- 🟢 **Contract Dashboard Fix (Long Beach FY26/27)** — DONE. Core fix prod Jun 13; **Long Beach 26/27 verified rolling up 2026-07-04** (CompanyYears 89866 = $80,843.63/552h, ContractCalendars 1034 = 2556 rows) — the IT email became moot (proc fix let normal regen heal it). 📁 `contract-dashboard-fix/`.
- 📝 **Irvine Billing Reconciliation** — automate Celeste's monthly check. 📁 `billing-reconciliation/PROJECT-irvine-billing-recon.md` ⚠️ Step-1 proven; Step-2 = 3 questions for Celeste.
- ⏸️ **V1.5 Landing Page** — role-gated TRIM IT home (SALES/PROD/ACCT) + TODAY + LLM chat. 📁 `v1.5-landing-page/PROJECT-*.md` 🔗 UserGroups, [[gsts-ui-style-guide]] ⚠️ design phase; needs R2 (T&A source), R3 (crew photos), accounting-role gap.
- 🗄️ **Customer Verifier** — 414/414 verified (first automated task). 📁 `customer-verifier/` ⚠️ **done; superseded by Cockpit**.

---

## 🌳 WORK — Track 2 (arbor-core · CONFIDENTIAL, Skipper-eyes-only)
*Clean in-house Agent OS replacing TRIM IT (strangler-fig, sales-engine first). Never on play/team/vendor-facing.*

- 🔵 **Strategy + Foundation** — apex direction + 9 ratified decisions. 📁 `arbor-core/docs/` ▶️ `STRATEGY.md` + `build/FOUNDATION-DECISIONS.md`.
- 🔵 **One-Stop UI (commercial estimator)** — customer→inventory→quote→work-order app. 📁 `arbor-core/app/api/` ▶️ **`docs/ONESTOP-UI-CHECKPOINT.md`** 🔗 schema v1.7, migrations 0001-0023 ⚠️ pricing engine COMPLETE; **next: Skipper hands-on click-test**; MinIO photo store deferred.
  - includes: **Pricing Reconciler (Slices ①-④)**, **Legacy-Map Georeferencing** (Gemini vision, 0.2-5.6m), **Big-Site Scaling** (60k+ trees), **Area Cleanup / zone tidy** (Ph1 shipped).
- 🔵 **RFP Automation (B1 intake → B2 match/create → B3 draft)** — proven on Rosa's 3 requests, 2-lab verified, **drafts only never sent**. 📁 `arbor-core/rfp-automation/` + `importer/b2_*` ▶️ `INTAKE-SPEC.md` ⚠️ next: B3→pricing hookup; B2 CSV→live TRIM IT (blocked on prod access).
  - 📝 **Bid-Package Electronification** ("kill the PDFs") — design done. ▶️ `rfp-automation/BID-PACKAGE-electronification.md`.
- 🔵 **Cockpit → arbor-core Bid Handoff** — one-way queue, P0-P4 done + verified. 📁 `importer/bidqueue_import.py`+`import_service.py` ▶️ `docs/COCKPIT-BIDQUEUE-HANDOFF-spec.md` ⚠️ **import_service needs systemd/@reboot** for prod.
- 🔵 **V1.5 Auth Global Gate** — login + Application.cfc gate on play (beta env). 📁 `arbor-core/docs/decisions/V15-AUTH-BUILD-SPEC.md` ⚠️ spec crew-approved; **R1-R11 mandatory during build**; P2 needs crew sign-off before pilot.
- 🟢 **arbor_core DB (LIVE)** + 🔵 **importers/nightly grains** — Postgres RLS spine; price-history (6:00) + site-rebid (6:05) nightly crons. 📁 `migrations/`, `tools/refresh-*.sh` ▶️ `migrations/README.md`.
- 📝 **Municipal Bid Branch** — DIR-wage cost build-up (separate from commercial). ▶️ `docs/MUNICIPAL-BID-BRANCH-direction.md` ⚠️ decision: spec now vs polish commercial first.
- ⏸️ **AI Tree Vision** — species/size from photos. ▶️ `docs/SUBPROJECT-ai-tree-vision.md` ⚠️ gated on MinIO photo store.
- 📝 **Arbor AI System / Hermes brain** — the AI OS layer (scaffold only, no live agents). 📁 `arbor-core/arbor-ai-system/` ⚠️ first milestone: Hermes runs ONE process (B1) live.
- 🔵 **Crew model integration** — gemini/kimi/glm ask scripts. 📁 `arbor-core/crew/` ⚠️ kimi SIGKILLs on long foreground — use glm/gemini or bg.

---

## 📚 REFERENCE / STANDARDS (the `Applies:` targets — link these from projects)
- 📚 **[[dashboard-metric-standards]]** — the 6 metric rules every dashboard follows. 📁 `DASHBOARD-METRIC-STANDARDS.md`
- 📚 **[[gsts-ui-spec]]** (v1.0) + **[[gsts-ui-style-guide]]** + theme — UI rules, tokens, welcome modal, **emoji→UTF-8 BOM**. 📁 `arbor-stack/gsts-ui-spec-v1.0.md`, `reference/GSTS-UI-STYLE-GUIDE.md`, `reference/gsts-theme.css` ⚠️ **this is the guide that got missed on a UI build — every UI project must link it.**
- 📚 **[[csv-export-standard]]** — **every data page gets a CSV export** (button + `exportCSV` handler + `csv-export-include.cfm`), wired up front. Skipper standing rule. ⚠️ got missed once (2026-07-04) — build-checklist item.
- 📚 **Deploy** — `DEPLOY-PLAYBOOK.md` + `contracts/dev-handoff-contract.md` (Jordan=IT/$0, Travis=$75/hr).
- 📚 **Contracts** — `contracts/{repair,db-repair,dev-handoff,external-comms}-contract.md` (how we do each work type).
- 📚 **Roadmap/backlog** — `TRIMIT-1.5-ROADMAP.md`, `repairs-needed.md`, `REVIEW-PILE.md`, `DEPLOY-PACKAGE-CHECKPOINT.md`.
- 📚 **Env/access** — `arbor-stack/gstsdatabase-access.md`, `gilligan-environment-snapshot.md`; **Ship Log** `gsts-ship-log.md`+`ship-log/`.

---

## 🧠 Knowledge bases for Boss Herman (2026-07-02, overnight autonomous build)
- 🟢 **Herman read-only DB access** — HermanRO db_datareader login + forced-command query gateway on gilligan (`~/herman-gateway/`); Herman queries play read-only, autonomously. Hourly re-grant persistence. ⚠️ last-mile install on Herman's box pending (can't SSH in; staged + `HERMAN-SETUP.md`). Detail: `memory/2026-07-02-herman-trimit-kb-overnight.md`, technique in [[PLAYBOOK]].
- 🟢 **trimit-knowledge vault** (shareable) — 78 notes, live-pulled schema + vetted query playbook + operating model. Repo `wade3337-ctrl/trimit-knowledge`, local `~/trimit-knowledge/`. Crew-verified (2 rounds, clean).
- 🟢 **arbor-knowledge vault** (BLACK/confidential) — 16 notes, arbor-core strategy/build. Repo `wade3337-ctrl/arbor-knowledge`, local `~/arbor-knowledge/`.

## 🧹 CLEANUP FLAGS (for Phase 2/3 + a tidy pass)
- **Stale / retire candidates:** `exec-dashboard-audit/` working copies (superseded by RC-01) · `ex_*` experimental pages · **ZTest-\* proliferation** (fold into Cockpit) · Customer Verifier (done). Confirm before deleting (repair-contract: look first).
- **Orphans:** old Exec-Performance-Day / Exec$Periods$Overview flagged for hide/rename (V1.5 M2).
- **Duplicates / drift risk:** revenue sources on RC-02 (Schedule/CrewSheets/TrueProduced/Billed) · **close%/win-rate definitions spread across RC-01, Steve's dash, Executive$ClosePercentage, SPM** — city-excl aligned but centralize to prevent drift.
- **Naming:** "Workbench" ambiguity (Arborist Workbench page vs Workbench PLAY DB vs Cockpit) — mostly resolved, stray refs linger.
- **Open external gates (not our blocker):** Steve sign-off (diligence dash) · Brent (RC-03) · Steve accounting rule (Proj B) · prod DB access via Jordan/AWS (arbor-core B2 live query, prod read) · IsMeasured DB fix re-run on prod.
