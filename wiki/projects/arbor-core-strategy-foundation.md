---
title: arbor-core — Strategy + Foundation
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, strategy, foundation, decisions, confidential]
applies: ["[[arbor-core-db-importers]]"]
links: ["[[arbor-core-onestop-ui]]", "[[arbor-core-arbor-ai-system]]", "[[arbor-core-crew-infra]]"]
updated: 2026-07-03
---

# arbor-core — Strategy + Foundation

**One-liner:** The apex direction + the 9 ratified foundation decisions (D1–D9) that lock how arbor-core is built — a clean, in-house **Agent OS** (vertical SaaS product for tree-care) that strangler-figs TRIM IT, sales-engine first, model-agnostic, owned-edge.
**Status:** 🔵 active — strategy agreed (Skipper 2026-06-21); D1–D9 RATIFIED 2026-06-26. Schema frozen at v1.7 (light re-gate pending). Pivoted to the **agent layer** as the product/moat.
**📁 Location:** `arbor-core/docs/` + `arbor-core/build/`
**▶️ Resume:** `arbor-core/docs/STRATEGY.md` + `arbor-core/build/FOUNDATION-DECISIONS.md`

## Applies / uses
- ADR-001 (locked stack: Postgres · Python/FastAPI · model-agnostic gateway · React, Docker) + ADR-002 (mapping).
- Schema `sales-engine v1.7` (frozen) — the durable-nouns, process-agnostic data model the decisions produced.
- [[arbor-core-db-importers]] — D4 lazy import + D9 multi-tenancy realized as the live RLS spine.

## State & flags
- **Mission:** own the strategic edge, rent nothing strategic (only the swappable model). Strangler-fig, not big-bang; TRIM IT becomes a read-only history archive.
- **Locked decisions (D1–D9):** Keycloak auth · authz-in-brain + composable atomic RBAC (UNION of roles) · earned-trust autonomy dial (humans AND agents; un-bottlenecks QC) · lazy data-quality-gated import · Infisical secrets · GitHub-Actions + self-hosted runner CI · **two independent geographic axes (Branch ⟂ Sales Territory)** · scale-by-data + process-agnostic schema · **D9 multi-tenancy baked in — arbor-core is a PRODUCT the Skipper sells; Great Scott = tenant #1 / dogfood.**
- D9 refinement: "multi-tenant by SHAPE, single-tenant by OPERATION" — build the un-retrofittable boxes now, defer heavy isolation machinery until tenant #2 is real.
- ⚠️ Two-track rule: this is **BLACK** — off the play server, Skipper's eyes, modern stack (NOT ColdFusion).
- Open (non-blocking): light re-gate of v1.7 delta; customer-spine data-quality criteria (D4a); pick physical arbor-play/prod host box; update STRATEGY/CHARTER to the product framing.
- **Strategic pivot (Skipper, session end 2026-06-26):** data-first risks becoming "cleaner TRIM IT" → the AGENT layer is the product. First agent = Bid Follow-Up Agent.

## Related
- [[arbor-core-onestop-ui]] — the first product slice (sales/estimating) built on this foundation.
- [[arbor-core-arbor-ai-system]] — the agent-layer the strategy pivots toward.
- [[arbor-core-crew-infra]] — the agent crew that builds it WITH Gilligan.
