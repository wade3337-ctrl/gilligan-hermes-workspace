---
title: arbor-core — RFP Automation (B1→B2→B3)
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, rfp, intake-agent, match-or-create, drafting, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[arbor-core-onestop-ui]]", "[[arbor-core-arbor-ai-system]]", "[[arbor-core-municipal-bid-branch]]", "[[arbor-core-strategy-foundation]]"]
updated: 2026-07-03
---

# arbor-core — RFP Automation (B1→B2→B3)

**One-liner:** The inbound-request pipeline — **B1** read a messy email+attachments → one structured `intake_record`; **B2** match-or-create against the customer spine (lazy, data-quality-gated import); **B3** draft the archetype-aware outbound (filled bid sheet / proposal / WO acceptance). Proven on Rosa's 3 real requests, 2-lab verified, **DRAFTS ONLY — never sent.**
**Status:** 🔵 active — B1/B2/B3 all working end-to-end.
**📁 Location:** `arbor-core/rfp-automation/` + `arbor-core/importer/b2_*`
**▶️ Resume:** `arbor-core/rfp-automation/INTAKE-SPEC.md`

## Applies / uses
- [[arbor-core-db-importers]] — B2 runs match-or-create against the live RLS customer spine.
- `INTAKE-SPEC.md` — the agent's output contract (source/classification/customer/site/contact/request/dates/routing/attachments/actions/needs_review).
- Foundation D4 (lazy, data-quality-gated import) — B2 pulls ONLY touched customers, cleans at the gate, never bulk-copies; idempotent on `legacy_company_id`.

## State & flags
- **B1 intake agent** (`rfp-automation/agent/`) — messy forwarded email → `intake_record` JSON; 2-lab verified (GLM+Gemini); identity rule = serviced property is the customer (mgr → management_company); dates → ISO. Handles 3 archetypes: `formal_rfp` / `new_customer_proposal` / `one_off_work_order`. `needs_review` = the human-in-the-loop seam (earned-trust dial).
- **B2 match-or-create** (`importer/b2_match_or_create.py`) — searches TRIM IT (CSV proxy), MATCH BAR = full token coverage (no false-merge). Proven: MainPlace=own/skip · Altamar=imported · Paradise Palms=created-new.
- **B3 outbound drafting** (`agent/DRAFT-PROMPT.md`, `draft-outbound.sh` → `drafts/`) — archetype-aware; WO keeps the `[#XN6997806]` routing tag; RFP refuses to invent pricing.
- **Bid-Package Electronification ("kill the PDFs")** — 📝 design done, `rfp-automation/BID-PACKAGE-electronification.md`.
- ⚠️ **Next:** B3 → pricing hookup (MainPlace bid sheet needs the [[arbor-core-onestop-ui]] pricing engine); swap B2's CSV proxy → live read-only TRIM IT query (**blocked on Jordan/AWS prod access**); wire B1→B2→B3 into one runnable flow.

## Related
- [[arbor-core-onestop-ui]] — B3's pricing hookup target (the estimating engine).
- [[arbor-core-arbor-ai-system]] — B1 = the candidate first live Hermes process (the intake agent).
- [[arbor-core-municipal-bid-branch]] — formal-RFP archetype flows into the separate municipal branch.
