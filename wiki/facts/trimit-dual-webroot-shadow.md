---
title: TRIM IT dual-webroot shadow (C:\ overrides D:\)
type: fact
domain: env
tags: [infra, coldfusion, play, webroot, gotcha, deploy]
links: ["[[play-dev-access]]", "[[repair-contract]]", "[[v15-landing-assistant]]", "[[trimit-deep-audit]]", "[[arbortools-net-vendor-saas]]", "[[rc-02-revenue-performance]]"]
updated: 2026-08-04
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

## ⚠️ 2026-08-03 — IT BIT AGAIN (RevenuePerformance Invoiced-tab build), and it clarifies the 08-01 note
Building the new Invoiced source on `Dashboard-RevenuePerformance.cfm`: edited the **D:\ copy, md5-verified it, cleared cfclasses, and did a full CF service restart** — the served page **never changed** (~1h lost) until I ALSO deployed to the **C:\ shadow** `C:\ColdFusion2023\cfusion\wwwroot\GSTS\`. Then it went live.
- **Reconciles the ⭐ 08-01 line below ("nothing on C: is served by the LIVE site"):** that was strictly about **IIS binding** — IIS binds `play.…` → D:\. But the **ColdFusion application server resolves the physical `.cfm` from its OWN webroot first**, so for any page that exists in the C:\ shadow, **C:\ is what actually gets compiled and served.** The practical rule (deploy to BOTH) is unchanged and was reconfirmed the hard way. Don't read "IIS binds D:\" as "C:\ is inert for .cfm" — it isn't.
- ⚠️ **PROD almost certainly has the same split** — the prod deploy instructions for RevenuePerformance (and any shadowed file) **must hit both roots.** → LESSONS 2026-08-03.
- Backups from the build: `...\GSTS\Jasonsrepairs\revperf-invoiced-20260803-151506\` (IIS copy + `.CFROOT-SHADOW.cfm`).

## Known shadowed GSTS .cfm (2026-07-11) — 8 files
`Dashboard-RevenuePerformance.cfm` (now synced) · `Dashboard-CustomerLeads.cfm` · `Dashboard-SalesPipeline.cfm` · `Exec$Periods$Overview.cfm` · `Exec.MarketFocus.Focus.cfm` · `Export-CustomerList.cfm` · `Diag.Batch9.Candidates.cfm` · `Diag.PeriodOverview.20260529.cfm`.
✅ **Audit CLOSED 2026-08-01:** all **6 shared dashboard files were diffed C:\ vs D:\ and MATCH** (identical MD5 + dates) — RevenuePerformance, CustomerLeads, Export-CustomerList, dashboard-auth-gate, dashboard-access-check, SalesPipeline. **Nothing was silently stale.** The standing risk is unchanged: keep deploying to BOTH webroots or they drift again.

## 🗺️ Precise picture of the two drives (verified 2026-08-01, [[trimit-deep-audit]])
The framing above needs one correction the Skipper asked for directly:
- The **FOLDER** `C:\ColdFusion2023\cfusion\wwwroot\GSTS\` is exclusively **ours** (19 files — our dashboards, repairs, backups). But the **C: drive itself is the ColdFusion install**, with system folders (`CFIDE`, `cf_scripts`, `WEB-INF`) and a non-ours `restplay` folder.
- ⭐ **Nothing on C: is served by the LIVE site.** IIS binds only `play.greatscotttreeservice.com` → **D:\** (the real TRIM IT, 8,645 `.cfm`) plus `playapi`. Our C: `GSTS` is a **shadow copy under ColdFusion's built-in web server**, not the live pages.
- `restplay` (86 files) = an inert static AngularJS demo app (index/home HTML + a Japanese locale), same 2026-04-25 bulk-copy timestamp as the vendor SaaS → another clone artifact, harmless.
- The vendor's own SaaS lives at `D:\home\arbortools.net\wwwroot\` and is likewise inert here → [[arbortools-net-vendor-saas]].

## Related
- [[play-dev-access]] — the play server + how we connect. · [[repair-contract]] — render-verify-the-served-output rule. · [[v15-landing-assistant]] — where this was discovered.
