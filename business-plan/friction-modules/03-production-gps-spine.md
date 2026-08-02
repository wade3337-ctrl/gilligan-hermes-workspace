# Friction Module 03 — Production / GPS-Telematics Spine

**Status: SPINE v1 BUILT (2026-08-02).** Part of the Friction Hit List → 5-Year Business Plan.
🔒 Fort Point / owner-tier. (Production node stays open; this is the foundation piece.)

---

## The premise (Skipper's Production brain-dump)
Core production friction = **no objective, real-time signal on field execution** (yard-departure timeliness · real-time job performance · verifying crews report accurately). It's all self-reported on paper, 15 days late (that's C1). **The fix is GPS/telematics + the tablet field app.** OneStepGPS is already logging the signal (departure, drive, stops, idle, geofences, PTO inputs, harsh-event/speed) — it's just **siloed from TRIM IT.**

Spin-off nodes (Skipper's call): area-manager bandwidth · training · new-hire pipeline · aged-worker retirement/succession.

## The extensible architecture
1. **Feeds** (read-only): OneStepGPS API · TRIM IT/play (`gsql.sh`) · the fleet spreadsheet.
2. **The spine** = one reconciled vehicle map (OSG device ↔ unit# ↔ VIN ↔ TRIM IT ↔ crew). **The keystone every module needs** ("was the right truck there?").
3. **Modules** bolt on: yard-departure · time-on-job vs clock-in/out · crew-assignment-vs-presence · boom/PTO hours · safety scorecard · fuel/idle waste + odometer/maintenance · area-manager activity.

## What's in the data (verified in the live OSG payload)
Every Skipper idea is present: `drive_status`/`drive_status_begin_time` (yard-departure, dwell) · `input1/input2` digital inputs (**PTO/boom** time) · `harsh_event`/`max_accelerating_force`/`posted_speed_limit`/idle (**safety**) · odometer, engine hours, fuel + **idle-fuel waste** · rich vehicle metadata for reconciliation. **No VIN in OSG** (the reconciliation wrinkle).

## The spine build — reconciliation result
Sources: OSG **100** trackers (94 active, no VIN) · TRIM IT `dbo.Equipment` **436** (322 VIN, 211 active) · spreadsheet **246** (VIN + unit# + plate + transponder + cost + retirement).
- **71 units fully reconciled** across all three (the verified core).
- **89/100 trackers matched** to a fleet unit by name. The `AB/B/C/D`-by-type scheme **is shared** across OSG + TRIM IT + spreadsheet.
- **11 "orphan" trackers** are almost all **OSG naming inconsistency** (`B47 HW 1`, `C66 HW 125`, `C 68 Unit #175`, `C74 New HW #9` — the units exist). Genuine unknowns: `C1/C2/C3`, `BA TRAN Unit #169`, `D37`. ⇒ real match ~95%+.

### ⚠️ Corrections logged (accuracy discipline)
- My earlier **"no shared key / can't auto-reconcile" was WRONG** (too-small TRIM sample). The schemes align; ~89–95% auto-match.
- Do **not** state "145 trucks have no GPS" as fact. That first cut (motorized types 1/3/8/9/10/12, TRIM-active, no matched tracker) is **inflated by stale ERP records + the 11 naming mismatches.** It's a **lead** (possible coverage gap), not a measured figure — needs one ERP-active cleanup pass.

## Deliverables / exception lists
`arbor-stack/fleet-telematics/` → `vehicle-master.csv` + `exceptions_untracked_no_gps.csv` · `exceptions_orphan_trackers.csv` · `exceptions_erp_vin_gaps.csv` (81 VIN gaps). Stale/dupe trackers to retire: **AB8 (2021), C1/C3 (2024)** + duplicate "(New)" replacements.
Tooling: `osg_pull.py` (read-only OSG), `equip_raw.txt` export, `reconcile_final.py`. OSG API key in `~/.openclaw/.secrets/` (chmod 600). **Read-only posture; ask before any write/delete** (Skipper's standing instruction — the key has destructive power).

## Key finding
**OneStepGPS device names aren't standardized** — that's the single thing blocking a clean ~100% auto-match. Standardize the names (or store the crosswalk we just built) and the spine is permanent.

## Module A — Yard-departure (BUILT 2026-08-02)
`osg_snapshot.py` poller (every 20 min → `snapshots.jsonl`) + `yard_departure.py` engine. 4 yards in `yards.json`: **Stanton (HQ) · Laguna Woods · Irvine · City of Industry (satellite)**. Minute-precise via OSG `drive_status_begin_time`. Nightly rollup+prune (self-maintaining). First real morning distribution = the AM after 2026-08-02.

## Module B — Time-on-job vs Clock-in/out (BUILT 2026-08-02; cross-check pending data overlap)
**GPS side** (`jobsite_dwell.py`): truck stops away from a yard = job-site visits w/ duration; yard-excluded, multi-crew aware (validated: 2 trucks co-located = one job; roaming arborist = short separate stops).
**Clock side** = `dbo.UserCalendars` — a goldmine: `ActStart/ActEnd`, `OrigStart/OrigEnd` (pre-edit), **GPS at every punch** (`ClockIn/OutLatitude/Longitude`, ~99% of recent field records tagged), meal punches, work-centroid. Audit trail of edits = `dbo.UserCalendarHistory` (5,172 events: editor `UserID`, `CurDate`, `Reason`, old→new).
**Cross-check (truck on-site vs clocked hours + punch-location + edits) is STAGED** — lights up when play clock data (≤ the restore horizon, ~7/30) and the live GPS feed (≥8/2) overlap on a day. Play-lag is the only blocker.

### Clock-side findings (real, on ~60d history — no overlap needed)
- **Integrity is clean:** punch edits are **99.8% supervisor-made** (12 self of 5,172); 5 people do 71% (Manuel Perez, Raudel Gutierrez, Omar Sanchez, Francisco Aguilar, Roxanne Montijo). **Meal-break compliance ~99%** (only ~39 of 3,931 >5h shifts flagged) — a "checked, you're fine" result for a CA company.
- **🚨 NEW FRICTION ITEM — the punch app fails in the field:** of 5,172 edits, **~890 are no-signal/no-service/phone errors** + ~600 system errors + 967 meal-attestation notes. **~1,500 punches are hand-corrected by foremen because crews at remote sites can't get a cell signal to clock in/out.** Same disease as the paper crew sheets — *the tool fails in the field, a human patches it by hand.* **Fix = offline-capable punching** (queue locally, sync on signal). → add to `FRICTION-HIT-LIST.md` §C.
- **City of Industry satellite yard discovered from the clock data** (34.0025, -117.872; 7-person crew: Marco/Benjamin Ayon, Francisco Iniguez, Daniel Cruz Aranda, Jose Cano) — resolved most "elsewhere" clock-ins. Residual true off-yard = **327 (8%)** (Jose Albarran, Alejandro Flores, Mario Ramirez, Luis Franco…) — home/road punches the truck cross-check will resolve.
- Files: `jobsite_dwell.py`, `clock_analysis.py`, `clock_mine.py` (raw `clock_raw*.txt` gitignored).

## Next
1. **GPS #1 (tomorrow):** firm the ~11 OSG name mismatches + clean ERP-active list → "trucks without GPS" as fact.
2. Read the first real yard-departure distribution (AM after 8/2).
3. When play advances to an 8/2+ day: run the **truck-on-site vs clocked-hours cross-check** (resolves the 327 residual off-yard punches + true on-site-vs-reported accuracy).
4. More GPS modules queued: boom/PTO hours, safety scorecard, area-manager activity, 3-way vehicle reconciliation cleanup.
5. **Add the no-signal-punch friction to the main hit list §C.**
