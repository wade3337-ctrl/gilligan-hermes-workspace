# 🔒 Count-Once Revenue Ledger — 2026 path to goal (VERIFIED LIVE 2026-07-22)
Confidential / BLACK. Built per Boss Herman's spec + Gilligan's reconciliation. Play DB ~24h behind prod.
All figures **recomputed live from TRIM IT** (not Herman's snapshot constants). Read-only.

## Layer 0 — GOAL (decision needed)
| Source | Value | Notes |
|---|---|---|
| **SalesGoal monthly** (Skipper edited 7/22) | **$25,188,095** | real per-month shape (flattened H2); what the board uses now |
| GoalSettings ZUserID9 × 12 (Herman) | $25,045,428 | flat $2,087,119×12 — loses monthly shape |
→ **Rec: keep SalesGoal monthly** (it's what you edited). Diff = $142,667.

## Layer 1 — FINANCIAL ACTUAL YTD (accounting period, status-filtered) ✅ ADOPTED Herman's basis
- **All markets: $12,011,557** ✓ (= Herman's $12.01M). Basis: `Invoices.PeriodID→Periods.StartDate`, `StatusDefID IN (21,100,22,23,148)`, no proforma/credit.
- of which **Municipal: $4,192,062** ✓ (= Herman's TRIM IT $4,192,062 exactly; Brent workbook $4,160,086 → **+$31,976 reconciliation diff**, do NOT force-match).
- Nonmuni: $7,819,495.
- My OLD board used InvoiceDate + no status filter = $12,077,172 → **was $65,615 high** (period-timing, not status).
- **Accrual bridge: NOT YET APPLIED** — needs Brent/accounting feed (July accrual $82,475 per workbook). Cannot derive safely from TRIM IT (Herman's rule). Until fed, actual is "unadjusted."

## Gap after actuals = $25,188,095 − $12,011,557 = **$13,176,538**

## Layer 2 — MUNICIPAL FORECAST REMAINING (decision needed — definitions differ)
| Source | Value | Basis |
|---|---|---|
| Live City Budgets engine "Remaining" (grand total) | $2,224,313 | **fiscal-year** per city, net of scheduled+invoiced |
| Herman "remaining H2 municipal projection" | $3,741,400 | **calendar** H2 2026 |
→ Gap is FY-vs-calendar + whether scheduled is netted. **Open: which basis for a calendar-2026 goal?** (Muni *invoiced* is reconciled; only the *forward* number is in question.) Adjust Herman: use our **live reconciled engine**, NOT the xlsx at `/opt/data/...` (hand-typed plugs — the $178K Newport "overage" is a spreadsheet true-up, not a transaction; and that path is on Herman's box).

## Layer 3 — FIRM NONMUNI SOLD COVERAGE (WorkOrders 46/109, dated ≤12/31)
- **Firm dated through year-end: $3,113,468** (278 WOs) — [Herman snapshot $4,599,683 — pre-refresh, recompute lower].
- Undated / beyond-year (separate "Needs Production Date" queue, NOT coverage): **$3,174,488** (251 WOs).
- (Muni firm-dated, for reconciliation only: $1,020,161 / 75 WOs.)
- Note: my OLD board's "on schedule" $3.34M was **CrewSheets production-board** data — Herman correctly says that's a PRODUCTION view, keep it separate from financial coverage.

## Layer 4 — FRESH PENDING PIPELINE (GoAheads status 49, <90 days, deduped MAX/project, non-muni)
- All nonmuni fresh pending: $4,387,356 (207 projects) — [Herman $4.34M ✓ close].
- **HOA/Commercial/PropMgmt** (Markets 5,6,16, proper GeoMarket join): **$3,877,092 raw** (176) → **@40% = $1,550,837**. [Herman $4.34M→$1.74M].
  - mix: HOA $3.48M · Retail $0.29M · Comm/Ind $0.28M · PropMgmt $0.12M · Apt $0.11M · …
- Conversion % configurable (40% default). Raw is NOT coverage — pending client approval.

## COUNT-ONCE BRIDGE (live)
| Line | If muni=$2.22M (engine) | If muni=$3.74M (Herman H2) |
|---|---|---|
| Annual goal (SalesGoal) | $25.19M | $25.19M |
| − Actual YTD (acct period) | $12.01M | $12.01M |
| = Gap after actuals | **$13.18M** | **$13.18M** |
| − Municipal forecast remaining | $2.22M | $3.74M |
| − Firm nonmuni sold (dated) | $3.11M | $3.11M |
| − Risk-adj fresh pipeline @40% | $1.55M | $1.55M |
| = **Still needing new sales/scheduling** | **≈ $6.30M** | **≈ $4.78M** |

⚠️ **The true uncovered gap (~$4.8–6.3M) is materially LARGER than Herman's snapshot "~$2.95M"** — because live firm-WO ($3.11M) and pipeline ($1.55M) recompute well below his pre-refresh snapshot ($4.60M / $1.74M). This is the key finding.

## EXCLUSIONS (count-once discipline — honored)
Pending proposals >90 days · undated sold work (separate queue) · duplicate GoAhead revisions (dedup MAX/project) · never add GoAheads + their WorkOrders twice · CrewSheets production ≠ accounting actual.

## OPEN DECISIONS FOR SKIPPER
1. **Goal:** SalesGoal monthly $25.19M (rec) vs GoalSettings×12 $25.05M?
2. **Muni forward number:** FY-engine $2.22M vs calendar-H2 $3.74M (I'd compute calendar-2026 from the engine's monthly rows).
3. **Accrual:** want me to source the accrual feed from Brent/accounting? (can't derive from TRIM IT).
4. **Confirm sold-status list** (46,109) with Herman — my firm-WO recompute is ~$1.5M below his snapshot.
