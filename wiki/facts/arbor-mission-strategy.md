---
title: Arbor AI — mission & strategy
type: fact
domain: work
tags: [arbor-core, strategy, mission, strangler-fig, moat]
links: ["[[skipper-and-company]]", "[[two-track-confidentiality]]", "[[trimit-stack-and-tph]]", "[[build-principle-v1-first]]"]
updated: 2026-07-02
---

# Arbor AI — mission & strategy

**Mission through-line:** build **Arbor AI** = `arbor-core`, a clean in-house **Agent OS** that **replaces** TRIM IT 1 over time (**strangler-fig**), starting with the sales engine. *(Supersedes the old "Arbor sits on top of V1, not a replacement" framing.)*

## Canonical strategy
- **STRATEGY = canonical in `~/arbor-core/docs/STRATEGY.md`** (agreed **Jun 21 2026**; supersedes the archived "evolve V1.5 / V2-migration" docs).
- **Apex in one breath:** *own the edge, rent nothing strategic* · clean in-house **Agent OS** rebuild · **strangler-fig, sales-engine first** · **build WITH an agent crew** (Gilligan = foreman, Skipper = owner/director) · **two-track rule** · moat = vertical + owned.
- Detail docs under `arbor-core/docs/` (CHARTER · VISION · ADR-001 · research-*).

## Strategy evolved (Jun 20 2026)
Skipper decided to build a **clean, modern, in-house rebuild** that becomes the Arbor foundation:
- **strangler-fig**, domain-by-domain; old TRIM IT 1 demoted to read-only **history archive**; phased cutover ("many small switches, not big-bang").
- **First slice = the SALES ENGINE** (get work in the door; clean data model first — convoluted TRIM IT 1 data is what stalls even existing tools).
- **Stack = MODERN / Arbor-native (NOT ColdFusion)**; loose data-level coupling to TRIM IT 1 (pull read-only).
- Lives in a **separate private repo** `wade3337-ctrl/arbor-core`, local `~/arbor-core/`; in nightly backup.
- Confidentiality + play-server rules → [[two-track-confidentiality]].
