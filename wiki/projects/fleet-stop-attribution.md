---
title: Fleet Stop Attribution (which job each truck landed on + on-the-way + boom/PTO)
type: project
domain: work
status: active
created: 2026-08-05
updated: 2026-08-05
tags: [gps, onestepgps, telematics, fleet, stop-attribution, boom, pto, production]
applies:
  - "[[only-trustworthy-data]]"
  - "[[async-report-rule]]"
links: ["[[gps-telematics-integration]]", "[[friction-hit-list]]"]
---

# Fleet Stop Attribution

Sister module to yard-departure. Question the Skipper posed (2026-08-05): **record which scheduled job each truck landed on, and highlight guys stopping on the way to/from work.** Recording, NOT judging right/wrong job. Built this session; ships in the morning fleet email. Tooling: `arbor-stack/fleet-telematics/`.

## What it does (the pipeline)
1. **Stops** — `stop_attribution.py` reuses `jobsite_dwell` logic: per truck/day, cluster parked-away-from-yard GPS pings into stops (≥5 min dwell).
2. **Candidate jobs** — `fetch_jobs.sh` pulls the day's job sites from TRIM IT play, **widened source** = union of (a) closed crew sheets for the day + (b) work orders whose scheduled span covers the day (`StartDate ≤ day ≤ EndDate`) → ~37 sites vs 22 from crew sheets alone.
3. **Geocode gaps** — coords resolve from `Locations.Latitude` first, else `AddressDefs.DefaultLocationID` (local, free); still-missing addresses geocoded via **OSM Nominatim** (`geocode_jobs.py`, cached in `geocode-cache.json`, 1/sec). 8/3: **36 of 37 sites resolved (97%)**.
4. **Match** — each stop → nearest job. **Match radius = 550m** (tuned to the data's natural break: near-misses cluster tight at 475–590m = crews parked just off a large-property pin; genuine off-job is >1km). Four states:
   - `at_job` — within 550m of a scheduled job (record the landing)
   - `on_the_way` — off-job stop, **narrowed in the report to the commute window only** (before a truck's first job / after its last) = the "stopping on the way in/out" signal
   - `in_shop` — parked at a known repair shop (`shops.json`; down for repair, not working)
   - `parked` — ≥8h or overnight sit off a job = take-home / idle
5. **Report** — `stop_report.py` → `/tmp/stop-digest.txt` (email section) + `stop-dashboard.html`. Wired into the existing morning job (`yard-morning.sh` + `yard-send.js`) → Skipper-only email + **dashboard http://100.82.161.7:8093/stops.html** (yard board still at `/`).

## Fleet classification (Skipper's key, 2026-08-05)
`truck_role()` in `stop_attribution.py`: **D/B/C = crew · AB = trafficator · BA = crew (Ba Tran) · C1–3 = cameras (excluded).** T = manager/crew, S = sales — **not currently GPS-tracked** (flag as `unknown` if they ever appear). Tracked fleet ≈ all crew + trafficators; there are basically no support trucks to filter.

## The honest finding (why "off-job" ≠ slacking)
Chased and killed three theories (bad pins · fleet mix · multi-truck crew-clustering — only 13/136 near a matched crew-mate). Consistent truth: **TRIM IT carries coordinate pins for only ~37 sites while 56 trucks make 215 stops/day.** Most field stops (residential/route) simply **aren't pinned as jobs** → so the tool is a reliable **job-landing recorder** (8/3: 82 landings / 31 trucks) but **cannot yet be a slacking detector.** Off-job → labeled *likely unmapped work*, **never accused.** The path-B lever (getting more daily work pinned in TRIM IT) is an ops/dispatch change, parked for the Skipper's timing → the **23 no-match trucks**.

## Boom / PTO hours — NEXT (buildable, 2026-08-05)
- Engine bus is **NOT wired** (verified 0/100: eng_hours/idle/rpm/seatbelt empty) — but **that's irrelevant**: the bucket trucks' **PTO is on a wired digital input** (Skipper: *"you can see it live in OneStepGPS — it changes a color on the truck label when they engage the PTO"*).
- **30 boom/bucket units = all B-trucks B23–B55** (`boom-trucks.json`, from the fleet master Vehicle Schedule). B=bucket/boom, C/D=chipper/dump → a crew ≈ B+C+D.
- OSG API does **not** label which input is the PTO (searched: 0 "PTO", `device_field_list` null). Poller now **captures all 4 digital inputs (`in1–in4`) every 20 min.**
- ▶️ **RESUME (tomorrow, needs a workday of data):** identify the PTO input by **correlation** — the input that goes high on B-trucks during daytime job dwells and differs from C/D. Then build **PTO-engaged hours per truck per day** (20-min cadence = directional; tighten for B-trucks later if minute precision wanted).

## Key files (`arbor-stack/fleet-telematics/`)
`stop_attribution.py` (engine, 4-state) · `fetch_jobs.sh` (widened job pull) · `geocode_jobs.py` + `geocode-cache.json` · `stop_report.py` (digest+dashboard) · `shops.json` (repair shops) · `boom-trucks.json` · `osg_snapshot.py` (poller, now captures `in1–in4`) · CSVs `stop-attribution.csv`. Committed to the **`gilligan-arborstack`** repo (separate from the 30-min workspace push — commit AND push it separately).

## Data caveats
Only ~2–3 days of GPS history (poller started 8/2) = directional. Match radius + long-park thresholds are tunable constants. Recipes captured in `LESSONS.md`/`PLAYBOOK.md` under `[gps-fleet]`.
