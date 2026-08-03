---
title: PROD is readable over the WEB — two proven observe-only paths
type: fact
domain: env
tags: [prod, trimit, data-access, dashboard, playwright, read-only, revenue]
links: ["[[anomaly-monitor-suite]]", "[[dashboard-auth-gate]]", "[[prod-db-access-blocked]]", "[[gstsreadonly-prod-dsn]]", "[[dev-browser-access]]", "[[june-invoicing-lag]]", "[[trimit-server-topology]]"]
updated: 2026-08-03
---

# 🔓 Production TRIM IT is an open, proven READ source (over the web)

**Proven 2026-08-03.** Direct SQL to prod is still blocked ([[prod-db-access-blocked]]) and the token'd JSON
endpoint still reads the play mirror ([[gstsreadonly-prod-dsn]]) — but the **production website itself serves
live production figures**, and that had been missed for weeks. Two observe-only paths, both working:

## 1. Dashboard POST (no login wall)
`POST https://www.greatscotttreeservice.com/gsts/Dashboard-RevenuePerformance.cfm`
- Send the Arbor-Helper service cookie **`ZUserID=376`** ([[dashboard-auth-gate]]) + a form body:
  `startDate` · `endDate` · `groupBy` · `revenueSource` · `territory` · `workType` · `monthlyGoal` ·
  `targetTPH` · `browserToday`. Returns **HTTP 200** with real produced / TPH figures.
- ⚠️ **The dashboard IGNORES URL date params.** Dates must go in the POST body (or, in a browser, be typed
  into `#startDate`/`#endDate` followed by **Apply**). With neither, it silently returns the **current month**.

## 2. Browser (Playwright)
`~/.local/devscout/prodnav8.js` — logs in as **`jwade`** (`~/.openclaw/.secrets/prod-login.json`), drives the
date inputs, reads innertext. Same driver family as [[dev-browser-access]]; use it for anything the POST
won't render. **Observe-only discipline applies** — never fire New/Create/Save controls.

## ⭐ The distinction that matters
The **dashboard** reads the **live prod DB**; only the JSON **endpoint** (`/GSTS/api/MonitorData.ReadOnly.cfm`)
is stuck on the play mirror, because that file lives on the play box. So *scraping the prod dashboard is
genuinely live production data*, not a mirror — which is what unblocked the Skipper's interim daily pulse
([[anomaly-monitor-suite]]) without waiting on a deploy.

## ⚠️ Limits — know these before building on it
- **Headline only.** Overtime-by-person, contract burn-down and `salesperson_jobs` are NOT on the dashboard —
  they still need the JSON endpoint deployed to prod.
- **Early in a month the volume line lies.** `jobs/hrs` counts *scheduled* scope while TPH counts *completed*
  hours — do **not** read produced ÷ hours as TPH until the month matures.
- **It is a PRODUCTION dashboard, not an invoiced one** — default source *"True Produced Work (day sheet +
  schedule)"*, and there is **no invoiced option on it at all**. Invoiced lives only in the invoice register /
  Steve's spreadsheet. → basis rules in [[june-invoicing-lag]].
