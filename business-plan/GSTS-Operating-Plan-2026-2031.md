# Great Scott Tree Care — Operating Plan 2026–2031
## How we deliver the margin expansion the growth plan promises

> 🔒 **STRICTLY CONFIDENTIAL — M&A / need-to-know.** Companion to `GSTS-50M-Growth-Plan.md`. Deal-aware (earnouts, Fort Point). Do NOT surface to Aspen, Boss Herman, MuniBot, Brent, or any shared context.

**Author:** Jason Wade, COO · **Version:** v1 draft, 2026-07-24
**Companion to:** the Strategic Growth Plan (revenue & geography). **This document covers how the business must operate to make that plan achievable.**

---

## 1. The gap this plan closes

The growth plan commits to **EBITDA margin expanding from 20% to 25%** between 2026 and 2031. That single assumption carries an enormous amount of the plan's value:

| 2031 outcome | EBITDA | Exit value @ 10–12× |
|---|---|---|
| Revenue plan delivered, margin flat at 20% | $10.0M | $100–120M |
| Revenue plan delivered, margin at 25% | **$12.5M** | **$125–150M** |
| **Value of the 5 points** | **$2.5M/yr** | **$25–30M of enterprise value** |

Margin expansion of that size does not come from working harder. It comes from **revenue growing faster than the cost of administering it.** Today the opposite is true: our administrative cost scales almost linearly with volume. **This plan changes that relationship.**

---

## 2. The operating thesis

> ### **At every point where we create value — quoting work, doing work, and billing work — the work happens outside our system and is typed in afterward.**

That single pattern explains our cost structure, our data quality, and our inability to answer basic questions about our own business.

**The fix is one principle, applied three times: capture the work once, at the source, as it happens.**

### The measured baseline (trailing 12 months, live production data)

| | |
|---|---|
| **Bid turnaround** | median **6 days**, p75 14, p90 **36** |
| **Handoffs per bid** (logged) | **5.6** average, p90 11, max 25 |
| **Duplicate data-entry events** | **≈17,800/yr** (≈3.4 per bid, 10 min each) |
| **Cost to produce one bid** | **≈$215**, of which **≈35% is friction** |
| **Field data** | 87,189 hrs / **$11.1M** per 6 months, keyed by **8 managers**, ~1 hr each per night; **83 field staff, none enter their own work** |
| **Billing** | 3,033 invoices / **$21.5M** manually extracted and re-keyed into QuickBooks |
| **Total identified friction** | **≈5,473 hrs/yr ≈ 2.6 FTE ≈ $480K base / $624K loaded** |

**$624K of loaded friction on $24M of revenue ≈ 2.6 margin points.** Recovering two-thirds of it delivers roughly **one third of the promised expansion from cleanup alone** — before a dollar of growth.

---

## 3. ⚠️ Sequencing: the earnouts and the exit run on different metrics

This determines the order of everything below.

| Payoff | Metric | What moves it |
|---|---|---|
| **Earnouts 2026–27 (~$10M)** | **Adjusted Gross Profit** — direct-cost GP, **excludes overhead** | **Revenue velocity and field productivity.** Admin savings barely register. |
| **Exit 2031 (EBITDA × multiple)** | **Adjusted EBITDA** | **Overhead reduction** lands squarely here. |

> **Therefore: revenue- and field-facing work comes FIRST — it pays inside the earnout window. Overhead work comes second — it pays at exit.** Reversing this would cost real money on a two-year clock.

---

## 3A. Phase 0 (now → close, H2 2026) — Build the capacity to execute
**Objective: remove the constraints that would make Phases 1–3 undeliverable — at near-zero cost, with no structural change during diligence.**

### 3A.1 Technical delivery capability — the gating constraint ⭐
**Nothing else in this plan is deliverable without the ability to build, deploy and maintain software at a reasonable cadence. Today we cannot.**

**Current state:**
- A fully built, crew-reviewed, security-audited dashboard package has been **staged and waiting since 20 July** — tested work that cannot reach production.
- Technical delivery runs through **a coordination layer between the company and the vendor who performs the work**, adding latency without adding output. Fully loaded cost of that layer: **≈$186K/yr**.
- The **capability itself sits with a single external vendor** under a direct company contract (minimum-spend commitment). Internal technical capability is thin.

**The change — a different delivery model, not just a cheaper one:**

