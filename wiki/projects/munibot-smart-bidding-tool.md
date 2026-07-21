---
title: MuniBot Smart Municipal Bidding Tool
type: project
domain: work
track: 1
status: LIVE — v5 deployed on MuniBot (warehouse-inventory + CycleTimeEach + fail-closed gate); scripted Long Beach proof PASS; agent test-as-prod ran but DIVERGED from the script on the PCA/QAC review gate (see 07-18 v5 section)
tags: [munibot, bidding, pricing, municipal, brent, boss-hermes, price-buddy, tph, rfp]
applies: ["[[only-trustworthy-data]]", "[[trimit-stack-and-tph]]", "[[repair-contract]]"]
links: ["[[munibot-data-warehouse]]", "[[pricing-guide-bid-prefill]]", "[[brent-agent]]", "[[aspen-retention-agent]]"]
updated: 2026-07-18
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

## ✅ 2026-07-18 — v5 DEPLOYED (Herman email #66 "deploy and rerun Long Beach proof") + agent test-as-prod
**Deploy (Gilligan, owner-directed).** Installed `munibot-v5-fix.tar.gz` into the `munibot` container. **Bundle integrity: all 11 SHA256SUMS OK; Attachment AA = `e0f42c…bf233` matches Herman's declared hash byte-for-byte** (the City form is preserved untouched — the generated XLSX is internal analysis only). Backed up prior runtime scripts → `~/.munibot/home/_backups/pre-v5-20260718-013500/`. `uv pip install -r requirements.txt` (adds RapidOCR stack); **15/15 unittest suite PASS**; installed `bid_engine.py`/`bid_output.py`/`competitor_extractor.py`.
- **v5 fixes:** Price Buddy = completed WorkOrderLines, Qty=1, `CycleTimeEach/60 × $130` floor (rejects stale AvgPrice/AvgTPH); **warehouse-inventory gap now CLOSED** — inventory discovery checks the active RFP packet first, then the whole city warehouse (candidate-gated RapidOCR for scanned PDFs); full inventory (87,229) kept separate from the 20,000-tree annual cap; premium rates held where TRIM IT has a verified one; formula-driven workbook; final XLSX reopened+validated before reporting success; **no email-sending function in the bundle.**
- **Scripted Long Beach proof = PASS:** engine exit 0 (Price Buddy 6 bands CycleTimeEach; inventory **87,229**; cap 20,000). `bid_output.py` exit **2 = intended fail-closed** (REVIEW REQUIRED — no verified current LB rate for **Pest Control Advisor** + **Qualified Applicator** → safe fallbacks). Independent `verify_long_beach.py` on the fresh workbook: PASS (46 lines / 64 formulas, watering held $904.49, 6 grid prices all ≥ cycle floors, method `cycle_time_each_qty1_v1`, AA hash intact). Held — nothing to Brent.

**Agent test-as-prod (Skipper: "have MuniBot actually run the test").** Drove the agent itself: `docker exec -u hermes … hermes -z "$(cat prompt.txt)" --skills municipal-bid-pricing --yolo` (model glm-5.2). ⚠️ **Gotcha:** nested double-quotes in the `-z` prompt (path with spaces) broke shell parsing → pass the prompt via a FILE and `-z "$(cat file)"`; also the log dir must be `chown hermes` (a root-made dir → Permission denied). Agent exit 0, built its own 5-tab workbook (`muni-scratch/lb2027/Long_Beach_PW25-648_Cost_Proposal.xlsx`), **dispatched its own 2 crew reviewers** (caught+fixed a stump-grinding 35%-of-removal overprice), and **HELD release** (no email, nothing to Brent). Strong challenger analysis: found WCA's actual 2021 bid in the warehouse, escalated at 3.5% CPI, won the 4 volume bands (+10%/+5%), floor-held the 2 small-tree bands WCA underbids below our cost.
- **🚩 KEY FINDING — agent vs script DIVERGE on the review gate:** the v5 *script* fail-closes (exit 2, REVIEW REQUIRED) on PCA/QAC when TRIM IT has no verified current rate. The *agent's own skill workflow did NOT* — it priced them (PCA $173.76/hr, QAC $128.63/hr) and only marked the sheet "HOLD — pending review." So Herman's script-level fail-closed gate is **not enforced inside the skill logic** the agent runs. Also inventory drifted: agent **87,481** vs script **87,229** (~0.3%, different discovery paths). → Worth wiring the fail-closed PCA/QAC gate into `SKILL.md` so the agent reproduces it. Captured in [[munibot-data-warehouse]] context; artifacts: `~/.munibot/home/muni-scratch/agent-runs/` (log + prompt).

## 🤖 2026-07-20 — MuniBot given its OWN 2-judge bid-check crew (Kimi K3 + Gemini 3.1 Pro)
Skipper: give MuniBot a bid-checking crew (gpt-5.6-sol + Kimi 3). Chose the **crew-script pattern** (arbor-core style), not native sub-agent models.
- **Kimi K3** ✅ — ported `kimi-ask.py` → `~/.munibot/home/crew/`, key → `~/.munibot/.secrets/kimi.json`; tested live in-container (as hermes).
- **gpt-5.6-sol** ❌ — installed codex 0.144.1 (static musl binary) but FAILED on auth. Root cause: MuniBot's codex ChatGPT-oauth token expired and its single-use **refresh token was already used by the host codex** — two copies can't share one oauth ([[herman-agent]] uses API-key crew, NOT a shared codex). See LESSONS `[infra/agents] Codex ChatGPT-oauth can't be cloned into a 2nd container`.
- **Fix (Skipper, one login, no spare):** MIRROR Herman's crew instead of sol → removed the codex binaries, added **Gemini 3.1 Pro** (`gemini-ask.py`, key `~/.secrets/gemini.json`), tested live ✅.
- MuniBot now runs a **Kimi + Gemini** 2-judge bid-check crew. Pointer in `~/.munibot/memories/MEMORY.md` + guide `~/.munibot/home/crew/README.md`; both under the bind-mounted `~/.munibot` → survive restart/recreate.
