---
title: Aspen — Cockpit → Bigin push (sales pipeline sync)
type: project
domain: work
track: 1
status: PAUSED 2026-08-02 — Skipper discussing with Nate before build; nothing built/written
tags: [aspen, bigin, cockpit, crm, pipeline, sync, build]
applies: ["[[external-comms-contract]]", "[[repair-contract]]"]
links: ["[[aspen-retention-agent]]", "[[sales-cockpit]]", "[[50m-growth-goal]]", "[[herman-agent]]"]
updated: 2026-08-02
---

# Aspen — Cockpit → Bigin push

**Objective (Skipper 2026-08-02):** Aspen reads the Sales Cockpit → pushes to Bigin → maintains the live SALES pipeline in Bigin. "Gilligan builds, Aspen runs."
> ⚠️ **This note is the canonical build-state (Gilligan owns it).** Do NOT keep it in the aspen-knowledge vault — that vault autosyncs FROM the Aspen board and **quarantines** files written directly into it (my first copy got swept to `_quarantine/` by the 02:52 autosync). Gilligan-owned build state lives HERE in the workspace wiki. Design/context still lives in `aspen-knowledge/business-development/bigin-structure-and-plan.md`.

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
- **Model B (NEW option):** Aspen feed = a **Sub-Pipeline inside each rep's EXISTING Team Pipeline**; "pull" = flip the `Sub_Pipeline`/`Stage` picklist on the same card — no cross-pipeline move, card never leaves the rep's board. Lighter; strong candidate. → **decide A vs B with Nate.**
**Cheap at our scale:** 50k+ credits/day; writes = 1 credit/10 records; upsert = idempotency lever; **webhooks (Notification API) replace polling** so Aspen hears about a rep pull in real time. Notes/Tags/Tasks all writable on a deal (context + flags + next-action). Full detail → [[bigin-api-capabilities]].

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

## BUILD ORDER (dry-run before ANY write)
1. **Owner map:** TRIM IT `Projects.SalesRepID` → Bigin owner ID (Chad/Megan/Nate/Scott).
2. **Shared-ID link:** `Workbench` link table + Bigin "TRIM IT ProjectID" custom field on Pipelines.
3. **Cockpit read:** reuse the cockpit's exact stage SQL via `trimit-ro-query.sh` → accounts + lane + owner + flags.
4. **DRY-RUN push:** dedup vs existing Bigin Accounts/Deals; report what WOULD change; **Skipper reviews.**
5. **Go-live pilot** (one rep's book) → expand → pull-back/webhooks → Aspen drives (handoff).
