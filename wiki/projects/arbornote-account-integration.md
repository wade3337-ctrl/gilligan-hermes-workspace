---
title: ArborNote — GSTS account + API integration
type: project
domain: work
status: active
confidential: fort-point-black
created: 2026-08-02
updated: 2026-08-03
tags: [arbornote, integration, api, shadow-it, rebekah, acquisition, friction]
applies:
  - "[[friction-hit-list]]"
  - "[[trimit-investor-case]]"
links: ["[[vendor-fieldapp-build]]", "[[dev-browser-access]]", "[[friction-hit-list]]"]
---

# ArborNote — GSTS Account + API Integration

🔒 Fort Point / owner-tier. Skipper gave an ArborNote **API key** + **web login** (`~/.openclaw/.secrets/arbornote-api.json` · `arbornote-login.json`). ⚠️ **READ-ONLY — do NOT alter the GSTS account.** Full detail: `memory/2026-08-02.md`; import framework: `~/trimit-knowledge/concepts/arbornote-integration-framework.md`.

## The reveal
GSTS has a **LIVE ArborNote account (id 1068, since Nov 2023)** — NOT dormant. **97 projects / 23,283 trees / 82 Pending**, huge **July-2026 spike (52 projects)**. **Shadow-IT at scale:** **Rebekah** (sales arborist) runs a book she brought from a former employer — builds pricing in ArborNote, **hand-transfers to the GSTS pricing worksheet (cumbersome)**. Big "CZ" community bid in flight (5,000+ trees). ⇒ strong friction evidence: our people use ArborNote because on-site inventory→bid beats TRIM IT.

## The API (mapped, read-only)
- **Public:** `https://api.arbor-note.com/v1` — auth **`x-api-key`** header (case-sensitive; Bearer 403s → use curl not urllib). CRM objects: `clients`, `projects` (treeCount summary/GPS/market/notes/status), `work-orders`. NO export endpoint.
- **🔑 The priced inventory: `GET /v1/projects/{id}/tags`** — returns every tree with **`price`, `hours`**, species, health, dbh, height, timing, frequency, objective, GPS, photo. (Proven: CZ-Streets 397897 = 1806 priced trees.) *This is the endpoint the earlier probes missed (it's `/tags`).*
- **Internal:** `wup8z01em5.execute-api.us-east-1.amazonaws.com/v21/` — session-auth, richer (dashboard/projects/work-orders/settings); reached via browser login (proven, as Jason/admin).

## The dormant TRIM IT import (Travis/Jordan) — now finishable
Built but never used: proc **`BulkImportInventoryDetailFromArborNote`** (27KB, 43-field mapping, dry-run proven) + `GSTSArborNote*` tables + `GSTSArborNoteProjectsDashboard.cfm`. **Missing only: the API key + a working API caller** — their prototype `arbornote-sync.py` used the WRONG auth (Bearer→403). **We now have both** → the import (and Rebekah's transfer) is buildable: pull `/tags` → their proc / the GSTS worksheet. **Acquisition thesis proven** (any ArborNote book pulls programmatically).

## Next
Pull `/tags` → GSTS pricing worksheet to kill Rebekah's manual transfer; finish Travis/Jordan's import with the correct key/endpoint/auth.
