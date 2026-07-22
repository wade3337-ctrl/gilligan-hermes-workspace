---
title: Revenue Ledger — polish backlog
type: project
domain: work
confidential: black
status: active — dashboard live; polish items queued
tags: [revenue, ledger, backlog, polish, dashboard, todo]
applies: ["[[fort-point-confidentiality]]"]
links: ["[[deal-tracker-dashboard]]", "[[count-once-revenue-ledger]]", "[[trimit-accrual-formula]]"]
updated: 2026-07-22
---

# Revenue Ledger — polish backlog

What's left to polish on the count-once [[deal-tracker-dashboard]] (Skipper said "good for now" 2026-07-22). Ordered by value.

## Queued
1. **Live calendar-muni forecast calc** — replace the `MUNI_H2_CALENDAR_FORECAST = $3.74M` config with a live calendar-2026 municipal number computed from the [[city-forecasting]] engine's monthly rows. Today: config value (Skipper's calendar choice); engine FY-remaining reconciles to ~$3.19M (budget−invoiced). The FY-vs-calendar gap is the thing to resolve.
2. **Confirm sold-WO status codes (46,109) with Herman** — live firm-WO recompute ($3.11M) runs ~$1.5M under Herman's snapshot ($4.60M). Likely just pre-refresh vintage, but confirm the status list is complete (no missing "sold/approved" statuses).
3. **Per-month coverage columns (Herman §11 full monthly table)** — current monthly table shows Goal / Invoiced / Δ only. Add per-month: Current Accrual · Prior Accrual Reversal · Adjusted Actual · Municipal Forecast · Firm Nonmuni Work · Risk-adj Pipeline · Projected Total · Gap. Needs bucketing firm-WO + pipeline by expected month.
4. **Drill-throughs** — click a rollup → the underlying projects / WorkOrders / GoAheads / city (Herman §11).
5. **Fail-visibly** — if the muni engine CSV fetch or accrual fn errors, surface it loudly on the board (partial guards exist: muni snapshot-fallback note, accrual live/off flag).

## Data-dependency notes
- **Accrual = DONE** (was the big one) — live via [[trimit-accrual-formula]], no Brent feed needed.
- Muni invoiced + classification (`ProjectGroups=11`) validated to the dollar vs Herman.
- Reconciliation diffs shown on-board: Brent workbook vs TRIM IT muni ($4.16M vs $4.19M), firm-WO snapshot vs live.

## Deliver-to-Herman note
Herman asked for the reconciliation table + overlap exceptions before "complete." It's in `business-plan/count-once-ledger-2026-07-22.md`. **Do NOT auto-send** — Skipper directs any share (comms lock: no outbound agent-to-agent without owner OK).