> ### **Design, build and verification move in-house. The external vendor's role narrows to production deployment and specialist work — not primary development.**

1. **Build in-house at a demonstrated cadence.** In roughly the same period the outsourced sales-workflow build produced a shell page (a filter panel and an iframe over an existing results page, unchanged on our server since 25 April), in-house work delivered and verified: **seven V1.5 dashboards · a shared authorisation gate closing real data-exposure across ~20 pages · City Budgets (3 tabs) · the Revenue Performance rebuild (actual-vs-estimate correction, 3-bucket model, dual TPH, non-productive-time analysis) · a landing-page assistant with live write actions · the field-map fix · and the GPS import pipeline reverse-engineered end to end.** All documented and render-verified. **The capability doesn't need to be hired — it needs to be recognised and resourced.**
2. **Narrow the vendor to deployment and specialist work** — production releases, ColdFusion internals, database procedures, and anything touching money. Managed **directly**, under contract with the company.
3. **Institute a real deployment path:** build on play → verify → staged package → **scheduled production window with a named approver and a logged record of what shipped.** Not ad-hoc personal access — a controlled, auditable procedure. *(This also avoids creating a new internal-control gap of the kind identified in §5.3.)*
4. **Restructure the coordination layer.** Owner-directed; execute through HR with a full credential/asset inventory completed **before** notice, and vendor continuity confirmed **first**.
5. **Recover in-flight work product before any change** — source, database objects, specs and current state, deployed to our own dev environment. Salvage what has value (the field-map colour-coding work feeds Phase 1); treat the rest as greenfield.

**Limits of this model — named, not glossed:**
| Limit | Mitigation |
|---|---|
| In-house build capability operates on the dev/play environment, **not production** | The vendor's core role: a controlled production deployment path |
| **Key-person concentration** in the in-house model | Document the process rather than the person; develop a second internal resource; retain vendor capacity |
| Some work genuinely requires a professional developer — CF internals, procs, anything financial | Keep that capacity under contract; scope it correctly rather than defaulting all work to it |
| **In-flight development is invisible** — work has not been living on company infrastructure, so progress cannot be verified or recovered | All development lands on our dev environment as a condition of engagement |

**Effect:**
| | |
|---|---|
| Deployment lead time (staged → live) | weeks → **target ≤5 business days** |
| Run-rate cost removed | **≈$186K/yr loaded** → flows to EBITDA; treat as a **run-rate adjustment in the quality-of-earnings work** |
| Enterprise value of that run-rate @ 10–12× | **≈$1.8–2.2M** |
| Backlog released | the V1.5 dashboard suite and the pending fix package |

**Risks to manage in execution:**
- **Vendor continuity is the critical dependency** — confirm the delivery vendor holds independent credentials before any access is revoked. *(Their application accounts are currently inactive; server-level access must be verified.)*
- **Credential and asset inventory before notice:** production/server admin, domain registrar and DNS, SSL certificates, software licences, hosting/backup/monitoring portals, recovery emails and MFA devices, and any source code held locally.
- **Single-vendor concentration remains** after the change — internal capability development is the mitigation, not an optional extra.
- **Diligence narrative:** *"We restructured a role that was creating deployment latency; the technical work is performed by a direct vendor under contract and has continued uninterrupted."*

### 3A.2 Recover the bid tail — no capital required
The **p90 of 36 days** is where qualified deals die. Ownership rules, aging alerts and a day-7 escalation are a report and a process change, not a build. **Revenue recovery inside the earnout window at effectively zero cost.**

### 3A.3 Instrument the baseline
Publish monthly from now: bid turnaround (median/p90), handoffs per bid, admin hours per $1M revenue, TPH by segment. **By the time investment is requested, we will have trend data rather than a snapshot.**

### 3A.4 Decide buy vs. build
Formal evaluation of the market platform (ArborNote) against extending our own — completed as a Phase 0 deliverable so the answer exists before the question is asked.

### 3A.5 Pilot field capture with one crew
Cheap, reversible, and it establishes adoption reality before any commitment.

---

## 3B. Phase 1 STARTING POSITION — we are inheriting an asset, not starting clean
**Assessed 2026-07-24 via independent walkthrough of the vendor dev environment (`dev.greatscotttreeservice.com`, a separate host from our play sandbox).**

