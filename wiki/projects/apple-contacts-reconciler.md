---
title: Apple Contacts ↔ TRIM IT Reconciler
type: project
domain: work
track: 1
status: proposal
tags: [pipeline-tool, vcard, reconciler, entity-resolution, contacts, db-repair]
links: ["[[scott-manager-dashboard]]", "[[sales-cockpit]]"]
updated: 2026-07-02
---

# Apple Contacts ↔ TRIM IT Reconciler

**One-liner:** Parse Scott's Apple Contacts vCard (his hand-curated answer key — one clean card per property manager) and reconcile it against TRIM IT so his clean "Janina Bates" becomes the CanonicalManager and TRIM IT's dirty `ProjectContacts.Desc1` variants snap on as aliases — reading his brain instead of rebuilding it.
**Status:** 📝 proposal — scoping (green-lit 2026-06-23); **awaiting Scott's vCard export.** 2 sub-projects: read-only diff first, write-back later.
**📁 Location:** `arbor-stack/pipeline-tool/PROJECT-apple-contacts-reconciler.md`
**▶️ Resume:** `arbor-stack/pipeline-tool/PROJECT-apple-contacts-reconciler.md`

## Two sub-projects (keep separate)
1. **Reconcile / compare (READ-ONLY, safe — do first):** parse `.vcf` → auto-match his managers vs TRIM IT (Contacts master + `ProjectContacts.Desc1` aliases) → diff report (typo-variants that resolve to one manager · contacts/emails/phones TRIM IT is missing · sites not linked · conflicts). Output feeds the dashboard mapping layer.
2. **Clean up / write-back (CAREFUL, separate):** use the diff to fix/add TRIM IT contacts. This is a **DB write** → follows [[db-repair-contract]]: build+test on play, backup first, exact dev steps, devs deploy. **Never auto-write the live customer DB** — generate proposed changes for review.

## State & flags
- **Export solved:** one-click "export all to one .vcf" — no Mac → iCloud.com in a desktop browser (Ctrl+A → Export vCard). Handles 500+ trivially.
- **Personal-vs-work filter (auto, TRIM IT = the filter):** 3 buckets — confident WORK (auto-keep) · probable-work REVIEW (the only part needing Scott) · personal/unknown QUARANTINE (never imported). Privacy guardrail: personal contacts never touch the company DB.
- **Direction: one-way for now** (Apple = identity source of truth; TRIM IT cleaned in reviewed batches). No two-way sync yet.
- Tech: parse with stdlib (Python/Node), no Apple API; conservative auto-merge + review queue (same rules as the dashboard mapping layer).
- **Next:** Skipper exports vCard → Gilligan builds the read-only diff → review → decide write-back batches.

## Related
- [[scott-manager-dashboard]] — the dashboard this feeds (eliminates its manual de-dupe review).
- [[sales-cockpit]] — the clean contact/account model both feed the sales engine.
