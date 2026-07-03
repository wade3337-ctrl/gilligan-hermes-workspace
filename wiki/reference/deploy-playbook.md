---
title: Deploy Playbook
type: reference
domain: how-we-work
tags: [deploy, handoff, prod, manifest, smoketest]
links: ["[[dev-handoff-contract]]", "[[repair-contract]]", "[[db-repair-contract]]"]
updated: 2026-07-03
---

# Deploy Playbook

**What it is:** The complete, verifiable process for handing a play→PROD UI deploy to the devs, built to close the two production misses caused by incomplete/unverified handoffs (a 404'd shared stylesheet; a DB cleanup that never landed). Devs deploy exactly what we name, so we hand the FULL dependency tree and verify PROD afterward. Pairs with [[dev-handoff-contract]].
**📁 Source:** `arbor-stack/DEPLOY-PLAYBOOK.md`

**Used by:** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]] — **any play→prod deploy.**

## Key rules
- **Dev handoff resourcing:** **Jordan Kim = IT Manager (salaried, $0 marginal)** for prod deploys + menu/AppForms config. **Travis / Data Processing LLC = $75/hr**, ONLY for deep DB/security/proc work we can't run ourselves.
- **1. `deploy-manifest.js` (run BEFORE handoff):** in `production-dashboard/`, walks each page's source (recursing `cfinclude`s + `<iframe>` sub-pages), enumerates EVERY file it touches, checks each against play (source) vs prod (dest). Anything missing on prod is flagged ❌ (a 404 waiting to happen). **Resolve every ❌ before sending.** Derived from actual code — nothing forgotten from memory.
- **2. Hand over the package, not a name-list:** the manifest table + the actual files (or a zip). For each file give exact source (play path) and exact prod destination path. Name the menu/AppForms audience if a menu item is involved.
- **3. `deploy-smoketest.sh` (run AFTER dev deploys):** `BASE=https://greatscotttreeservice.com/GSTS bash deploy-smoketest.sh <pages>` — loads each page on PROD and HEAD-checks every CSS/JS/image. Any non-`[200]` = missing resource; sign-off requires 0 misses.
- **Process:** build+verify on play (check dual-webroot shadow copy) → manifest, fix every ❌ → hand over package → dev deploys → smoketest prod → render prod. **Sign-off = manifest fully deployed + smoke-test clean + page renders correctly on prod.**
- **Open item (Jun 17 2026):** `Dashboard-SalesPipeline.cfm` 404s on prod (never deployed or renamed) — flag for devs.
