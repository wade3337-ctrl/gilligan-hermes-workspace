# Contract: handing a deploy to the devs (play → PROD)
**Why:** prod misses came from incomplete + unverified handoffs. Devs deploy exactly what's named.

## Resourcing
- **Jordan Kim — IT Manager (salaried, $0 marginal):** prod deploys + menu/AppForms config (broken links, hardcoded IDs, placement, titles, dedupe).
- **Travis / Data Processing LLC ($75/hr):** ONLY deep DB/security/proc work we can't run ourselves.

## 💰 BATCH EVERYTHING INTO ONE DEPLOY (Skipper, standing rule 2026-07-27)
> *"I prefer to deploy it all at once. It cost money each time I have Travis do this."*

**Every Travis deploy is billed.** A deploy is therefore not "send it when it's ready" — it is
**"hold until everything known-outstanding is ready, then send once."**

- **Never hand over a single fix.** A newly found bug goes onto the outstanding-deploy inventory, not into an email.
- **Before any handoff, sweep for everything else prod is missing** — files, DB objects, GRANTs, menu/AppForms
  wiring, and any play file that has drifted ahead of prod. One missed item = another billed trip.
- **Urgency is the only override, and it is the Skipper's call, not mine.** A crashing prod page *may* justify its
  own trip; a mislabelled column never does. Surface the tradeoff, let him decide.
- **Keep a live inventory** of everything prod is missing, so the next batch is assembled in minutes instead of
  rediscovered. Current one: **`arbor-stack/predeploy-pkg3/OUTSTANDING-FOR-PROD.md`**.

## Steps
1. **BEFORE** — `node deploy-manifest.js <Page1.cfm> <Page2.cfm> …` (in `production-dashboard/`). It lists EVERY dependency (pages, includes, iframes, CSS/JS/images) with play vs prod presence. **Resolve every ❌ missing-on-prod before sending.**
2. **Hand over the package, not a name-list** — the manifest + the actual files (or a zip). For each file: exact **source** (play path) and exact **prod destination** path. Name the **menu/AppForms audience** if a menu item is involved.
3. **Dev deploys to prod.**
4. **AFTER** — `BASE=https://greatscotttreeservice.com/GSTS bash deploy-smoketest.sh <pages>` → confirm 0 404s; render the page on prod.

## Acceptance / sign-off
Manifest fully deployed + smoke-test shows 0 missing + page renders correctly on prod.
