---
title: TrimIT DB gotchas — dual-webroot & DB-driven menus
type: fact
domain: env
tags: [infra, trimit, coldfusion, deploy, gotcha, appforms, webroot]
links: ["[[play-dev-access]]", "[[workbench-play-db]]"]
updated: 2026-07-02
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

## Related
- [[play-dev-access]] — where you test these changes before dev deploy.
