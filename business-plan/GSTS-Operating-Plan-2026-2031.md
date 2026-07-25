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
| **Bid turnaround** | median **6 days**, p75 14, p90 **32** (3,663 bids with genuine elapsed time) |
| **Handoffs per bid** (logged) | **5.6** average, p90 12, max 25 |
| **Duplicate data-entry events** | **≈17,800/yr** (≈3.6 per bid, 10 min each) |
| **Cost to produce one bid** | **≈$215**, of which **≈35% is friction** |
| **Field data** | 87,189 hrs / **$11.1M** per 6 months, keyed by **8 managers**, ~1 hr each per night; **83 field staff, none enter their own work** |
| **Billing** | 3,033 invoices / **$21.5M** manually extracted and re-keyed into QuickBooks |
| **Transcription only** (re-keying we already timed) | **≈5,473 hrs/yr ≈ 2.6 FTE ≈ $165.7K base / $215.3K loaded** |
| **Total identified friction** (transcription + the rest of bid production) | **≈15,000 hrs/yr ≈ 7.2 FTE ≈ $469K base / $610K loaded** |

**$610K of loaded friction on $25.1M of revenue (the 2026 goal) ≈ 2.4 margin points.** Recovering two-thirds of it delivers roughly **one third of the promised expansion from cleanup alone** — before a dollar of growth.

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
The **p90 of 32 days** is where qualified deals die. Ownership rules, aging alerts and a day-7 escalation are a report and a process change, not a build. **Revenue recovery inside the earnout window at effectively zero cost.**

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

### 4.0 Make the win-rate measurement canonical — it exists, but only one place knows how
**We do measure win rate: 70.2%** (trailing 12 months, 3,335 net-new proposals; municipal recurring work excluded). The definition lives in `Executive$ClosePercentage$ByRep` and is correct.

**The problem is that the definition is non-obvious and undocumented outside that one file.** Win and loss are recorded on the **go-ahead**, not the proposal:

| Where you'd look | What you find | Verdict |
|---|---|---|
| `Proposals.Approved` | **0 of 5,015** | dead field |
| `Proposals.DateApproved` | **0 of 5,015** | dead field |
| Proposal status = "Lost" | 194 of 5,015 (3.9%) | **misleading on its own** |
| **`GoAheads.StatusDefID`** | Archived 951 · Inactive 412 · **Lost 345** · Expired 31 | ⭐ **this is the real loss signal** |

Take the obvious route and you get a **96% win rate**, which is nonsense. Take the correct one and you get **70.2%**, which is a real number. *(This was tested the hard way on 2026-07-25 — the obvious route was taken first and it was wrong.)*

> **Two people asked for "our win rate" today would produce 70% and 96%, both in good faith. That is a reporting risk in a diligence year.**

**Do (Q3 2026, near-zero cost):**
1. **Canonise the definition** — into the metric-standards reference, not just one dashboard's comments: *net-new proposals in window (excluding municipal recurring) with a live go-ahead ÷ all such proposals.*
2. **Populate the proposal-level outcome too**, so the answer doesn't depend on knowing the go-ahead trick — Won / Lost / No-Decision with a reason code on Lost.
3. **Publish win rate weekly**, segmented by rep and segment, from the one canonical query.

**Targets:** canonical definition published and adopted by **Q4 2026** · win rate reported weekly from a single source by **Q4 2026** · proposal-level outcome populated on **≥95% of new proposals** by **Q1 2027**.

### 4.0b The win-rate/speed link — directionally supportive, not yet clean
Measured on the bids where turnaround is computable:

| Turnaround | Bids | Win rate |
|---|---|---|
| ≤1 day | 429 | **97.2%** |
| 2–3 days | 285 | 92.3% |
| 4–7 days | 393 | 92.4% |
| 8–14 days | 422 | 90.8% |
| 15–30 days | 342 | **88.9%** |

**An ~8-point spread between same-day and three-week quoting** — which is the mechanism this whole phase rests on. ⚠️ **But do not present it as proof yet:** this subset requires an RFP→proposal link, and linked bids skew toward wins, so the levels are inflated and the 30+ day bucket is noisy.

**Making it clean is a Phase 1 deliverable**, because it converts "faster quoting wins more work" from an industry belief into our own measured number — and that is what turns a speed target into a revenue forecast.
**Target:** a defensible win-rate-by-turnaround curve, on the full proposal population, by **Q1 2027**.

### 4.0c ⚠️ Whose clock is it? — every Phase 1 speed target is on OUR time only
**Raised by the COO 2026-07-25, and it must be answered before any target is presented:** *"the time it takes to get a go-ahead isn't always something we control — we wait for the customer to sign, and sometimes it has to go in front of their board."* **Correct — so the targets are deliberately set only on the part we own.**

