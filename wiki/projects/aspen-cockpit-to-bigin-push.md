---
title: Aspen — Cockpit → Bigin push (sales pipeline sync)
type: project
domain: work
track: 1
status: ACTIVE (unpaused 2026-08-07 — Skipper: "I don't need to ask Nate, I'll inform him when we have it done"). Running-dry pilot DESIGN COMPLETE; now designing the Collections/AR lane. Still zero autonomous writes to live Bigin.
tags: [aspen, bigin, cockpit, crm, pipeline, sync, build]
applies: ["[[external-comms-contract]]", "[[repair-contract]]"]
links: ["[[aspen-retention-agent]]", "[[sales-cockpit]]", "[[50m-growth-goal]]", "[[herman-agent]]", "[[bigin-mcp-integration]]", "[[bigin-api-capabilities]]"]
updated: 2026-08-02
---

# Aspen — Cockpit → Bigin push

**Objective (Skipper 2026-08-02):** Aspen reads the Sales Cockpit → pushes to Bigin → maintains the live SALES pipeline in Bigin. "Gilligan builds, Aspen runs."
> ⚠️ **This note is the canonical build-state (Gilligan owns it).** Do NOT keep it in the aspen-knowledge vault — that vault autosyncs FROM the Aspen board and **quarantines** files written directly into it (my first copy got swept to `_quarantine/` by the 02:52 autosync). Gilligan-owned build state lives HERE in the workspace wiki. Design/context still lives in `aspen-knowledge/business-development/bigin-structure-and-plan.md`.

## 🔍 2026-08-07 — RUNNING-DRY SIZING RULE (pilot headline signal; measured live)
Skipper chose **Running Dry** as the pilot's "you'd-have-missed-this" (c) signal. Pulled Ethan's book live (`cockpit-read.sh 1140`): **83 live projects · 4 Running-Dry · 6 Re-Sell.**
- ⚠️ **DON'T size a dry account by `Projects.CurrentYear`** — for as-needed HOA work it's near-zero/NULL and understates 3–8×. My first pass reported "$15,516 at risk"; the real go-ahead/WO total was **$43,162.** Size by the **flagged WorkOrder `Total` (= the go-ahead)** + the **customer's book at `CompanyID` level**.
- **True sizing = 3 joins:** WorkOrder (`GoAheadID`, `ContractID`, `Total`, `EndDate`) → Contract (`TotalPrice`, often NULL for per-job HOA go-aheads) → `CompanyID` rollup (`COUNT` live projects, `SUM CurrentYear` book, `SUM Last12NetTotal` = trailing-12mo actual).
- **These go-aheads are STANDALONE** (1 WO each, `ContractID` NULL) → no recurring contract = no auto-renew safety net; job ends → property silently stops. That's WHY Running-Dry matters on HOA books.
- **The 4 (live 2026-08-07):** Optimum/Tustin Barcelona **$20,447** ends 10/22 (cust Optimum = **139 live · $962K book · $167K trailing**) · Mgmt Trust/Yale Estates **$9,795** ends 8/14 · Keystone/Natalia Johnson **$9,440** ends 10/02 · Cardinal/Villa Point **$3,480** ends 8/10. ⚠️ "Customer" = the MANAGEMENT COMPANY (umbrellas many HOAs), not the single property.
- **BUILD IMPLICATION:** the Bigin Running-Dry card/flag must carry **go-ahead $ + end date + customer book (live projects, trailing-12mo $)**, NOT the project CurrentYear — so the surfaced stake is honest.
- **OPEN data flag (not tonight):** book vs trailing-12mo actual gaps are large (Keystone $373K book / $8.5K actual; Mgmt Trust $198K / $0) — `Last12NetTotal` likely only counts invoiced/completed work; confirm before quoting either as "customer size."

