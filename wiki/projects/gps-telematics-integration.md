---
title: GPS / Telematics integration (OneStepGPS ↔ TRIM IT)
type: project
domain: work
status: active
created: 2026-08-02
updated: 2026-08-03
tags: [gps, onestepgps, telematics, production, reconciler, fleet, friction]
applies:
  - "[[friction-hit-list]]"
  - "[[only-trustworthy-data]]"
links: ["[[dev-browser-access]]", "[[friction-hit-list]]", "[[play-dev-access]]"]
---

# GPS / Telematics Integration (OneStepGPS ↔ TRIM IT)

The Production friction fix: no objective real-time signal on field execution → **OneStepGPS already logs it; it was just siloed.** Skipper gave a **Legacy API key** (`~/.openclaw/.secrets/onestepgps-login.json`). ⚠️ **READ-ONLY posture, ASK before any write/delete (standing).** Build tooling: `arbor-stack/fleet-telematics/`. Full detail: `business-plan/friction-modules/03-production-gps-spine.md` + `memory/2026-08-02.md`.

## Capability
- OSG **snapshot** endpoint works (`/v3/api/public/device?latest_point=true&api-key=`); the **history** endpoint errors → we build our own history via a **read-only poller** (`osg_snapshot.py`, cron every 20 min → `snapshots.jsonl`). Nightly rollup+prune (self-maintaining). Payload carries: drive-status, PTO/boom inputs, harsh/speed/idle (safety), odometer, fuel + idle-waste, position.

## Built (2026-08-02)
- **Vehicle spine** — 3-way reconcile Spreadsheet(246)↔TRIM IT `dbo.Equipment`(436)↔OSG(100). OSG has NO VIN → bridge = asset-name scheme; **~89–95% auto-match**. Exception lists: untracked trucks · orphan/stale trackers · 81 VIN gaps. (⚠️ "145 trucks no GPS" is a soft lead, not fact.)
- **Yard-departure module** — `yard_departure.py`, minute-precise via OSG `drive_status_begin_time`; 4 yards (**Stanton · Laguna Woods · Irvine · City of Industry satellite**).
- **Time-on-job** (`jobsite_dwell.py`) + **clock mining** (`clock_analysis.py`/`clock_mine.py`): integrity clean (99.8% supervisor punch-edits, meal ~99%); **NEW friction — no-signal punch app** (~1,500 hand-corrections). City-of-Industry satellite crew (7, Ayon crew) found in clock data.

## T&A↔WO reconciler (the tail-end-of-production node)
Branch managers DAILY reconcile clocked T&A vs WO-booked hours by hand. Direction: **a reconciler (exception engine), not a new process** → grows into the future T&A app (crew-leader-assigned, geolocated punches). **v1 corrections:** `CrewSheets.ActHours`=the ESTIMATE (not clocked); at aggregate clocked≈booked (0.08%) → managers' reconciliation balances → reconciler value = **remove daily labor**, not find errors. GPS proposes the split BETWEEN locations; same-property multi-WO is GPS-blind (**municipal 70% same-property, HOA 41%**; ~13% of crew-days need the crew-leader split). **v2:** daily-worked-crew link · GPS proposer · raw/real-time data.

## Fleet cleanup + morning REPORT (2026-08-05)
- **23 OSG device fixes, all via API, all verified** (of 28 messy of 100): 11 cosmetic renames + `C68 - HW 175` + **`S-49 - Ba Tran`** (VIN `5TDKDRAH0PS519692` from OSG → fleet master asset S49, 2023 Toyota Highlander) + 5 "(New)" pairs (dead base→`(RETIRED)`, live→clean). Left alone: **D58** (two live trackers HW117/HW118, unresolved) · **C1/C2/C3** (camera test units).
- 🔑 **OSG authenticated session capability** — login needs **MFA** (email 6-digit). `~/.local/devscout/osg_mfa_capture.js` saves session to **`osg-auth.json`** ("remember device" → **no MFA 30 days**). **Safe write = `PATCH /v3/api/public/device/{id}?vuid=6eqEBuimPtXNb-81f07-0F` `{"display_name":"..."}`** (partial; verify `other-fields-changed:[]`). Scripts: `osg_do_rename.js` / `osg_batch_rename.js` / `osg_retire.js`. Broader writes/deletes still ASK-first.
- 📊 **Morning yard-departure REPORT — LIVE, Skipper-only, both formats.** `yard_report.py` → `/tmp/yard-digest.txt` (email) + `yard-dashboard.html` (grouped by yard, ⏰ late after 07:30 PT tunable, cleans names/drops cameras+RETIRED). Email `yard-send.js` (needs `NODE_PATH=.../anomaly-monitor/node_modules`) → jwade only. Dashboard served you-only **http://100.82.161.7:8093/** (`ensure-yard-server.sh`). Cron (merged, existing untouched): `45 15 * * *` `yard-morning.sh` (~8:45 AM PT) + `*/10` watchdog. Caveat: ~2–3 days data = directional; D58 shows twice till resolved.

## Stop attribution + boom/PTO (2026-08-05) → [[fleet-stop-attribution]]
Big build this session — its **own note: [[fleet-stop-attribution]]**. In short:
- **Stop-attribution module SHIPPED** into the morning email + dashboard (`http://100.82.161.7:8093/stops.html`): records **which scheduled job each truck landed on** (8/3: 82 landings/31 trucks), plus a **commute-window "on-the-way" highlight**, **in-shop** (repair), and **take-home** filtering. Match radius **550m** (tuned to the 475–590m near-miss cluster). Widened job source (crew sheets ∪ WO span) + Nominatim geocode → **97% site coverage**.
- **Honest finding:** the tool is a reliable **job-landing recorder**, NOT a slacking detector — TRIM IT pins only ~37 sites vs 56 trucks/215 stops, so most field stops are **unmapped work, not off-job**. Off-job = flagged as *likely unmapped*, never accused. Path-B lever = pin more work (ops change) → the 23 no-match trucks.
- **Fleet key (Skipper):** D/B/C=crew · AB=trafficator · BA=crew · C1–3=cameras · T/S not GPS-tracked. **B23–B55 = the 30 bucket/boom trucks** (`boom-trucks.json`).
- **Boom/PTO = NEXT, buildable:** engine bus is NOT wired (0/100), but the **PTO is on a wired digital input** (Skipper: live in OSG, "changes a color on the truck label"). Poller now captures `in1–in4`; identify the PTO input by correlation over a workday, then build PTO-engaged-hours. ⏭️ **RESUME tomorrow.**

## Standing infra note
⚠️ **Two arbor-stack checkouts** — cron/ops use `/home/wade3337/arbor-stack`; session work sometimes lands in `~/.gilligan-hermes/home/arbor-stack`. fleet-telematics lives in the **canonical** path; crons (poller 20-min, rollup nightly) point there.