| Clock | Span | Whose | Do we target it? |
|---|---|---|---|
| **Quote production** | customer request → **proposal sent** | **OURS** | ✅ **Yes — every target in §4.1/4.2 is this clock.** median 6d, p90 32 |
| **Customer decision** | proposal sent → go-ahead | **THEIRS** — signature, board meeting cadence, budget cycle | ❌ **No.** Not ours to promise. |
| Activation | go-ahead → work order | ours | ⚠️ p90 37 days — see §4.2 |

**And the data confirms the split is clean.** On *our* clock, board-governed customers are no slower than direct ones:

| Segment | Bids | Median | p90 |
|---|---|---|---|
| Commercial / direct | 1,017 | **6.9 d** | 33.4 |
| **HOA / property management (board-driven)** | 1,615 | **6.8 d** | 36.1 |
| Municipal / public | 1,059 | **4.4 d** | 25.0 |

> **If customer governance were driving our quote turnaround, HOA work would be visibly slower than direct commercial. It is 0.1 days different. The six days are ours.**

That closes the most likely objection in the room — *"that's not us waiting, that's the customer"* — with our own data, before it is raised.

⚠️ **Customer decision time is genuinely invisible to us today** (`Proposals.DateApproved` and `GoAheads.ApprovedDate` are empty, and go-aheads are back-entered so 97% appear same-day). **Capturing it is worth doing** — not to target it, but because a customer who takes 60 days to approve is a forecasting fact and a follow-up trigger. Understanding *their* cadence (e.g. an HOA that meets monthly) is a **sales-timing advantage**, not a stick.

### 4.1 Bid velocity — quote on site, same day
- **Now:** median **6.0 days** · p75 **14.2** · p90 **32**. *(Our clock — §4.0c.)*
- **⭐ The target is not a stretch — a third of the work already does it.** **1,159 of 3,691 bids (31.4%) already go out within 2 days.** The job is not inventing a new capability; it is **making the fast path the normal path** and finding out why the other two thirds don't take it.
- **Do:** on-site quoting for bids that don't need a full inventory; eliminate manual e-traveler assembly (7 reports saved to PDF and combined by hand, 30 min/bid); live totals at the point of scope; customer receives a **live map and approves with a click**.
- **Targets** — *stated as moving the existing fast cohort, which is how they will actually be managed:*

| Measure | Now | End-2026 | End-2027 |
|---|---|---|---|
| Bids quoted **within 2 days** | **31.4%** | ≥45% | **≥60%** |
| Median turnaround | 6.0 d | ≤4 d | **≤2 d** |
| p90 turnaround | 32 d | ≤20 d | **≤10 d** |

- **Why it pays inside the earnout window:** every day removed is quoting capacity returned to the same arborists. **Revenue from existing headcount is exactly what AGP is built on** (§3).

### 4.2 Kill the tail — it is where the money actually is
- **Now: 981 bids (26.6%) take more than 14 days**, and they carry **≈$13.5M of quoted value.** That is not a rounding error at the edge of the distribution — **it is a quarter of our quoting, and more than half a year's revenue in slow-moving work.**
- Applying the ~8-point win-rate spread from §4.0b to that cohort implies **roughly $1M of value exposed to elapsed time alone** — directional, and the reason §4.0b's clean measurement is a Phase 1 deliverable rather than a nice-to-have.
- **Do:** aging alerts on open bids; a single named owner per bid; escalation at day 7; a weekly list of everything over 14 days with a next action.
- **Targets:** bids over 14 days **26.6% → ≤10%** by end-2027 · **no bid over 14 days without a named owner and a next action** by Q4 2026.

**Plus the second half of our own clock — activation.** Once the customer says yes, turning a go-ahead into a scheduled work order is entirely ours:

| Go-ahead → work order | Now |
|---|---|
| Median | **0 days** |
| p75 | 4 days |
| **p90** | **29 days** |

Most of it is same-day, which is good. **But one in ten pieces of signed work waits a month to reach the production queue** — revenue already won, sitting still, inside the earnout window. Likely the two-step status flip that fails silently. **Target: p90 ≤5 days by end-2027**, and it is a process fix, not a build.