## 🔁 2026-08-07 — PILOT LOOP + "New / Surfaced" = home of the Point (DECISION A locked)
**Pilot loop, one running-dry account end-to-end:** (1) Aspen nightly cockpit read flags it → (2) Aspen drops a card into Ethan's **Aspen Feed** with honest size baked in (go-ahead $ + customer book in notes) → (3) Ethan sees it → (4) pulls it into Pricing, sends a fresh bid → (5) Aspen watches TRIM IT for the new proposal, clears/moves the card, logs the catch. **Steps 1/2/5 = Aspen (build); 3/4 = Ethan (adoption). That split IS the pilot.**
- **⭐ DECISION (Skipper 2026-08-07): the `New / Surfaced` lane = the physical home of Point (c).** Everything Aspen CATCHES (running-dry now; re-sell + expiring-contract later) lands there. Gives 3 things free: rep gets a **worklist** (left→right = "what you'd have missed → go work it") · **(d) command view for free** = count of cards in New/Surfaced across reps = live "silent opportunity being surfaced" · **self-measuring** = a card moving out to Pricing/Won = a proven win.
- **⭐ DECISION A (Skipper 2026-08-07): a catch = a NEW "RE-QUOTE" card in New/Surfaced**, NOT a flag on the existing Scheduled card. Rationale: it's a distinct action the rep must take, keeps the lane a clean worklist, and makes the Point visible instead of buried. (Rejected B = tag-in-place: easy to scroll past, loses the worklist + the free command-view count.)

