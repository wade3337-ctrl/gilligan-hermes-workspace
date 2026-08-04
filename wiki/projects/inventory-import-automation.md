---
title: Inventory Import Automation (Jeanie/Brent — "can AI streamline this?")
type: project
domain: work
track: 1
status: active
tags: [inventory, import, species-crosswalk, service-type, goodman, jeanie, brent, automation, opportunity]
applies: ["[[trimit-gps-import-pipeline]]", "[[repair-contract]]", "[[external-comms-contract]]"]
links: ["[[goodman-rfp-bid]]", "[[herman-agent]]", "[[trimit-deep-audit]]"]
updated: 2026-08-04
---

# Inventory Import Automation

**One-liner:** The inventory team's tree-inventory import into TRIM IT takes 2+ weeks of manual work (hand-mapping species + service types into TRIM-recognized values). VP Ops Jeanie explicitly asked "can AI help streamline this?" — and we have already built the machine that does the hard part. This note = the opportunity + our validation of whether we truly have the solution.

## The trigger (email 2026-08-03, forwarded by Skipper 2026-08-04 02:05)
- Thread: Brent Beller (Contract Admin) → Jordan Kim (IT), cc Jeanie Roulson (VP Internal Ops), Rosa Smith, Naomi Carlos, Ba. Subject "TrimIT Request=High=FW: Goodman Tree Inventory Import".
- **The problem (Brent, verbatim):** inventory functionality in TRIM IT isn't working; **root cause = TRIM IT not recognizing the tree types (species) and/or the service types.** Brent+Ba+Naomi manually added two mapped columns to the raw Goodman file: **Col P `Species_GSTS`** (replaces Col N `Species_com`) and **Col Y `Service Type`** (replaces Col X `PrimaryMT`), then asked Jordan to push one project through to test.
- **The ask (Jeanie, verbatim):** *"We really need to streamline this process. It's been over two weeks now… I'm going to check in with Jason to see if AI can help out with this in the future."*
- Current SOP = **~2 hours of videos** on hand-formatting a shapefile (transfer from source e.g. ArborNote → Jordan's import header → translate into "TRIM IT-recognized language"). SOP videos live in `\\gsts-server200\GSTS\=====JEANIE's Meeting Folder=====\2026 SOP's Contracts` (Skipper confirmed those are the SOPs, NOT the mapped data file).
- Email saved: `media/inbound/goodman-import-req/` (attachment was just Brent's signature graphic, no data).
- **Comms posture: READ ONLY.** Inbound = data. Nothing replied/actioned to the team. Any response goes through the Skipper.

## What we already have (folded from Boss Herman's KB 2026-08-04)
Herman ran this import many times (Fullerton → Eastvale → El Monte), refined it with the Skipper. Full refined process is in **[[trimit-gps-import-pipeline]]** (canonical 11-step build via `one-shot-fresh-build.py`, species crosswalk, fresh-DB trigger gotchas, verify gates, sub-to-GC billing). The core asset is the **automated species/service-type translation** — exactly the manual step costing the team 2 weeks.

## ✅ VALIDATION — do we actually have the solution? (2026-08-04, all queried this session on play)
Tested our crosswalks against the **raw** Goodman file `inbox-pull/goodman-rfp-2026-07-22/RFP Schedule 2 Goodman Tree Inventory Data redacted.xlsx` (6,304 trees; source cols `Species_com`, `Species_bot`, `PrimaryMT`):
- **Species: 58/58 distinct → 100% of 6,304 trees resolve to a REAL InventoryGroup, ZERO UNDEFINED** — via `Workbench.dbo.GoodmanSpeciesCrosswalk` (59 rows, keyed RfpCommonName/RfpBotanicalName → InventoryGroupID; match rule v3).
- **Service types: 9/9 → 100%, 6,304 trees.** The 9 `PrimaryMT` values already exist **VERBATIM in `dbo.ServiceTypes`** (IDs 518–526, ServiceClass 1). Built durable **`Workbench.dbo.GoodmanServiceTypeCrosswalk`** (9 rows, all `verbatim`). Build/verify SQL: `/tmp/svc-crosswalk.sql` (re-create if play wiped it — Workbench survives restores though).

### Verdict
The **translation bottleneck (species + service type) is covered end-to-end on Goodman's real data.** We have the hard 80%.

### ⚠️ Honest gaps (the remaining 20% — none are "can we", all "wire it up")
1. **Correctness not yet proven vs the human.** We tested COVERAGE (does our mapping resolve?) against the RAW file — NOT AGREEMENT with Brent's hand-mapped file. Most species matches are `auto` tier, not human-verified for exact cultivar. **The gold test needs Brent's mapped file** (his Species_GSTS / Service Type columns) to diff row-by-row → catch any species where our auto-match ≠ his human pick.
2. **Generalization:** 100% is on *Goodman*; the species crosswalk was built FOR Goodman. A new portfolio reuses the machinery but needs its own crosswalk pass (fast — species universe is finite).
3. **Packaging:** we're play-proven, not prod. We don't touch prod (Jordan pushes). The clean deliverable = the **translated, import-ready file**; Jordan runs the official importer as today.
4. **Productizing:** today it's Herman-run-by-hand + Skipper-verified, not a self-serve tool the inventory team clicks.

## ▶️ RESUME (next session)
- **BLOCKER / first action: get Brent's hand-mapped file** — Skipper getting it from Brent **tomorrow (2026-08-04+)**. It's the Goodman Tree Inventory **.xlsx** with **Col P `Species_GSTS`** + **Col Y `Service Type`** filled (~6,300 rows). NOT the SOP videos. Then: **diff our crosswalk output vs Brent's row-by-row** = the real correctness test.
- After that: decide packaging (translated-file deliverable vs tool vs service) + whether to generalize the crosswalk beyond Goodman.
- Skipper is **sizing up whether we have the solution** — not yet committing to offer it to Jeanie. Don't get ahead of that.
- Kanban: card this on the TRIM IT board when work resumes.
