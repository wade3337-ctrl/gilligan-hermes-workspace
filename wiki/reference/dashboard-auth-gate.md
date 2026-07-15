---
title: Dashboard auth-gate (Track-1 V1.5) + re-authorizing headless consumers
type: reference
domain: work
track: 1
tags: [auth, security, coldfusion, dashboards, v15, ZUserID, automation, monitor]
applies: []
links: ["[[anomaly-monitor-suite]]", "[[play-dev-access]]", "[[dashboard-metric-standards]]"]
updated: 2026-07-15
---

# 🛡️ Dashboard auth-gate + the headless-consumer re-auth rule

**What it is:** `production-dashboard/dashboard-auth-gate.cfm` — the shared include added to every V1.5 Track-1 dashboard (2026-07-12 hardening). Defense-in-depth: TRIM IT's framework only checks that a `ZUserID` cookie *exists* (any garbage value returns financials), so this gate validates the cookie is a **real, authorized user** before any data/output. This is the **Track-1 dashboard gate** — distinct from the arbor-core Track-2 `Application.cfc` global gate ([[arbor-core-v15-auth]]).

## How it authorizes (in order)
- Reads `cookie.ZUserID` → integer `dashUID` (0 if missing/non-numeric).
- **Bootstrap allow-list — always passes, even if the table is empty:** `9` (Jason, admin) + **`376` (Arbor Helper bot — the service identity for automation)**.
- Else: `SELECT 1 FROM Workbench.dbo.DashboardAccess WHERE UserID=@uid` — the **single source of truth**, managed no-code from the **`Dashboard-Access.cfm`** admin page.
- Fallback if that table is missing: exec/finance leadership title/login check (`jwade,sgriffiths,jgriffiths,jmcneill` / president/owner/executive/chief/controller/CEO/COO/CFO/VP).
- Fail → **HTTP 403**: JSON `{"error":"unauthorized"}` for `?aisummary=1`, else the dark-green "Not authorized" 🔒 HTML page.

## 🚩 THE STANDING RULE — gating a surface breaks its headless consumers
When you add/extend an auth gate on a data page, **every headless/automation fetch of that page starts getting 403'd — silently.** Grep for every `fetch()`/`curl`/`view.sh` hit of the surface and **re-authorize them in the same change.**
- **How to re-authorize an automated fetch:** send the bot identity cookie → `Cookie: ZUserID=376`. (Node: `headers:{ ..., 'Cookie':\`ZUserID=${S.serviceUserID||376}\` }`.)
- **Proven incident (2026-07-15):** the July-12 gate silently 403'd the anomaly-monitor's `bookedPacing()` POST to `Dashboard-RevenuePerformance.cfm` → the COO daily email showed *"📅 Forward pace unavailable today (HTTP 403)"* for days. Same bug in `revenue-block.js` (per-salesperson + Nate rollup revenue snapshot). Fix = `Cookie: ZUserID=376` in `monitor.js` + `revenue-block.js`; verified HTTP 200 + real data. (`m2-revenue.js` has the same cookie-less pattern but is unused legacy.)
- Symptom to watch: a report line that reads "unavailable / N/A" instead of a number, with the underlying error swallowed into a fallback string. → grep the report text for `unavailable|403|N/A` after any security deploy.

## Related
- [[anomaly-monitor-suite]] — the consumer that broke + was fixed.
- [[play-dev-access]] — the play box these dashboards + the monitor run against.
- [[arbor-core-v15-auth]] — the *other* (Track-2) gate; don't conflate.