## 📧 2026-08-07 — COLLECTIONS lane: the routing + property feed ALREADY EXISTS (correction)
⚠️ **I first claimed customer→rep routing was "the unsolved make-or-break gap" and that "Ethan owns zero AR accounts → Collections is Scott's feature." BOTH WRONG** — I read a stale `ar-report/ar-rep-mapping.md` (raw `Companies.SalesRepID`, dumped everything on Scott, even listed ex-employee Patrick Fringer). The **LIVE weekly system disproves it.**
- **`arbor-stack/anomaly-monitor/ar-collections-monitor.js`** (runs weekly via `run-ar-weekly.sh` off Dimitry's xlsx) already: routes each account by **BestRep = most-recent active-invoice rep** (ex-employees excluded, `companies-rep.psv` col4 refreshed by `bestrep.sql`) · **labels every account by PROPERTY** (community pulled from each invoice Memo on the "AR Aging Subtotals" sheet, + balance + days aged) · splits **per-rep** + Nate rollup + **Municipalities→Skipper+Brent** + a **NEEDS REP** unmatched bucket · preview-vs-live modes · 10-day staleness guard · date tags. Render check: `node ar-collections-monitor.js --file=<xlsx> --stdout --allow-stale`.
- **Live routing (8/04 report, 31+ behind):** Ethan **$149,922 / 3** (Optimum $87,641 · The Groves $44,206 · BHE $18,075) · Garrett **$198,019 / 10** · Rebekah **$133,970 / 6** · Scott **$41,714 / 2** (LEAST) · **TOTAL 21 acct / $523,627** (munis separate). Ethan has real chunky AR → **good Collections pilot rep**, and Optimum routes to Ethan in BOTH lanes (running-dry re-quote + $87K overdue) → the two lanes AGREE, no divergence.
- **BUILD = SMALL:** the fetch→route→property-label→per-rep pipeline is DONE + trusted. Bigin only adds what the email can't: **persistent cards that auto-clear when paid (off the next report), aging escalation, and the (d) rollup.** Collections lane = pipe this existing feed into each rep's Aspen Feed @ Collections.
- **ROUTING DECISION (settled by the live system, not re-litigated):** BestRep (active-invoice rep), which also aligns Collections with Running-Dry's selling-rep. The crude Companies.SalesRepID mapping is SUPERSEDED.

## 🏷️ 2026-08-07 — New/Surfaced card LIFECYCLE (4 exits; misses = the management signal)
A card leaves New/Surfaced by one of four exits: **Surfaced** (born) → **Worked** (rep pulls to Pricing/bids = win, exits clean) · **Dismissed** (rep says not worth it → Aspen must NOT re-nag) · **Expired** (window closed, no action = MISS).
- **⭐ REFRAME (Skipper 2026-08-07): the Expired pile is worth more than the wins.** 4 surfaced, 1 worked, 3 expired = **$X that walked because nobody re-quoted, now VISIBLE.** New/Surfaced does double duty: **worklist** for the rep (left side) + **missed-money ledger** for Jason/Nate (Expired exit). That ledger is what (d) the command view is really FOR.
- **⭐ DECISION A (Skipper 2026-08-07): the "window" = the go-ahead's OWN end date.** If the flagged WorkOrder `EndDate` passes with no new proposal in TRIM IT → card flips to Expired/miss. Data-driven, per-account, no arbitrary timer — the real deadline is "re-quote must land before the current job ends or there's a service gap." (Rejected B = fixed 14-day timer: arbitrary, treats a Monday deadline and a 60-day-out job the same.)
- **Build note:** the card's Bigin due/closing date = that `EndDate` (drives the auto-Expire); Aspen's nightly read re-checks TRIM IT for a new proposal on the ProjectID to auto-move Worked cards out.

## 📇 2026-08-07 — RE-QUOTE card spec + lane sort (locked)
**Card face (real example, ProjectID 1099070):** Title `🔴 RE-QUOTE — Optimum / Tustin Barcelona HOA` · Amount **$20,447** (the go-ahead, NOT project CurrentYear) · Due/Closing = `2026-10-22` (job EndDate → drives auto-Expire) · Tags `Running Dry` + `Aspen-Surfaced` · link `TRIM IT ProjectID`. **Notes** carry the honest size: *"Job ends 10/22, nothing queued. Customer Optimum = 139 live properties · $962K book · $167K trailing-12mo. Last activity 7/30. Re-quote before job ends to avoid a service gap."*
- **⭐ DECISION A (Skipper 2026-08-07): lane sort = URGENCY primary (soonest EndDate first), CUSTOMER BOOK as tiebreaker.** Rationale: a missed deadline is unrecoverable (job just ends); a whale with runway can wait its turn. (Rejected B=relationship-size-first, C=job-$-first.) → Villa Point ($3,480, ends Mon 8/10) sorts ABOVE Optimum ($20K, ends 10/22).

## 🔐 2026-08-07 — AUTONOMY (the pause gate for Nate) — locked
**Trust boundary (the line Nate will care about):** Aspen is **autonomous UP TO the New/Surfaced lane** (its own sandbox — creating a RE-QUOTE card touches nothing the rep typed, nothing on their live sale motion, fully reversible). **The human gate = the PULL:** the moment the rep drags a card out of New/Surfaced into Pricing, a human made the call. Aspen never creates deals, changes owners, or moves anything on the rep's real pipeline on its own.
- **⭐ DECISION B (Skipper 2026-08-07): the PILOT starts GATED, then graduates.** Batch 1's cards — Aspen shows Jason what it WANTS to create in New/Surfaced; he eyeballs before they post. Once it's proven, flip to autonomous-within-the-lane. (Rejected A = autonomous from day one.) Rationale: cheap trust-building with Nate + catches any bad catch before Ethan ever sees it.
- **Still true after graduation:** autonomy only ever extends to *inside* New/Surfaced. The rep's pull stays the permanent human gate regardless.
- **⭐ DECISION A (Skipper 2026-08-07): graduation trigger = a CLEAN STREAK — 3 consecutive nightly batches with every card approved / zero bad catches → flip to autonomous. Any bad catch resets the streak.** (Rejected B=≥90% precision over ~20, C=gut-feel.) Objective, fast, self-correcting.

### ✅ RUNNING-DRY PILOT — DESIGN COMPLETE (2026-08-07, all decisions locked; still zero writes)
North star (Floor=a/Point=c) · signal=Running Dry sized by go-ahead $ + `CompanyID` book · loop detect→surface→see→act→track · New/Surfaced=home of the Point · catch=its own RE-QUOTE card (A) · 4-exit lifecycle, window=job EndDate (A) · card spec + urgency-first sort (A) · autonomy=gated-then-graduate via 3-clean-night streak (B+A) · trust boundary = autonomous up to the lane, rep PULL is the permanent gate.
**Still open before build/Nate:** (1) pilot scorecard (what proves it worked) · (2) Collections/AR lane (the other half) · (3) the Nate one-pager drawn from the above.

## 🧭 NORTH STAR — LOCKED 2026-08-07 (the lens for every decision below)
Skipper worked the "what's the ONE thing" question and it resolved. The four candidate goals aren't a menu — **they're a stack**, so "pick one" was the wrong frame:
- **(a) One live home for every rep's deals = the FLOOR.** Prerequisite; nothing else works if deals aren't reliably in Bigin and current. *Failure = adoption risk (reps don't trust it → DOA).*
- **(b) Aspen does the grunt work = the ENGINE (the how, not the why).** The mechanism that keeps (a) true without reps hating data entry.
- **(c) Surfaces what they'd miss = the POINT.** The only item a plain CRM can't already do → the entire justification for building Aspen vs. "just use Bigin." *Failure = value risk (no reason it exists).*
- **(d) Command view for Jason + Nate = the REWARD (byproduct).** If a + c are real, d falls out for free — a live rollup is just the sum of honest pipelines.

**Resolution (Skipper confirmed "it lands"):** **FLOOR = a · POINT = c.** b and d are downstream. **Build top-down:** stand up the floor (a) *in a way that makes the point (c) possible*, i.e. every schema/sync choice is judged by "does this let Aspen surface something the rep would've missed?" — not just "did the card sync?"
**Design principles that follow:** dry-run before writes · source-of-truth split (Aspen writes only its OWN fields) · idempotent dedup · never make a rep do data entry the sync could do.

## 🗓️ 2026-08-06 — PLANNING SESSION (decisions locked; still no writes)
Skipper worked the plan forward (prep for the Nate conversation). Locked so far:
- **Autonomy = C (graduated).** Start the pilot fully review-gated; graduate Tier-1 writes to autonomous once proven; Tier-2 stays gated permanently.
- **Write taxonomy (the artifact for Nate):**
  - **Tier 1 (auto once proven — ERP-reflecting, reversible):** stage sync from cockpit lane · work fields (last-service, LTV, TPH, contract-end) · flags (running-dry/re-sell/expiring) · informational notes.
  - **Tier 2 (always gated — sales decisions):** create a new Deal · change owner · close won/lost · overwrite any rep-typed field.
- **Pilot rep = ETHAN CHESLEY, `SalesRepID 1140`** (measured, type 1). ⚠️ Chad/Megan are MARKETING with thin TRIM IT footprint — not sync candidates.
- **Ethan footprint (CORRECTED 2026-08-06 — measured via gsql.sh play):** Ethan Chesley `SalesRepID 1140` / `UserID 325`. ⚠️ FIRST read used `Projects.SalesRepID`+`FirstProposalDate` = ACCOUNT OWNERSHIP (426 legacy locations, looked dormant) — WRONG place. Selling lives in the **`Proposals`** table keyed on `SalesRepID`: **2,237 proposals in last 12mo, $122.7M proposed (gross, incl. multi-year Future0x totals; NOT annual, NOT won), span 2025-08-28→2026-07-31.** → Ethan is a HIGH-VOLUME ACTIVE SELLER.
- **LESSON:** rep selling activity = `Proposals.SalesRepID` (+ `ProposalDate`/`ProposalSentDate`/`StatusDefID`); `Projects.SalesRepID` is account ownership. `Proposals.Total` bundles Current+Future year totals — use `CurrentYearTotal` for annual, `DateApproved`/won-status for sold.
- **Pilot north-star (CORRECTED):** track Ethan's LIVE proposal pipeline through Bigin stages (hot deal-flow), gated per the Tier taxonomy. Pin real current-year + won$ before build so Bigin dollars are honest.

## 🛠️ ASPEN SIDE BUILT + DRY-RUN PROVEN 2026-08-06 (read-only, zero writes)
Built the whole push engine in `aspen-stack/bigin-sync/` and ran it live against Ethan. **Nothing written to Bigin — dry-run only.**
- **`owner-map.json`** — TRIM IT SalesRepID → Bigin owner ID + pipeline, all 4 reps resolved from live data: **Ethan 1140→`…1941001` (Ethan Pipeline) · Garrett 1118→`…0428156` (Garretts new) · Rebekah 1143→`…2174001` (Rebekah Pipeline) · Scott 19→`…2313001` (Scott Pipeline, to create).** ⭐ Scott Griffiths IS now a Bigin user (`…2313001`) — old note said he wasn't.
- **`cockpit-read.sh <SalesRepID>`** — pulls a rep's LIVE hot proposal pipeline via `trimit-ro-query.sh`, **rolled up to ONE row per ProjectID** (linchpin), status→lane. Rep master = **`dbo.SalesReps`** (NOT `flow.SalesReps`); selling = `Proposals.SalesRepID`; status names = `StatusDefs.Desc1`; value = COALESCE(CurrentYearTotal, Total, SubTotal) — **CurrentYearTotal is often NULL**.
- **`dry-run-push.js <SalesRepID>`** — reads cockpit output, pulls existing Bigin deals in the rep's pipeline, dedups on a `[TI:<ProjectID>]` tag in Deal_Name, and REPORTS create/update/skip. Writes a full plan JSON. **No API writes.**
- **Ethan dry-run result:** 104 hot projects → **would create 104 cards, $2.84M new-card pipeline value** (103 Bidding, 1 Follow Up). 30 existing Ethan-Pipeline deals (pre-existing, no `[TI:]` tag → all counted as new; real go-live needs name-dedup vs those 30 or accept overlap).
- **Stage translator v1 (in owner-map.json):** open bid [41 Active,106 InProcess,334 Revised,149 Locked]+sent≤6mo→**Bidding** · DateApproved≤90d→**Scheduled (Won)** · 141 Lost→**Follow Up**. ⚠️ Confirm vs the LIVE cockpit SQL before go-live (cockpit is canonical → [[CANONICAL-cockpit-alignment]]).

### ✅ #2 + #3 DONE 2026-08-06 (reconciled to canonical cockpit; still zero writes)
- **#3 STAGE RECONCILIATION — cockpit-read.sh v2 now MIRRORS the live cockpit** (`Dashboard-SalesCockpit.cfm`). Corrected a real error: v1 assigned lanes from PROPOSAL STATUS only; the canonical cockpit assigns them from **WorkOrders** via this exact mutually-exclusive cascade — `BidOpen & !WActive`→**Bidding** · `WInProgress`→**Working** · `WActive`(future)→**Scheduled (Won)** · `DoneRecent(≤90d)`→**Recently Done** · else→**Follow Up**. WO status codes: 46/109=active, 48=completed, 38=future. Base = `Projects` where StatusDefs.Desc1 IN (InProcess,Pending), scoped `p.SalesRepID`, filtered `IsActive=1`. Value = `p.CurrentYear` (matches board), property = 1st line of JobAddress (clean). **RunningDry + ReSell overlays carried as flags** → Bigin tags.
- **#2 LINCHPIN FIELD — dry-run-push.js v2 is field-aware.** Dedups on a `TRIM IT ProjectID` custom field when it exists, else falls back to `[TI:<id>]` in Deal_Name (+warns on name overlap). ⚠️ **Bigin API/MCP CANNOT create custom fields** (UI-only, like pipelines — no create-field among the 69 tools). → field creation folds into Phase 0: **Bigin UI → Pipelines module → add field `TRIM IT ProjectID`, type Single Line (or Number), api_name `TRIM_IT_ProjectID`.** Scripts auto-upgrade to it the moment it appears.
- **Reconciled Ethan dry-run (v2):** **122 live-pipeline projects** → would create 122 cards, **$1.03M** new-card value (lower than v1's $2.84M because value now = per-project CurrentYear, matching the cockpit, not summed proposal totals). Lanes: **Bidding 48 · Scheduled(Won) 32 · Follow Up 24 · Working 9 · Recently Done 9.** Overlays: Running Dry 5, Re-Sell 9. 1 name-overlap warning vs the 30 pre-existing untagged deals.

### ▶️ OPEN before go-live (all safe, no writes yet)
1. **Phase 0 (Skipper, admin UI):** create `Scott Pipeline` + add `Aspen Feed` sub (7 stages) to Ethan/Garrett/Rebekah/Scott + add the `TRIM IT ProjectID` field on Pipelines.
2. **Dedup vs the 30 existing Ethan deals** at go-live (name match) once the field exists — or accept they'll get re-carded clean.
3. Then flip dry-run → real upsert into the `Aspen Feed` sub (via Bigin MCP), Ethan first.

## ⏸️ PAUSED 2026-08-02 — Skipper to discuss with NATE first
Verified + planned; **nothing built or written**. Resume when the Skipper gives the go + the answers below.
**Unblocks on:** (1) which book to pilot first (rec: Megan/OC = most existing accounts, or Chad/IE where the sub-pipeline+drip already exist); (2) whatever Nate wants re pipeline structure / stage translator / ownership; (3) **AUTONOMY LEVEL for Aspen's Bigin WRITES (open, discuss w/ Nate):** once verified, do Aspen's pipeline writes run FULLY AUTONOMOUS, or get a review gate like outbound emails? It's the team's SHARED CRM. Rails already in design: dry-run before writes · source-of-truth split (Aspen writes only its OWN fields, never the reps' sale-motion) · idempotent dedup. This is a trust-boundary call, not technical.
**On resume:** start at BUILD ORDER step 1 (owner map) → dry-run (step 4) before any Bigin write. Re-confirm the Bigin token refresh if it's been weeks.

## 🏗️ ARCHITECTURE — Aspen gets its OWN pipeline (the trust boundary) [2026-08-06]
Decided direction (Skipper 2026-08-06): Aspen manages a DEDICATED pipeline; reps pull cards from it into their own pipeline at will. Grounded in the LIVE Bigin structure (read via API 2026-08-06):
- **Existing pipelines (Bigin = one layout per pipeline):** `Sales Pipeline` (main) · **`Ethan Pipeline`** (pilot rep already has his own) · Chad · Megan · Garrett · "Garretts new" · Rebekah · "-expired- Chases". ⚠️ duplicates/legacy exist → cleanup later.
- **Plan:** create **`Aspen — Opportunity Feed`** pipeline. Aspen writes FREELY + autonomously inside it (its own sandbox, never touches the rep's board). Rep PULLS a card into their pipeline (`Ethan Pipeline`) to work it; can push back. **Promotion = the single human gate** (replaces per-write Tier gating on the rep's live board — much cleaner).
- **Bigin mechanics (confirm exact UI gesture at build):** moving a card between pipelines = native pipeline/layout reassignment (rep UI + API). A card lives in ONE pipeline at a time — "back and forth" = MOVE, not a mirrored copy. Aspen keeps tracking a promoted deal via the shared **TRIM IT ProjectID** link (refreshes work-facts without owning the card). "Connected Pipelines" feature available for optional AUTO-promotion later.
- **Autonomy under this model:** inside Aspen's pipeline = fully autonomous; Tier-2 (create/own/close on the REP's pipeline) only ever happens by the rep's pull. Tier taxonomy still governs what Aspen writes to its OWN cards.

## 📚 FULL API STUDY DONE 2026-08-06 → [[bigin-api-capabilities]] (canonical capability map)
Read the whole Bigin v2 API surface + probed our live org. **Architecture-critical discovery (CONFIRMED LIVE):** Bigin deals have a native **3-level hierarchy — `Pipeline` (Team Pipeline) → `Sub_Pipeline` (picklist) → `Stage`.** Today every rep pipeline has ONE default sub (e.g. `Garretts new Pipeline Standard`). This opens a **second, lighter build model**:
- **Model A (drafted):** Aspen = its OWN Team Pipeline(s); rep "pulls" = MOVE the record to the rep's pipeline. Clean isolation, heavier.
- **Model B ✅ CHOSEN (Skipper 2026-08-06):** Aspen feed = a **`Aspen Feed` Sub-Pipeline inside each rep's EXISTING Team Pipeline**; "pull" = flip the `Sub_Pipeline`/`Stage` picklist on the same card — no cross-pipeline move, card never leaves the rep's board. Lighter + better rep adoption. Blueprint redrawn around B → `aspen-stack/bigin-pipeline-blueprint.md`. Phase 0 (UI/admin, loop Nate): create `Scott Pipeline` + add a 7-stage `Aspen Feed` sub inside Ethan/Garrett/Rebekah/Scott.
**Cheap at our scale:** 50k+ credits/day; writes = 1 credit/10 records; upsert = idempotency lever; **webhooks (Notification API) replace polling** so Aspen hears about a rep pull in real time. Notes/Tags/Tasks all writable on a deal (context + flags + next-action). Full detail → [[bigin-api-capabilities]]. The live tool path Aspen writes through = the native Zoho MCP server → [[bigin-mcp-integration]].

## 🔑 API CAPABILITY — CREATE pipelines is UI-ONLY (verified vs Bigin dev docs, 2026-08-06)
**Definitive:** the Bigin API does NOT expose pipeline/layout CREATION. `GET /bigin/v2/settings/layouts` is READ-only (docs: "Get layouts metadata"); the create-pipeline endpoints 401'd because they don't exist. The API surface is: **record CRUD** (Add/Update/Get records in the Pipelines module = deals) + **settings metadata READS** + users READ. Scope held = `modules.ALL settings.ALL users.READ` (admin) — authority isn't the limit; the endpoint doesn't exist.
- → **Division of labor:** (Phase 0) pipeline SHELLS created in the Bigin **web UI** by a human/admin (natural point to loop Nate) — Scott's new MAIN + one Aspen sub per rep. (Phase 1+) Aspen/API **populates + manages the CARDS** inside them (fully supported: create/update/move deals, stages, flags, notes).
- Card movement between pipelines ("pull back and forth") = record re-assignment (UI + API). "Connected Pipelines" = optional auto-flow later. Each Bigin "Team Pipeline" = one layout in the Pipelines module.
- **✅ DONE 2026-08-06 — Chad-sub inspected (live layout read via `settings/layouts?module=Pipelines`).** FINDING: **there is NO lightweight "sub" in Bigin.** Every pipeline = a full standalone layout with its own Stage picklist. `Chad Pipeline` is a **21-stage full lifecycle** (Potential Lead → Closed Won). "Connect to main + pull cards back and forth" = simply MOVING a deal record between two layouts (UI drag or API re-assign). So an "Aspen sub" is just another pipeline we keep short/feed-shaped; the pull is a native move.
- **The current STANDARD rep pipeline (clone target for Scott's main):** `Megan Pipeline` = `Rebekah Pipeline` = `Garretts new Pipeline` are **byte-identical 18-stage** layouts → that's the house standard. Clone it verbatim for Scott. (Ethan/Chad carry extra Closed Won/Lost/Recurring tails; the clean trio does loss-tracking via Proposal Lost + Lost Job Follow Up.)

### 📋 UI SETUP BLUEPRINT (copy-follow — all 4 reps + Scott's main) — canonical file `aspen-stack/bigin-pipeline-blueprint.md`
**A. Scott's NEW MAIN — name `Scott Pipeline` — 18 stages (verbatim clone of Megan/Rebekah):**
Potential Lead · Contact Made · Pre Qualified · Unqualified · Pre Bid · Pricing · Proposal in Process · Proposal Sent · Go Ahead · Proposal Lost · Scheduled · Lost Job Follow Up · Job in Progress · Completed and in Review · Billing · Paid in Full · Collections · Post Job Follow Up · Recurring Contract.
**B. FOUR Aspen sub-feeds — `Aspen Feed — Ethan` / `— Garrett` / `— Rebekah` / `— Scott` — stages = the cockpit's 5 lanes:**
**7 stages (Skipper APPROVED 2026-08-06):** New / Surfaced · Follow Up · Bidding · Scheduled (Won) · Working · Recently Done · Pulled by Rep (the 5 cockpit lanes + entry/terminal bookends → promotion metric).
**Stage translator (cockpit lane → rep MAIN stage on pull):** Follow Up→Potential Lead/Lost Job Follow Up · Bidding→Proposal Sent/Pre Bid · Scheduled (Won)→Go Ahead · Working→Job in Progress · Recently Done→Recurring Contract.

## Access model — Aspen is DIRECT to Bigin (not through Gilligan)
- **Bigin = fully direct:** end-state = Aspen holds its OWN OAuth on its OWN runtime and calls the Bigin API itself. Gilligan only BUILDS + verifies, then hands off (creds + scripts move to Aspen's board). ⚠️ **Current:** token verified on jdog1 (Gilligan's box); making it truly Aspen-direct is a handoff step (provision OAuth on Aspen's runtime + deploy push scripts there).
- **TRIM IT = autonomous but SCOPED through a gateway** (by security design): Aspen's read hops through the `aspen-dispatch.sh` forced-command on jdog1 (read-only query only; arbor-core/crew hard-denied). Not a raw DB connection — least-privilege, Track-1 only.

## ✅ Verified LIVE 2026-08-02 (both ends of the pipe work)
- **Bigin API:** token in `~/.secrets/bigin-oauth.json` refreshes cleanly; scope `ZohoBigin.modules.ALL settings.ALL users.READ` (admin). Reads OK: **9 active users** (Chad `…2097047`, Megan `…1618001`, Nate `…2078003`, Jason, Garrett, Jeanie, Ethan, Rebekah, IT Admin); modules = Contacts/Accounts/**Pipelines**(=deals)/Tasks/Notes… Deals module reachable. → can create/update deals, link Accounts, read users.
- **Aspen → TRIM IT read:** already exists — `aspen-gateway/trimit-ro-query.sh` (read-only `HermanRO` on play GSTS) via `aspen-dispatch.sh` (Track-1 scoped; arbor-core/crew denied). → Aspen can read the cockpit's underlying data today.
- **Design:** complete + Skipper-approved → `aspen-knowledge/.../bigin-structure-and-plan.md`.

## ⚠️ Flags
- **Brent is NOT a Bigin user** (confirmed) → blocks the MUNICIPAL lane only; does NOT block sales (Chad/Megan/Nate/Scott). Add Brent later.
- **Security:** `trimit-ro-query.sh` has the `HermanRO` DB password in plaintext → rotate later (read-only login, low blast radius).
- **Data distinction:** old IE drip = NEW prospects → Chad's "Inland Empire Expansion" sub-pipeline. **THIS build = EXISTING TRIM IT customers from the cockpit** → each account's owning rep's STANDARD pipeline, stage-translated.

## Source-of-truth split (approved, no clobber)
TRIM IT/Cockpit = WORK facts (property, history, last service, LTV, contract-end, TPH, dry/rebid flags). Bigin = SALE motion (stage, owner, next action, close date, notes). Linchpin = shared ID: Bigin Deal custom field "TRIM IT ProjectID" + a `Workbench` link table (Deal ID ↔ TRIM IT key).

## Stage translator (cockpit 5 lanes → Bigin) — DRAFT, confirm at build
Follow up now → Potential Lead / Lost Job Follow Up · Bidding → Proposal Sent/Pre Bid · Scheduled(Won) → Go Ahead · Working → Job in Progress · Recently done → Closed Won/Recurring · 🔴 Running dry / 💰 Re-sell → tag + next-action.

## 🌟 2026-08-07 — Ethan's "Aspen Feed" sub-pipeline CREATED (via browser) + Collections=AR feature
**First real WRITE to Bigin for this project** — done by DRIVING THE BROWSER on LAPTOP 2 (remote CDP; see [[device-node-control]]), because sub-pipeline/stage creation is UI-only (no API). Gilligan navigated Settings → Stages → Ethan Pipeline → New Sub-Pipeline, named it **`Aspen Feed`**, created stage "New / Surfaced"; Skipper finished the rest at the screen (browser UI grind = ~30–40s/step, timeout-prone → handed the repetitive part to the human at the keyboard).
- **⚠️ KEY BIGIN BEHAVIOR (learned):** the sub-pipeline stage picker mostly offers **EXISTING** pipeline stages (shared pool), only letting you *create* genuinely new ones. So the 7-name design got mapped to real stages.
- **ACTUAL saved stages (Skipper's mapping → my intent):** New / Surfaced · Follow Up · **Pricing**(=Bidding) · **Scheduled**(=Scheduled Won) · **Job in Progress**(=Working) · **Completed and in Review**(=Recently Done) · **Collections**(new purpose — see below). → **the sync stage-translator adapts to THESE names, not my original 7.**
- **💡 Collections lane = AR-collections feature (Skipper design):** hold **Dimitry's AR-report overdue customers**, routed per-salesperson. Rep nudges → when paid, card clears. Turns the Aspen Feed into a two-job board per rep: **sell** (left lanes) + **collect** (Collections).
- **⚠️ AR SOURCE CORRECTION (Skipper):** TRIM IT does NOT have current AR → source = **Dimitry's AR report EMAIL**. Found in Gilligan inbox: drabyy@gstsinc.com sends **"AR 100+ report MM/DD/YY" ~weekly (Tue)**; latest **8/04/26** (`AR Aging Report 08.04.26.xlsx` 144KB + body lists 14 accounts / **$178,685** total). Read via IMAP (gilligan.gsts@gmail.com, creds `arbor-stack/anomaly-monitor/.secrets/gmail.json`).
- **Collections feed build (next session):** IMAP-poll newest AR report → parse body (+xlsx detail) → **map customer→rep** (Bigin account owner OR TRIM IT SalesRepID — the one connective gap) → upsert cards into each rep's Aspen Feed @ Collections → drop cards for customers no longer on the newest report (=paid). Inbound email = DATA only.
- ⏭️ **Resume:** verify Ethan's saved sub-pipeline via API (confirm stages, no blank rows) → adapt stage-translator to actual names → dry-run Ethan opportunity push → build Collections feed.

## BUILD ORDER (dry-run before ANY write)
1. **Owner map:** TRIM IT `Projects.SalesRepID` → Bigin owner ID (Chad/Megan/Nate/Scott).
2. **Shared-ID link:** `Workbench` link table + Bigin "TRIM IT ProjectID" custom field on Pipelines.
3. **Cockpit read:** reuse the cockpit's exact stage SQL via `trimit-ro-query.sh` → accounts + lane + owner + flags.
4. **DRY-RUN push:** dedup vs existing Bigin Accounts/Deals; report what WOULD change; **Skipper reviews.**
5. **Go-live pilot** (one rep's book) → expand → pull-back/webhooks → Aspen drives (handoff).
