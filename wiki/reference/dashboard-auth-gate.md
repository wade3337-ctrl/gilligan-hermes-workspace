---
title: Dashboard auth-gate (Track-1 V1.5) + re-authorizing headless consumers
type: reference
domain: work
track: 1
tags: [auth, security, coldfusion, dashboards, v15, ZUserID, automation, monitor, access-control, realuser-gate]
applies: []
links: ["[[anomaly-monitor-suite]]", "[[play-dev-access]]", "[[dashboard-metric-standards]]", "[[trimit-dual-webroot-shadow]]"]
updated: 2026-07-20
---

# 🛡️ Dashboard auth-gate + the headless-consumer re-auth rule

**What it is:** `production-dashboard/dashboard-auth-gate.cfm` — the shared include added to every V1.5 Track-1 dashboard (2026-07-12 hardening). Defense-in-depth: TRIM IT's framework only checks that a `ZUserID` cookie *exists* (any garbage value returns financials), so this gate validates the cookie is a **real, authorized user** before any data/output. This is the **Track-1 dashboard gate** — distinct from the arbor-core Track-2 `Application.cfc` global gate ([[arbor-core-v15-auth]]).

## How it authorizes (in order)
- Reads `cookie.ZUserID` → integer `dashUID` (0 if missing/non-numeric).
- **Bootstrap allow-list — always passes, even if the table is empty:** `9` (Jason, admin) + **`376` (Arbor Helper bot — the service identity for automation)**.
- Else: `SELECT 1 FROM Workbench.dbo.DashboardAccess WHERE UserID=@uid` — the **single source of truth**, managed no-code from the **`Dashboard-Access.cfm`** admin page.
- Fallback if that table is missing: exec/finance leadership title/login check (`jwade,sgriffiths,jgriffiths,jmcneill` / president/owner/executive/chief/controller/CEO/COO/CFO/VP).
- Fail → **HTTP 403**: JSON `{"error":"unauthorized"}` for `?aisummary=1`, else the dark-green "Not authorized" 🔒 HTML page.
- **(2026-07-20) This decision now lives in the shared `dashboard-access-check.cfm`** (sets `request.dashOK`, no output/abort). The gate `<cfinclude>`s it then enforces the 403 — so the exact same decision drives both the gate AND the menu (below). Deploy `dashboard-access-check.cfm` to BOTH webroots (the gate includes it; [[trimit-dual-webroot-shadow]]).

## Menu visibility is now permission-driven (2026-07-19/20)
- The classic-home **Dashboards submenu** (`Profile$Main.HiRes.cfm`) `<cfinclude>`s `dashboard-access-check.cfm` and shows the submenu only if `request.dashOK` — so it **appears only for authorized users and hides for everyone else**, like other TRIM IT menus. Retired the old `ZUserID EQ 9` Jason-only pilot gate. Menu-visibility and page-access read the SAME list → can't drift. The "Manage Access…" link is admin-only (UserIDs 9/3).
- **DashboardAccess seeded to 23 users** (Skipper-approved 2026-07-19/20): leadership + IT (115/1) + Scott, Steve, Dimitry, Jeanie, Jordan, Jaime, Manuel Perez, Omar, 2× Daniel Ruelas, Agustin, Francisco, Pedro Jimenez, Joseph Young, Rosa Smith, Naomi, Roxanne, Jason. Grant/remove instantly via `Dashboard-Access.cfm` (no redeploy).

## `realuser-gate.cfm` — the lighter sibling gate (NEW 2026-07-20)
For pages that should be visible to **any real logged-in TRIM IT user** (NOT restricted to the DashboardAccess allow-list) but must NOT leak to a garbage cookie. Validates `ZUserID` exists in `flow.Users` (bootstrap 9/376); JSON-or-HTML 403 otherwise. First user: `Exec$PercentagePerformed2.cfm` (Steve's accrual report). Use this instead of `dashboard-auth-gate.cfm` when the audience is "all logged-in staff," not "the dashboard list."

## Pre-deploy leak sweep (2026-07-20) — 3 un-gated financial pages caught before prod
The standard pre-deploy crew treatment found three pages leaking data (200 + financials) to a garbage cookie, already bundled for prod: `Executive$Sales$Detail$Customer.cfm` + `Executive$Sales$Unattributed.cfm` (fixed with dashboard-auth-gate + repointed retired `Frame$Beta`/dead `Document$Invoice` links) and `Exec$PercentagePerformed2.cfm` (fixed with realuser-gate). **Lesson:** the deploy manifest only walks ENTRY pages — deep drill children and bundled legacy add-ons need an explicit garbage-cookie gate audit before every ship.

## 🚩 THE STANDING RULE — gating a surface breaks its headless consumers
When you add/extend an auth gate on a data page, **every headless/automation fetch of that page starts getting 403'd — silently.** Grep for every `fetch()`/`curl`/`view.sh` hit of the surface and **re-authorize them in the same change.**
- **How to re-authorize an automated fetch:** send the bot identity cookie → `Cookie: ZUserID=376`. (Node: `headers:{ ..., 'Cookie':\`ZUserID=${S.serviceUserID||376}\` }`.)
- **Proven incident (2026-07-15):** the July-12 gate silently 403'd the anomaly-monitor's `bookedPacing()` POST to `Dashboard-RevenuePerformance.cfm` → the COO daily email showed *"📅 Forward pace unavailable today (HTTP 403)"* for days. Same bug in `revenue-block.js` (per-salesperson + Nate rollup revenue snapshot). Fix = `Cookie: ZUserID=376` in `monitor.js` + `revenue-block.js`; verified HTTP 200 + real data. (`m2-revenue.js` has the same cookie-less pattern but is unused legacy.)
- Symptom to watch: a report line that reads "unavailable / N/A" instead of a number, with the underlying error swallowed into a fallback string. → grep the report text for `unavailable|403|N/A` after any security deploy.

## Related
- [[anomaly-monitor-suite]] — the consumer that broke + was fixed.
- [[play-dev-access]] — the play box these dashboards + the monitor run against.
- [[arbor-core-v15-auth]] — the *other* (Track-2) gate; don't conflate.
