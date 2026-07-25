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
- **`Invoices.CreatedByID` is always 11** (Rosanna Baez — an inactive **service account**, `Role001='Generate Invoices'`) on all 50,233 invoices since 2006. Never read it as "who did this."
- **`RFPs.NeedInventory` / `NeedSiteWalk` = 0 of 22,369**; `EstValue` empty. Those flags answer nothing.
- **`ParentWorkOrderID` is NULL on revised WOs** → the revised-WO → invoice link is severed; you can't systematically prove completed work was billed.
- Real handoff counts DO exist and are trustworthy: **`dbo.RFPActions`** (29,063 actions / 5,145 bids = 5.6 per bid).
- Full context + what each of these does to the numbers → [[trimit-investor-case]].

## Related
- [[play-dev-access]] — where you test these changes before dev deploy.
