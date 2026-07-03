---
title: Completed-vs-Sold
type: project
domain: work
track: 1
status: active
tags: [analysis, reconciliation, completed-sold, brent, commercial, municipal]
applies: ["[[db-repair-contract]]"]
links: ["[[budget-report-municipal]]", "[[sales-cockpit]]"]
updated: 2026-07-03
---

# Completed-vs-Sold

**One-liner:** Reproduce Contract-Admin Brent's weekly "Completed & Sold" report — a YTD tracker of work Completed + work Sold vs last year (YoY) — as a configurable server dashboard, WITHOUT Brent hand-pulling TrimIT → spreadsheet.
**Status:** 🔵 active — Commercial recipe validated to the dollar; **paused mid-build**; muni section needs direction.
**📁 Location:** `arbor-stack/completed-sold/`
**▶️ Resume:** `arbor-stack/completed-sold/CHECKPOINT.md`

## Applies / uses
- [[db-repair-contract]] — read-only DB analysis on play; look-first, no writes without backup/preview.
- Metric = `WorkOrders.EstValue` ($); WorkOrder-centered 10-column source map (Company/Project/City/GoAhead/Notified/Start/End/EstValue/TPH/Rep).

## State & flags
- ✅ **Commercial CONFIRMED** — June-2026 sold-commercial per-rep reconciled EXACTLY to Brent's $956,466. SOLD = `StatusDefs.Desc1='Active'` AND `DateCompleted IS NULL` by EndDate month; COMPLETED = `Desc1='Complete'` by DateCompleted month (exclude 'Revised').
- Commercial = **NOT EXISTS** `ProjectGroups.ProjectGroupDefID=11`; Municipal = EXISTS group 11. `IN(12,14)` undercounts — don't use.
- ⏳ **Municipal = the main unknown** — repeating monthly values → likely CompanyYears contract value allocated monthly (burn-down), NOT job aggregation. Needs the follow-up Codex prompt (`Codex-Followup-Municipal-and-Completed.md`, not yet run).
- ⏳ Validate the **Completed** side (May-Completed per-rep targets recorded) + confirm the month Completed-vs-Sold cutoff rule.
- Rep attribution = `Projects.SalesRepID`. Build fresh (no existing TrimIT report emits these 10 cols) in the `MonitorData.ReadOnly.cfm` style.
- Paused 2026-06-12 to focus on the Contract-Dashboard prod fix (Codex bandwidth was the constraint).

## Related
- [[budget-report-municipal]] — shares the municipal contract-value burn-down question.
- [[sales-cockpit]] — downstream consumer of rep-grain sold/completed.
