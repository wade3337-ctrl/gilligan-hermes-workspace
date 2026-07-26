---
title: TRIM IT investor/owner case (2 decks + measured factbase)
type: project
domain: work
track: 1
status: active
confidentiality: black
tags: [deck, investor, fort-point, workflow, cost-model, bottleneck, transcription, tph, diligence]
applies: ["[[two-track-confidentiality]]", "[[only-trustworthy-data]]", "[[external-comms-contract]]"]
links: ["[[gsts-operating-plan-2026-2031]]", "[[bid-process-reengineering]]", "[[vendor-fieldapp-build]]", "[[trimit-db-gotchas]]", "[[trimit-stack-and-tph]]", "[[gsts-field-labor-rate]]", "[[fort-point-acquisition]]"]
updated: 2026-07-26
---

# 📊 TRIM IT investor/owner case (2026-07-24)

**One-liner:** Two decks making the case that GSTS's constraint is **intake, not delivery** — built on measured TRIM IT data, not opinion.
**📁** `arbor-stack/bid-process-reengineering/` — `INVESTOR-CASE-FACTBASE.md` (shared facts) · `DECK-A-STEVE-SCOTT.md` (built) · `COST-MODEL-rekeying.md` · `COST-PER-BID-worksheet.md` · `DEPARTMENT-BOTTLENECK-MAP.md`
**Status (2026-07-26):** ✅ **Deck A APPROVED v5.1** (tag `deck-a-approved-20260726`, frozen) · 🔵 **Deck B built**, in the Skipper's final read-through. ⚠️ **The figures in the sections below are the 07-24 build — several were re-derived on 07-25/26. The current headline numbers are in [the 2026-07-26 section](#-2026-07-26--both-decks-built-rendered-and-reviewed) at the bottom; read it first.**

## Audience & goal
- **(A) Steve + Scott** — honest condition. **(B) Fort Point investment team** — efficiency / less overhead / more output per labor hour.
- **Goal = BUY-IN, not dollars.** Both decks close on alignment so *they* ask "what would it take?"

## Skipper's thesis (his words)
Hard to **FIND** info · can't **TRUST** info · hard to **GET info IN**.
Benchmark = **ArborNote** (one-stop on-site setup + inventory + bid, live map, click-to-approve) vs our **11 steps / 7 teams / 5× re-keying**.

## 🚨 The killer finding — bid records are created *after the fact*
RFP + proposal-sent + go-ahead are stamped **within the same second** (RFP 1972933: 15:14:45.093 / .070 / 15:14:44.377 — and the proposal RECORD was created **2025-11-17, eight months before its own RFP**, with the go-ahead stamped before both: **the record was built backwards**). **16.2% within 60 seconds, 26.8% within 1 hour, 97.4% of sent→approved same-day.**
⇒ **TRIM IT is a filing cabinet, not a workflow tool.** Proves "hard to get info in" *and* explains why dates/metrics can't be trusted.
- **Real turnaround** (back-entry excluded, **n=3,663** of 5,004 bids that reached a sent proposal): median **6.0 d**, p75 **14.2**, p90 **32**, avg **13.5** → Skipper's "10 days" **VALIDATED**. ⚠️ My first pass said median 2d — **WRONG**, contaminated by back-entry. Don't reuse.
- 📐 **ONE documented basis for every bid figure:** trailing 12 months to **2026-07-22** · population = RFPs with a **sent proposal** · exclude <1 hr as after-the-fact · cap 365 days. Runnable proof: `VERIFY-deck-numbers.sql`. (The 07-24 figures were unreproducible because that pass **mixed windows** — back-entry % from calendar-2026, turnaround from TTM.)
- **Dead fields:** `NeedInventory`/`NeedSiteWalk` = **0 of 22,369** RFPs; `EstValue` empty → "we can't answer a basic question about our own sales process."
- Flagged privately for Steve: pipeline/backlog/aging figures rest on back-entered dates — confirm nothing external depends on them.

