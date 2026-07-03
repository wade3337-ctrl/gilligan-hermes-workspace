---
title: Scheduled-revenue date basis (decision pending)
type: fact
domain: work
tags: [revenue, date-basis, metric, decision-pending]
links: ["[[dashboard-metric-standards]]", "[[trimit-stack-and-tph]]"]
updated: 2026-07-02
---

# Scheduled-revenue date basis (⚖️ decision pending, Jun 25 2026)

The same "scheduled work" totals differently by date rule:

- **Per scheduled calendar DAY** — Revenue dashboard / `Calendars.EstValue`; capacity truth, splits multi-month jobs fairly.
- **Full WO value by END-date month** — Nate/Brent's Completed+Scheduled report, `Synch.WorkOrders.All.List.cfm`; booked-sales view, always highest.
- **By-START.**

## They diverge by each month's carry-in
| Month | per-day | by-end | by-start |
|---|---|---|---|
| Jul | $1.10M | $1.71M | $982K |
| Aug | $555K | $676K | $565K |

- Per-day ≈ by-start **only when carry-in is low** (Aug yes, Jul no).
- **Which basis is authoritative = a real decision for later.**

## Detail
`DASHBOARD-METRIC-STANDARDS.md` §date-basis + `spm-verify/RECON-completed-scheduled-vs-revenue-2026-08.md`.