### What exists — more than expected
A genuine rebuild of the field/project application, **not a reskin**:
- **Eight-step Company/Project wizard** — every form bound to live records, populated selects (21 sales reps, ~85 GeoMarkets), inline help, coherent Back/Save/Save-&-Next progression, fiscal-year lock with a real explanation.
- **Boundary editor** — per-shape tooling, draggable vertices, complete Edit Area modal, layer state persisting server-side.
- **Artwork/print layout designer** — 7 paper sizes, 4 zoom modes, 13 toggleable print items, live legends with real counts.
- **Field App BETA** — the strongest screen: satellite view, **WebGL marker layer**, working filter rail, species-colour legend, deep asset edit modal (Details/Images/Observations).
- **Its own JSON API** (`FieldApp/api/map/…`), own CSS/JS, Bootstrap 5.3.
- **Zero application JavaScript errors and no 500s** across every page walked. The code is clean at runtime.

**Genuinely new vs wrapped:** the wizard, Boundaries, Plotting and Field App BETA are new builds. **Exceptions:** the Artwork tab is new chrome around **8 legacy `Tan/Wizard-Map-*.cfm` iframes**, and the Pricing Worksheet is a legacy WebPortal page wearing the new skin.

### 🔍 The real problem — verification discipline, not capability
> **The build quality is good. Nobody opened the tool and looked at it.**

Four small data defects sit in the critical path and make four screens *present* as broken even though the machinery behind three of them is sound:
1. `labelLat`/`labelLng` returned as **empty strings** → plotted at **lat 0 / lng 0** → the map opens on the Atlantic Ocean.
2. The **"Fit" button is inert** — no recovery from (1).
3. **Saved map views unset** → Artwork and Print inherit the broken base map. *The printed map — presumably the deliverable — renders the ocean.*
4. **Six located assets** where the same project's pricing legend totals hundreds.

This is exactly the discipline our repair contract already requires: **render-verify the served output.** It is the cheapest gap in the whole programme to close.

### Additional gaps to carry into Phase 1
- **No tablet breakpoint.** One media query at `767.98px`; **250px nav + 350px sidebar = 600px of fixed chrome.** At iPad width the desktop layout applies in full. **This is a desktop tool today** — a direct gap against the field-capture premise (§4.3).
- **"Add Contact" inserts a blank record before the user types anything** (`Field.Contact.Create.cfm`) — creates junk data by design.
- **Dev app links attachments to PRODUCTION storage** (`www.greatscotttreeservice.com/gsts/Storage/…`) — an environment-boundary problem.
- Project Contacts renders blank fields; Notes flag toggles have **no visible on/off state** and are state-changing GETs; Setup's Inventory Actions are bare links to legacy scripts **with no confirmation step**.
- Company contact data is dirty (duplicates, typos, one email stored as `mailto:…`).

### Consequences for the plan
1. **Phase 1 is NOT greenfield.** Preserve and finish this. **Recover the source before any vendor change** (§3A.1 item 5).
2. **Estimated distance: a handful of focused fixes plus a data backfill to be demonstrable** — further to field-ready, principally the tablet layer.
3. **The vendor conversation is now specific and factual:** *"the map tool opens over the Atlantic and the Fit button does nothing — walk me through how this was tested."* Far stronger ground than a productivity argument.
4. **Institute render-verification as a condition of acceptance** for all delivered work, in-house or vendor.

---

## 4. Phase 1 (2026–2027) — Protect and win the earnouts
**Objective: AGP. Speed and field productivity, not office savings.**

### 4.1 Bid velocity — quote on site, same day
- **Now:** median 6 days; **1 in 4 over two weeks; 1 in 10 over a month.** Competitors quote on site from a tablet.
- **Do:** on-site quoting for bids that don't require a full inventory; eliminate the manual e-traveler assembly (7 reports saved to PDF and combined by hand, 30 min/bid); live totals at the point of scope; customer receives a **live map and approves with a click**.
- **Why it pays now:** win rate decays with every day elapsed. **Faster quoting is revenue from existing headcount** — and revenue is what AGP is built on.
- **Targets:** median **≤2 days** by end-2027 · **p90 ≤10 days** (from 36) · 50% of simple bids quoted **same day**.

### 4.2 Kill the tail, not just the average
- The **p90 of 36 days** is where deals die. Those are qualified opportunities lost to elapsed time.
- **Do:** aging alerts on open bids; a single owner per bid; escalation at day 7.
- **Target:** no bid older than 14 days without an owner and a next action.

