# Bigin Pipeline Blueprint — Aspen ↔ Sales (copy-follow UI setup)

**Status:** DRAFT for Skipper/Nate to stamp the shells. Create = Bigin **web UI** (API cannot create pipelines). Cards = Aspen/API after.
**Scope (Skipper 2026-08-06):** ALL FOUR reps at once — Ethan · Garrett · Rebekah · Scott — plus Scott's brand-new MAIN.
**Inspected live 2026-08-06:** every Bigin pipeline is a full standalone *layout* with its own Stage picklist. `Megan`=`Rebekah`=`Garretts new` are byte-identical 18-stage layouts = the house standard. `Chad Pipeline` = 21-stage full lifecycle. There is no lightweight "sub" object — a "sub" is just a short pipeline; pulling a card = moving the deal record between layouts (UI drag or API re-assign).

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

## 2) FOUR Aspen sub-feeds — one per rep
Pipeline names: `Aspen Feed — Ethan` · `Aspen Feed — Garrett` · `Aspen Feed — Rebekah` · `Aspen Feed — Scott`

Stages = the cockpit's 5 lanes + 2 housekeeping bookends (Skipper APPROVED 2026-08-06) = **7 stages**:

1. New / Surfaced   ← Aspen drops a freshly-surfaced card here before triage
2. Follow Up
3. Bidding
4. Scheduled (Won)
5. Working
6. Recently Done
7. Pulled by Rep   ← set when the arborist pulls the card into their MAIN (promotion metric)

## 3) Stage translator — cockpit lane → rep MAIN stage (applied when a card is pulled)
- Follow Up → Potential Lead / Lost Job Follow Up
- Bidding → Proposal Sent / Pre Bid
- Scheduled (Won) → Go Ahead
- Working → Job in Progress
- Recently Done → Recurring Contract
- 🔴 Running dry / 💰 Re-sell → carried as a tag + next-action, not a stage.

## 4) The pull mechanic (how rep + Aspen share a card)
- A deal lives in ONE pipeline at a time. "Back and forth" = MOVE the record between `Aspen Feed — X` and `X Pipeline` (native in the rep UI; also API-reassignable).
- Linchpin so Aspen keeps refreshing work-facts after a pull: shared **TRIM IT ProjectID** custom field on the Pipelines module + a `Workbench` link table (Bigin Deal ID ↔ TRIM IT key).
- Autonomy: Aspen writes FREELY inside its own `Aspen Feed — X`; the single human gate is the rep pulling a card into their MAIN. Tier-2 actions (create/own/close on the rep's MAIN) only happen by that pull.

## 5) Build order after shells exist
1. Owner map: TRIM IT `Proposals.SalesRepID` → Bigin owner ID.
2. Add `TRIM IT ProjectID` custom field on Pipelines + `Workbench` link table.
3. Cockpit read via `trimit-ro-query.sh` → accounts + lane + owner + flags.
4. DRY-RUN push into `Aspen Feed — Ethan` first → Skipper/Nate eyeball.
5. Go-live Ethan → clone to Garrett/Rebekah/Scott.
