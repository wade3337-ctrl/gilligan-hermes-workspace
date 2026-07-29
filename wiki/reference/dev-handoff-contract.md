---
title: Dev Handoff Contract
type: reference
domain: how-we-work
tags: [contract, handoff, deploy, prod, resourcing]
links: ["[[deploy-playbook]]", "[[repair-contract]]", "[[db-repair-contract]]", "[[v15-prod-deploy-state]]", "[[external-comms-contract]]"]
updated: 2026-07-28
---

# Dev Handoff Contract

**What it is:** The contract for handing a deploy to the devs (play → PROD). Prod misses came from incomplete + unverified handoffs; devs deploy exactly what's named, so we hand the full dependency tree and verify prod. The contract form of the [[deploy-playbook]].
**📁 CANONICAL — this file is the contract.** `contracts/dev-handoff-contract.md` is a stub pointing here (it fell 5 weeks behind and `ROUTING.md` pointed at it; fixed 2026-07-29).

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

## 📦 THE PACKAGE READS AS A WORK ORDER, NOT AN AUDIT — standing rule (Skipper, 2026-07-28)
> *"files, descriptions of the fixes and instructions, no fluff"* — and *"remove the production is behind references."*

The vendor needs to know **what the file is, where it goes, what it fixes, and how to confirm it.** Nothing
about what someone else missed, no deployment history, no blame. Proven on `TRIMIT-BUGFIXES-20260728.zip`
(→ [[v15-prod-deploy-state]]):
- **Strip the internal working record.** Our `MANIFEST.md` was 21 mentions of "crew" and 5 of "Skipper" —
  pulled from the package, identical copy kept in our own repo so nothing is lost.
- **Folder names make claims too.** `patches-sectionC\` → `ui-files\`, `prod-should-currently-be\` →
  `baseline\`. The old name asserted a claim about prod *in the path*.
- **🔍 Run a leak scan over every text file AND every filename** before zipping: `behind · drift · crew ·
  Skipper · stale · vendor · missed · prod-should · password · secret · <internal folder names> · <nicknames> ·
  <internal hostnames/IPs>`. It caught a **CFML comment** reading *"removed … per Skipper … backup in
  Jasonsrepairs"* inside a file we were about to hand a vendor. Source comments ship too.
  - When you reword a file to fix a leak, **prove the change is comment-only** by diffing against the
    last confirmed version — then push the same file to play so **play == what ships**.
- **🔢 Never hand-type a checksum or a byte count.** Generate the table from the staged folder
  (`Get-FileHash` + `Length`) and **assert every row**. A typed 66,927 for a 66,595-byte file slipped through
  once — the hash was right, so nothing downstream would have caught it, and a vendor verifying by size stops
  mid-deploy. Same class of error as the stale-manifest checksums that blocked us twice before.
- **Shared shells go as verify-then-copy, never as an overwrite** — `install-this\` + `baseline\` + a unified
  `.diff`, so the dev can confirm their copy matches the baseline before replacing it.
- **Confirm the exact draft with the Skipper before sending** (per the [[external-comms-contract]] per-email
  rule), and keep the hold marker (`DO-NOT-SEND-HELD.txt`) in the staged folder until he releases it.

## Key rules
- **Resourcing:** **Jordan Kim — IT Manager (salaried, $0 marginal):** prod deploys + menu/AppForms config (broken links, hardcoded IDs, placement, titles, dedupe). **Travis / Data Processing LLC ($75/hr):** ONLY deep DB/security/proc work we can't run ourselves.
- **1. BEFORE** — `node deploy-manifest.js <pages>` (in `production-dashboard/`): lists EVERY dependency (pages, includes, iframes, CSS/JS/images) with play-vs-prod presence. Resolve every ❌ missing-on-prod before sending.
- **2. Hand over the package, not a name-list** — the manifest + the actual files (or a zip). For each file: exact source (play path) and exact prod destination path. Name the menu/AppForms audience if a menu item is involved.
- **3. Dev deploys to prod.**
- **4. AFTER** — `BASE=https://greatscotttreeservice.com/GSTS bash deploy-smoketest.sh <pages>` → confirm 0 404s; render the page on prod.
- **Sign-off:** manifest fully deployed + smoke-test 0 missing + page renders correctly on prod.
