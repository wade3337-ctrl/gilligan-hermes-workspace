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

## 2026-07-21 (covers PT 2026-07-20)
- **Learns reviewed** from `2026-07-20.md` + `2026-07-21.md` (PT-evening 07-20 rolling into 07-21 UTC): (1) TRIM IT DB-cleanup audit→PARKED, (2) MuniBot given its own Kimi K3 + Gemini 3.1 Pro bid-check crew (sol failed on cloned codex-oauth), (3) TRIM IT profile-pic install on play + the "play is NOT read-only" correction, (4) Steve's Financial Report Dashboard PROD deploy → Jordan (crew DO-NOT-SHIP r1 → hardened, 564→563), (5) Dimitry Convene financials + $2.0M→$4.1M EBITDA-bridge gap, (6) Cam Bryan(t) investment-banker call prep + advisor routing.
- **Verified already-distilled by the session** (it did its own wiki work per Skipper "save all in your atomic wiki"): DB-cleanup (`trimit-db-cleanup`, WORK/PROJECTS, kanban #53) ✅; advisor routing (`fort-point-advisors-and-open-questions.md`, updated 07-21, Cam-vs-Gary-vs-Steve lanes + call-prep artifact) ✅. LESSONS already carried the two big new gotchas (codex-oauth can't clone into a 2nd container 07-20; "I have WRITE access to play, don't say read-only" 07-21; advisor-routing 07-21) and PLAYBOOK the db-audit/db-infra/db-data-model + deploy-staging/pre-deploy-crew/realuser-gate entries (07-20). **LESSONS +0, PLAYBOOK +0.**
- **Notes UPDATED (4) — KEEP-CURRENT status freshness the session hadn't folded back:**
  1. `wiki/projects/steve-diligence-dashboard.md` — status 🔵awaiting-signoff → 🟠 **PROD package built + crew-verified + emailed to Jordan (07-21)**; added a deploy section (byte-identical source, `Workbench.dbo.ProposalOriginalRep` prod-missing hidden dep, DO-NOT-SHIP r1 catches, UNDEFINED 564→563, staged `D:\GSTS-Deploy\STEVE-FRD-DEPLOY-20260721\`); +[[deploy-playbook]] link; date→07-21.
  2. `wiki/index/PROJECTS.md` — Project-D line synced to the same 🟠 deploy-to-Jordan status.
  3. `wiki/projects/munibot-smart-bidding-tool.md` — added 07-20 section: MuniBot now runs a Kimi K3 + Gemini 3.1 Pro 2-judge bid-check crew (sol dropped on the cloned-codex-oauth failure); links [[herman-agent]].
  4. `wiki/facts/play-dev-access.md` — added "play is a WRITE path, not read-only" clarification (Administrator key vs the separate HermanRO/GSTSREADONLY/gilligan-bot RO accounts); date→07-21.
- **Notes created:** 0 (all learns folded into existing notes — no near-duplicates; profile-pic recipe deemed too niche to add).
- **Archived:** none.
- **Orphans:** full scan (excl _archive/index) → 4 notes have zero OUTBOUND links but all 4 have inbound refs (`herman-trimit-login`←brent-agent · `gilligan-session-settings`←ENVIRONMENT · `gsts-employee-handbook-2026`←4 notes · `analysis-north-yard-hours`←gsts-field-labor-rate+overtime-cost-forecaster) → **0 true orphans.**
- **Left for the Skipper:** nothing outstanding (Steve-dash now waits on Jordan; EBITDA bridge intentionally parked pending Steve's data).

## 2026-07-22 (covers PT 2026-07-21 evening → early 07-22 UTC)
- **Learns reviewed** from `2026-07-21.md` (PT-evening) + `2026-07-22.md`: (1) count-once revenue LEDGER rebuild of the private deal dashboard (goals LIVE via HermanRO Workbench grant, accrual wired from `dbo.GetPeriodAccrual`, uncovered gap $4.73M), (2) TRIM IT profile-pic on play + "play is WRITE not read-only" correction, (3) Steve FRD prod-deploy package to Jordan, (4) Dimitry Convene TTM adj-EBITDA ~$2.0M → $2M add-back bridge (parked pending Steve), (5) segment-margin analysis (equalized TPH ~$123; DIR Tree-Maintenance not Laborer; muni erosion), (6) MuniBot vision fix + on-demand dashboard-capture, (7) Cam datapack — AGP≈50% CONFIRMED, TTM adj-EBITDA $3.80M BELOW the $4.1M floor, defend-the-EBITDA §9e, (8) team re-goal $25.1M→$25.19M, deal-dash moved host-process→Docker `deal-dash` :8091 (firewall).
- **Verified already-distilled by the live session** (it did its own wiki work): `deal-tracker-dashboard` (fully rewritten to count-once ledger + Docker + $25.19M + EIP correction, current 07-22) ✅; `segment-margin-analysis` (created 07-21, full findings) ✅; `count-once-revenue-ledger`, `trimit-accrual-formula`, `steve-recon-b-municipal-accrual` referenced/current ✅. **LESSONS +0** (already carries the 07-22 coldfusion/perf, coldfusion/security-sa, serializeJSON-uppercase, and trimit/data "to-schedule=InProcess" entries, plus 07-21 codex-oauth / play-write / advisor-routing). **PLAYBOOK +0** (already carries infra/network Docker-publish, infra/agents dashboard-capture + hermes-vision, trimit/accrual GetPeriodAccrual, trimit/db-access gsql.sh-Workbench, dashboard/reuse CSV-pull).
- **Notes UPDATED (2) — keep-current the session hadn't folded:**
  1. `wiki/facts/gsts-adjusted-ebitda.md` — `updated:` 2026-07-19 → 2026-07-21 (stale vs its own Cam-7/21-confirmed body).
  2. `wiki/projects/segment-margin-analysis.md` — Finding #1: added Cam/FTI-QoE independent validation of equalized-TPH (HOA $130.7 / Muni $127.0 / Comm $123.3) + [[gsts-adjusted-ebitda]] cross-link.
- **Notes created:** 0 (all durable learns already covered — no near-duplicates).
- **Archived:** none.
- **Orphans:** full scan (excl _archive/index) → same 4 no-outbound notes (`herman-trimit-login`←brent-agent · `gilligan-session-settings`←ENVIRONMENT · `gsts-employee-handbook-2026`←PROJECTS · `analysis-north-yard-hours`←gsts-field-labor-rate) all have inbound refs → **0 true orphans.**
- **Left for the Skipper:** nothing outstanding (ledger polish backlog, Dimitry EBITDA bridge, and Jason $1.0M/Gary check all intentionally parked in their notes).

## 2026-07-23 (covers the monster TRIM IT + Kling session, early 07-23 UTC)
- **Learns reviewed** from `2026-07-23.md` + session dump `2026-07-23-0511.md`: (1) **Goodman Portfolio RFP bid** as Gothic's sub (~28 props/6,400 trees, DUE 8/3) — "train Boss Herman" exercise, pilot GLC Fullerton Bldg 4 (Proj 1105465) COMPLETE + verified; (2) reverse-engineered TRIM IT's **official GPS import subsystem** (raw SQL inserts failed → trees never render); (3) full field-population pass incl. the **SizeCode/SizeModelSizeID display trap** (popup reads SizeCode, not DBHRange), IsNewPlot/DevMark map-visibility, `GenerateZoneDef$Force$One` for NULL ZoneDefID, the `AND 1=0` field-dots stray; (4) **Lat/Long 0/0 geocoder** — two independent geocoders (dead keyless-Google DB proc + client-side gate), Jordan's dev shipped the simpler client-side fix to prod; (5) profile-pic cron TZ (3AM PT ≈ 10–11 UTC, not 3 UTC) widened to all-day; (6) **Kling AI** video/image gen wired up.
- **Verified already-distilled by the live session** (Skipper said "save all of this to your atomic wiki"): `trimit-gps-import-pipeline` (created 07-23, exhaustive — pipeline procs, render gates, all field display traps, SizeCode trap, `AND 1=0` bug) ✅; `goodman-rfp-bid` (created, linked from PROJECTS + herman-agent + gps-pipeline, status current = pilot done, NEXT=pricing) ✅; `kling-ai` (created 07-23) ✅; `herman-agent` + `PROJECTS.md` updated ✅. **LESSONS already carried** the 07-23 entries: geocode-0/0 (253), multi-producer-diagnosis (257), OLE fixed-size varchar(8000) (251), cron refresh-timing (255); **PLAYBOOK** already had census-via-OLE geocode (225).
- **Notes UPDATED (2):**
  1. `wiki/index/ENVIRONMENT.md` — added a `[[kling-ai]]` MOC pointer (it was stranded: had an outbound link but ZERO inbound refs / not in any index — now discoverable + reciprocally linked).
  2. `PLAYBOOK.md` — added a "GPS survey spreadsheet → render-ready TRIM IT inventory via the official importer" one-liner pointing to `[[trimit-gps-import-pipeline]]` (genuinely new proven technique; PLAYBOOK had no reference to it). **LESSONS +0, PLAYBOOK +1.**
- **Notes created:** 0 (session already created all 3 new notes; no near-duplicates).
- **Archived:** none.
- **Orphans:** full scan (excl _archive/index) → reconnected **kling-ai** (via ENVIRONMENT MOC). Remaining 4 no-outbound notes (`herman-trimit-login`←brent-agent · `analysis-north-yard-hours`←gsts-field-labor-rate+overtime · `gilligan-session-settings`←ENVIRONMENT · `gsts-employee-handbook-2026`←4 notes) all have inbound refs → **0 true orphans.**
- **Left for the Skipper:** nothing outstanding (Goodman NEXT = pricing via Price Buddy, then scale the other 27 properties — parked in [[goodman-rfp-bid]]; Kling image gen needs a separate image resource pack per [[kling-ai]]).