### 4.3 Field capture at source — tablets
- **Now:** paper packets printed, handed out, collected, and typed in by 8 managers, ~1 hr nightly. **$11.1M of production per 6 months recorded second-hand.**
- **Do:** crews report **as they go** on a tablet — hours, work completed, **photos**. Real-time job progress visible to office and customer.
- **Why it pays now:** (a) **TPH becomes trustworthy**, so field productivity can be managed toward the $130 target; (b) photos and live progress are a **retention and upsell asset**; (c) same-day completion data accelerates billing.
- ⚠️ **Adoption is the whole risk.** Pilot with one crew (§3A.5) and hold to one rule: **if it is not faster than paper for the crew, it fails.** Do not scale on a mandate.
- **Targets:** ≥80% of crew sheets captured in the field by end-2027 · manager nightly entry **60 min → ≤15 min** · TPH reported within 24 hrs of work.

### 4.4 Make TPH real, then manage it
- **Now:** productive TPH **commercial $157.53 · municipal $146.70**. Blended "true" TPH is far lower because non-revenue hours are large and unevenly distributed between segments.
- **✅ The zero-revenue-hours question is resolved (2026-07-25) and it changes this target.** The ~21,000 hours were **not** unbilled work — **99.5% are zero-dollar crew sheets on work orders that carry revenue on other sheets**, because a multi-visit job posts the dollars once while the hours land on every visit.
- ⇒ **The defect is the denominator, not the money.** **Per-crew-sheet TPH is invalid for any job taking more than one visit** — which is most real work. We have been managing the field on a metric that miscounts multi-visit jobs.
- **Do:** compute and report TPH at **work-order level**; publish productive and true TPH side by side with one agreed definition; keep internal time (Yard / Safety Training / OJT / Modified Duty) visible as its own line rather than buried in the denominator.
- **Targets:** work-order-level TPH published as the managed measure by **Q4 2026** · single agreed definition adopted across every dashboard by **Q4 2026** · both measures reported weekly · **Irvine closes its ≈$290K/yr gap to the $130 target by end-2027.**

## 5. Phase 2 (2027–2029) — Decouple overhead from growth
**Objective: EBITDA. This is where the margin points are earned.**

### 5.1 One record, end to end
- **Now:** the same site and scope data is re-keyed **5 times** (RFP → e-traveler → proposal → work order → invoice), across **5.6 handoffs** per bid (p90 12, max 25). **≈17,800 duplicate entry events/yr ≈ 3.6 per bid ≈ 36 minutes of pure re-typing on every bid.**
- **Do:** collapse 11 steps into 5 stages around **one record**; every handoff becomes a status change with automatic notification instead of an email with a PDF attached.
- **Targets:** duplicate entry events **17,800 → under 4,000** by end-2029 · handoffs per bid **5.6 → ≤3** · **p90 handoffs 12 → ≤6** (the worst decile is where rework actually lives).

### 5.2 Close the billing loop — the ERP has not known whether an invoice was paid since 2014
**Measured 2026-07-25, and it is worse than "the status field is stale":**

| | |
|---|---|
| Invoices created in the last 12 months | **3,112** |
| …carrying status **"Pending"** | **3,112 — 100%** |
| Last invoice ever marked **"Paid"** | **24 June 2014** |
| Invoices sitting in "Pending" all-time | **38,001** |

> **For twelve years, every invoice this company has issued has been recorded as "Pending" and never marked paid.** Payment lands in QuickBooks and never returns. "Who owes us" lives in a spreadsheet emailed from accounting.

#### ⭐ Bring AR ageing into our system (COO directive, 2026-07-25)
**AR ageing lives in QuickBooks and reaches us as a spreadsheet emailed weekly. It should live in the system that knows the job.**

**The good news — this is not a build. The tables already exist and have simply never been used:**

| Structure | State |
|---|---|
| **`dbo.Payments`** table | **exists · 0 rows, ever** |
| `Invoices.InvoiceBalance` | exists · populated on **0 of 3,112** |
| `Invoices.DueDate` | exists · populated on **1,126 of 3,112 (36%)** |
| `Invoices.Total` | ✅ populated — **$22.09M** in the last 12 months |

> **"We have a Payments table. In twenty years it has never had a row in it."**
> That single fact is this plan's whole thesis in miniature — **the capability was built and never connected.**

**Staged path — deliberately sequenced so we get the answer early, not at the end:**
1. **Now (weeks, near-zero cost):** we *already* parse Dimitry's weekly AR ageing file automatically for the collections emails. **Point that same feed at the database** — write balances into `Invoices.InvoiceBalance` and receipts into `Payments`. **AR ageing then lives in TRIM IT at weekly granularity immediately**, without waiting for any integration.
2. **Then:** set `DueDate` on 100% of invoices at creation (36% today) — ageing buckets are meaningless without it.
3. **Then (Phase 2 proper):** the **two-way accounting integration** so payment status returns to the job automatically and the weekly file becomes unnecessary.
4. **Then:** retire the emailed spreadsheet as the source of truth.

