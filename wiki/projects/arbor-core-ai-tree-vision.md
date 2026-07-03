---
title: arbor-core — AI Tree Vision
type: project
domain: work-arbor-core
track: 2
status: parked
tags: [arbor-core, ai-vision, species-id, dbh, pricing, confidential]
applies: []
links: ["[[arbor-core-onestop-ui]]", "[[arbor-core-arbor-ai-system]]", "[[arbor-core-strategy-foundation]]"]
updated: 2026-07-03
---

# arbor-core — AI Tree Vision

**One-liner:** From a couple of field photos: **identify the species**, **estimate DBH / size class**, and **feed pricing** — so an arborist walks up, snaps 2 photos, and the tree is auto-identified, sized, and pre-priced with no expertise at the tap.
**Status:** ⏸️ parked sub-project (Skipper 2026-07-01) — runs alongside the coarse-pass build, not blocking it. **Gated on the MinIO photo store.**
**📁 Location:** `arbor-core/docs/`
**▶️ Resume:** `arbor-core/docs/SUBPROJECT-ai-tree-vision.md`

## Applies / uses
- Model-agnostic gateway (ADR-001) — a general multimodal model vs a tree-specific ID service (PlantNet/iNaturalist-style, or an arborist inventory program's ID feature).
- Foundation D4 trust model — an AI suggestion is `needs_review` until a human confirms; never blind-trust a photo ID.
- Foundation D7 blob store (MinIO) — photos ride the tree drill-down's photo store.

## State & flags
- **Plug-in seams already built in [[arbor-core-onestop-ui]]:** the Inventory **species datalist** (AI would auto-suggest instead of typing) · `tree.size_class` / future `dbh` (AI size estimate populates) · the tree drill-down photo store (same images feed the ID) · the estimating engine's species+size → per-year price suggestion.
- **Sequence (each stage independently useful):** coarse pass first (species datalist ✅ done) → photo store on the drill-down → size-class-from-photo (coarse S/M/L/XL) → species-ID → DBH → pricing hookup.
- ⚠️ **Blocker:** photo object-storage (MinIO) not yet built — currently photos are by-URL; this is the same deferral flagged in the One-Stop UI checkpoint.

## Related
- [[arbor-core-onestop-ui]] — all the seams (species field, size class, photo drill, pricing) live here; MinIO deferral is shared.
- [[arbor-core-arbor-ai-system]] — a vision agent would live in the AI-layer's toolset.
