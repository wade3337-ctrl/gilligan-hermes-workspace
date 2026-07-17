---
title: Production Perf — future-dated crew sheets inflate production
type: fact
domain: work
track: 1
status: held
tags: [production-performance, crew-sheets, data-quality, trimit, held, brent, dashboard]
applies: ["[[dashboard-metric-standards]]", "[[repair-contract]]"]
links: ["[[rc-04-spm]]", "[[shared-engine-kills-dashboard-drift]]", "[[municipal-budgets-po-gated]]"]
updated: 2026-07-16
---

# 🚧 Production Perf — future-dated crew sheets inflate production (HELD 2026-07-16)

**Status:** ⏸️ **HELD** — Skipper is asking the team *why* the future-dated crew sheets exist before we change the dashboard. Do NOT ship the fix until he says go. Revisit later.

## What the Skipper saw
On the **Production Performance** tab (`Dashboard-ProductionPerf.cfm?ZProjectID=1105030` = City of Irvine, FY 25/26), **August 2026 shows real production** — 10 jobs / **$81,403.90** / 476.7 hrs / TPH 170.8 — even though **today is July 16, 2026** (server clock + `GETDATE()` both confirm). Irvine's FY is **Sep–Aug**, so Aug-2026 is the last (future) month of FY25/26; it should be ~$0.

## Root cause — it's DATA, not a display bug
Production is binned by **`cs.WorkDate`** (`CrewSheets`) filtered to `HoursEntered=1 AND IsCheckedIn=1 AND StatusDefs.Desc1 IN ('Active','Complete')`, summing **`cs.ActValue`** (see `ProductionPerf.data.cfm` ~line 132, filter identical at year/period/day grains). There are crew sheets with **future WorkDates**, already checked-in + hours-entered + Complete — impossible for real "produced" work. Company-wide (checked-in production $) by month:
- 2026-06 $1,613,786 (past ✓) · 2026-07 $694,713 (current, partial ✓)
- **2026-08 $469,308** · **2026-09 $78,564** · **2026-10 $9,898** — all FUTURE ❌ (~**$557K** total; max future WorkDate = **2026-10-05**).

Irvine's Aug slice = the $81,403.90 (e.g. "Service Request Trimming", "Citywide Tree Limbs" sheets dated Aug 4–11 2026, Complete).

## Proposed fix (NOT yet applied — held)
**Cap production at today**: add `AND cs.WorkDate < DATEADD(day,1,CAST(GETDATE() AS date))` (WorkDate ≤ today) to the production filter **at all three grains** (year / period / day — they must stay identical or grains drift, per the file header). Effect: future months across ALL cities → $0; Irvine year total drops $81,403.90 → ~$2.70M. "Production" then honestly means *work done to date*. Future months still list at $0 like any not-yet-happened month.

- ⚠️ This changes **headline production for every city** (excludes ~$557K company-wide) — that's why it needs the Skipper's + team's OK.
- 🔎 Same future-dated `CrewSheets` likely also touch **SPM Production/Results** ([[rc-04-spm]]) and any crew-sheet-fed surface — check those when we act.

## Upstream question for the team
Why is ~$557K of work logged as **Complete + checked-in** with **Aug–Oct 2026** dates while it's still July? Crew-sheet WorkDate entry pattern (crews pre-dating? scheduled sheets mis-flagged checked-in?). Fixing the entry is the real cure; the dashboard cap only hides the symptom.

## Related
- [[dashboard-metric-standards]] — TPH target 130; production definition.
- [[rc-04-spm]] — shares the CrewSheets source.
- [[shared-engine-kills-dashboard-drift]] — the year/period/day filter-parity principle to preserve when editing.
