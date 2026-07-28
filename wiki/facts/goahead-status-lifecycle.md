---
title: GoAheads status lifecycle — what the status values mean operationally, and why 'InProcess' is a stuck record
type: fact
domain: work
track: 1
status: active
tags: [trimit, sop, goaheads, data-quality, close-rate, gotcha]
applies: ["[[only-trustworthy-data]]", "[[canonical-definition]]"]
links: ["[[bid-process-reengineering]]", "[[trimit-db-gotchas]]", "[[rc-04-spm]]", "[[sales-cockpit]]"]
created: 2026-07-28
updated: 2026-07-28
---

# GoAheads status lifecycle

**Source of truth:** *Activating Go-Aheads SOP*, revised 2026-02-06 —
`arbor-stack/bid-process-reengineering/sops/2026-revised/05-activating-go-aheads.md`.
Received from Jeanie Roulson 2026-06-23, **independently re-sent by Rosa 2026-07-28** (byte-identical text,
md5 `807f50265ded`) — so it is confirmed as the version the field is actually working to.

## ⭐ The thing the code never told us: activation is a TWO-STEP status flip
> **IMPORTANT: Update StatusDefID to In Process → Update Record. Then update StatusDefID to Active →
> Update Record. This two-step sequence is required to successfully activate the go-ahead.**

**Therefore a GoAhead left sitting in `InProcess` is a HALF-FINISHED ACTIVATION** — someone did step 1 and
never did step 2. It is not a workflow state anyone intends to rest in. That is a **data-quality signal we
can query for**, and nothing in the schema hints at it; it only exists in the SOP.

## Status distribution (play restore, GoAheads created in the last 2 years, 2026-07-28)
| Status | n | EstValue |
|---|---|---|
| Complete | 5,423 | $38.49M |
| Pending | 2,888 | $60.39M |
| Archived | 1,498 | $29.28M |
| Inactive | 1,184 | $23.22M |
| Lost | 740 | $15.01M |
| Active | 673 | $7.90M |
| Expired | 266 | $3.89M |
| **InProcess** | **8** | **$120,861** |

**Good news: the SOP is being followed.** 8 stuck out of ~12,680 is a 0.06% failure rate.
✅ `Complete` is by far the largest *won* state — which is why omitting it from a close-rate numerator is so
damaging (that was the `Executive$ClosePercentage$Detail.cfm` blocker fixed 2026-07-28).

## The 8 stuck records — two distinct problems
**(a) Two genuinely abandoned, both >18 months old:**
`196186` Optimum / Pacific Ranch HOA, $1,600, created 2024-10-11 (655 days) ·
`199576` City of Fountain Valley emergencies, $1,924, created 2025-01-08 (566 days).

**(b) FIVE near-identical Irvine Company records, all recent, all stuck at step 1:**
`215655` `215665` `215669` `215685` `215693` — all *"2026 (Jul/Aug) - Crystal Cove (Summer Tr…"*,
**all exactly $22,649**, created 2026-07-15/16. Plus `215786` Corona Del Mar palms $4,092 (2026-07-20).
These are **not** the multi-season split the SOP describes in Step V — that produces *different* seasons,
and these are all the same Jul/Aug season at the same value.
**Most likely read: someone attempted the two-step activation repeatedly, each attempt left an `InProcess`
record behind, and none completed.** ⚠️ Unverified inference — worth asking whoever owns that account.
**Operationally: ~$22.6K of Crystal Cove summer work may not have reached Scheduling.**

*(The SOP's own Important Note #1 — "for duplicate work order lines, leave as-is until IT resolves the
issue" — says duplicate creation is a known, unresolved TRIM IT defect. Consistent with what we see.)*

## Other SOP facts worth knowing before touching go-ahead data
- **Future-year change orders are activated by temporarily lying about the year.** You bump the proposal to
  Pending, set `Current Year` to the *current* year, activate, then **must restore the true future year**.
  The SOP warns in bold: *"Failure to do this will cause billing in the wrong year."* → **any go-ahead whose
  project year looks wrong may be a half-completed future-year CO.** `GoAhead Scope` should read `Future01`.
- **Multi-season / multi-year plans are deliberately split into SEPARATE go-aheads and work orders**, one per
  season (e.g. `2026 Jan/Mar & Removals` · `2026 Apr/Jun` · `2026 Oct/Dec`). So one approval legitimately
  becomes several go-aheads — **do not treat that fan-out as duplication.**
- **Change orders are NOT sent to Scheduling** — they amend an existing work order.
- Description naming is a convention, not enforced: `Year (Season, Community)`, `Year (Removals, Season,
  Community)`, `Year (Treatment, Community)`, `Year (% Season, Community)` for multi-years.

## Why this note exists
The SOP had been filed since June but was never connected to the data model, so the go-ahead status lists
we have been editing in the close-rate and SPM pages were being treated as opaque enum values.
**Filed ≠ known.** When a process document lands, ask what it implies about the data.
