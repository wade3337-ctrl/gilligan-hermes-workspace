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
updated: 2026-07-24
---

# 📊 TRIM IT investor/owner case (2026-07-24)

**One-liner:** Two decks making the case that GSTS's constraint is **intake, not delivery** — built on measured TRIM IT data, not opinion.
**📁** `arbor-stack/bid-process-reengineering/` — `INVESTOR-CASE-FACTBASE.md` (shared facts) · `DECK-A-STEVE-SCOTT.md` (built) · `COST-MODEL-rekeying.md` · `COST-PER-BID-worksheet.md` · `DEPARTMENT-BOTTLENECK-MAP.md`
**Status:** 🔵 Deck A built. **Deck B (Fort Point) not yet built.**

## Audience & goal
- **(A) Steve + Scott** — honest condition. **(B) Fort Point investment team** — efficiency / less overhead / more output per labor hour.
- **Goal = BUY-IN, not dollars.** Both decks close on alignment so *they* ask "what would it take?"

## Skipper's thesis (his words)
Hard to **FIND** info · can't **TRUST** info · hard to **GET info IN**.
Benchmark = **ArborNote** (one-stop on-site setup + inventory + bid, live map, click-to-approve) vs our **11 steps / 7 teams / 5× re-keying**.

## 🚨 The killer finding — bid records are created *after the fact*
RFP + proposal-sent + go-ahead are stamped **within the same second** (RFP 1972933: 15:14:45.093 / .070 / 15:14:44.377). **12% within 60 seconds, 25% within 1 hour, 97% of sent→approved same-day.**
⇒ **TRIM IT is a filing cabinet, not a workflow tool.** Proves "hard to get info in" *and* explains why dates/metrics can't be trusted.
- **Real turnaround** (back-entry excluded, 2,329 bids): median **6d**, p75 **14d**, p90 36d, avg ~17d → Skipper's "10 days" **VALIDATED**. ⚠️ My first pass said median 2d — **WRONG**, contaminated by back-entry. Don't reuse.
- **Dead fields:** `NeedInventory`/`NeedSiteWalk` = **0 of 22,369** RFPs; `EstValue` empty → "we can't answer a basic question about our own sales process."
- Flagged privately for Steve: pipeline/backlog/aging figures rest on back-entered dates — confirm nothing external depends on them.

## 🏭 THREE transcription points (the spine of the case)
1. **Bid desk** — ~23,000 bid-chain records/yr → **≈17,800 duplicate data-entry events**, bid desk **~8 people** ⇒ **~9 duplicate entries/person/working day (~1.5 hr each)**. (⚠️ my raw distinct-ID count said 24 people — Skipper corrected it; see LESSONS.)
2. **Production** — paper crew packets → collected → **a manager types each day in**. 6 months measured: **4,736 crew sheets · 87,189 field hrs · $11,085,071**, keyed by **8 managers** (Manuel Perez 1,491 · Celeste 1,232 · Omar 723 · Larry 592; 499 no enterer). **83 field staff, none enter their own work.** ⚠️ **So TPH — our margin metric — is computed from transcribed paper self-reports.** Present TPH as *"what the system says,"* not verified truth. Fix = tablet field reporting w/ photos + real-time progress.
3. **Billing/AR** — manual extract from TRIM IT → send → **manual QuickBooks entry**. 3,033 invoices / $21.5M per year. 🚨 **No audit trail:** all **50,233 invoices since 2006** stamped `CreatedByID=11` = Rosanna Baez, **inactive, left 4 yrs ago**, `Role001="Generate Invoices"` = a **service account** (I first misread this as key-person risk — Skipper caught it). Payment lands in QuickBooks and never returns ⇒ the AR blind spot is **architecture, not a bug**.

## 🗺️ Department bottleneck map — THE HEADLINE
> **"We don't have a delivery problem, we have an intake problem."**