**Targets:** AR ageing reportable **from TRIM IT** by **Q2 2027** (weekly-refresh basis) · `DueDate` on **100%** of new invoices by Q4 2026 · payment status automatic — **no spreadsheet in the path** — by end-2028 · **DSO trend produced from the system of record**, which is the form a buyer will ask for it in.

- **Do:** automated invoice delivery; a **two-way accounting integration** so payment status returns to the job it belongs to.
- **Targets:** invoice→QuickBooks manual entry **eliminated** (recovering the 506 hrs in §2) · **DSO measurable inside the operating system** by end-2028 · every job traceable **sold → completed → billed → paid** · **invoice status reflects reality on ≥95% of invoices** — the simplest test that the loop is actually closed.
- **Why it pays at exit:** a buyer's diligence team will ask for a DSO trend and an AR ageing straight from the system of record. Today that request cannot be met from the ERP at all.

### 5.3 Close the control gaps — audit-ready records are worth real money at exit
**Measured 2026-07-25:**

| | |
|---|---|
| Invoices in the system, 2006 → 2026 | **50,283** |
| **Distinct creators recorded across all of them** | **1** |

Every invoice for twenty years is attributed to a single service account belonging to an employee who left four years ago. **Segregation of duties cannot be evidenced on $21.5M/yr of billing.** Separately, when a work order is revised the link to its invoice is severed (`ParentWorkOrderID` unset), so it is not possible to prove systematically that all completed work was billed — a **traceability** gap, not a leakage one (§4.4 established the money is fine).

- **Do:** real user attribution on financial records; preserve the work-order→invoice chain through revisions; retire the shared service account.
- **Targets:** **100% of new invoices attributed to a real, active user** by Q2 2027 · revision chain preserved on 100% of revised work orders · **both gaps closed before a data room opens.**
- ⚠️ **Raise with the CFO privately before diligence** (§Appendix). A QoE or audit team finds these. **Far better volunteered than discovered.**

### 5.4 Retire the friction
- **Target: recover ≥60% of the $610K loaded friction (≈15,000 hrs) by end-2029**, redeployed into selling and supervision rather than removed as headcount.
- **This is the target that drives the scoreboard (§7):** ≈15,000 hrs less 60% ≈ **6,000 hrs**, spread across $50M of 2031 revenue ≈ **120 admin hrs per $1M**. The headline metric is not an aspiration bolted on at the end — it is the arithmetic of this section plus the growth plan's revenue ramp.
- **Interim checkpoint so it cannot drift:** **≥30% recovered by end-2027**, reported on the same monthly instrument as everything else (§3A.3).

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
> **Today: ≈600** (≈15,000 hrs of identified friction ÷ $25.1M, the 2026 goal).
> **If nothing changes, $50M of revenue requires ≈29,900 hours ≈ 14.4 FTE of administrative friction** — we would add the equivalent of twelve full-time people who never touch a tree.
> **Target 2031: ≤125** — revenue more than doubles *while* administrative labor falls ~60% (§5.4). The ratio improves **five-fold**.

*Basis: "identified friction" = bid-production friction + field transcription + invoice re-keying (§2), the same non-overlapping stack behind the $469K/$610K. Stated on plan revenue in every year so the trend reflects process change, not billing timing.*

| Metric | Baseline (2026) | 2027 | 2031 |
|---|---|---|---|
| Admin hrs per $1M revenue | ≈600 | ≈495 | **≤125** |
| **Deployment lead time** (staged → live) | **weeks** | ≤5 days | ≤2 days |
| Bid turnaround — median | 6.0 days | ≤2 days | ≤1 day |
| Bid turnaround — p90 | 32 days | ≤10 days | ≤5 days |
| **Bids quoted within 2 days** | **31.4%** | **≥60%** | ≥80% |
| **Bids taking over 14 days** | **26.6%** | **≤10%** | ≤5% |
| **Go-ahead → work order, p90** | **29 days** | **≤5 days** | ≤2 days |
| **Win rate** (canonical defn, net-new) | **70.2%** | reported weekly | managed |
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
2. ~~The ~21,000 commercial field hours carrying no revenue~~ — ✅ **CLOSED 2026-07-25:** attribution artifact (multi-visit jobs), not leakage. Fix = work-order-level TPH. See §4.4.
3. Loaded-burden multiplier (1.3× assumed) — confirm with the CFO.
4. Municipal proposal premium — unquantified.
