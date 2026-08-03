# TODO

## 🔴 DAILY EMAILS — resume on prod data (2026-08-03)
- **State:** COO daily email + per-salesperson + Nate-rollup crons all HELD since 7/25 ("stale data"). Dark 9 days = why Skipper feels blind.
- **Root cause:** endpoint `MonitorData.ReadOnly.cfm` (on play box) reads the play mirror despite `GSTSREADONLY` DSN labeled prod — nightly play refresh reverts it. Endpoint itself WORKS (token+IP OK; returns July invoiced $1.69M/accrued $277k).
- **FIX shipped:** deploy pkg `arbor-stack/anomaly-monitor/deploy-monitordata-prod/` (+ `MonitorData-prod-deploy-20260803.tgz` md5 10f2d2b7) → Jordan deploys to prod `\GSTS\api\`, confirm DSN reads live prod. Then flip monitor `S.host` play→prod + un-hold crons.
- **Interim decision PENDING Skipper:** resume to jwade-only now (recommended, no stale-to-team risk) vs un-hold full team w/ "play-mirror interim" caveat line. Recipients stay jkim/jroulson/sgriffiths per Skipper 8/3.
- **No scrape needed** — emails work, just held; endpoint functions. (Original "scrape" ask superseded by this simpler path.)


- [ ] **(2026-08-03) Fleet spine — firm the soft numbers** (GPS module #1): normalize the ~11 inconsistent OneStepGPS device names (B47 HW 1 / C66 HW 125 / C 68 Unit #175 / C74 New HW #9 / etc.) or store the crosswalk we built; then clean the TRIM IT ERP-active list so "motorized trucks with no GPS" becomes a fact, not the ~145 first-cut lead. → business-plan/friction-modules/03-production-gps-spine.md

## 🔥 Friction register — nodes still to work (brain-dump one at a time)
Done: **Marketing/BD · Sales · Production (GPS + clock)**. Remaining:
- [ ] **Accounting node** (flows directly out of completion/billing — the tail-end node) → then invoicing/AR items D1–D8 fold in here.
  - *Seed (Skipper 8/3):* **AP is paper-bound.** Controller prints everything, can't get his head around paperless/automated. AP can't push vendors to **bill electronically** or stand up a **simple vendor pay portal** — no e-invoicing, no AP automation. (The AP-side mirror of the AR blind spot D3; note it's partly a *people/change-resistance* item, not just tooling.)
- [ ] **HR node** (new-hire pipeline, onboarding, certs).
  - *Seed (Skipper 8/3):* HR is **on board** with automation/paperless (opposite of the AP controller — the *people* side is ready here). Real blocker = **legal & privacy hurdles** (sensitive HR/PII, compliance). They've **stood up an HR framework in Claude** (claude.ai) but **nothing implemented or integrated with TRIM IT yet**. **Long-term play: that framework BECOMES the HR node**, integrated with TRIM IT. → likely one of his consumer-Claude domain docs to hand over (per USER.md consolidation habit).
- [ ] **Safety node** (safety training/records — partly touched via Typhoom win).
- [ ] Also open from earlier: area-manager bandwidth · aged-worker retirement/succession · purchasing/material ordering · fleet (beyond the GPS spine).

## 🛠️ Active builds — resume pointers
- [ ] **T&A↔WO reconciler v2** (production tail-end): daily-worked-crew link (not home crew) · GPS timeline as the split PROPOSER · run on raw/real-time pre-fix data · crew-leader/app WO-split for the ~13% same-property (mostly municipal) case. v1 proved the approach reconciles; value = remove daily branch-manager labor. → business-plan/friction-modules/03 + memory/2026-08-02.md.
- [ ] **ArborNote automation** — the pricing endpoint is FOUND: `GET /v1/projects/{id}/tags` (auth **x-api-key**) returns priced trees. Travis/Jordan's dormant TRIM IT import (`BulkImportInventoryDetailFromArborNote` + GSTSArborNote* tables) can be FINISHED (they only lacked the key + the API caller/right auth — both now known). Build: pull /tags → their proc / the GSTS pricing worksheet → **kills Rebekah's manual transfer.** → wiki/facts/dev-browser-access + trimit-knowledge/concepts/arbornote-integration-framework.md.
- [ ] **Nate commission-report detail** — emailed 8/2, awaiting his reply to quantify the biweekly reconciliation friction (Marketing/BD node).
- [ ] **Read first real yard-departure distribution** — AM after the poller ran overnight (8/3).
