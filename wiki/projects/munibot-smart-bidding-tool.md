---
title: MuniBot Smart Municipal Bidding Tool
type: project
domain: work
track: 1
status: LIVE — built by Boss Hermes + installed & smoke-tested on MuniBot (v2 + SKILL palm fix); ready for first live Long Beach run
tags: [munibot, bidding, pricing, municipal, brent, boss-hermes, price-buddy, tph, rfp]
applies: ["[[only-trustworthy-data]]", "[[trimit-stack-and-tph]]", "[[repair-contract]]"]
links: ["[[munibot-data-warehouse]]", "[[pricing-guide-bid-prefill]]", "[[brent-agent]]", "[[aspen-retention-agent]]"]
updated: 2026-07-17
---

# MuniBot Smart Municipal Bidding Tool

**One-liner:** an AI-in-the-loop tool that auto-populates a municipal tree-care bid from a dropped RFP packet (e.g. City of Long Beach PW25-648) so Brent + team review a priced draft instead of building each bid from scratch. Used by **MuniBot (for Brent), Brent, and Boss Hermes**. **Boss Hermes builds it.**

## Vision (Skipper, 2026-07-17)
- **Not a static calc — true AI every run** (each city's pricing schedule is structured differently → live mapping + pricing).
- **Two layers:** (1) **Pricing Brain** — standing, always-current knowledge base; (2) **Bid Filler** — per-RFP agent that fills a specific city's form.
- **North star:** *win the bid at the lowest price that still clears our margin floor.* Win-first (market comps + historically competitive/winning prices), **margin floor = TPH**.
- **TPH is a runtime parameter** — $130/hr this year, rises over time; confirm current rate every run, never hardcode.
- **Multi-year fixed-price = the Irvine trap:** floor set against TPH across the *whole term*, cross-checked vs the RFP's renewal escalation caps (Long Beach has "increase shall not exceed __%/renewal"). If cap < our TPH growth → base price must be higher. Don't lock into a losing contract.

## Three data signals (the Brain)
- **Schedules of comp** — the 11 municipal contracts in TRIM IT (`LocationServiceTypes`, ServiceTypeID 149/47/21, `ProjectGroupDefID=11`). Normalized benchmark (median headline).
- **Price Buddy engine** — existing [[pricing-guide-bid-prefill]] tool (`dbo.GetLevel4PriceRange$TPH`, reads INVOICED history → per-tree $ at species×service×size + AvgTPH). Wire in as a weighted signal + cost floor; **don't rebuild**.
- **Historical bids** — from the **[[munibot-data-warehouse]]** (`/opt/data/municipal-archive/`, ~42GB), NOT TRIM IT (~71% of proposals lack Won/Lost disposition).

## Key methodology (fold in 5 prior crew-flagged fixes)
Time-decay + inflation-normalize vintages; min n≥5 + hierarchical fallback; "floor not ceiling" (selection bias); canopy/access multiplier beyond DBH; show-the-work (N, date range, variance). Store prices at finest size granularity → roll up to any city's brackets.

## Status / resume
- ✅ **Prompt FINAL** → `smart-bidding-tool/PROMPT-for-boss-hermes.md`. Skipper approved to run (2026-07-17); handing to Boss Hermes.
- ✅ **Access wired:** warehouse bind-mounted **read-only** into the `hermes` container at **`/warehouse/`** (NOT under `/opt/data` — the boot wrapper `chown -R /opt/data` collides with a ro submount). Compose `hermes-sandbox`; backup `docker-compose.yml.bak-premount-*`. ⚠️ Recreate hermes ONLY with `HERMES_UID=1000 HERMES_GID=1000` set (default is 10000 → breaks it). Verified read-only + Boss Herman healthy.
- Origin: Skipper drafted a benchmark prompt with Fable-5; asked Gilligan to perfect it for Boss Hermes (crew+loop). Gilligan restructured it from a one-time benchmark into the two-layer agentic tool above.
- Acceptance test = a worked proof-run filling **Long Beach Attachment AA** (packet saved: `inbox-pull/long-beach-pricing-2026-07-16/`).
- ▶️ **NEXT:** Skipper hands the final prompt to Boss Hermes → Hermes builds (crew+loop). Watch for: (1) `.lnk` cities re-sync ([[munibot-data-warehouse]]), (2) Long Beach proof-run as acceptance.

## Related
- [[pricing-guide-bid-prefill]] — the Price Buddy engine this weights in.
- [[munibot-data-warehouse]] — the historical-bid source.
- [[brent-agent]] · [[aspen-retention-agent]] — municipal BD context.

## ✅ 2026-07-17 — BUILT (Boss Hermes) + INSTALLED on MuniBot (Gilligan)
Hermes built it (3 Python scripts: `bid_engine.py`, `competitor_extractor.py`, `bid_output.py` + `SKILL.md`), emailed to Gilligan, who installed it into MuniBot's container (docker `munibot`; host `~/.munibot` ↔ container `/opt/data`):
- venv `/opt/data/.venv` (uv, container-native py3.13) + `pymupdf` + `openpyxl`; scripts in `/opt/data/home/`; `TRIMIT_PIPE` already correct; scratch dir created.
- **v1 (email #62):** all 4 smoke tests pass — `bid_engine` pulled 129 TRIM IT rate items → 48 averaged, 180 nearby, 48 competitor files, 6 Price-Buddy bands; `competitor_extractor` pulled the full WCA-vs-GSTS line-item set.
- **v2 (email #63):** 4 fixes — no-blank auto-fill (Crown Raise=35% Full Prune, Stump=35% Removal), **$130 TPH labor floor** (day $3,120 / emerg $390 day $488 night), variable volume discount (10% under WCA on high-vol bands, 8% std, 5% low-vol), Date-vs-Fan palm. `bid_output` smoke: "46 line items (no blanks)", "all labor ≥ $130 TPH floor".
- **SKILL.md palm fix (email #64):** Date Palm clean 8% under WCA, Fan Palm 40% under. Placed at `/opt/data/skills/productivity/municipal-bid-pricing/SKILL.md`.
- All 3 Herman emails replied (installed + verified) with Skipper approval. Ready for the first live Long Beach run with Brent. Scripts archived at `inbox-pull/munibot-pricing-tool-*`. Install gotchas: container HOME=/root (run scripts by full path); venv MUST be built inside the container. See [[munibot-data-warehouse]] (the data it reads).
## 🧪 2026-07-17/18 — v3 Price Buddy fix + REAL end-to-end test staged
- **v3 (Herman email #65):** Price Buddy cost floor fixed — `EstTPH` (WO-level, wrong) → **`CycleTimeEach`** (real full per-tree cycle: trim+clean+chip+travel, from ~170k Qty=1 completed lines); `BlendedFloor = CycleTimeEach/60 × $130`. Corrected floors: 0-6 $120 (was $28-61) · 7-12 $162 · 13-18 $173 · 19-24 $228 · 24-30 $287 · 31+ $295. `bid_engine.py` only; installed + smoke-tested (v2 backed up in-container). **4 Herman updates today total: v1 → v2 scripts → SKILL palm → v3 Price Buddy.**
- **REAL TEST — Brent's 8 city bids (`inbox-pull/city-bids-2025-2026/`):** sorted into **BEFORE-bids** (8 BLANK pricing forms = MuniBot input) + **WINNING-answers** (8 GSTS SUBMITTED bids = scorecard) + `MANIFEST.md`. Cities: 2025 Bell Gardens / Glendale / Rosemead / West Covina · 2026 Gardena / Norwalk / Pomona / Riverside. Plan: feed the blanks → MuniBot prices (unit rates) → compare line-by-line to what GSTS actually bid.
  - **Caveats:** Glendale = scanned/image PDFs (0 extractable text → needs OCR, likely the weak link); Riverside answer = `RFP_2535_Cost_Summary.pdf` (no "(Submitted)" tag, classified by content).
  - **⏳ Warehouse-inventory gap (Skipper directive):** MuniBot must pull each city's tree inventory from the WAREHOUSE, not the dropped RFP folder. All 8 cities have warehouse inventory (18/18/24/43/9/22/16/27 files), but `bid_engine.extract_inventory_files(rfp_dir)` only rglob's the rfp-dir (competitor files ARE warehouse-searched; inventory isn't). **Emailed Herman 2026-07-18 to add `warehouse/<county>/<city>/` inventory search** (reuse the county-dir walk). Awaiting updated `bid_engine.py` → then install + run the 8-city test.
