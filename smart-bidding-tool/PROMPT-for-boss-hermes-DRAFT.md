# PROMPT — Build the Municipal Smart-Bidding Tool (for Boss Hermes)

> **Executor:** Boss Hermes, using the crew + loop techniques (subagents at every phase).
> **Users of the finished tool:** MuniBot (on Brent's behalf), Brent directly, and Boss Hermes.
> **Kickoff (Skipper, 2026-07-17):** approved to run. Build it right out of the box with the crew.

---

## 0. Environment & access — READ FIRST (so you don't stall mid-build)

You run in container `hermes` (`~/.hermes → /opt/data`). Confirm each resource before you rely on it:

- ✅ **TRIM IT (schedules of comp + Price Buddy):** you have `/opt/data/home/trimit-query.sh` (read-only SQL, pipe on stdin). The Price Buddy engine is the SQL function **`dbo.GetLevel4PriceRange$TPH`** — inspect it directly in TRIM IT. Municipal segment `ProjectGroupDefID = 11`.
- ⚠️ **The warehouse (historical bids) is NOT mounted in your container.** It lives in **MuniBot's** container at `/opt/data/municipal-archive/` (host: `~/.munibot/municipal-archive/`, ~42 GB, 185 cities). Your `/opt/data` is `~/.hermes` — you cannot see it. **Resolve this FIRST, one of two ways:** (a) ask the Skipper/Gilligan to bind-mount the warehouse **read-only** into your container, or (b) **delegate all warehouse mining to MuniBot** (it has the mount + is the Track-1 owner of this data) and consume its structured results. Do not fabricate the historical-bid layer because you can't reach the files — stop and get access.
- 📎 **Long Beach proof-run packet** (Deliverable 4): `Pricing Worksheet.xlsx` (143K-tree inventory + species×DBH matrix) + `Appendix 1 - Cost Proposal.pdf` (the fill form, "submit AS IS"). Currently staged in Gilligan's workspace; have it placed where you can read it before the proof-run.
- 🔒 **Confidentiality:** this is Track-1 municipal data. Keep it Track-1; never mix in arbor-core / Track-2 / BLACK material.

---

## 1. Mission

Build a **reusable, AI-in-the-loop tool** that takes a dropped municipal RFP packet (a city's cost-proposal form + any tree inventory it comes with, e.g. the City of Long Beach PW25-648 packet) and **auto-populates a priced bid draft for human review**. Brent drops the packet → MuniBot fills the line items with recommended prices + rationale → the team reviews and adjusts in a meeting.

**This is NOT a static calculator.** Every city's pricing schedule is structured differently, so the mapping and pricing use **live AI reasoning on every run**. The static parts (our historical data) live in a standing knowledge base; the reasoning parts (map this city's form, weigh the signals, set the price) happen fresh each time.

The tool is **two layers**:
- **Layer 1 — The Pricing Brain:** a standing, always-current knowledge base of what work is worth (built from our comps, our invoiced history, and our historical bids).
- **Layer 2 — The Bid Filler:** a per-RFP agent that reads a specific city's form and fills it using the Brain.

---

## 2. North star — the pricing philosophy (this defines "smart")

**Win the bid at the lowest price that still clears our margin floor.**

- **Lead with competitiveness** — price to *win*, driven by market comps (what other cities pay) and our historically competitive/winning prices.
- **Hard floor = margin at our current throughput target (TPH).** TPH = **$130/hour this year**, but it **rises over time**. Treat TPH as a **runtime parameter confirmed on every run** — never hardcode 130. If MuniBot/Boss Hermes doesn't know the current rate, **get it (TRIM IT / ask the Skipper) before pricing.**
- **Multi-year fixed-price danger — the Irvine trap.** On a locked, multi-year contract we can't re-price mid-term, but our cost/target keeps rising. So the floor must be set against **TPH over the whole contract term**, not just today. Cross-check the RFP's own escalation caps (Long Beach: *"price increase shall not exceed ___% per renewal period"*). **If that cap is below our expected TPH growth, the base price must be set higher** to avoid locking into a losing contract. Going too cheap once = years of losing work (Irvine is the cautionary example).
- **Never silently price below floor.** Any recommended line under the multi-year floor is flagged as a loss-maker with the shortfall shown.

---

## 3. Ground rules (strict — keep from the original)

- **Never invent or estimate a price.** Every number traces to a source: a contract line, an invoiced job, or a stated model input. Unreadable/absent = record **MISSING**, move on.
- **Only trustworthy data reaches the team.** Flag anything wonky; omit rather than mislead.
- **Use the crew at every phase** (produce → independent check → resolve disagreements with evidence). Log every disagreement + resolution in the **Data Quality Log**. If verification is skipped anywhere, **say so** — a silently unverified number is worse than a flagged one.
- **Confirm counts and STOP on surprises.** If the contract count, form structure, or data reality differs from what's assumed here, stop and report before proceeding.
- **Don't round intermediate values;** round only final displayed prices to the cent, hours to one decimal.

---

## 4. Use what already exists (do NOT reinvent)

- **"Pricing Buddy" already exists — it's "Price Buddy."** There is an active project, *Pricing Guide → History-Aware Bid Prefill*. **Read `arbor-stack/pricing-guide/PROJECT-pricing-bid-prefill.md`** and the SQL function **`dbo.GetLevel4PriceRange$TPH`** before touching Phase for it. How it *actually* works: it reads **invoiced history** → per-tree price at *species × service class × size*, with **Avg TPH**; suggested price = `price × (target TPH ÷ actual TPH)`. It is **not** a "crew-hours × $130" table. **Wire it in as one weighted signal + the cost-floor; do not rebuild it.**
- **Historical bids live in MuniBot's warehouse**, not TRIM IT: **`/opt/data/municipal-archive/`** (~42 GB, organized by county/city, including prior bid working files). ⚠️ **Do NOT use TRIM IT proposal win/loss for this — ~71% of proposals are never marked Won/Lost** (the disposition gap is why Price Buddy reads invoiced work instead).
- **Current schedules of comp are in TRIM IT — this is the PRIMARY, authoritative source.** `LocationServiceTypes` keyed by `Locations.ProjectID → LocationID`; `ServiceTypeID` 149 = pruning, 47 = removal, 21 = planting; municipal segment `ProjectGroupDefID = 11`; read-only via MuniBot's `trimit-query.sh`. This holds the **current, live** rate card for every municipality we contract with — start here. **Boss Hermes: if you lack TRIM IT read access or schema knowledge, delegate the extraction to MuniBot, who has both.**
- **The warehouse COMPLEMENTS TRIM IT (does not replace it):** it holds schedule-of-comp *exhibit PDFs* (~291 "schedule"/201 "compensation" files) — use these for (a) source-of-truth verification, (b) **historical/expired rates** the time-decay analysis needs, and (c) **cities not in TRIM IT** (ones we bid but didn't win). TRIM IT = current & structured; warehouse = broader, historical, source PDFs.

---

## 5. LAYER 1 — Build the Pricing Brain (standing knowledge base)

Three signal sources, normalized into ONE MuniBot-queryable store.

### 5A. Schedules of comp — the 11 municipal contracts *(the original prompt's Phases 1–3, hardened)*
- **Phase 1 — Raw extraction, verbatim, no interpretation.** Per contract: municipality, term (start/end), escalation terms, and every priced line item exactly as written (line #, description, unit, size class, price, contract year the price applies to). **Blind double-extraction** by two independent agents, then reconcile line-by-line; mismatches get re-read at the source. **Confirm the count** — if not exactly 11 priced schedules, STOP and report what you found.
- **Phase 2 — Normalize** into the canonical taxonomy (below). **Store at the FINEST size granularity available** so prices can roll up to *any* city's brackets (Long Beach uses `0-6 / 7-12 / 13-18 / 19-24 / 24-30 / over-31`; other cities differ). Keep raw bands; map by midpoint; a band spanning two canonical bands is recorded in both and flagged **split-band**. Never force a fit — unmappable → **Other** + flag.
- **Phase 3 — Benchmark stats** per (service × size band × unit): n, min, max, **median (headline)**, mean, stdev, and the full list of (municipality, price) pairs. Include n=1 items, marked.
- **Add the 5 fixes a prior 4-lab crew review already flagged on this exact logic:**
  1. **Time-decay + inflation-normalize** across vintages — adjust older-year prices to present-day before comparing; apply a freshness weight (~18-month half-life). *(The original prompt has zero time-normalization — real hole.)*
  2. **Min-N** — require **n ≥ 5** to trust a cell; below that, hierarchical fallback (city → county → all) and always **show N**.
  3. **"Floor, not ceiling"** — invoiced/won data is selection-biased; label benchmarks accordingly.
  4. **DBH-only is too crude** — carry a **canopy/access multiplier** hook, not just size bracket.
  5. **Show the work** — every number carries N, date range, variance.

### 5B. Price Buddy engine — our invoiced/TPH signal *(original Phase 4, corrected)*
- One agent documents Price Buddy from the existing project doc + SQL; a second **verifies by reproducing ≥2 calculations** from underlying data. Express in real terms: **hours = invoiced $ ÷ actual TPH**; **our cost floor per line = the price that yields target TPH** (at the runtime TPH).
- Output: per canonical band, **our cost floor at a given TPH** (parameterized, not hardcoded to 130).

### 5C. Historical bids — the "what's been competitive" signal *(NEW)*
- Mine `/opt/data/municipal-archive/` for **our prior bid submissions** and, where the packet reveals it, **outcomes** (who won, at what price). Extract what we bid per line item.
- Use as the competitive-range signal. **Flag disposition gaps honestly** — don't imply win/loss we can't source.
- **Verified warehouse contents (2026-07-17):** 185 city folders across 5 counties — ~3,562 "bid", 1,188 "proposal", 319 "cost", 291 "schedule", 201 "compensation", 210 "award", 7,835 "invoice", 733 "inventory" files, plus GIS shapefiles. Structure = per-city contract lifecycle (agreement, amendments, award staff report, bid working files, invoices, inventory).
- ⚠️ **Known gap:** 7 cities are Windows `.lnk` shortcut stubs whose data did NOT transfer — **Long Beach, Anaheim, Aliso Viejo, Cerritos, Lake Forest, Stanton** (+ a network-share shortcut). Treat these as **empty/missing** until re-synced; do not report "no history" for them as if it were real absence.

### Brain output
- **One structured, MuniBot-queryable store** (not just human CSVs) keyed by *canonical service × size band × unit*, each cell holding: comp median (+stats, vintage-adjusted), our TPH cost-floor (at a given TPH), historical-bid competitive range, confidence/N, and full provenance.
- **A refresh procedure** so a new or updated contract/price re-runs the affected slice — this is the "always aware" requirement.

---

## 6. LAYER 2 — The Bid Filler (runs per RFP, AI-in-the-loop, itself a crew+loop job)

**Input:** a dropped RFP packet (cost-proposal form + any inventory/shapefile export, like Long Beach's 143K-tree worksheet).

**Steps each run:**
1. **Parse the city's form** → its exact line items, units, size bands, contract term, and renewal escalation caps.
2. **AI-map each city line to our canonical taxonomy** — this is the part that can't be static. A **judge agent verifies every mapping** ("would the city agree this line belongs in this bucket?"); unmapped → flag, never force.
3. **Confirm current TPH + contract term;** compute the **multi-year margin floor** (project TPH across the term, cross-checked against the RFP's escalation cap — see §2).
4. **Price each line from the weighted blend:** win-first (competitive comps + historical winning range) **subject to the multi-year floor.** Emit price + rationale + confidence + floor-check status.
5. **Skeptic pass** — every line checked against floor and comps; loss-makers and thin-evidence lines flagged.
6. **Completeness critic, loop-until-dry** — no line left blank, every price justified, every flag surfaced; repeat until it finds nothing new.

**Output:** the **filled cost-proposal draft in the city's own format** + a **rationale/confidence sheet** + a **"review these" list** (low-confidence, at-floor, or strategic-call lines) — handed to Brent + team to adjust in the meeting.

---

## 7. Deliverables

1. The **Pricing Brain** data store + schema.
2. The three source pipelines (5A / 5B / 5C) + the **Data Quality Log**.
3. The **Bid Filler** tool/skill, invocable by **MuniBot (for Brent)** and **Boss Hermes**.
4. A **worked proof-run on the Long Beach RFP** (fill Attachment AA end-to-end, with rationale) — this is the **acceptance test**.
5. The **refresh procedure** doc.
6. **Final report:** contracts processed, raw line items extracted, clean-vs-flagged counts, what crew verification caught and corrected, how Price Buddy works (one paragraph), the 5 highest-volume canonical line items with median prices, and the Long Beach proof-run findings (which lines are at-floor / strong-margin / strategic).

---

## 8. Crew + loop (required — every phase AND every bid run)

- **Phase 1 blind double-extraction + reconcile** (a price that survives two blind reads is trustworthy).
- **Phase 2 mapping judge** (challenges every forced fit).
- **Phase 3 adversarial skeptic** (attacks the statistics — mixed units? outliers with mundane causes?).
- **Phase 5B verifier** (reproduces ≥2 Price Buddy calcs).
- **Completeness critic, loop-until-dry**, at the end of Layer 1 *and* on every Bid-Filler run.
- **Record every disagreement + resolution in the Data Quality Log.**

**Recommended execution order (so it lands out of the box):** build Layer 1 (5A → 5B → 5C) → stand up the Brain store → build the Bid Filler → **prove it on Long Beach (Deliverable 4)** → then the refresh procedure. Parallelize the 11 extractions; Phase 2 waits on all 11 (barrier).

---

## 9. What NOT to do

- Don't average across different units (per-tree vs per-inch vs per-hour vs lump-sum stay separate).
- Don't drop n=1 line items — mark them.
- Don't silently resolve ambiguity — flag and keep going.
- Don't skip crew verification on any phase; if it genuinely can't run, disclose it.
- **Don't hardcode TPH** — confirm the current rate every run.
- **Don't price a multi-year fixed line to today's TPH** — use the whole-term floor.
- **Don't treat TRIM IT proposal Won/Lost as reliable** (disposition gap).
- **Don't rebuild Price Buddy** — wire in the existing engine.
- Don't deliver a bid draft with any line blank or any price unjustified.
