# Great Scott — The Friction Hit List

**A working register of wasted time, manual re-work, and structural drag — what it costs, and what we are doing about it.**

Owner: Jason Wade (COO) · Compiled: 2026-08-02 · Status: LIVING DOCUMENT (attack list)
Audience: internal working tool → feeds the **5-Year Business Plan** and the Scott / Steve / Fort Point conversations.

> 🔒 **Confidential — Fort Point / owner-tier.** Lives with the Operating Plan. Not for the team or shared channels.

> 📚 **Module deep-dives** (built node-by-node with the Skipper) live in `business-plan/friction-modules/`:
> **01 — Marketing / BD** (the 3 door-openers, comp, Nate's biweekly commission reconciliation) · **02 — Sales** (the WorkPhloem verdict + the 5×-rekey correction). Production and the rest to follow.

---

## Why this exists (Jason's framing)

Getting people to change direction is hard when the cost of "how we do it today" is invisible. This document makes it **visible and countable**: every speed bump we know about, in one place, with a dollar or hour figure next to it and a column that says *what we're already doing to kill it*. It turns "we should be more efficient" into a prioritized list you can actually attack — and it shows Scott and Fort Point that the need is real, measured, and already being worked.

### The whole problem in one sentence
TRIM IT is a **filing cabinet, not a workflow tool.** Work happens somewhere else — on paper, in email, in the field, in the arborist's head — and then gets typed *into* the system after the fact. Everything below is a symptom of that one root cause, which shows up as **three problems**:

1. **Hard to FIND** information in TRIM IT.
2. **Can't TRUST** the information (same data entered many times = many chances to diverge).
3. **Hard to GET new information IN** (manual PDF assembly, re-keying, Excel photo sheets, filename rules).

### The headline reframe — this narrows the fix, it doesn't broaden it
> **"We do not have a delivery problem. We have an intake problem."**

We measured every handoff from customer request → cash:

| Stage | Median | p90 | Verdict |
|---|---|---|---|
| Request → proposal sent | **6 days** | **32 days** | 🔴 **BOTTLENECK** |
| Go-ahead → work order | 0 days | 37 days | 🟡 tail risk |
| Work order → scheduled | 1 day | 14 days | 🟢 healthy |
| Completed → invoiced | 0 days | 2 days | 🟢 excellent (99.4% billed) |
| Invoice → cash | — | — | ⚫ not measurable in TRIM IT |

**Everything slow is upstream of the sale.** Once work is sold, the machine runs. That means fixing intake converts **directly to throughput without adding delivery capacity** — the definition of operating leverage, and the single strongest point for Fort Point.

---

## The top-line number

| | Measured |
|---|---|
| Identified administrative friction | **≈17,100 hours / year** |
| In people terms | **≈8.2 full-time equivalents** |
| Loaded cost | **≈$729,000 / year** |
| As an efficiency ratio | **≈680 admin hours per $1M of revenue** → target **≤125** |

*Basis: trailing-12-month TRIM IT data, pulled 2026-07-24/26. Supersedes earlier 15,000 hr / $610K figures. The $729K is being taken as **lower overhead** (drops to EBITDA / enterprise value), not redeployment.*

---

## How to read the columns
- **Cost** — the measured or estimated drag. ⚠️ = basis-fragile, re-derive before any external/deck use.
- **Fix** — the technology or process change that removes it.
- **Status** — where that fix stands today: 🟢 live/proven · 🟡 in build · 🔵 designed, not started · ⚪ documented only.

---

# THE REGISTER

## A. INTAKE — the constraint (all upstream of the sale)

### A1. Bid turnaround is a lottery
- **Friction:** Median bid takes **6 days**; **1 in 4 takes over two weeks (p75 14.3d); 1 in 10 takes over a month (p90 32d).** The average (13.7 days) is **well over twice the median** — that's not a process, it's variance. Every slow day is a day the customer can call a competitor.
- **Cost:** Lost win-rate + arborist capacity. ✅ **Re-derived live 2026-08-02** (n=3,730; data current to 2026-07-29): median 6.0 · p75 14.3 · p90 32.0 · avg 13.7 — all firm.
- **Fix:** ArborNote-style single-record proposal flow — inventory + price + send in one pass, live totals, customer approves by clicking a link.
- **Status:** 🟡 Sales Cockpit → arbor-core bid handoff loop **built and proven** (find job → "Bid this work" → rebid with real inventory).

### A2. The bid record is created AFTER the fact
- **Friction:** For a large share of bids, the request, the "proposal sent," and the approval are all **timestamped within the same hour — sometimes the same second, in reverse order.** ✅ **Re-derived live 2026-08-02: of 5,071 sent bids, 1,342 (26.5%) were created within an hour of being "sent" — 1 in 4.** The real work happened elsewhere; TRIM IT got back-filled. This is *the* definitive proof of "hard to get info in" — and why we can't answer basic questions about our own pipeline.
- **Cost:** Not directly dollarized — it's the *reason* the other intake costs exist. (Note: nothing is back-dated — 0 of 5,033 bids. Say "created after the fact," never "back-dated.")
- **Fix:** Capture once, at the source, in a live workflow.
- **Status:** 🔵 Future-state designed; same build as A1.

### A3. Duplicate data entry (⚠️ RE-PRECISED 2026-08-02 — do not use the old "re-keyed 5×" wording externally)
- **Friction (corrected):** The bid **objects** (RFP → Proposal → Work Order) do **NOT** force manual re-keying — the DB *generates* each from the prior (`GenerateProposal` reads the worksheet; `GenerateWorkOrderLines*` read `ProposalLines`; identity/address flows by reference). The real, defensible duplication sits in: **field inventory/scope capture** (Excel photo sheets · Google-Earth maps · hand counts), **out-of-system artifacts** (PDF assembly, attachments), the **transcription points** (production paper → keyed; QuickBooks re-key), and the **"created-after-the-fact" back-entry** (people work *outside* the tool then back-fill, bypassing the auto-generation).
- **Cost:** The team-confirmed ≈17,800 duplicate-entry events/yr are real, but attach to *capture + transcription*, not object-to-object typing. Re-derive the $ basis before external use.
- **Fix:** Make on-site capture fast/usable enough that people work **in** the tool, not around it (the FieldApp premise) — see module 02.
- **Status:** 🟡 Partly in the WorkPhloem build (inventory capture); ⚠️ **the "5×" claim must be re-precised in the investor case before any Fort Point use.** → `friction-modules/02-sales.md`.

### A4. Manual file-wrangling *outside* the system
- **Friction:** Desktop folders, strict PDF naming (**a `#` breaks the upload**), W: drive logo hunts, **hand-combining many PDFs into one e-traveler**, Excel serialized-photo sheets, Google Earth maps. Error-prone, slow, unsearchable — the real record doesn't live in a searchable system.
- **Cost:** Rolled into the bid-desk friction; also the root of "hard to FIND."
- **Fix:** In-system attachments, auto-generated proposal packet, customer-facing live map.
- **Status:** 🔵 Designed.

### A5. Inventory-QC rework loop
- **Friction:** **53.5% of bids go back through inventory QC** — ≈2,673 extra round-trips/year. One clean pass runs ~2.3 days; a round trip stretches to ~9.0. On top of that, inventory QC **hand-types tree counts and prices and hand-builds maps on PDFs** ≈ **3 FTE / ~6,200 hrs/yr**.
- **Cost:** ~3 FTE + the turnaround tax. ⚠️ 53.5% is an association, not proven cause (job size uncontrolled) — Phase-1's first measurement.
- **Fix:** Capture inventory once at the source; automated quote-checker instead of a manual QC round-trip.
- **Status:** 🔵 Designed; ⚪ the causal driver still to be measured.

### A6. Too many handoffs, and brittle mechanics
- **Friction:** Admin ↔ Arborist ↔ Inventory ↔ IQC ↔ Scheduling ↔ Branch Managers, all via email + action-item queues. Plus **immutable RFP notes** (a typo = delete and redo) and hidden "update it twice" unlock buttons — pure tribal knowledge.
- **Cost:** Coordination drag + bus-factor.
- **Fix:** Handoffs become **status flips + auto-notify**; editable records.
- **Status:** 🔵 Designed.

---

## B. ACTIVATION — sold work that sits

### B1. The two-step go-ahead flip
- **Friction:** Activating approved, signed work requires a **two-step status flip (In Process → Active)** and one flip silently fails. Result: go-ahead → work order has a **p90 of 37 days** — **1 in 10 signed jobs waits a month** to reach the production queue. **8 go-aheads currently stuck mid-activation ≈ $121K** (incl. 5 near-identical Crystal Cove attempts at $22,649 that may never have reached Scheduling).
- **Cost:** Revenue already won, sitting still — inside the earnout window.
- **Fix:** One-click activation + a monitor that flags anything stuck in "In Process."
- **Status:** 🟢 Lifecycle documented + stuck items identified; 🔵 the one-click fix.

---

## C. PRODUCTION CAPTURE — our margin metric runs on paper

### C1. Field work reaches the system second-hand
- **Friction:** Paper crew packets are printed, handed out, collected at day's end, and **keyed in by hand by 8 office staff.** **$11.1M and 87,000 field hours in 6 months reached the system transcribed off paper — not one field employee enters their own work.** Entry lag: median **15 days**, p90 **104**.
- **Cost:** **TPH — the number we manage margin with (target $130) — is computed entirely from transcribed paper self-reports.** Present those figures as "what the system says," not verified truth. Also scales linearly: more crews = more transcription = more office headcount. No real-time job status; the customer sees nothing.
- **Fix:** A **tablet/iPad field interface** — crews report as they go, capture photos the client can see, drive real-time progress. Same "capture once at the source" principle as the bid side.
- **Status:** 🟡 Vendor field-app build in flight (4 known critical-path defects; not greenfield).

### C2. Non-productive field time — **already being attacked** ✅
- **Friction:** Every hour a crew isn't on a job is paid but not billable. Job-booked hours run **~17% below paid hours.**
- **What Jason has already done:** Replaced **3 of the 4 monthly 30-min safety meetings** with a **2-minute daily video briefing (Typhoom).** Net ≈ **47 min/person/month back to the field ≈ 700 crew-hours/year ≈ $90,000** at current rate — **and safety coverage went UP** (daily vs weekly).
- **Status:** 🟢 **LIVE. This is the proof that the plan is already producing results** — lead with it.

---

### C3. The mobile punch app fails at remote job sites (measured 2026-08-02)
- **Friction:** Crews clock in/out on a phone app that **needs cell signal** — many job sites have none. Result: **~1,500 punches are hand-corrected by foremen** (no-signal/no-service/phone errors ≈890 + system errors ≈600, on `UserCalendarHistory`'s 5,172 edit events). Same disease as the paper crew sheets: the tool fails in the field, a human patches it by hand.
- **Cost:** Supervisor admin time (5 people do 71% of the edits) + timekeeping not clean as-recorded (13% of punches edited). ✅ **Integrity is fine** (99.8% supervisor edits, meal compliance ~99%) — this is a *tech-reliability* cost, not a labor-integrity one.
- **Fix:** Offline-capable punching (queue punches locally, sync when signal returns).
- **Status:** ⚪ Measured; → `friction-modules/03-production-gps-spine.md` Module B. (The GPS truck-vs-clock cross-check will also quantify on-site-vs-reported time once play/GPS overlap.)

## D. INVOICING & AR — the third transcription point + the blind spot

### D1. Re-key every invoice into QuickBooks
- **Friction:** After billing, a **manual extract** of the invoice out of TRIM IT, then **manual re-entry into QuickBooks** to track AR. 3,033 invoices/year re-keyed. **Third** transcription point in the business.
- **Cost:** ≈**250–500 hrs/yr** (confirm per-invoice time).
- **Fix:** Integration between the two systems.
- **Status:** ⚪ Documented.

### D2. No audit trail on invoice creation
- **Friction:** **Every invoice for 20 years — 50,283 of them — is stamped to one inactive account in a former employee's name.** We cannot attribute any invoice to who actually created it.
- **Cost:** No accountability trail on **$21.5M/yr** of billing; a **QoE / diligence red flag** — better raised by us than found. (Do NOT frame as "one person does all billing" — that's a misread; the finding is the missing audit trail. And do not state how long ago she left — no termination date exists.)
- **Fix:** Stamp the real user.
- **Status:** ⚪ Identified; handle deliberately with Steve first.

### D3. Paid-vs-open isn't knowable in TRIM IT
- **Friction:** `Invoices.StatusDefID` has been dead since ~2014; payment lands in QuickBooks and **never flows back.** DSO / cash conversion **isn't measurable in the ERP** — the trusted "who owes us" is an **AR aging spreadsheet emailed by accounting.**
- **Cost:** No collections signal in the operating system; can't trace a job sold → completed → billed → paid in one place. **The most alarming section for a PE owner.**
- **Fix:** Two-way sync or in-system AR.
- **Status:** ⚪ Identified; 🔒 raise with Steve privately before any buyer sees it.

### D4. Change-order invoice correction ≈ 25 manual steps
- **Friction:** Correcting one change-order invoice is a ~25-step manual unwind.
- **Fix:** Automate or prevent the miscalc.
- **Status:** ⚪ Documented — strong automation candidate.

### D5. Completed work can't be traced to its invoice
- **Friction:** When a work order is revised, the link from completed work to the invoice that billed it **breaks** (no parent/child pointer). We can't *systematically* prove all completed work was billed — it takes manual, project-by-project reconciliation.
- **Cost:** Traceability/control gap — do NOT dollarize (the "$207K unbilled" was double-counting, not leakage).
- **Fix:** Parent/child pointer on revised WOs.
- **Status:** ⚪ Documented.

### D6. Period-close snapshots are broken → finance reconciles by hand
- **Friction:** "Period close" writes a `Periods.TotalPrice` snapshot, but closes fire **prematurely or never** — April "closed" on Apr 22 and read **$1.224M vs a real $2.179M (−$955K)**; March and May never closed at all. Several exec dashboards prefer the broken snapshot over live invoices.
- **Cost:** Finance can't trust the close; the CFO report is only right because it *ignores* the snapshot and sums live. Manual reconciliation every month + a blast radius of wrong dashboards.
- **Fix:** Fix the close process (or compute live everywhere); we already mapped the blast radius.
- **Status:** ⚪ Root-caused, pinned, not started.

### D7. Municipal phantom accrual — backed out by hand every month
- **Friction:** One percentage-of-completion accrual formula is applied to **both** commercial (billed at completion — valid) and municipal (billed progressively — already recognized), so municipal gets a **phantom accrual off the whole remaining contract value.** Accounting **manually strips it out** every month (≈**$145,839** in June; ~$111K in May).
- **Cost:** Recurring manual correction + a monthly-reported number nobody trusts until it's hand-fixed.
- **Fix:** Fix the accrual proc (zero municipal accrual for progressively-billed cities). Blocked on Steve's accounting rule.
- **Status:** 🟡 Root-caused + corrected on play; blocked on the finance rule to ship.

### D8. Commissions & month-end accruals are manual and person-owned
- **Friction:** Commissions (Jeanie) and month-end accruals / MP2 reporting (Dimitry) are hand-built, living in individual workflows — bus-factor + no audit trail, same pattern as the invoice stamp.
- **Cost:** Not yet quantified.
- **Fix:** Systematize + attribute.
- **Status:** ⚪ Known; ⚪ needs measurement.

---

## E. MUNICIPAL — where overhead scales with revenue

### E1. The City of Irvine "human API"
- **Friction:** The Irvine contract requires **a full-time person retyping data between TRIM IT and Davey TreeKeeper** (contractually mandated), plus that contract's billing and proposals. It's the only contract in the company that needs a dedicated administrative body.
- **Cost:** ~**$52K base / ~$68K loaded** for the role; the contract runs **≈$290K/yr below our own $130 TPH target** (blended basis). **The role is invisible to TPH** — we manage margin with a number that can't see it.
- **Fix:** Build the integration so the person isn't the bridge — **OR price the administrative burden into the renewal.** (Frame it this way; we can't drop Davey.)
- **Status:** ⚪ Measured; decision pending.
- **Strategic:** This is the cleanest picture of "overhead that scales with revenue" — **win another municipal contract on a foreign system and you hire another human bridge.** That is the ceiling on municipal growth, our most productive field segment.

### E2. Municipal proposals consume "absurd" time
- **Friction:** Municipal RFP prep is heavy and not yet separable in the bid-turnaround data.
- **Fix:** Municipal bid co-pilot (MuniBot / Aspen, a tool per bid stage).
- **Status:** 🔵 Designed within the Aspen/BD engine.

---

## G. INTEROPERABILITY — compatibility with the rest of the market's software

### G1. TRIM IT talks to nothing — every outside system is a human bridge
- **Friction:** Data can't move between TRIM IT and the software the rest of the industry (and our own acquisitions and contracts) run on. Today the "integration" is a person retyping — Davey TreeKeeper for Irvine (E1), QuickBooks for AR (D1). Winning a contract or buying a company on a foreign system means **hiring another human API.**
- **Cost:** Every one of those bridges is overhead that scales with revenue; it's also the ceiling on both municipal growth and roll-up integration.
- **Fix (current thinking — capability, not yet a built plan):** TRIM IT / arbor-core stays the **system of record**, with a **published API + import/export** so other tools (ArborNote, TreeKeeper, QuickBooks, etc.) connect *to* it. The strategic payoff is **acquisition integration** — acquire an operator whose crews already run ArborNote and they keep working day one, no retraining at the moment of maximum disruption, while their history imports on our timeline.
- **Status:** 🔵 Designed as a direction (ArborNote-as-fallback); ⚪ **buy-vs-build evaluation is still a Phase-1 to-do** — broad market compatibility is not yet a documented plan.
- ❗**Open scope question for the plan:** how far does "compatible with all other tree software" go — a one-way import to onboard acquisitions, or true two-way sync so crews can keep using their tool permanently? Very different builds.

## F. FOUNDATION — the enablers underneath everything

### F1. We can't even segment our own bids
- **Friction:** `NeedInventory` / `NeedSiteWalk` = **0 of 22,369** RFPs; `EstValue` empty. We literally **cannot answer "do our big bids take longer than our small ones."** The fields exist; they're empty.
- **Fix:** Capture the attributes at the source in the new flow.
- **Status:** 🔵 Designed.

### F2. TRIM IT bloat / dead code
- **Friction:** **964 tables, 3,628 procs; 271 dead tables, 84 truly-dead procs.** Decades of accretion make every change riskier and slower.
- **Fix:** Deep-audit cleanup plan (processes-first, evidence-based removal set).
- **Status:** 🟡 Full 7-stage audit **done**; cleanup plan built, **paused** ("revisit later").

### F3. Our own work runs on borrowed, fragile infrastructure
- **Friction:** Our repair/dashboard layer runs on a shared "play" box (froze 5.5 h once, cause undiagnosed) with single-copy crown-jewel data. Being replaced this week.
- **Fix:** Migrate our layer to our own dev box (rebuild script gated on a passing verification).
- **Status:** 🟡 Plan written, data captured, restore proven; awaiting the fresh box.

---

## H. KNOWN FRICTION — NOT YET MEASURED (candidate areas to scope)

These are real speed bumps we know exist but haven't analyzed. **Listed so they're not forgotten; each needs a measurement pass before it gets a cost figure.** This list should grow as Jason enumerates what he sees day-to-day.

- **H1. Fleet / equipment module** — vehicles, trucks, chippers, maintenance, fuel, DOT inspections, equipment utilization. **Zero analysis to date.** Likely candidates: manual maintenance logs, no utilization visibility, equipment cost not tied to job margin. → *needs a scoping pass on the TRIM IT fleet tables + how the shop actually tracks it.*
- **H2. HR / onboarding / certifications** — hiring paperwork, ISA/DOT certs, safety training records (partially touched via Typhoom). → *unscoped.*
- **H3. Purchasing / plant & material ordering** — the SOPs mention plant ordering by the production team; not measured.
- **H4. Scheduling / routing efficiency** — scheduling *speed* is healthy (1 day), but **route density / drive-time** is a different question and unmeasured.
- **H5. Customer communication** — no automated status/photos to customers today (tied to C1).
- *[add here as Jason names them]*

---

# HOW WE ATTACK IT (the organized part)

Sequenced so the earnout math works — **AGP earnouts run on revenue and exclude overhead, so revenue/field-facing fixes come first; overhead savings pay at exit.**

| Wave | Theme | Items | Why now |
|---|---|---|---|
| **1 — In flight** | Prove momentum | C2 (Typhoom ✅), A1/A2 bid loop (🟡), C1 field app (🟡), F2/F3 (🟡) | Already returning hours + de-risks the platform |
| **2 — The intake fix** | Kill the constraint | A3, A4, A5, A6, B1, F1 | One build (single-record flow) closes most of the $729K and the turnaround lottery |
| **3 — Back-office truth** | Trust + control | D1–D5 | Removes the QoE red flags and the AR blind spot |
| **4 — Municipal leverage** | Unlock the best segment | E1, E2 | Turns "overhead scales with revenue" into scalable growth |

**The through-line for the plan:** repaired TRIM IT UI → the arbor-core single-record framework → an Agent OS layer → drives the $50M / 5-yr growth **and** the acquisition-integration platform for the roll-up.

---

# HOW TO USE THIS BY AUDIENCE

- **Scott** — "That's the real condition; we shouldn't leave it like this." Lead with the paper-crew-sheet reality (C1) and the Typhoom win (C2) so it's honest *and* shows momentum.
- **Steve (CFO/QoE)** — "I need to be able to trust these numbers." Lead with D2/D3 (audit trail + AR blind spot), handled privately first.
- **Fort Point** — "That system is the constraint on operating leverage and on integrating acquisitions." Lead with the intake reframe: back-end has headroom, fixing intake converts to revenue without proportional cost.

---

# OPEN ITEMS / TO MEASURE NEXT
- What distinguishes the p90 go-ahead→WO tail (37 days)?
- The causal driver of the inventory-QC round-trip (control for job size) — Phase-1's first measurement.
- Real per-invoice QuickBooks re-key time (to firm D1).
- Loaded cost + whether municipal proposal effort can be timed (E1/E2).
- ~~Re-derive the basis-fragile bid figures before external/deck use.~~ ✅ **DONE 2026-08-02** — all firm (see A1/A2); p90 corrected 36→32, avg corrected ~17→13.7.

---

*Provenance: every figure traces to a measured TRIM IT query documented in `arbor-stack/bid-process-reengineering/` (DEPARTMENT-BOTTLENECK-MAP.md, INVESTOR-CASE-FACTBASE.md, AS-IS-WORKFLOW-MAP.md, COST-MODEL-rekeying.md) and the wiki. Pulled 2026-07-24/26; **bid-turnaround + back-entry figures re-derived live 2026-08-02** (`REVERIFY-20260802.sql`, data current to 2026-07-29). ⚪/🔵/🟡/🟢 mark fix maturity, not figure confidence.*
