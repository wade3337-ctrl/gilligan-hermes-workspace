# Q2 2026 COO Operating Plan — DELIVERED TO THE BOARD 2026-07-29

**Status: SENT by Jason Wade to the Board of Directors, 2026-07-29. FROZEN — do not edit.**
The delivered text is `Q2-2026-coo-plan-SENT-20260729.md`. Any later revision opens a new file.

## Basis of every figure in the delivered report

**Productivity is CFO revenue ÷ clocked payroll hours.** Chosen deliberately so the board cannot
recompute a different answer from the CFO's own statements.
- Numerator: Controller's income statement "Total Income" — Q1 **$5,318,331**, Q2 **$5,904,101**, H1 **$11,222,433**.
- Denominator: `dbo.CrewMemberCalendars.TotalHours` (electronic timekeeping) — Q1 **44,781**, Q2 **47,195**, H1 **91,976**.
- → **Q1 $118.76 · Q2 $125.10 (+5.3%) · H1 $122.01.** Against the $130 target: −$11.24 and −$4.90.

**Headcount** — `dbo.CrewMembers` + timekeeping: 94 on the roster · ~83 log hours in a month ·
**~76 work a typical weekday** at ~8.9 hrs. The weekday figure is the one used.

**The plan arithmetic** (15 hires at 184 hrs/person/month → 18,089 paid hrs/mo):
- at the Q2 rate → $2,262,977/mo → **$24.8M**, short **$299,706** over six months
- at the H1 rate → $2,207,165/mo → **$24.47M**, short **$634,577**
- closing the $300K: **+$1.38/paid hr** (to $127.86) **or** +376 job-hrs/mo (**11 min/person/day**), or
  the balanced split of **+$1.38 and 5 min/person/day**
- job-booked share **94.3%** (44,499 job hrs ÷ 47,195 paid); one point ≈ **153 hrs/mo**
- on-the-job rate $155.22 (Q2 revenue ÷ 38,038 revenue-bearing hrs); +$5 saves **465 hrs/mo**

**Safety-meeting change** — first principles, not from the ERP: 3 × 30-min meetings removed, 2-min daily
video added back → **47 net min/person/month × ~76 = 59 crew-hrs/mo ≈ 708/yr ≈ $89,000.**

**Production dollars are NOT used in the delivered report.** They appear in the fuller
`Q2-2026-operations-review.md` and run ~3% above revenue (production leads billing by $178,361 in Q2).

## Claims deliberately cut before sending
- ❌ *"5.7% of paid hours never reach a crew sheet — recoverable time."* Untrue: it is stale crew-member
  assignment → [[crew-assignment-drift]].
- ❌ *"The weekly sales-and-production meeting produced the utilization shift."* Causation was never
  established — the Skipper's correction.
- ❌ Year-over-year productivity: impossible on this basis, timekeeping began Nov 2025 →
  [[timekeeping-live-nov-2025]].
- ❌ The inclement-weather caveat and the timekeeping footnote — cut by the Skipper before sending.

## If challenged
Every number is reproducible from the play restore. The two that would move if re-run: **July is excluded
throughout** (open month, invoicing lags 3–10 days), and production figures depend on the `CalDate` fix
shipped 2026-07-28 → [[production-perf-future-dated-crewsheets]].
