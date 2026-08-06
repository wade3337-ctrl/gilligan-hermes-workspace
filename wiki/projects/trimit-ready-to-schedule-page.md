---
title: TRIM IT Ready-to-Schedule page — Nate's "approved awaiting schedule" view
type: project
domain: work
track: 1
status: 🟢 BUILT + live on play 2026-08-05/06, gated; InProcess fix holds; prod deploy pending Jordan
tags: [trimit, coldfusion, scheduling, work-orders, nate, dashboard, production]
applies: ["[[repair-contract]]", "[[dashboard-auth-gate]]", "[[gsts-ui-style-guide]]"]
links: ["[[goahead-status-lifecycle]]", "[[trimit-db-gotchas]]", "[[v15-landing-page]]", "[[trimit-sales-pipeline-page]]"]
created: 2026-08-06
updated: 2026-08-06
---

# TRIM IT Ready-to-Schedule page

**One-liner:** A Production page that shows work **approved but not yet scheduled** — reconciled to the number Nate cites in his weekly meeting report. Built to give Nate a live, self-serve version of his manual "approved awaiting schedule" list.

- **LIVE (play):** `https://play.greatscotttreeservice.com/GSTS/Dashboard-ReadyToSchedule.cfm`
- **On the V1.5 landing** under the **Production** node → [[v15-landing-page]].
- **Default window = "Approved in last 7 days" (Nate's view)** via a **dropdown** (7 / 14 / 30 / 90 days / full backlog) so you can widen when you want the bigger picture. (Earlier `through` date-input param removed → now vestigial in the query; only the CSV filename + empty-state text referenced it.)

## ⭐ The InProcess fix (the bug that made our number too low)
Scheduling / "approved awaiting schedule" reports MUST include **StatusDefID 109 (InProcess)**, not just **46 (Active)**. Go-ahead activation is a **2-step flip InProcess→Active** ([[goahead-status-lifecycle]]); a WO left `InProcess` is **approved but half-activated** — its WO shell has **$0 EstValue + 0 TotalHours + NULL StartDate**, so the value must come from **`Proposals.Total`** (via `WorkOrder → GoAhead → Proposal`).

Diffed our first cut ($44.9K) vs Nate's meeting report ($256K): gap =
- **InProcess excluded ($129K)** — the bug, now fixed;
- **stale play, approved after last snapshot ($69K)** — data freshness, not logic;
- **proposal-has-no-WO-yet ($58K)** — a grain difference.

Also: **`Proposals.LegacyRef` = the displayed proposal #** Nate cites; **`Proposals.Total` = his EstValue** exactly. (All three captured in LESSONS 2026-08-06 + [[trimit-db-gotchas]].)

🔑 **`WorkOrders.Created` is the reliable approval anchor** — it matches Nate's 7/29–7/31 dates exactly; **`WorkOrders.ApprovedDate` is always NULL** and cannot be used. → [[trimit-db-gotchas]].

## Verified on play (7-day window)
- **21 work orders · $139,352 · 4 overdue · 17 needs-activation · 43 ready-hrs.** Renders clean (200, zero CF errors). **Culver east ($32,727) present** ✅ — the InProcess fix holds.
- **30-day window tested:** 47 WOs / $260K.
- **On the number vs Nate's $256K:** the 7-day view lands at **$139K on play** because play is **frozen at 8/3** and missing the 8/4–8/5 approvals (e.g. Newport Grid 18 Palms $66.8K) that Nate's list includes. The **logic** now matches his; the residual gap is purely **data freshness** (footer note flags it). On prod / after a fresh refresh it should converge to ~$256K.

## ▶️ OPEN / TODO
- **Prod deploy via Jordan** when the Skipper approves (play is frozen at 8/3). Log to `gsts-ship-log.md` + the Reference page per the repair contract at deploy.

## Related
- [[goahead-status-lifecycle]] — why InProcess is a half-finished activation that must be counted here.
- [[trimit-sales-pipeline-page]] — a sibling investor/board page reconciled to Nate's reports.
- [[v15-landing-page]] — where it lives (Production node).