### 4.3 Field capture at source — tablets
- **Now:** paper packets printed, handed out, collected, and typed in by 8 managers, ~1 hr nightly. **$11.1M of production per 6 months recorded second-hand.**
- **Do:** crews report **as they go** on a tablet — hours, work completed, **photos**. Real-time job progress visible to office and customer.
- **Why it pays now:** (a) **TPH becomes trustworthy**, so field productivity can actually be managed toward the $130 target; (b) photos and live progress are a **retention and upsell asset**; (c) same-day completion data accelerates billing.
- **Targets:** ≥80% of crew sheets captured in the field by end-2027 · manager nightly entry ≤15 min · TPH reported within 24 hrs of work.

### 4.4 Make TPH real, then manage it
- Productive TPH today: **commercial $157.53 · municipal $146.70**. Blended "true" TPH is far lower because non-revenue hours are large and unevenly distributed.
- **Do:** publish both measures with a single agreed definition; investigate the **~21,000 commercial field hours currently carrying no revenue** (unbilled work vs. attribution error — unresolved, and material either way).
- **Target:** definition agreed and reported weekly by Q4 2026; non-revenue hours explained and reduced.

---

## 5. Phase 2 (2027–2029) — Decouple overhead from growth
**Objective: EBITDA. This is where the margin points are earned.**

### 5.1 One record, end to end
- **Now:** the same site and scope data is re-keyed **5 times** (RFP → e-traveler → proposal → work order → invoice), across **5.6 handoffs** per bid.
- **Do:** collapse 11 steps into 5 stages around **one record**; every handoff becomes a status change with automatic notification instead of an email with a PDF attached.
- **Target:** duplicate entry events **17,800 → under 4,000**.

### 5.2 Close the billing loop
- **Now:** invoices manually extracted, sent, then re-keyed into QuickBooks. Payment never returns to the operating system — **invoice status has not updated since ~2014**, so the ERP cannot distinguish paid from open.
- **Do:** automated invoice delivery; a two-way accounting integration so payment status lives with the job.
- **Targets:** invoice→QuickBooks manual entry **eliminated** · **DSO measurable inside the operating system** · every job traceable **sold → completed → billed → paid**.

### 5.3 Close the control gaps
- **Now:** every invoice for twenty years is attributed to a **single inactive account**; the completed-work→invoice link is severed on revised work orders.
- **Do:** real user attribution on financial records; preserve the work-order→invoice chain through revisions.
- **Why:** audit-ready records are worth real money at exit and remove a diligence objection.

### 5.4 Retire the friction
- **Target: recover ≥60% of the $624K loaded friction by end-2029**, redeployed into selling and supervision rather than removed as headcount.

---

## 6. Phase 3 (2029–2031) — The platform that scales
**Objective: make growth and acquisitions cheap to absorb.**

### 6.1 Municipal expansion without human bridges
- **Now:** one person is a **full-time human API** between our system and Davey TreeKeeper for City of Irvine (**contractually mandated**); a second does the equivalent for every other municipality. Irvine — our largest contract by labor — runs **≈$290K/yr below our TPH target**.
- **Do:** build the integration so a person isn't the bridge; where a foreign system is contractually required, **price that administrative burden into the bid or renewal**.
- **Target:** win a new municipal contract **without adding administrative headcount** — the test of whether this worked.

### 6.2 An acquisition-integration playbook
- Fort Point's thesis is add-on acquisitions. **Every acquisition must be onboarded onto a system.** A platform that is typed into after the fact cannot absorb another company's volume without adding back-office staff — which erodes the very synergy the deal is underwritten on.
- **Do:** a documented, repeatable onboarding path — data migration, crew onboarding, customer and contract transfer — with a target time-to-integrate.
- **Target:** onboard an acquisition in **≤90 days** with **no permanent back-office headcount added**.

### 6.3 Job-level unit economics
- **Now:** we manage margin at the crew-hour level and cannot attribute cost-to-serve at the job level. The fields exist and are empty — `NeedInventory` and `NeedSiteWalk` are populated on **0 of 22,369** RFPs this year.
- **Do:** capture job attributes at source (because capture is a by-product of the work, not extra typing).
- **Target:** margin by job type, service line, and contract — reported monthly.

---

