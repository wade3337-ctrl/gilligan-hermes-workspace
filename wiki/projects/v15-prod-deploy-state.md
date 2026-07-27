---
title: V1.5 prod deploy state — what production is still missing
type: project
domain: work
track: 1
status: active
tags: [deploy, prod, trimit, travis, jordan, batch, outstanding]
applies: ["[[dev-handoff-contract]]", "[[deploy-playbook]]", "[[trimit-dual-webroot-shadow]]"]
links: ["[[rc-02-revenue-performance]]", "[[rc-04-spm]]", "[[steve-diligence-dashboard]]", "[[revenue-goal-close]]", "[[trimit-server-topology]]", "[[v15-landing-assistant]]"]
updated: 2026-07-27
---

# V1.5 prod deploy state — what production is still missing

**One-liner:** The single running inventory of everything prod does not yet have, so the next handoff is one
batched trip instead of five billed ones.
**Status:** 🚧 **HELD** — package 3 is built, staged and render-verified, but gated behind 36 pre-existing defects.
**📁 Canonical (keep current there, not here):** `arbor-stack/predeploy-pkg3/OUTSTANDING-FOR-PROD.md`
**▶️ Resume:** fix the 36 in `arbor-stack/predeploy-pkg3/MORNING-FIXLIST.md`, re-stamp checksums, send once.

## Why this note exists
**Every Travis trip is billed** — the Skipper's standing rule of 2026-07-27 is *batch it all, send once*
(→ [[dev-handoff-contract]]). A newly found bug joins this inventory; it does not become its own email.

## What prod is missing (shape only — the canonical doc has files, MD5s, destinations)
| | Item | Owner |
|---|---|---|
| **A** | **Package 3 code** — `Dashboard-RevenuePerformance.cfm` (**BOTH** webroots) + `Executive$Sales$Unattributed.cfm`. Staged `D:\GSTS-Deploy\PKG3-BUGFIXES-20260727\`, `DO-NOT-SEND-HELD.txt` marker in place. | Travis |
| **B** | 🚧 **THE GATE — 36 pre-existing defects** in RevenuePerformance, none introduced 7/27. Worst: Target TPH of 0 accepted *and persisted* · Pace-vs-Goal not prorated · 2026-hardcoded holidays · **North + South ≠ ALL** · jobs KPI counted per bucket · partially-posted day read as fully Actual · seasonal-goal overwrites and SAVES monthlyGoal. **Verify each against the code before fixing.** | us |
| **C** | **Play files drifted AHEAD of prod** (package 1 froze 7/19, we kept fixing): `Dashboard-V15Home.cfm` (Arbor Helper to-do hook) · `Profile$Main.HiRes.cfm` (the vestigial "Availability" widget the Skipper asked removed 7/23 — **shared shell, apply the diff, don't overwrite**) · `Profile.Project.Detail.cfm` (header overlap). | Travis |
| **D** | **One database ask, three items:** run `01-create-rgc-vProjectMarket-PROD.sql` (fixes the live SPM Results crash) · GRANT the CF `GSTS` login access to **`Workbench`** (Steve's dashboard, else 916) · GRANT it `SELECT ON SCHEMA::rgc`. ❓ **which login the prod CF datasource uses is unknown — ask with the package.** | Travis |
| **E** | **Package 1's menu wiring never ran** — files landed, the AppForms/permission half did not. Prod's `dbo.AppForms` has exactly **one** V1.5 entry (City Budgets 1287, and it predates the package). Correctness, not breakage — `dashboard-access-check.cfm` degrades to a leadership check. **Jordan ($0), not Travis (billed).** | Jordan |
| **F** | **NOT shipping, decided:** Arbor Helper (*"not ready"*, 7/27) · [[revenue-goal-close]] held — D-1 ships one view it needs, not the subsystem. | — |

## The prod crash that started it (2026-07-27)
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
