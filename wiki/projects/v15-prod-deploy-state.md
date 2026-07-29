---
title: V1.5 prod deploy state — what production is still missing
type: project
domain: work
track: 1
status: active
tags: [deploy, prod, trimit, travis, jordan, batch, outstanding]
applies: ["[[dev-handoff-contract]]", "[[deploy-playbook]]", "[[trimit-dual-webroot-shadow]]"]
links: ["[[rc-02-revenue-performance]]", "[[rc-04-spm]]", "[[steve-diligence-dashboard]]", "[[revenue-goal-close]]", "[[trimit-server-topology]]", "[[v15-landing-assistant]]", "[[sales-cockpit]]", "[[dashboard-auth-gate]]", "[[production-perf-future-dated-crewsheets]]", "[[timekeeping-live-nov-2025]]", "[[crewsheet-acthours-is-the-estimate]]"]
updated: 2026-07-29
---

# V1.5 prod deploy state — what production is still missing

**One-liner:** The single running inventory of everything prod does not yet have, so the next handoff is one
batched trip instead of five billed ones.
**Status:** 📦 **SHIPPED 2026-07-28 05:57 UTC** — the whole batch went to Jordan (jkim) CC jwade as
`TRIMIT-BUGFIXES-20260728.zip` (md5 `b66cc5b11118c1353d7064e5b96323a2`, 136,297 b, **17 entries**).
Sections A–G all closed before sending; nothing rejected.
**📁 Canonical (keep current there, not here):** `arbor-stack/predeploy-pkg3/OUTSTANDING-FOR-PROD.md`
· shipped manifest `predeploy-pkg3/shipped/MANIFEST-SHIPPED-20260728.md`
**▶️ Resume:** Jordan to install (DB script first, then files, then clear `WEB-INF\cfclasses`) and confirm on prod.

## 📦 What shipped (2026-07-28)
- **8 web files** — `Dashboard-RevenuePerformance.cfm` · `Executive$Sales$Unattributed.cfm` ·
  `Executive$ClosePercentage$Detail.cfm` · `SalesProductionMeeting$`{`Production`,`Drill`,`Results`}`.cfm` ·
  `FinancialReport/FinancialReport`{`Dashboard`,`Export`}`.cfm`.
