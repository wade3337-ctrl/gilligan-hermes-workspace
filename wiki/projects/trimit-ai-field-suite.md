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

## 🧱 Full modular design (self-contained — canonical detail in `~/arbor-stack/trimit-ai-field-suite/ARCHITECTURE.md`)
**Everything is plug-in modules on a shared core.** A module ships, hides behind an enable flag, or is removed without touching the core or its siblings.

**Shared CORE (7 services):**
- **C1 Source Adapters** — ingest ANY source (TreeKeeper xlsx/shp, ArborNote `/tags`, raw file, photo, voice) → one normalized 43-col staging shape.
- **C2 AI Translation Brain** — map any vocabulary → TRIM IT canonical (species/service/size/height/condition/grow-space), confidence-scored (LLM + deterministic lookup).
- **C3 Learning Synonym/Crosswalk Store** — known values resolve instantly; accepted picks write back so it gets smarter. `Workbench` tables (survive restore); seeds = Goodman crosswalks; shape borrowed from `GSTSArborNoteSynonyms`.
- **C4 Pricing Engine** — every tree → GSTS price + labor hours from 50yr history (**the moat**). Price Buddy + `HoursEach`.
- **C5 Import Engine** — Herman's `one-shot-fresh-build.py` (68 pitfalls handled). NOT Jordan's SP.
- **C6 Verify/QC — self-validating correctness** (no human answer-key): ① resolves to a REAL InventoryGroup/ServiceType (never UNDEFINED cat-197) · ② species has REAL pricing history · ③ renders through full FK chain · ④ price in sane range. Tiers: T1 verbatim / T2 botanical / T3 AI-fuzzy(→human confirm). T1/T2 auto-apply.
- **C7 Confidence & Audit** — every AI decision logged w/ confidence + provenance; nothing auto-imports below threshold.

**Module contract** (how ANY function plugs in — the 7 features + any new idea declare the same 6): inputs · core services used (C1–C7) · outputs · UI surface · enable flag · verify hook. Register a manifest row to add; flip a flag to disable; drop the row to remove. Core untouched.

**v1 feature modules = ArborNote's 7:** M1 AI Import (#7, proven spine) · M2 Species-ID vision (#2) · M3 Verbal Entry voice (#3) · M4 Mass Edit (#5) · M5 Conversational Query/Edit (#6) · M6 LiDAR capture (#1/#4, native ARKit app = the big rock).

**⏸️ Parked (roadmap, NOT v1 — do not lose):** N1 Inventory→Bid (sleeper flagship; ArborNote structurally can't do it) · N2 risk/priority score · N3 re-inventory diff · N4 portfolio health rollup · N5 photo→WO · N6 GPS dedup · N7 crew route optimize.

## Phases (proposed)
P1 synonym store + AI brain core (feature #7) · P2 native TRIM IT screens · P3 pricing layer (S1/S2) ·
P4 AI-over-ERP (#5/#6) · P5 vision/voice (#2/#3) · P6 🔴 LiDAR native app (#1/#4) · P7 prod pilot via Jordan (both webroots).

## ✅ More decisions (2026-08-04 04:53)
- **Design whole, assemble MODULAR** — plug-in modules on a shared core (add/remove functions freely). Full design: `~/arbor-stack/trimit-ai-field-suite/ARCHITECTURE.md` (7 core services C1–C7 · module contract · M1–M6 features · N1–N7 new-moat modules).
- **Correctness is self-validating** against TRIM IT ground truth (real InventoryGroup/ServiceType + real pricing history + renders + sane price) — **NOT** dependent on Brent's hand-map (that's an optional cross-check now). Stronger than one arborist's opinion.
- **New moat modules invented — ⏸️ PARKED (Skipper 05:00, kept on roadmap, worked later, do NOT lose):** N1 Inventory→Bid (sleeper flagship — the thing ArborNote structurally can't do), N2 risk/priority score, N3 re-inventory diff, N4 portfolio health rollup, N5 photo→WO, N6 GPS dedup, N7 crew route optimize.
- **✅ v1 scope locked = CORE (C1–C7) + the 7 ArborNote features (M1–M6).**

## ▶️ Resume / open
- **Next decision (for Skipper):** react to the core/module-contract shape; then pick the build kickoff. LiDAR sub-decision: own ARKit app vs partner. (N1–N7 parked.)
- Kanban: card on the TRIM IT board when the first build starts.
- Build order: core (C1–C7) → M1 import spine → software modules (N1/M4/M5) → vision/voice (M2/M3) → LiDAR (M6, big rock).
