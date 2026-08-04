---
title: TRIM IT Menu Cleanup (native left-nav)
type: project
domain: work
track: 1
status: active
tags: [trimit, menu, appforms, cleanup, landing-page, audit, dead-links]
applies: ["[[repair-contract]]", "[[db-repair-contract]]"]
links: ["[[v15-landing-page]]", "[[trimit-deep-audit]]", "[[dashboard-metric-standards]]"]
updated: 2026-08-04
---

# TRIM IT Menu Cleanup (native left-nav)

**One-liner:** Prune / dedupe / re-home the current TRIM IT left-side navigation menu (the Jason Wade profile's ~119 links) based on a re-verified "what works / what doesn't" pass — start by removing the confirmed-dead links.

**Ask (Skipper, 2026-08-04):** "look at our TRIM IT menu audit of what works and what doesn't … start cleaning up the landing page." Confirmed direction = the **native TRIM IT menu** (not the V1.5 hub). Re-verify first, then save the plan.

## Source material
- **Menu Audit PDF** (May 8, 2026): `arbor-stack/Arbor AI/A.I/TrimIT Menu Audit — Jason Wade Profile.pdf` — full walk of 13 top-level categories / ~119 links. Extracted text: `/tmp/menuaudit.txt` (regenerate via `uv run --with pypdf`).
- **This note = the 2026-08-04 LIVE re-verification** (PDF was 3 months stale; several items had degraded further).

## 🔑 Structural fact — how the menu is stored
- Menu = **`dbo.AppForms`** (297 forms; `Desc1`=label, `ObjectPath`=URL) linked per-profile via **`dbo.MyAppForms`** (10,404 rows; `AppFormID`→`ProfileID`, `SeqOrder`).
- **`AppForms`/`MyAppForms` live in the GSTS db → nightly DROP+RESTORE on play → menu edits DO NOT persist on play.** So this cleanup is a **PROD change Jordan applies** (or test on a frozen `GSTS_cleanup` copy). Workflow: Gilligan drafts a reviewed remove/hide/rename change-set → Skipper approves → Jordan runs on prod. Per [[db-repair-contract]].
- Remove-from-menu = delete/disable the row(s); leaving the `.cfm` on disk is fine.

## ✅ RE-VERIFIED LIVE 2026-08-04 (HTTP test, ZUserID=9, on play — every status from a query run this session)

### 🔴 Confirmed BROKEN → remove (9)
| AppFormID | Label | ObjectPath | Live status |
|---|---|---|---|
| 1190 | CU$Schedule$New | CU$Schedule$New.cfm | **404** |
| 1101 | CU$Schedule$Thin | CU$Schedule$New$Thin.cfm | **404** |
| 1071 | CU$Schedule | CU$Schedule.cfm | **timeout** (000/15s) — base page now hangs too |
| 1002 | Completed Work Orders | Synch.WorkOrders.All.NowComplete.cfm | **timeout** (000/25s) — runaway query |
| 1014 | Should Be Billed | ReportDev/Report$ShouldBeBilled.cfr?ZPeriodID=94 | **timeout** (000/20s) — was ~11s in May, now dead |
| 1178 | Equipment Repair List | http://24.199.20.236:8021/... | **dead host** (000/12s) |
| 1155 | Prior Year (JAN-JUN) | http://24.199.20.236:8021/... | **dead host** |
| 1163 | Cameras | http://24.199.20.236:8021/gsts/Cam.cfm | **dead host** (audit missed this one) |
| 1148 | Production Page | http://24.199.20.236:8021/gsts/Mobile8021/... | **dead host** (audit missed this one) |

**Bare-IP host `24.199.20.236:8021` is fully unreachable** — every menu item on it is dead.

### 🟠 Loads but degraded
- **Marketing Clusters / Cluster Definitions** (1246 / 1247, both `Maint-ClusterDefs-Page.cfm`) — 200 but **8.8s**; embedded **Google Fusion Tables map is dead** (Google killed Fusion Tables 2019).
- **Exec$Periods$Overview** (100) — 200 but **5.9s**; dev-style name.

### 🧹 Works, but dev-junk → hide/rename (don't delete)
- 1249 `CU$Schedule$Scope`, 1255 `CU$Schedule$Scope$V2` — 200 (dev names)
- 1046 `PVC$Performance` (+ 1033 `PVC Performance Reports`, same path) — 200

### ♊ True duplicates (identical ObjectPath confirmed in AppForms) → keep one canonical
- **Approved GoAheads "7 Days" (1050) == "9 Days" (1192)** — literally the same `Report$ApprovedGoAheads$Style003.cfr` (30-day = 1189 is genuinely different). The 7/9 distinction is meaningless.
- Marketing Clusters (1246, Find) == Cluster Definitions (1247, Executive).
- Inventory Pricing Guide appears under Solve + Close (same path — IDs not yet captured; grep `Maint.InventoryCategories.Pricing.cfm`).

### 🔧 Loads but hardcoded (data, not broken) → parameterize from session
- 1037 Green Waste → `ZYear=2018` (stale).
- 1117 TPH (Last Week) → `ZUserID=9` — **every user gets Jason's report**.
- 1014 Should Be Billed / 1044 Should Be Scheduled → `ZPeriodID=94`.

### 🟠 Cross-env hardcoded prod URLs in the PLAY menu → make relative
(All start `https://www.greatscotttreeservice.com/gsts/…` — on play they bounce testers to prod.)
- 1226 *** Contract Billing ***, 1254 View Schedule Board, 1261 Production Forcast Report (also typo "Forcast"→"Forecast"), 1253 Inspections (AM), 1252 Inspections (JW), 1250 Job List - Adam, 1256 Watering App.

### ✍️ Typos / cosmetic
- "Job List - AAll Sale Reps" → "All Sales Reps"; "Forcast" → "Forecast"; `***` prefixes on Commercial/Contract Billing.
- Widespread HTML `<title>` mismatches (shared templates) — 15+ pages; cosmetic (browser tab/bookmark only), on-page content is correct.

## ▶️ Resume / next steps
1. **Remove batch (9 broken)** — draft the AppForms/MyAppForms change-set (delete or disable those AppFormIDs) as a reviewed list for Jordan → Skipper approves → prod.
2. Then queue, in order of value: **dedup** (merge 7/9-day GoAheads etc.) · **hide dev-junk** (CU$Schedule$Scope*, PVC, Exec$Periods$Overview) · **fix cross-env URLs** (make relative) · **parameterize hardcoded IDs** (TPH ZUserID=9 is the worst) · **typos/`***`**.
3. Open question for Skipper: **remove** the broken links outright, or **fix** the fixable ones (e.g., Should Be Billed's runaway query) — decide per-item.
4. ⚠️ Menu edits are prod-only (nightly restore on play). Consider testing the change-set on a frozen `GSTS_cleanup` copy first (same pattern as [[trimit-deep-audit]] cleanup).
