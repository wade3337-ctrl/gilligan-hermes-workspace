---
title: Customer Verifier
type: project
domain: work
track: 1
status: archived
tags: [customer-verifier, leads, verification, archived, first-automated-task]
applies: []
links: ["[[sales-cockpit]]"]
updated: 2026-07-03
---

# Customer Verifier

**One-liner:** Batch-verify the customer/leads list (414 records) automatically — the first automated task run in this workspace.
**Status:** 🗄️ archived — 414/414 verified; **done, superseded by [[sales-cockpit]]** (the unified CRM front door now owns lead/customer handling).
**📁 Location:** `arbor-stack/customer-verifier/` (per-record checkpoints/, `verification_full_results.xlsx`)
**▶️ Resume:** `arbor-stack/customer-verifier/verification_full_results.xlsx` (final output — nothing to resume)

## Applies / uses
- One-off batch job (Python: `_emit_batch.py`, `_build_survivors.py`, `_build_excel.py`); no dashboard/UI or DB standard applies.
- Inputs `CustomerList-Leads-2026-06-03.csv`; per-record JSON checkpoints under `checkpoints/`.

## State & flags
- ✅ Complete — 414/414 verified; results in `verification_full_results.xlsx`.
- 🗄️ **Retire candidate** (flagged in the PROJECTS cleanup list). Confirm before deleting (repair-contract: look first).

## Related
- [[sales-cockpit]] — the successor that subsumes this workflow.
