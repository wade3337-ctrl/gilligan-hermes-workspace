---
title: Dev Handoff Contract
type: reference
domain: how-we-work
tags: [contract, handoff, deploy, prod, resourcing]
links: ["[[deploy-playbook]]", "[[repair-contract]]", "[[db-repair-contract]]", "[[v15-prod-deploy-state]]"]
updated: 2026-07-27
---

# Dev Handoff Contract

**What it is:** The contract for handing a deploy to the devs (play → PROD). Prod misses came from incomplete + unverified handoffs; devs deploy exactly what's named, so we hand the full dependency tree and verify prod. The contract form of the [[deploy-playbook]].
**📁 Source:** `contracts/dev-handoff-contract.md`

**Used by:** [[rc-01-executive-financial]], [[rc-02-revenue-performance]], [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-05-arborist-workbench]], [[steve-diligence-dashboard]] — **any play→prod handoff.**

## 💰 BATCH EVERYTHING INTO ONE DEPLOY — standing rule (Skipper, 2026-07-27)
> *"I prefer to deploy it all at once. It cost money each time I have Travis do this."*

**Every Travis trip is BILLED**, so a deploy is not "send it when it's ready" — it is **"hold until everything
known-outstanding is ready, then send once."**
- **Never hand over a single fix.** A newly found bug joins the outstanding inventory, not an email.
- **Before any handoff, sweep for everything else prod is missing** — files, DB objects, GRANTs, menu/AppForms
  wiring, and any play file that has **drifted ahead of prod**. One missed item = another billed trip.
- **Urgency is the only override, and it is the Skipper's call, not mine** — surface the tradeoff, let him decide.
- **Keep a live inventory** so the next batch is assembled in minutes rather than rediscovered:
  `arbor-stack/predeploy-pkg3/OUTSTANDING-FOR-PROD.md` → summarised in **[[v15-prod-deploy-state]]**.

## Key rules
- **Resourcing:** **Jordan Kim — IT Manager (salaried, $0 marginal):** prod deploys + menu/AppForms config (broken links, hardcoded IDs, placement, titles, dedupe). **Travis / Data Processing LLC ($75/hr):** ONLY deep DB/security/proc work we can't run ourselves.
- **1. BEFORE** — `node deploy-manifest.js <pages>` (in `production-dashboard/`): lists EVERY dependency (pages, includes, iframes, CSS/JS/images) with play-vs-prod presence. Resolve every ❌ missing-on-prod before sending.
- **2. Hand over the package, not a name-list** — the manifest + the actual files (or a zip). For each file: exact source (play path) and exact prod destination path. Name the menu/AppForms audience if a menu item is involved.
- **3. Dev deploys to prod.**
- **4. AFTER** — `BASE=https://greatscotttreeservice.com/GSTS bash deploy-smoketest.sh <pages>` → confirm 0 404s; render the page on prod.
- **Sign-off:** manifest fully deployed + smoke-test 0 missing + page renders correctly on prod.