Every handoff request→cash measured: scheduling median **1 day**; completed→invoiced median **0 days**, **99.4% billed**; production non-productive time only **1.9%**. **All the slowness is upstream of the sale** → narrows the ask *and* proves the back end has headroom to absorb volume (strong for Fort Point).
- 🟡 Open: go-ahead→WO **p90 = 37 days** (median 0) — signed work sitting before it hits the production queue; likely the 2-step status flip. Worth chasing.
- ⚫ **AR blind spot:** `Invoices.StatusDefID` dead since ~2014 → **the ERP can't tell paid vs open**; truth = Dimitry's emailed AR xlsx; **DSO not measurable**. **Raise with Steve PRIVATELY first** — reads as a control weakness in diligence.
- ✅ **"$207K/$1.16M uninvoiced work" INVESTIGATED → NOT leakage, do NOT present.** The uninvoiced set is status `Revised` (superseded by change order); split is clean (Complete 2,763/2,764 invoiced · Revised 0/17); project-level check confirms billing (Moog WO $15,765 vs $15,879 invoiced, 0.7% apart). **Real finding underneath = traceability:** the revised WO→invoice link is severed (`ParentWorkOrderID` NULL on all 17), so you can't systematically prove all completed work was billed. A control gap, **not dollarized**. Skipper to spot-check WO 166236 himself.

## 💰 Cost model — COMPLETE, all times team-confirmed
- **Transcription:** bid desk **2,967 hrs** (17,800 dup entries × **10 min**) + production **2,000 hrs** (8 mgrs × 1 hr/night) + invoice→QuickBooks **506 hrs** (3,033 × 10 min) = **≈5,473 hrs ≈ 2.6 FTE ≈ $165.7K base / ≈$215K loaded.** Sting: partly done by people paid $90–110K.
- **Per bid (RFP→go-ahead):** **≈5.7 hrs ≈ $215 base**, of which **⚙️ friction ≈$76 (35%)**; × 5,145 bids = **≈$1.1M/yr to produce bids, ≈$391K/yr friction (≈$509K loaded).**
- Handoffs are **measured**, not estimated: `dbo.RFPActions` → **29,063 actions / 5,145 bids = 5.6 per bid** (median 5, p90 11, max 25).
- Confirmed times: e-traveler assembly **30 min** · go-ahead activation **10 min** · sales site visit **1–4 hrs** · **inventory 500 trees/day** (→ ≈$0.70/tree; **Goodman 6,400 trees ≈ 13 crew-days ≈ $4,500** — useful for Price Buddy → [[goodman-rfp-bid]]).
- Rates from `gsts-payroll-2026.md`: Sales Admin ≈$26/hr · Arborist ≈$45 · Inventory ≈$44 · IQC ≈$35. **Never put employee names or salaries in a deck.**
- ❓ Open: what % of bids need a site visit ("most" — the data can't say, `Need*` flags empty) = the biggest swing factor; municipal proposal premium unquantified.

## 🏙️ Municipal / the "human API"
- **Celeste** bridges TRIM IT ↔ **Davey TreeKeeper** for Irvine — **contractually mandated**, so the fix is *build the integration* or *price it into the renewal*; we can't drop Davey. **Larry** does the same for all other municipalities. Both $25.00/hr / $52,400.
- Irvine = largest contract by labor (29,898 hrs, $3.6M) at TPH **$120.31** vs the $130 target ⇒ **≈$290K/yr below target** (Long Beach $135.22 ⇒ $446K gap). ⚠️ **TPH can't see the office overhead** — that's the point.

## ⚠️ Measurement corrections to carry forward
- **Always state WHICH TPH.** On **productive hours** commercial **$157.53** > municipal **$146.70** (as always). My earlier "municipal beats commercial" used **blended** TPH including $0-revenue hours (commercial carries 27,325 = 24.4% vs muni 9,716 = 14.5%), which **inverts** the ranking.
- 🚫 **Do-not-present / open:** ~**21,000 commercial field hours with $0 revenue** (T&A explains only ~6,377) — unbilled work or an attribution artifact, unresolved.
- **`Invoices.InvoiceDate` is a BACKDATED accounting date** (reads before completion, median −3d) — measure billing speed off `Invoices.Created`.
- Skipper's corrections: **TRIM IT is not 50 years old** (the *company* is); the **$91K-vs-$84K example was OUR dashboard's bug** — never use it as TRIM IT evidence; don't inflate ship counts (77 files ≈ ~33 streams / ~12-15 deliverables).

## Related
- [[gsts-operating-plan-2026-2031]] — the plan this evidence feeds.
- [[bid-process-reengineering]] — the FLAGSHIP redesign this measures the case for.
- [[vendor-fieldapp-build]] — what already exists to build on.
- [[trimit-db-gotchas]] — the dead/untrustworthy fields called out above.
