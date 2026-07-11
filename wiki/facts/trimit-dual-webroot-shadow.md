---
title: TRIM IT dual-webroot shadow (C:\ overrides D:\)
type: fact
domain: env
tags: [infra, coldfusion, play, webroot, gotcha, deploy]
links: ["[[play-dev-access]]", "[[repair-contract]]", "[[v15-landing-assistant]]"]
updated: 2026-07-11
---

# 🥷 TRIM IT dual-webroot shadow — C:\ can override D:\

**The trap:** the play box runs **Adobe ColdFusion 2023**. CF serves a page from its OWN webroot **`C:\ColdFusion2023\cfusion\wwwroot\GSTS\`** IN PREFERENCE to the IIS site path **`D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\`**.
- File **exists in the C:\ shadow** → CF serves that copy (often STALE) and your D:\ edit does nothing.
- File **absent from C:\** → CF falls back to D:\. So **NEW files work from D:\**, which masks the problem and sends you chasing caches.

**How it bit us (2026-07-11):** editing `Dashboard-RevenuePerformance.cfm` on D:\ had zero effect on the served page; ~40 min lost ruling out CF trusted cache (was OFF), IIS/HTTP.sys output cache (app-pool recycle + cache-bust didn't help), and a full CF service restart (didn't help) — because the served file was a **6/27 C:\ shadow** the whole time. New files (AI-Chat.cfm) had worked, which is exactly the misleading signal.

## Rule (do this)
1. When a `.cfm` **EDIT** doesn't show in the SERVED output but a brand-new file would: **check the shadow FIRST** — `powershell "Get-ChildItem C:\ -Recurse -Filter <name> -EA SilentlyContinue"`. ⚠️ plain `where /r C:\ <name>` aborts on the first permission-denied dir and falsely prints "not found" — use the PowerShell form.
2. If shadowed, **deploy to BOTH webroots** (C:\ shadow + D:\), backing up the C:\ copy first (→ `...\GSTS\Jasonsrepairs\<name>.CSHADOW-bak-<ts>`).
3. Always **render-verify the SERVED output** ([[repair-contract]]), never trust the file-on-disk.

## Known shadowed GSTS .cfm (2026-07-11) — 8 files
`Dashboard-RevenuePerformance.cfm` (now synced) · `Dashboard-CustomerLeads.cfm` · `Dashboard-SalesPipeline.cfm` · `Exec$Periods$Overview.cfm` · `Exec.MarketFocus.Focus.cfm` · `Export-CustomerList.cfm` · `Diag.Batch9.Candidates.cfm` · `Diag.PeriodOverview.20260529.cfm`.
⚠️ **Audit pending:** for each, diff C:\ vs D:\ — where they diverge, the "live" page is the (possibly stale) C:\ copy and any past D:\-only edit never went live. This may affect prior ship-log items touching these pages.

## Related
- [[play-dev-access]] — the play server + how we connect. · [[repair-contract]] — render-verify-the-served-output rule. · [[v15-landing-assistant]] — where this was discovered.
