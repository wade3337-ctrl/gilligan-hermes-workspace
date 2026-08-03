---
title: Month-end invoicing lag — the COO "billed" line understates at month close
type: fact
domain: work
tags: [revenue, invoicing, ar, coo-email, metric-caveat]
links: ["[[anomaly-monitor-suite]]", "[[dashboard-metric-standards]]", "[[play-dev-access]]", "[[prod-web-read-access]]", "[[trimit-accrual-formula]]"]
updated: 2026-08-03
---

# Month-end invoicing lag (the "billed" line is not done at month-end)

**The finding (measured June 2026, PeriodID 333):** the daily COO email's **"Billed so far"** line materially UNDERSTATES the month right at close, because AR keeps *entering* invoices for ~10 days into the next month. Final June invoiced = **$1,981,476** (261 invoices), but by `Created` date:

- **Through Jun 30:** only **$1,489,664 (~75%)** had been entered.
- **Jul 1–3:** the bulk catch-up (+$464K) → **$1,953,852 (98.6%)** by **Jul 3** = effectively complete.
- Tail: one $26K invoice Jul 7, a final $1,590 straggler **Jul 10** = last June invoice keyed.

**So on the actual Jun 30 email, "billed" showed ~$1.49M, not the ~$1.98M a re-query shows today.** The lag is real and large (~25% of the month's billing lands after month-end).

**Why it matters:** informs the Skipper's pending "change how the COO daily numbers present" ask ([[anomaly-monitor-suite]]). The **produced / on-pace** line (schedule-board actual, ~$2.24M for June) is stable and does NOT suffer this lag — it's the trustworthy month-close headline. **"Billed" at/near month-end should be read as a floor, not the final**, and arguably labeled that way.

## 📊 2026-08-03 — generalised: THREE revenue numbers for one month, all correct
July 2026, reconciled three ways off independent sources (they tie):

| Basis | July 2026 | What it is |
|---|---|---|
| **Invoiced** (Steve's register) | **$1,738,143** | actually billed, 222 invoices — the hard, defensible number |
| **True Produced** (prod Revenue dashboard) | **$2,078,762.87** | work performed, day-sheet valued (731 jobs, 15,643 hrs, TPH $137) |
| **Earned** (invoiced + corrected accrual) | **~$2.18M** | $1.738M + $441K municipal accrual — ties to produced within ~$100K |
| **Gap** | **~$340,000** | produced-but-not-yet-invoiced = **WIP** (this note's lag, at scale) |

- ⚠️ **The Revenue-Performance dashboard is a PRODUCTION dashboard, not an invoiced one** — its default source
  is *"True Produced Work (day sheet + schedule)"* and it offers **no invoiced option at all**. Anyone reading
  "July revenue" off the screen gets the ~20%-higher production figure. → [[prod-web-read-access]]
- 🎯 **Deal discipline:** use **INVOICED** for anything comparative or external — YoY, TTM, deal material (it is
  what produced the −6.4% TTM finding). Produced is real but softer/higher; if anyone quotes $2.08M as "July
  revenue" it is PRODUCTION, and FTI would recut it to invoiced + accrual.
- **State the basis with every revenue figure.** Two numbers for one month is two questions being answered, not
  a discrepancy — the error is letting them swap silently.

**How it was measured:** direct read-only SQL on the PLAY box ([[play-dev-access]]) — `dbo.Invoices` filtered `(PeriodID=333 OR CustomerPeriodID=333)` + StatusDefs `Desc1 NOT IN ('Deleted','Voided')` (reproduces the revenue endpoint total to the cent), grouped by `CONVERT(date, Created)` with a running SUM. `Created` = actual data-entry date; `InvoiceDate` is often backdated to month-end so it hides the lag.