## 🏭 THREE transcription points (the spine of the case)
1. **Bid desk** — ~23,000 bid-chain records/yr → **≈17,800 duplicate data-entry events**, bid desk **~8 people** ⇒ **~9 duplicate entries/person/working day (~1.5 hr each)**. (⚠️ my raw distinct-ID count said 24 people — Skipper corrected it; see LESSONS.)
2. **Production** — paper crew packets → collected → **a manager types each day in**. 6 months measured: **4,736 crew sheets · 87,189 field hrs · $11,085,071**, keyed by **8 managers** (Manuel Perez 1,491 · Celeste 1,232 · Omar 723 · Larry 592; 499 no enterer). **83 field staff, none enter their own work.** ⚠️ **So TPH — our margin metric — is computed from transcribed paper self-reports.** Present TPH as *"what the system says,"* not verified truth. Fix = tablet field reporting w/ photos + real-time progress.
3. **Billing/AR** — manual extract from TRIM IT → send → **manual QuickBooks entry**. 3,033 invoices / $21.5M per year. 🚨 **No audit trail:** all **50,283 invoices since 2006** (verified against the DB 2026-07-26 — a review agent claimed 50,233; **the deck was right and the fact base was stale**) stamped `CreatedByID=11` = Rosanna Baez, **inactive, left 4 yrs ago**, `Role001="Generate Invoices"` = a **service account** (I first misread this as key-person risk — Skipper caught it). Payment lands in QuickBooks and never returns ⇒ the AR blind spot is **architecture, not a bug**.

## 🗺️ Department bottleneck map — THE HEADLINE
> **"We don't have a delivery problem, we have an intake problem."**

Every handoff request→cash measured: scheduling median **1 day**; completed→invoiced median **0 days**, **99.4% billed**; production non-productive time only **1.9%**. **All the slowness is upstream of the sale** → narrows the ask *and* proves the back end has headroom to absorb volume (strong for Fort Point).
- 🟡 Open: go-ahead→WO **p90 = 37 days** (median 0) — signed work sitting before it hits the production queue; likely the 2-step status flip. Worth chasing.
- ⚫ **AR blind spot:** `Invoices.StatusDefID` dead since ~2014 → **the ERP can't tell paid vs open**; truth = Dimitry's emailed AR xlsx; **DSO not measurable**. **Raise with Steve PRIVATELY first** — reads as a control weakness in diligence.
- ✅ **"$207K/$1.16M uninvoiced work" INVESTIGATED → NOT leakage, do NOT present.** The uninvoiced set is status `Revised` (superseded by change order); split is clean (Complete 2,763/2,764 invoiced · Revised 0/17); project-level check confirms billing (Moog WO $15,765 vs $15,879 invoiced, 0.7% apart). **Real finding underneath = traceability:** the revised WO→invoice link is severed (`ParentWorkOrderID` NULL on all 17), so you can't systematically prove all completed work was billed. A control gap, **not dollarized**. Skipper to spot-check WO 166236 himself.

