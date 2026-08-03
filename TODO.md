# TODO

- [ ] **(2026-08-03) Fleet spine — firm the soft numbers** (GPS module #1): normalize the ~11 inconsistent OneStepGPS device names (B47 HW 1 / C66 HW 125 / C 68 Unit #175 / C74 New HW #9 / etc.) or store the crosswalk we built; then clean the TRIM IT ERP-active list so "motorized trucks with no GPS" becomes a fact, not the ~145 first-cut lead. → business-plan/friction-modules/03-production-gps-spine.md

## 🔥 Friction register — nodes still to work (brain-dump one at a time)
Done: **Marketing/BD · Sales · Production (GPS + clock)**. Remaining:
- [ ] **Accounting node** (flows directly out of completion/billing — the tail-end node) → then invoicing/AR items D1–D8 fold in here.
- [ ] **HR node** (new-hire pipeline, onboarding, certs).
- [ ] **Safety node** (safety training/records — partly touched via Typhoom win).
- [ ] Also open from earlier: area-manager bandwidth · aged-worker retirement/succession · purchasing/material ordering · fleet (beyond the GPS spine).

## 🛠️ Active builds — resume pointers
- [ ] **T&A↔WO reconciler v2** (production tail-end): daily-worked-crew link (not home crew) · GPS timeline as the split PROPOSER · run on raw/real-time pre-fix data · crew-leader/app WO-split for the ~13% same-property (mostly municipal) case. v1 proved the approach reconciles; value = remove daily branch-manager labor. → business-plan/friction-modules/03 + memory/2026-08-02.md.
- [ ] **ArborNote automation** — the pricing endpoint is FOUND: `GET /v1/projects/{id}/tags` (auth **x-api-key**) returns priced trees. Travis/Jordan's dormant TRIM IT import (`BulkImportInventoryDetailFromArborNote` + GSTSArborNote* tables) can be FINISHED (they only lacked the key + the API caller/right auth — both now known). Build: pull /tags → their proc / the GSTS pricing worksheet → **kills Rebekah's manual transfer.** → wiki/facts/dev-browser-access + trimit-knowledge/concepts/arbornote-integration-framework.md.
- [ ] **Nate commission-report detail** — emailed 8/2, awaiting his reply to quantify the biweekly reconciliation friction (Marketing/BD node).
- [ ] **Read first real yard-departure distribution** — AM after the poller ran overnight (8/3).
