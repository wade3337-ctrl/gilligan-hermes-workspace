---
title: RC-01 Executive Financial Overview
type: project
domain: work
track: 1
status: shipped
tags: [dashboard, executive, financial, release-candidate, win-rate, tph]
applies: ["[[dashboard-metric-standards]]", "[[gsts-ui-spec]]", "[[gsts-ui-style-guide]]", "[[repair-contract]]"]
links: ["[[rc-02-revenue-performance]]", "[[rc-04-spm]]", "[[steve-diligence-dashboard]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-02
---

# RC-01 Executive Financial Overview → **renamed "Sales Performance" (2026-07-17)**

**One-liner:** 5-tab executive suite in one iframe shell — Sales by Rep, Sales by Market (+ Treatments sub-tab), Closing % by Rep, Closing % by Market, Crew Performance — plus close-% and crew drills. Ships as a UNIT.
**Status:** 🟢 shipped — **COMPLETE & PARKED** (Skipper, Jun 19). All 5 tabs reviewed, fixed, aligned; welcome modal added. Ships at the next full Executive-dashboard prod deploy.
**📁 Location:** `production-dashboard/Executive$Financial$Overview$Frame$Beta.cfm` (shell) + the 5 `Executive$*.cfm` tab pages + drills
**▶️ Resume:** `arbor-stack/release-candidates/RC-01-executive-financial-overview-dashboard.md`

## Applies / uses
- [[dashboard-metric-standards]] — target-driven TPH bands ($130 target); close-% cohort def; municipal excluded from close rate.
- [[gsts-ui-spec]] / [[gsts-ui-style-guide]] — welcome modal + "?" pro-tips (no permanent technical text); emoji `.cfm` needs UTF-8 BOM.
- [[repair-contract]] — backup-first, render-verify served output, log to ship-log.

## State & flags
- **Ship rule (Skipper Jun 19):** whole dashboard goes to prod together, only when every tab is reviewed & complete. No piecemeal tab pushes.
- Crew Performance **Productive % / True TPH fixed** — clamped to the Dec 1 2025 time-clock go-live; reads "n/a" before it; Job TPH keeps full history.
- Close rate is **commercial-only** (municipal = contract intake, not a sales close) → new Municipal/Cities tab links to City Budgets.
- **Prod deploy:** migrate the 6 chart/pro-tip assets that 404 on prod; verify UTF-8 BOM; sequence with the IsMeasured prod data fix.
- Non-blocker refinements queued: pool/flex-labor attribution accuracy; DB-proc review of the Perf rollup pages.

## Related
- [[rc-04-spm]] — shares the win-rate/close-% definition (centralize to prevent drift).
- [[steve-diligence-dashboard]] — same close-% shown in a second UI; city-exclusion aligned across both.

## ✅ 2026-07-17 — RENAMED "Sales Performance" + Crew Performance split out (walkthrough, ships #189/#191/#192)
Skipper: this frame is really a SALES dashboard except the Crew tab. Changes:
- **Renamed** the frame title/H1 → **"Sales Performance"** (file name kept = `Executive$Financial$Overview$Frame.cfm`, so AppForms 1104 + the Beta→Frame rename SQL are untouched). Now **4 sales tabs**: Sales by Rep · Invoiced Revenue by Market · Closing % by Rep · Closing % by Market.
- **Crew Performance split into its own standalone `Dashboard-CrewPerformance.cfm`** (single-frame clone, same date-filter + Welcome, iframes `Executive$Sales$ByCrewName.cfm`) for the production team. Classic menu (`Profile$Main.HiRes.cfm`) + V1.5 home (`Dashboard-V15Home.cfm`) both updated: "Executive Review" → "Sales Performance", + a "Crew Performance" link under Production. **New file added to the deploy set.**
- **Closing % by Market** (#191): "25 active city contracts" was counting contract ROWS incl. a test company → now distinct municipal accounts with adaptive "N cities and M agencies" phrasing (can't go stale).
- **Closing % by Rep** (#192): municipal-only reps dropped — rep must have ≥1 non-municipal proposal written in the window (the close-rate denominator).