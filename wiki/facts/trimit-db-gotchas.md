---
title: TrimIT DB gotchas — dual-webroot & DB-driven menus
type: fact
domain: env
tags: [infra, trimit, coldfusion, deploy, gotcha, appforms, webroot]
links: ["[[play-dev-access]]", "[[workbench-play-db]]", "[[trimit-investor-case]]", "[[only-trustworthy-data]]"]
updated: 2026-07-24
---

# TrimIT DB gotchas

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

## ⚠️ Dual-webroot shadow
- `C:\ColdFusion2023\cfusion\wwwroot\GSTS\` can **OVERRIDE** `D:\…\GSTS\` for some files.
- → After deploying any existing dashboard, **render-verify the served output** and **deploy to BOTH roots if shadowed**.
- Known shadowed: `Dashboard-SalesPipeline`, `Dashboard-CustomerLeads`, `Dashboard-RevenuePerformance`.

## 🧭 TrimIT left-nav / menus are DB-driven
- `dbo.AppForms` (item) + `dbo.MyAppForms` (per-user grant).
- **Add a page to a menu = INSERT both** (DB change → test play, devs deploy).
- **Not grep-able in the web root.**

## ⏱️ Dead / untrustworthy fields — do NOT build a metric on these (measured 2026-07-24)
- **Bid-chain timestamps are largely BACK-ENTERED.** RFP + proposal-sent + go-ahead are frequently stamped within the same second (12% within 60s, 25% within 1hr; 97% of sent→approved same-day). Any turnaround/aging metric must **exclude the back-entered set** first — an unfiltered median reads ~2d when the real one is **6d**.
- **`Invoices.InvoiceDate` is a BACKDATED accounting date** (median 3 days *before* completion). Measure billing speed off **`Invoices.Created`**.
- **`Invoices.StatusDefID` is dead since ~2014** → the ERP **cannot tell paid vs open**; AR truth lives in Dimitry's emailed xlsx. DSO is not measurable in TRIM IT.
- **`Invoices.CreatedByID` is always 11** (Rosanna Baez — an inactive **service account**, `Role001='Generate Invoices'`) on all **50,283** invoices since 2006. Never read it as "who did this." ⚠️ **There is NO termination date for that account** — `StaffMembers` (ID 15 → `UserID 11`) has `StatusDefID 377 = Inactive` but **`EndDate` is NULL**. The "left ~4 years ago" line that reached Deck A was never verified and the DB cannot support any year. Say **"a former employee"**, never a tenure.
- **`RFPs.NeedInventory` / `NeedSiteWalk` = 0 of 22,369**; `EstValue` empty. Those flags answer nothing.
- **`ParentWorkOrderID` is NULL on revised WOs** → the revised-WO → invoice link is severed; you can't systematically prove completed work was billed.
- Real handoff counts DO exist and are trustworthy: **`dbo.RFPActions`** (27,865 actions / 5,033 bids = 5.6 per bid).
- Full context + what each of these does to the numbers → [[trimit-investor-case]].

## 🧨 Column traps that return clean, plausible, WRONG answers (2026-07-26)
- **`CrewSheets.Total` is EMPTY on every row — production dollars live in `CrewSheets.ActValue`** (`CompletedDollars` carries the same figure). Querying `Total` makes every crew sheet look zero-revenue and every zero-dollar sheet look orphaned. Cost me a wrong conclusion before I caught it.
  ⚠️ **Corrected 2026-07-26: this note used to say `CrewSheets.NetTotal` — that column DOES NOT EXIST on CrewSheets.** `NetTotal` lives on `Invoices`, `WorkOrders`, `CrewNamePeriods` and others, never the crew sheet, so the "fix" would have failed with an invalid-column error at best. Verified basis: 6 mo to 2026-07-22 = **4,837 sheets · $10,810,918 `ActValue` · 85,351 `ActHours`**.
- **`Proposals` has NO `CreatedByID`** — the creator is **`Proposals.UserID`**. **`GoAheads` has no creator column at all.** So "who entered this" is answerable for RFPs and proposals, *not* for go-aheads. Never say "neither record has a creator field."
- **Municipal vs commercial = `ProjectGroups.ProjectGroupDefID = 11`** (municipal), commercial = `NOT EXISTS` that row. Join `CrewSheets → WorkOrders → Projects`.
- **`RFPActions.UserGroupID` IS the traveler step** (`UserGroups`: 3 Inventory · 4 Pricing · 5 Proposal · **11 Review = inventory QC** · 17 Prep · 18 Map · 27 Re-inventory). **A repeat visit to the same group on one RFP = a measurable return trip** — this is how the bid rework loop became countable. → [[trimit-investor-case]]
- **The real bid population is 5,033** (trailing 12 mo to 2026-07-22, reached a sent proposal). Not 5,004 / 5,015 / 5,145 — those were mixed windows. Back-entry: 810 within 60s (16.1%), 1,343 within 1 hr (26.7%).


## Related
- [[play-dev-access]] — where you test these changes before dev deploy.
