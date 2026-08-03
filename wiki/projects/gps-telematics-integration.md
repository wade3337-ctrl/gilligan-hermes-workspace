---
type: project
domain: work
status: active
created: 2026-08-02
tags: [gps, onestepgps, telematics, production, reconciler, fleet, friction]
applies:
  - "[[friction-hit-list]]"
  - "[[only-trustworthy-data]]"
links:
  - "[[dev-browser-access]]"
  - "[[friction-hit-list]]"
  - "[[play-dev-access]]"
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

## Standing infra note
⚠️ **Two arbor-stack checkouts** — cron/ops use `/home/wade3337/arbor-stack`; session work sometimes lands in `~/.gilligan-hermes/home/arbor-stack`. fleet-telematics lives in the **canonical** path; crons (poller 20-min, rollup nightly) point there.
