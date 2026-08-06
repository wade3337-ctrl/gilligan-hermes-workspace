# Bigin Pipeline Blueprint — Aspen ↔ Sales (copy-follow UI setup)

**Status:** DRAFT for Skipper/Nate to stamp the shells. Sub-pipelines + stages created in Bigin **web UI settings** (API cannot create pipelines/sub-pipelines). Cards = Aspen/API after.
**Scope (Skipper 2026-08-06):** ALL FOUR reps at once — Ethan · Garrett · Rebekah · Scott — plus Scott's brand-new MAIN.
**MODEL = B (Skipper decision 2026-08-06):** Aspen's feed is a **Sub-Pipeline INSIDE each rep's existing Team Pipeline**, NOT a separate pipeline. Confirmed live: Bigin deals carry `Pipeline` (Team Pipeline) → `Sub_Pipeline` (picklist) → `Stage`. Today each rep pipeline has one default sub (e.g. `Garretts new Pipeline Standard`). We ADD a second sub named `Aspen Feed` to each. A rep **"pulls" a card = flip its `Sub_Pipeline` from `Aspen Feed` → the rep's Standard sub** (+ set Stage via translator) — the card never leaves the rep's board.
> Why B (Skipper): less machinery, and the card staying in the rep's own view = better adoption. Cost: Aspen cards + real deals share one board → keep them separate with the `Aspen Feed` sub label + a tag.

---

## 1) Scott's NEW MAIN — pipeline name: `Scott Pipeline`
18 stages (verbatim clone of Megan/Rebekah — the current standard):

1. Potential Lead
2. Contact Made
3. Pre Qualified
4. Unqualified
5. Pre Bid
6. Pricing
7. Proposal in Process
8. Proposal Sent
9. Go Ahead
10. Proposal Lost
11. Scheduled
12. Lost Job Follow Up
13. Job in Progress
14. Completed and in Review
15. Billing
16. Paid in Full
17. Collections
18. Post Job Follow Up
19. Recurring Contract

*(Optional add Nate may want: `Closed Won` + `Closed Lost` tail like Ethan/Chad. The clean trio does loss-tracking via Proposal Lost + Lost Job Follow Up instead.)*

## 2) Aspen feed = ONE new `Aspen Feed` SUB-PIPELINE added inside each rep's Team Pipeline (Model B)
Add a sub-pipeline named **`Aspen Feed`** inside each of: `Ethan Pipeline` · `Garrett Pipeline`* · `Rebekah Pipeline` · `Scott Pipeline` (new, from §1).
*(*✅ RESOLVED 2026-08-06 via live deal counts: **`Garretts new Pipeline` is the LIVE one** (304 deals, last modified 2026-08-05) → add the sub HERE. Old `Garrett Pipeline` (829 deals, untouched since 2026-06-05) = legacy/archive; fold its cleanup into Nate's conversation, don't touch it now.)*

Each `Aspen Feed` sub gets these **7 stages** (the cockpit's 5 lanes + 2 housekeeping bookends, Skipper APPROVED):

1. New / Surfaced   ← Aspen drops a freshly-surfaced card here before triage
2. Follow Up
3. Bidding
4. Scheduled (Won)
5. Working
6. Recently Done
7. Pulled by Rep   ← set when the arborist pulls the card into their Standard sub (promotion metric)

**The pull mechanic under B:** rep drags the card from the `Aspen Feed` sub to their `... Standard` sub (native Bigin gesture) — API-equivalent = update the record's `Sub_Pipeline` + `Stage`. Same record, same Team Pipeline, no cross-board move.

## 3) Stage translator — cockpit lane → rep MAIN stage (applied when a card is pulled)
- Follow Up → Potential Lead / Lost Job Follow Up
- Bidding → Proposal Sent / Pre Bid
- Scheduled (Won) → Go Ahead
- Working → Job in Progress
- Recently Done → Recurring Contract
- 🔴 Running dry / 💰 Re-sell → carried as a tag + next-action, not a stage.

## 4) The pull mechanic (Model B)
- One deal record, always inside the rep's Team Pipeline. "Pull" = change `Sub_Pipeline` from `Aspen Feed` → the rep's Standard sub (+ Stage via translator). Rep does it by dragging the card between subs; API can do the same `Sub_Pipeline`+`Stage` update.
- Linchpin so Aspen keeps refreshing work-facts after a pull: shared **TRIM IT ProjectID** custom field on the Pipelines module + a `Workbench` link table (Bigin Deal ID ↔ TRIM IT key).
- Autonomy: Aspen writes FREELY on cards sitting in the `Aspen Feed` sub; the single human gate is the rep dragging a card into their Standard sub. Tier-2 actions (own/close on a live deal) only begin after that pull.
- Real-time: enable a **Notification API webhook** on the Pipelines module so Aspen hears the instant a rep pulls/edits — no polling.

## 5) Build order after shells exist
0. **Phase 0 (UI/admin, loop Nate):** create `Scott Pipeline` (§1) + add an `Aspen Feed` sub-pipeline (7 stages, §2) inside each of the 4 rep pipelines.
1. Owner map: TRIM IT `Proposals.SalesRepID` → Bigin owner ID.
2. Add `TRIM IT ProjectID` custom field on Pipelines + `Workbench` link table.
3. Cockpit read via `trimit-ro-query.sh` → accounts + lane + owner + flags.
4. DRY-RUN push into Ethan's `Aspen Feed` sub first → Skipper/Nate eyeball.
5. Go-live Ethan → clone the sub to Garrett/Rebekah/Scott → enable webhook → Aspen drives (handoff).