## 7. The scoreboard

**The headline operating-leverage metric:**

> ### Administrative hours per $1M of revenue
> **Today: ≈228** (5,473 friction hrs ÷ $24M). If nothing changes, $50M of revenue requires **≈11,400 hours ≈ 5.5 FTE** of transcription.
> **Target 2031: ≤100** — meaning we double revenue while holding administrative labor flat.

| Metric | Baseline (2026) | 2027 | 2031 |
|---|---|---|---|
| Admin hrs per $1M revenue | 228 | 170 | **≤100** |
| **Deployment lead time** (staged → live) | **weeks** | ≤5 days | ≤2 days |
| Bid turnaround — median | 6 days | ≤2 days | ≤1 day |
| Bid turnaround — p90 | 36 days | ≤10 days | ≤5 days |
| Handoffs per bid | 5.6 | 3 | ≤2 |
| Duplicate entry events/yr | 17,800 | 10,000 | <4,000 |
| Crew sheets captured in field | 0% | ≥80% | ≥95% |
| Manager nightly data entry | ~1 hr | ≤15 min | ~0 |
| TPH — productive (commercial) | $157.53 | — | manage to target |
| Jobs traceable sold→paid | not possible | partial | **100%** |
| DSO measurable in-system | no | — | **yes** |
| Days to integrate an acquisition | n/a | — | **≤90** |

---

## 8. Investment, risk, and what we are NOT doing

**We are not proposing a rip-and-replace.** The data model and write path for nearly every step **already exist inside TRIM IT**. The work is connective tissue plus a field/customer-facing layer.

**Buy vs. build will be evaluated formally.** The market standard (ArborNote) solves the commercial/HOA quoting flow well. A large share of our book is **municipal contract work** — contract periods, city budgets, accruals, per-city invoicing — with years of history in TRIM IT. The likely answer is a **hybrid**: adopt the on-site quoting and customer-approval pattern; keep our system of record. That evaluation is a Phase 1 deliverable.

**Principal risks**
| Risk | Mitigation |
|---|---|
| Field adoption of tablets | Pilot with one crew; make it *faster* than paper or it fails |
| **Technical delivery capacity** — the binding constraint | Addressed directly in **Phase 0 §3A.1**: direct vendor management, a defined deployment path, and internal capability development |
| **Single-vendor concentration** on technical delivery | Build internal capability; document the deployment process so it isn't person-dependent; keep the vendor contract with the company, not an intermediary |
| Change fatigue in the office | Remove typing before adding process; the first change must give time back |
| Diligence/close distraction (H2 2026) | Phase 1 items are small and operational; nothing structural before close |
| Contractually mandated foreign systems (Davey) | Integrate or price it in — do not assume it can be removed |

**Explicitly out of scope:** headcount reduction. Recovered capacity is redeployed to selling, supervision, and quality. *We are not buying software to cut people; we are buying back the capacity of the people we have.*

---

## 9. Why this is the right plan for this owner

Fort Point's value-creation thesis is (1) aggressive organic growth, (2) new-territory expansion, (3) add-on acquisitions. **All three are constrained by the same thing:**
- Organic growth is constrained by **bid velocity and win rate**.
- Territory expansion is constrained by **administrative cost that scales with each new contract**.
- Acquisitions are constrained by **a platform that cannot absorb volume without adding back office**.

**This plan removes the same constraint from all three — and supplies the mechanism for the margin expansion the growth plan already promises.**

---

## Appendix — evidence base
All figures measured from live production data 2026-07-24; step times confirmed with the people who perform the work; pay rates from the 2026 payroll workbook. Full working papers:
`arbor-stack/bid-process-reengineering/` — `INVESTOR-CASE-FACTBASE.md` · `DEPARTMENT-BOTTLENECK-MAP.md` · `COST-MODEL-rekeying.md` · `COST-PER-BID-worksheet.md` · `AS-IS-WORKFLOW-MAP.md` · `FUTURE-STATE-v0.1.md`

**Open items before external use:**
1. Share of bids requiring a site visit ("most" — the data cannot say; biggest swing factor in cost-per-bid).
2. The ~21,000 commercial field hours carrying no revenue — unbilled work or attribution artifact. **Unresolved; do not present.**
3. Loaded-burden multiplier (1.3× assumed) — confirm with the CFO.
4. Municipal proposal premium — unquantified.
