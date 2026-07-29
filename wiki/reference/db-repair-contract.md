---
title: DB Repair Contract
type: reference
domain: how-we-work
tags: [contract, database, proc, schema, prod-deploy]
links: ["[[repair-contract]]", "[[dev-handoff-contract]]", "[[deploy-playbook]]"]
updated: 2026-07-03
---

# DB Repair Contract

**What it is:** The contract for a DATABASE repair (proc / data / schema) — separate from a UI repair because the play DB reverts on the nightly prod→play refresh, so DB fixes must be deployed to prod by devs to stick.
**📁 CANONICAL — this file is the contract.** `contracts/db-repair-contract.md` is a stub pointing here (it fell 5 weeks behind and `ROUTING.md` pointed at it; fixed 2026-07-29).

**Used by:** [[rc-03-city-budgets]], [[completed-vs-sold]], [[anomaly-monitor-suite]] — **any proc/data/schema fix** (and the DB-proc-level metric fixes flagged in [[dashboard-metric-standards]]).

## Key rules
- **1. Build + TEST on PLAY first** to prove it's right (play reverts nightly — fine for testing). Use `gsql.sh`.
- **2. Back up prod-appropriately** — NOT Jasonsrepairs (play-only). `SELECT * INTO dbo.zBak_<thing>_<date>` for affected rows, and/or script out the current proc definition to a file. Let IT use their own restore process.
- **3. Hand devs exact, scoped steps** — name every object (`dbo.<Proc>`), which server/env it lives on and deploys TO, and the exact action/params (run this proc with these params / regenerate these IDs). No "the files we changed."
- **4. Devs deploy to PROD.**
- **5. Verify on prod** against a stated acceptance check (e.g. "Long Beach 26/27 now ~$97K, not $0").