## 💰 Cost model — COMPLETE, all times team-confirmed *(⚠️ the TOTALS below are the 07-24 stack — superseded by the ≈17,100 hrs / $729K re-derivation in the 2026-07-26 section; the per-bid mechanics still hold)*
- **Transcription:** bid desk **2,967 hrs** (17,800 dup entries × **10 min**) + production **2,000 hrs** (8 mgrs × 1 hr/night) + invoice→QuickBooks **506 hrs** (3,033 × 10 min) = **≈5,473 hrs ≈ 2.6 FTE ≈ $165.7K base / ≈$215K loaded.** Sting: partly done by people paid $90–110K.
- **Per bid (RFP→go-ahead):** **≈5.7 hrs ≈ $215 base**, of which **⚙️ friction ≈$76 (35%)**; × **5,004 bids** (re-based 2026-07-25 to the single documented window — *was 5,145*) = **≈$1,076,000/yr to produce bids, ≈$380K/yr friction (≈$494K loaded).**
- Handoffs are **measured**, not estimated: `dbo.RFPActions` → **27,865 actions / 5,004 bids = 5.57 ≈ 5.6 per bid** (median 6, p90 12, max 25). ⚠️ Re-measured, not re-divided — dividing the old numerator by the new population would have produced a fabricated 5.8. → [[LESSONS]]
- Confirmed times: e-traveler assembly **30 min** · go-ahead activation **10 min** · sales site visit **1–4 hrs** · **inventory 500 trees/day** (→ ≈$0.70/tree; **Goodman 6,400 trees ≈ 13 crew-days ≈ $4,500** — useful for Price Buddy → [[goodman-rfp-bid]]).
- Rates from `gsts-payroll-2026.md`: Sales Admin ≈$26/hr · Arborist ≈$45 · Inventory ≈$44 · IQC ≈$35. **Never put employee names or salaries in a deck.**
- ❓ Open: what % of bids need a site visit ("most" — the data can't say, `Need*` flags empty) = the biggest swing factor; municipal proposal premium unquantified.

## 🏙️ Municipal / the "human API"
- **Celeste** bridges TRIM IT ↔ **Davey TreeKeeper** for Irvine — **contractually mandated**, so the fix is *build the integration* or *price it into the renewal*; we can't drop Davey. **Larry** does the same for all other municipalities. Both $25.00/hr / $52,400.
- Irvine = largest contract by labor (29,898 hrs, $3.6M) at TPH **$120.31** vs the $130 target ⇒ **≈$290K/yr below target** (Long Beach $135.22 ⇒ $446K gap). ⚠️ **TPH can't see the office overhead** — that's the point.

## ⚠️ Measurement corrections to carry forward
- **Always state WHICH TPH.** On **productive hours** commercial **$157.53** > municipal **$146.70** (as always). My earlier "municipal beats commercial" used **blended** TPH including $0-revenue hours (commercial carries 27,325 = 24.4% vs muni 9,716 = 14.5%), which **inverts** the ranking.
- ✅ **RESOLVED 2026-07-25, and no longer do-not-present:** the ~21,000 commercial (≈30,000 all-segment) field hours at **$0 revenue** are **NOT leakage**. Of 36,888 zero-dollar hours TTM: **6,377** are internal non-productive (Yard · Safety Trg · OJT · Mod Duty — exactly the already-known T&A figure) and **30,351 (99.5% of the rest)** sit on 583 WOs that DO carry revenue on another crew sheet; only **160 hrs / 13 WOs** have genuinely no revenue (11 deliberate "$0 Go-Ahead" goodwill/storm + a Christmas-tree setup). ⚠️ **Mechanism corrected 2026-07-26: multi-CREW, not multi-visit** — two crews on one job, all production posts to one sheet (53% of the hours; multi-visit is 27%). **The real finding is a metric defect: per-crew-sheet TPH is invalid on these jobs — only WO-level TPH is valid**, and this is what inverted the blended segment comparison. 🔒 One of the 13 is an owner's residence (3.8 hrs) — immaterial, but a **related-party item for QoE**; Skipper-only, not for any deck.
- **`Invoices.InvoiceDate` is a BACKDATED accounting date** (reads before completion, median −3d) — measure billing speed off `Invoices.Created`.
- Skipper's corrections: **TRIM IT is not 50 years old** (the *company* is); the **$91K-vs-$84K example was OUR dashboard's bug** — never use it as TRIM IT evidence; don't inflate ship counts (77 files ≈ ~33 streams / ~12-15 deliverables).

## Related
- [[gsts-operating-plan-2026-2031]] — the plan this evidence feeds.
- [[bid-process-reengineering]] — the FLAGSHIP redesign this measures the case for.
- [[vendor-fieldapp-build]] — what already exists to build on.
- [[trimit-db-gotchas]] — the dead/untrustworthy fields called out above.

## ✅ 2026-07-26 — BOTH DECKS BUILT, RENDERED AND REVIEWED
**Deck A — "How Work Actually Moves Through This Company"** (owners + CFO) → **✅ APPROVED by the Skipper, v5.1**, git tag `deck-a-approved-20260726`. Frozen.
**Deck B — "Where the Operating Leverage Is"** (Fort Point) → built, reviewed, still in the Skipper's read-through.
📁 `arbor-stack/bid-process-reengineering/` · PDFs in `pdf/` · renderer `make-deck-pdf.js` · queries `VERIFY-deck-numbers.sql`.
⚠️ **`arbor-stack` is its own git repo** (`gilligan-arborstack`, private) — **NOT covered by the workspace's 30-min push.** Commit and push it separately. → [[github-offchip-backup]]

### The headline numbers (all re-derived 2026-07-25/26 off a 25 Jul 03:03 prod restore)
- **Identified administrative friction ≈17,100 hrs/yr ≈ 8.2 FTE ≈ $560K base / $729K loaded** — bid production excl. IQC ≈8,400 · **inventory QC ≈6,200 (3 FTE, headcount)** · field transcription 2,000 · invoice re-keying 500.
- **≈680 admin hrs per $1M** revenue (on the $25.1M 2026 goal).
- Bid turnaround: median **6 days**, 1 in 4 over two weeks, 1 in 10 over a month (n=3,663).
- **The $610K/$737K figures are superseded.** Do not quote them.

### ⭐ THE BIG NEW FINDING — the bid loop is measurable
The process is a **loop, not a line**: sales admin → **IQC pulls/builds maps** → field counts trees → **IQC enters all data + builds pricing sheets** → arborist prices → **back to IQC for corrections** → repeat → bid packet.
Measured via `RFPActions.UserGroupID=11` (Review = IQC): **2,882 bids, 5,555 visits, 53.5% revisited, 2,673 extra trips/yr, worst bid 9 passes.**

| Trips through IQC | Bids | **Median** days to get the bid out |
|---|---|---|
| One clean pass | 1,277 | **2.3** |
| One round trip | 755 | **9.0** |
| More than one | 782 | 11.1 |

**A round trip roughly quadruples turnaround.** ⚠️ Association, not proven cause — job size is **not** controlled for; that is Phase 1's first measurement.

### Corrections that cost real time (don't repeat)
- **Multi-CREW, not multi-visit:** the ~30,000 zero-revenue field hours happen when two crews work one job and all production posts to one crew's sheet. I invented "multi-visit" from the pattern; the Skipper knew the mechanism. → [[trimit-db-gotchas]]
- **Double-count:** I added the new 2,800-hr IQC line on top of a total that already held a ≈4,200-hr estimate for the same work. **Net out what new evidence replaces.**
- **Means vs medians:** quoted a "13-day" round-trip penalty off averages with a 285-day tail; on medians it is ~7 days.
- **TPH basis:** contract = blended · segment = productive. → [[trimit-stack-and-tph]]
- **Municipal book is 11 cities**, not 20 contracts — a plan KPI ("contracts per bridging FTE") was built on the phantom count.
- **ArborNote is the benchmark, NOT the answer** (Skipper): no municipal capability, breaks past ~5,000 trees, monthly subscription, zero control over the roadmap. Deck B now says so in the body. *(Deck A §10 still carries the old framing — approved, awaiting his call.)*

### Deck safety rails (in `make-deck-pdf.js`, both verified by test)
1. **Name guard** — aborts the build if any employee name would print.
2. **Coaching guard** — aborts if presenter-directed language would print (*"never improvise", "that's the win", "not for the room"…*). Added because Deck A's aside was stripped only by luck of starting `*(Prep note` while Deck B's identical one printed for weeks.
3. Emphasis stripping handles `*italic*` as well as `**bold**` — 7 literal asterisks were printing.

## Superseded / historical
Kept so an old copy of a deck can be dated, and so no one re-derives a figure that was already retired.
- (2026-07-24, superseded) Bid population **5,145** (and **5,166** in the cost model) → re-based **5,004** on 07-25; friction **$391K/$509K** → **$380K/$494K**; total bid-production cost **$1,106,000** → **$1,076,000**.
- (2026-07-24, superseded) Turnaround population **2,329** · p90 **36** · avg **~17** · back-entry **12% within 60s / 25% within 1 hr** → **3,663 · 32 · 13.5 · 16.2% / 26.8%**. Cause: the 07-24 pass mixed a calendar-2026 window with a trailing-12-month one.
- (2026-07-25, superseded) Total identified friction **≈15,400 hrs ≈ 7.4 FTE ≈ $480K/$624K**, then **15,000 hrs / 7.2 FTE / $469K/$610K** → **≈17,100 hrs / 8.2 FTE / $560K/$729K** once **inventory QC (≈6,200 hrs, 3 FTE)** was added on 07-26.
- (2026-07-25, superseded) Admin hrs per $1M: **615 → 600 → ≈680**.
- (2026-07-24, superseded) Invoice count **50,233** → **50,283** (verified against the DB).
- (2026-07-26, superseded) Zero-revenue field hours explained as **multi-visit** → the mechanism is **multi-CREW**. The hours figure was right; the cause was invented from the pattern.

