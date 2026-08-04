---
title: TRIM IT AI Field Suite
type: project
domain: work
track: 1
status: active
created: 2026-08-04
updated: 2026-08-04
tags: [trimit, ai, field-suite, inventory-import, lidar, species-id, arbornote, pricing, arbor-core]
applies: ["[[repair-contract]]", "[[trimit-gps-import-pipeline]]", "[[external-comms-contract]]"]
links: ["[[inventory-import-automation]]", "[[arbornote-account-integration]]", "[[arbor-core-strategy-foundation]]", "[[trimit-investor-case]]", "[[friction-hit-list]]", "[[herman-agent]]", "[[goodman-rfp-bid]]"]
---

# TRIM IT AI Field Suite

**One-liner:** A standalone **Track-1** suite that matches/beats ArborNote's 7 announced Enterprise
features **+ LiDAR**, built on TRIM IT and **consuming the arbor-core AI layer** — arbor-core can
orchestrate it later. Our structural moat: full ERP + 50yr GSTS pricing history + live production
data, so our AI versions **auto-price**; theirs can't.

## ✅ Decisions locked
- **Track 1, team-facing** (Skipper 2026-08-04 04:47): standalone suite that **arbor-core calls on later**.
- **AI brain, not hardcoded** per-format mappings (Skipper 04:26): LLM reads any source's columns+values,
  proposes TRIM IT canonical mappings (confidence-scored), human confirms misses, **learns back** into a
  synonym store. Deterministic lookup first, AI only on unknowns.
- **Build on Boss Herman's proven engine** (`one-shot-fresh-build.py`, 68 pitfalls), NOT Jordan/Travis's
  ArborNote SP (reference-only, unverified, wrong source). Steal only the `GSTSArborNoteSynonyms` *shape*.
- **Goodman = Davey TreeKeeper**, not ArborNote (source correction 04:26).
- **LiDAR is in scope** — build it into our app (native iOS/ARKit); converts ArborNote's one hardware moat into a checkbox.

## The win-set = ArborNote's 7 features + LiDAR
- 🟢 **#7 AI-Assisted Import** (✅ done/proven — Goodman 58/58 species · 9/9 service), **#5 AI Mass Edit**, **#6 Conversational Query/Edit** — AI-over-our-ERP; already here/ahead.
- 🟡 **#2 AI Species ID** (photos→species+health+**price**), **#3 AI Verbal Tree Entry** — vision/voice builds.
- 🔴 **#1/#4 LiDAR DBH/Height** — hardware moat; native ARKit field app (the big rock, no asset yet).
- Supporting: pricing automation (Price Buddy), kill Rebekah's manual ArborNote→GSTS `/tags` transfer, friction/investor evidence, 🔒 acquisition thesis (BLACK, pointer only).

## Where it lives
- **Project folder (canonical):** `~/arbor-stack/trimit-ai-field-suite/` — `README.md` (master plan/phases),
  `FEATURE-MAP.md` (7 features + positioning, Skipper's strategic read verbatim), `ASSET-INDEX.md` (every known asset by path).
- ⚠️ `arbor-stack` is its **own git repo** (`gilligan-arborstack`, private) — commit AND push separately from the workspace.

## Phases (proposed)
P1 synonym store + AI brain core (feature #7) · P2 native TRIM IT screens · P3 pricing layer (S1/S2) ·
P4 AI-over-ERP (#5/#6) · P5 vision/voice (#2/#3) · P6 🔴 LiDAR native app (#1/#4) · P7 prod pilot via Jordan (both webroots).

## ▶️ Resume / open
- **Next decision (for Skipper):** "all at once" P1→P7 vs land the import spine (P1–P3) first, LiDAR/AI/vision as fast-follows (LiDAR = a native-app project, the heaviest rock).
- **Gold correctness test pending:** Brent's hand-mapped Goodman file → diff row-by-row = proves *agreement* not just *coverage*. Skipper getting it from Brent (~2026-08-04).
- LiDAR path sub-decision: build our own native ARKit app vs partner/white-label the capture.
- Kanban: card on the TRIM IT board when the first build starts.