- **1 DB script** — `database\01-create-workbench-objects-PROD.sql` (the SPM Results crash fix, → [[rc-04-spm]]).
- **`ui-files\`** — the drifted-ahead shell files as a **verify-then-copy** set: `install-this\` + `baseline\`
  + unified `diffs\` (iPad z-index, header overlap), because they are shared shells — apply the diff, never overwrite.
- **`START-HERE.md`** as the single entry point.
- ⚠️ Only `Dashboard-RevenuePerformance.cfm` also needs the **CF shadow** webroot; the other 7 are D: only
  (verified absent from `C:\ColdFusion2023\cfusion\wwwroot\GSTS`). → [[trimit-dual-webroot-shadow]]

### How the package was made vendor-safe (the reusable part → [[dev-handoff-contract]])
**Skipper's directive:** *"files, descriptions of the fixes and instructions, no fluff"* and
*"remove the production is behind references."* A handover reads as a **work order, not an audit of what
someone else missed.** Concretely: internal `MANIFEST.md` pulled (kept at
`release-candidates/NEXT-DEPLOY-20260724/`), folders renamed `patches-sectionC\`→`ui-files\` and
`prod-should-currently-be\`→`baseline\` (**the old names asserted a claim about prod in the folder name itself**),
`START-HERE.md` rewritten neutral.
- **Leak scan is now a packaging step** — every text file *and filename* scanned for internal wording. It caught
  a CFML comment reading *"removed … per Skipper … backup in Jasonsrepairs"* inside a vendor-bound file; the
  reword was **proven comment-only** by diffing against the Skipper-confirmed version, and play was updated to match.
- **Every checksum and byte count generated from the staged folder and asserted** — a hand-typed 66,927 for a
  66,595-byte file got through once; the hash was right, so nothing downstream would have caught it.

## Sections A–G at ship time
- **A** package-3 code · **C** drifted play files · **D** the DB ask · **G** suite-audit fixes → **all in the zip.**
- **B — the 36-defect gate: ✅ CLOSED 2026-07-27** (31 fixed/closed, 5 deferred with recorded reasons).
- **E — CONFIG: nothing outstanding** (the whole section had been stale).
- **F — not shipping, decided:** Arbor Helper (*"not ready"*) · `Dashboard-V15Home.cfm` (pulled 7/27, its only
  delta is the Arbor Helper hook) · [[revenue-goal-close]] (D-1 ships one view it needs, not the subsystem).

## 📦 Packages 4 and 5 — the crew-sheet date fix (2026-07-28)
The `WorkDate` → `Calendars.CalDate` rebind (→ [[production-perf-future-dated-crewsheets]]) went out as its
own numbered packages because package 3 was already in the developer's hands.
- **Package 4 — SHIPPED, CLOSED.** `TRIMIT-PRODUCTIONPERF-DATEFIX-20260728.zip`, md5
  `cbfe29905ba0c053c513cf44ab800f43`, 12,530 b — `ProductionPerf.data.cfm` (`d79b027f…`) +
  `Dashboard-ProductionPerf.Day.cfm` (`9ef12414…`). **Both must deploy together**; check 4 in its `START-HERE.md`
  (the day drill must sum to its period row) is what catches a half-deploy. Recorded in `predeploy-pkg4/SHIPPED.md`.
- **Package 5 — staged, HELD.** `TRIMIT-EXECSALES-DATEFIX-20260728.zip`, md5
  `45186d1f96bb12b9ec42d55079f602f8`, 13,381 b — `Executive$Sales$Detail.cfm` +
  `Executive$Sales$Detail$Customer.cfm`. Emailed to the Skipper to forward; **not sent to the developer by me.**
  Its lead check is *"the page returns rows"* — the symptom a user would actually report, since on the old
  basis crew 38 / June 2026 rendered **empty**.
- 📌 **Rule learned: once a package is forwarded it is FROZEN.** I kept appending to pkg4 (2 files → 4) after
  the Skipper had already sent the 2-file version, which would have left our record disagreeing with what the
  vendor actually holds. New work opens the next number even for the same defect class. → [[dev-handoff-contract]]
- ▶️ **Still open on this defect:** `Executive$Sales$ByCrewName.cfm` gates a metric on
  `cs.WorkDate >= TIMECLOCK_GOLIVE` — changing the basis changes which sheets qualify, so it needs a decision
  about what the metric is meant to measure, not a sweep. → [[timekeeping-live-nov-2025]] ·
  [[crewsheet-acthours-is-the-estimate]]

## Why this note exists
**Every Travis trip is billed** — the Skipper's standing rule of 2026-07-27 is *batch it all, send once*
(→ [[dev-handoff-contract]]). A newly found bug joins this inventory; it does not become its own email.
**Exception, learned the hard way:** that rule governs what goes into the *next* package — it does not license
reopening one already sent (see packages 4/5 above).

## The inventory as it stood before the ship (2026-07-27 — kept for the shape of the ask)
*Superseded by the section above: A/C/D/G shipped, B closed, F unchanged. **Row E was wrong** — the
"package 1's menu wiring never ran" item is retracted: `Dashboard-Access.cfm` is live on prod and
`Workbench.dbo.DashboardAccess` is already seeded, `AppFormID 1104` already carries the renamed frame, and the
dashboard links are hard-coded in `Profile$Main.HiRes.cfm` rather than driven by `AppForms` — **navigation was
never broken.** It had been written from the 7/19 release notes instead of from prod's current state.
🧭 **Check the target before listing something as outstanding.** (Same class as the stale checksums in A/B.)*
| | Item | Owner |
|---|---|---|
| **A** | **Package 3 code** — `Dashboard-RevenuePerformance.cfm` (**BOTH** webroots) + `Executive$Sales$Unattributed.cfm`. Staged `D:\GSTS-Deploy\PKG3-BUGFIXES-20260727\`, `DO-NOT-SEND-HELD.txt` marker in place. | Travis |
| **B** | 🚧 **THE GATE — 36 pre-existing defects** in RevenuePerformance, none introduced 7/27. Worst: Target TPH of 0 accepted *and persisted* · Pace-vs-Goal not prorated · 2026-hardcoded holidays · **North + South ≠ ALL** · jobs KPI counted per bucket · partially-posted day read as fully Actual · seasonal-goal overwrites and SAVES monthlyGoal. **Verify each against the code before fixing.** | us |
| **C** | **Play files drifted AHEAD of prod** (package 1 froze 7/19, we kept fixing): `Dashboard-V15Home.cfm` (Arbor Helper to-do hook) · `Profile$Main.HiRes.cfm` (the vestigial "Availability" widget the Skipper asked removed 7/23 — **shared shell, apply the diff, don't overwrite**) · `Profile.Project.Detail.cfm` (header overlap). | Travis |
| **D** | **One database ask, three items:** run `01-create-rgc-vProjectMarket-PROD.sql` (fixes the live SPM Results crash) · GRANT the CF `GSTS` login access to **`Workbench`** (Steve's dashboard, else 916) · GRANT it `SELECT ON SCHEMA::rgc`. ❓ **which login the prod CF datasource uses is unknown — ask with the package.** | Travis |
| **E** | **Package 1's menu wiring never ran** — files landed, the AppForms/permission half did not. Prod's `dbo.AppForms` has exactly **one** V1.5 entry (City Budgets 1287, and it predates the package). Correctness, not breakage — `dashboard-access-check.cfm` degrades to a leadership check. **Jordan ($0), not Travis (billed).** | Jordan |
| **F** | **NOT shipping, decided:** Arbor Helper (*"not ready"*, 7/27) · [[revenue-goal-close]] held — D-1 ships one view it needs, not the subsystem. | — |

## The prod crash that started it (2026-07-27) — fix shipped 07-28
📌 The shipped script is **`database\01-create-workbench-objects-PROD.sql`** (renamed and widened from
`01-create-rgc-vProjectMarket-PROD.sql`): it fixes **two** live prod faults in one run — the SPM Results 208
*and* the Sales Cockpit customer pop-out, which never loaded because
`Dashboard-SalesCockpit.Profile.cfm:20` subqueries the never-deployed `Workbench.dbo.BidQueue` and the whole
endpoint sits inside one `cftry`, so it just returns `{"ok":false}`. → [[sales-cockpit]]
Creates only `rgc` schema + 21-row `rgc.MarketMap` + `rgc.vProjectMarket` (+ the empty `BidQueue`); idempotent,
seeds only if empty, touches no GSTS table.

SPM **Results** dies on production: `208 Invalid object name 'Workbench.rgc.vProjectMarket'`. RGC was
deliberately held out of the V1.5 deploy, so the `rgc` schema was never created on prod — but that page
`LEFT JOIN`s one view from it, **unguarded**, so it dies rather than degrading. Fix script creates *only* the
schema + 21-row `MarketMap` + the view; idempotent, transactional, and **proven from a cold scratch database**
rather than re-run where it already worked. → [[rc-04-spm]]

⚠️ **The scan that missed it** grepped `Workbench.dbo.` — the killer was in the `rgc` schema. *A dependency scan
that assumes `dbo` is not a dependency scan.*

## Related
- [[trimit-server-topology]] — `198.207.148.168` is production (proven by a controlled write); `GSTSREADONLY`
  is scoped to `GSTS` only, which is why prod reads of `Workbench` return 916.
- [[trimit-dual-webroot-shadow]] — RevenuePerformance must go to **both** webroots or prod serves stale.
- [[rc-02-revenue-performance]] — what package 3 actually contains.
