---
title: Dashboard auth-gate (Track-1 V1.5) + re-authorizing headless consumers
type: reference
domain: work
track: 1
tags: [auth, security, coldfusion, dashboards, v15, ZUserID, automation, monitor, access-control, realuser-gate]
applies: []
links: ["[[anomaly-monitor-suite]]", "[[play-dev-access]]", "[[dashboard-metric-standards]]", "[[trimit-dual-webroot-shadow]]", "[[rc-04-spm]]", "[[steve-diligence-dashboard]]", "[[v15-prod-deploy-state]]"]
updated: 2026-07-28
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
- ✅ **Audited 2026-07-28 and it fails CLOSED** — a crew finding claimed it grants access on any SQL exception.
  It sets `request.dashOK = false` on line 13 *before* anything can throw, and the `cfcatch` runs a **narrower**
  leadership fallback whose own inner catch leaves it false. **For any "fails open" claim, trace the flag from
  where it is INITIALIZED, not from the catch block.**

## Menu visibility is now permission-driven (2026-07-19/20)
- The classic-home **Dashboards submenu** (`Profile$Main.HiRes.cfm`) `<cfinclude>`s `dashboard-access-check.cfm` and shows the submenu only if `request.dashOK` — so it **appears only for authorized users and hides for everyone else**, like other TRIM IT menus. Retired the old `ZUserID EQ 9` Jason-only pilot gate. Menu-visibility and page-access read the SAME list → can't drift. The "Manage Access…" link is admin-only (UserIDs 9/3).
- **DashboardAccess seeded to 23 users** (Skipper-approved 2026-07-19/20): leadership + IT (115/1) + Scott, Steve, Dimitry, Jeanie, Jordan, Jaime, Manuel Perez, Omar, 2× Daniel Ruelas, Agustin, Francisco, Pedro Jimenez, Joseph Young, Rosa Smith, Naomi, Roxanne, Jason. Grant/remove instantly via `Dashboard-Access.cfm` (no redeploy).

