---
title: Vendor Field App build (dev server — Travis/Jordan)
type: project
domain: work
track: 1
status: active
tags: [vendor, dev-server, fieldapp, coldfusion, assessment, trimit, diligence]
applies: ["[[two-track-confidentiality]]", "[[only-trustworthy-data]]"]
links: ["[[play-dev-access]]", "[[gsts-operating-plan-2026-2031]]", "[[bid-process-reengineering]]", "[[division-of-labor]]", "[[dev-handoff-contract]]"]
updated: 2026-07-24
---

# 🏗️ Vendor Field App build (dev server)

**One-liner:** Travis (vendor, paid directly by GSTS) + Jordan Kim have been building a **sales-workflow / Field App rebuild** on `dev.greatscotttreeservice.com` — a host we have **no SSH on and were never given access to**. Assessed end-to-end 2026-07-24.
**Why it matters:** it is the *inherited starting point* for Phase 1 of the [[gsts-operating-plan-2026-2031]] — **Phase 1 is NOT greenfield.**

## 🚨 First: three hosts, not two
`dev` ≠ `play`. See the 3-host table in **[[play-dev-access]]**. I originally assessed the vendor's work from the *play* box (whose webroot folder is merely *named* `dev.greatscotttreeservice.com`) and wrongly reported they'd built almost nothing. Corrected 2026-07-24.
- Reachable read-only over HTTP: `view.sh` with `BASE=https://dev.greatscotttreeservice.com/GSTS`; auth is a `ZUserID` URL param (`&ZUserID=9`).

## ✅ The verdict — it's a genuine rebuild, not a wrapper
Walkthrough done by a browser-driven Claude session (prompt had to be **chunked** — the first attempt blew 1.4M tokens).
- **8-step Company/Project wizard** fully bound to live records (populated selects, inline `ⓘ` help, Back / Save / Save-&-Next, fiscal-year lock).
- **Boundary/vertex editor** (per-shape zoom, draggable vertices, complete Edit-Area modal, layer persistence).
- **Artwork/Print layout designer** (7 paper sizes, 13 toggleable printed items, real legend counts).
- **Field App BETA is the strongest screen** — satellite view, **WebGL marker layer** (`gsts-lib/gstsWebGLMarkerLayer.js`), working filter rail, deep asset Edit modal (Details/Images/Observations).
- Its **own JSON API** under `FieldApp/api/map/` and its own CSS/JS — architecturally new code.
- **Zero application JS errors and zero 500s** across every page touched. The code is clean at runtime.
- **Wrapped (the exceptions):** the **Artwork tab** = new chrome around **8 legacy `Tan/Wizard-Map-*.cfm` iframes**; the **Pricing Worksheet** = the old WebPortal page in the new skin (lives outside the app at `/gsts/PricingWorksheetDashboard.cfm`).

## ❌ Four data defects sitting in the critical path
The build is held back by **data handling, not missing features** — each makes a working subsystem *present* as broken:
1. `api/map/Field.MapSetup.Data.cfm` returns `labelLat`/`labelLng` as **empty strings** → plotted at **0,0** → the map auto-fits California-to-the-Atlantic → opens at world zoom.
2. The **"Fit" button is inert** — no recovery even with the 0,0 layers hidden.
3. **Saved map views unset** → Artwork *and* Print inherit the ocean. **The printed map — the deliverable — renders the Atlantic.**
4. **Inventory effectively empty:** Field App BETA shows **6 located assets** where the Species Summary Legend totals hundreds.

## ⚠️ Other gaps
- **No tablet breakpoint.** `main.css` has exactly one media query (`max-width: 767.98px`); at ~800px the desktop layout applies with **600px of fixed chrome** (350px sidebar + 250px nav). It's a desktop tool — a real gap against the field premise.
- **"Add Contact" inserts a blank record before you type** (`Field.Contact.Create.cfm` writes, then redirects to Edit).
- Dev app links **attachments to PROD storage** (`www.greatscotttreeservice.com/gsts/Storage/Data/…`); one legacy row still holds a Windows path `\gsts\Customer\Maps\8999\`.
- Project Notes flag toggles have **no visible on/off state** and are state-changing GETs.
- Setup's three Inventory Actions are bare links to legacy scripts with **no confirmation step**.

## 🎯 THE FINDING (this is the point)
**It's verification discipline, not capability — nobody opened the tool and looked.** Four fixable coordinate/view defects have made four subsystems look broken for weeks. Written up as **§3B** of the operating plan.
⇒ **Phase 1 = inherit + finish, not rebuild. Recover the source before any vendor change.**

## 🧑‍💼 The people question
- **Jordan Kim** — $143,325 base / **~$186K loaded**; Scott wants him out ASAP. **Travis is the vendor who does the actual work and GSTS pays Travis directly** (contract w/ min spend) → capability is not at risk. Joe = Joseph Young ($26/hr, UserID 363).
- ~$186K is a **run-rate EBITDA item** — against TTM adj EBITDA $3.80M vs the $4.1M floor it closes **62% of the gap**. → tell Steve so QoE catches it ([[gsts-adjusted-ebitda]]).
- Before any notice: **credential/asset inventory + recover in-flight work product** (source, dev-box access). Jordan has also been sitting on the prod read-only firewall ask since June ([[prod-db-access-blocked]] · `prod-db-access-ask-JORDAN.md`), mischaracterized as "Amazon blocking AI."

## 🧹 Owed
- Cleanup: the browser session accidentally created a **blank contact ContactID 222090** (Optimum) on dev — delete it.

## Related
- [[play-dev-access]] · [[gsts-operating-plan-2026-2031]] · [[trimit-investor-case]] · [[dev-handoff-contract]]
