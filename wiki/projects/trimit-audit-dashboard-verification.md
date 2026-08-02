---
title: TRIM IT — Dashboard Data-Correctness Verification (audit traps as a checklist)
type: project
domain: work
track: 1
status: done (2026-08-02) — all live dashboards PASS
tags: [trimit, audit, dashboards, verification, data-correctness]
applies: ["[[only-trustworthy-data]]", "[[dashboard-metric-standards]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-05-scheduling-crewsheets-production]]", "[[trimit-audit-06-invoicing-ar]]", "[[bod-commitment-dashboard]]", "[[trimit-audit-07-reporting-dashboards]]"]
updated: 2026-08-02
---

# Dashboard Data-Correctness Verification

> After the 7-stage [[trimit-deep-audit]], the Skipper asked: **"are our dashboards reading the right things?"**
> I turned the audit's biggest data traps into a checklist and grepped all **86 local dashboard `.cfm`**
> (`arbor-stack/production-dashboard/`). **Verdict: every LIVE dashboard passes all 5 traps.** (Local grep, 2026-08-02.)

## Scorecard
| # | Trap (from the audit) | Rule | Result |
|---|---|---|---|
| 1 | **Production date binding** (Stage 5) | bin on `Calendars.CalDate` via `CalendarID`, never `WorkDate` (63% corrupt) | ✅ **PASS** — all live prod dashboards use `COALESCE(cal.CalDate, cs.WorkDate)` (ProductionPerf(.data/.Day), Executive$Sales$Detail(+$Customer), BOD). Raw-`WorkDate` only in orphan `ex_*` files. |
| 2 | **Revenue basis** (Stage 6) | `SUM(Invoices.Total)`; NEVER raw `IsProForma=0 AND IsCredit=0` (99.5% NULL → near-zero) | ✅ **PASS** — no dashboard uses the raw filter. `AI-Chat.cfm` uses `ISNULL(IsProForma,0)=0` (correctly includes NULLs). BOD has a comment warning against it. |
| 3 | **Productivity denominator** (BOD work) | production TPH ÷ clocked payroll (`PaidHrs`), not the estimate `ActHours` | ✅ **PASS (by design)** — two legit metrics kept distinct: **Job TPH** (÷`ActHours` = bid quality/sales) vs **True TPH** (÷`PaidHrs` = production). Live crew dash computes BOTH. Governing note: `Reference-RepairsAndScheme.cfm`. |
| 4 | **Close-rate counts `Complete`** (Stage 4) | `Complete` is the largest WON go-ahead state — must be in the numerator | ✅ **PASS** — all 3 `Executive$ClosePercentage$*` include `'Complete'` in `gs.Desc1 IN ('Active','Pending','InProcess','Locked','Revised','Closed','Complete')`. |
| 5 | **Rollup freshness** (Stage 7) | don't read stale stored-aggregate tables directly | ✅ **PASS** — no live dashboard reads `ProposalTotals`/`WorkOrderSummary`/`ProposalOverview`/`TempProposalTotals`; they compute from base tables. |

## Why this came out clean
The dashboard work shipped over prior weeks already internalized these lessons (the ProductionPerf CalDate rebind, the BOD `SUM(Total)` basis, the close-rate `Complete` fix on 2026-07-28). The audit confirmed the *why* behind each, and this pass confirmed the *live SQL* matches.

## Minor housekeeping (not a data problem)
Three **orphan** experimental files still carry the OLD patterns (raw `WorkDate` binding + `ActHours`-only TPH): `ex_Detail.cfm`, `ex_DetailCustomer.cfm`, `ex_Executive_Sales_ByCrewName.cfm`. **Nothing links to them** (confirmed — 0 inbound refs), so zero live impact. → fold into the dead-`.cfm` list in [[trimit-cleanup-plan]] (Phase 2).

## Method (reusable)
Grep the local dashboard `.cfm` for each trap's signature: `WorkDate` in WHERE/GROUP/BETWEEN vs `COALESCE(cal.CalDate,...)`; `IsProForma=0 AND IsCredit=0`; `ActHours` in a TPH denominator vs `PaidHrs`; `Complete` in close-rate status sets; direct reads of rollup tables. Local-only (no play-box load).