## `realuser-gate.cfm` — the lighter sibling gate (NEW 2026-07-20)
For pages that should be visible to **any real logged-in TRIM IT user** (NOT restricted to the DashboardAccess allow-list) but must NOT leak to a garbage cookie. Validates `ZUserID` exists in `flow.Users` (bootstrap 9/376); JSON-or-HTML 403 otherwise. First user: `Exec$PercentagePerformed2.cfm` (Steve's accrual report). Use this instead of `dashboard-auth-gate.cfm` when the audience is "all logged-in staff," not "the dashboard list."

## Pre-deploy leak sweep (2026-07-20) — 3 un-gated financial pages caught before prod
The standard pre-deploy crew treatment found three pages leaking data (200 + financials) to a garbage cookie, already bundled for prod: `Executive$Sales$Detail$Customer.cfm` + `Executive$Sales$Unattributed.cfm` (fixed with dashboard-auth-gate + repointed retired `Frame$Beta`/dead `Document$Invoice` links) and `Exec$PercentagePerformed2.cfm` (fixed with realuser-gate). **Lesson:** the deploy manifest only walks ENTRY pages — deep drill children and bundled legacy add-ons need an explicit garbage-cookie gate audit before every ship.

## 🔓 The two ways a gate fails in practice (2026-07-28 suite audit — both were LIVE ON PROD)
Neither is a bug in the gate. Both are about **where** it sits.

**1. No gate at all — and TRIM IT's native login does not save you.** `FinancialReportDashboard.cfm` and
`FinancialReportExport.cfm` had **zero** gate includes. ClientLogin only checks the `ZUserID` cookie *exists*,
so a junk value read customer names, addresses and invoice amounts, and pulled the **full customer CSV**.
Proven before/after: `ZUserID=99999999` → **200 / 14,810 b of CSV** → **403**; a real user (376) still gets
200 and the identical 14,810 b. Fixed with `<cfinclude template="../realuser-gate.cfm">` as the **first
executable line** of both. → [[steve-diligence-dashboard]]
- **Gate choice was deliberate:** `realuser-gate` (any real logged-in user), **not** `dashboard-auth-gate`
  (allow-list) — it fully closes the forged-cookie hole with zero risk of locking Steve out mid-QoE.
  Tightening to the allow-list is a separate *policy* call, not part of a security fix.

**2. A gate inside a conditional is not a gate.** SPM Results had its include nested in `<cfif showComm>`, so
**`?ZCustType=municipal` routed straight around it** — a forged cookie got **200 / 19,291 b**. Hoisting it
above every branch made all three paths 403, and incidentally fixed a second finding: the municipal CSV export
called `csvField()` from that same skipped include. → [[rc-04-spm]]

🧭 **Audit rule that follows:** don't ask *"does this page include the gate?"* — ask **"is the include
unconditionally reached on every parameter combination the page accepts?"** Enumerate the `?param` branches and
probe each with a garbage cookie. Same pass also turned up a stack-trace leak (`?page=abc` rendering
`coldfusion.runtime` + `D:\home`) and reflected XSS — **an unvalidated URL param is the shared root of all three.**

⚠️ **Encode at the SINK, and know which sinks must stay raw.** Fixing the XSS, the first sweep tried to encode
all 33 uses of `URL.search` — but **14 are inside `cfqueryparam`, where the raw value is required** (encode it
and search silently stops matching) and where there was never an injection risk. Three variables, not one:
`searchURL` (URLEncodedFormat) for query strings · `searchAttr` (EncodeForHTMLAttribute) for HTML attributes ·
raw for bound SQL parameters only.

## 🚩 THE STANDING RULE — gating a surface breaks its headless consumers
When you add/extend an auth gate on a data page, **every headless/automation fetch of that page starts getting 403'd — silently.** Grep for every `fetch()`/`curl`/`view.sh` hit of the surface and **re-authorize them in the same change.**
- **How to re-authorize an automated fetch:** send the bot identity cookie → `Cookie: ZUserID=376`. (Node: `headers:{ ..., 'Cookie':\`ZUserID=${S.serviceUserID||376}\` }`.)
- **Proven incident (2026-07-15):** the July-12 gate silently 403'd the anomaly-monitor's `bookedPacing()` POST to `Dashboard-RevenuePerformance.cfm` → the COO daily email showed *"📅 Forward pace unavailable today (HTTP 403)"* for days. Same bug in `revenue-block.js` (per-salesperson + Nate rollup revenue snapshot). Fix = `Cookie: ZUserID=376` in `monitor.js` + `revenue-block.js`; verified HTTP 200 + real data. (`m2-revenue.js` has the same cookie-less pattern but is unused legacy.)
- Symptom to watch: a report line that reads "unavailable / N/A" instead of a number, with the underlying error swallowed into a fallback string. → grep the report text for `unavailable|403|N/A` after any security deploy.

## 🐛 `Dashboard-Access.cfm` — the SEARCH BOX misses ~80% of staff (found 2026-07-28)
Granting access to Celeste Armenta exposed this. The add-user search runs:
`WHERE FullName LIKE %q% OR LoginName LIKE %q%` — but **staff names live in `flow.Users.Desc1`, and
`FullName` is NULL on 272 of 339 users (only 67 populated).**
- Searching **"Celeste" returns 0 rows.** Searching **"carmenta"** (her login) finds her — UserID **209**.
- Same cause makes the granted-list display fall back to `LoginName`, so people show as
  `carmenta@gstsinc.com` rather than "Celeste Armenta".
- **Workarounds today:** search by the **login/email prefix**, or use **"Add by UserID"** directly.
- **Fix when we touch it:** add `Desc1` to both the search predicate and the display
  (`ISNULL(NULLIF(Desc1,''), ISNULL(FullName, LoginName))`), and order by the same expression.
- ⚠️ `HermanRO` **cannot read `Workbench.dbo.DashboardAccess`** (error 229 — the grant covers
  `Workbench.dbo.SalesGoal` but not this table), so I cannot verify the current roster from SQL; read it
  off the page. Object-level grants here are per-table, not per-database.
- Bootstrap confirmed in source: **UserID 9 = Jason Wade** and the Arbor Helper assistant are always
  allowed, so the list cannot lock the admin out. (`376` = Ulises Mario Muniz.)

## 🔴 3. The bootstrap allow-list IS the hole — and the auth CHECK cannot see it (2026-07-30)
The gate's bootstrap (`9` = Jason, `376` = bot) **always passes, by design**, so the admin can never be
locked out. But **`9` is a guessable integer and TRIM IT only checks the cookie EXISTS** — so
`curl -H "Cookie: ZUserID=9"` (no password, no session token) returns **200** on a page gated to the COO,
on a **publicly-resolvable host**. The gate correctly refuses user 340 while admitting a forged 9.

⚠️ **`verify-build.sh`'s auth group cannot detect this.** It probes `ALLOW_UID=9` → 200 and
`DENY_UID=340` → 403 and reports PASS — which proves *one real user cannot see another's page*, and says
**nothing about an attacker**, because 340 is a different **user**, not a **forged identity**. I read
`PASS 20 / FAIL 0` and wrongly told the Skipper deal figures were gated.
- 🔧 **An auth probe must include a forged/garbage cookie case** (`ZUserID=99999999`, and `9`-without-session),
  not merely a second legitimate user.
- Root fix is **session binding, not a page patch** (Skipper + Jordan). → [[play-public-cookie-forgeable]]

## Related
- [[play-public-cookie-forgeable]] — **the exposure this gate does not close**, and the standing rule that
  no deal material may render on play.
- [[claim-verification-discipline]] — why "the check passed" was not evidence.
- [[anomaly-monitor-suite]] — the consumer that broke + was fixed.
- [[play-dev-access]] — the play box these dashboards + the monitor run against.
- [[arbor-core-v15-auth]] — the *other* (Track-2) gate; don't conflate.
