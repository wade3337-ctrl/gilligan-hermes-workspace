---
title: Capacity & Growth Model (field/manager/yard/equipment build-out)
type: project
domain: work
track: 1
status: active
confidentiality: black
tags: [model, capacity, growth, headcount, equipment, yards, planning, 50m]
applies: ["[[two-track-confidentiality]]", "[[only-trustworthy-data]]", "[[comms-style-and-ask-first]]"]
links: ["[[gsts-operating-plan-2026-2031]]", "[[50m-growth-goal]]", "[[trimit-investor-case]]", "[[gsts-revenue-by-geography]]", "[[gsts-field-labor-rate]]", "[[inland-empire-expansion]]", "[[trimit-stack-and-tph]]"]
updated: 2026-07-26
---

# Capacity & Growth Model

**One-liner:** A real bottom-up model of what the business physically needs to grow — **projected growth by area, and the field crews, managers, yards and equipment required to deliver it.**
**Status:** 🟢 **ACTIVE — v0.1 baseline BUILT 2026-07-26** → `business-plan/GSTS-Capacity-Growth-Model.md`. Original call: *"we need to work on real model for the business tomorrow. projected growth by area, field guys, managers, yards equipment etc… we need to be prepared for these people."*

## Why now
The operating plan and both investor decks establish the **administrative** side of scaling ([[trimit-investor-case]]: ≈17,100 hrs of friction, ≈680 admin hrs per $1M). **Nothing yet models the operational side.** "We need to be prepared for these people" = when Fort Point asks *how do you actually deliver $50M*, the answer has to be a build-out plan, not a revenue curve.

## What it has to answer
- **Growth by area** — where the revenue comes from geographically (OC · IE · LA · municipal), not just in total.
- **Field crews** — crews per $ of production; the hiring ramp implied by each year of the revenue plan.
- **Managers / supervision** — span of control; at what crew count another manager is required.
- **Yards** — capacity per yard, and the revenue level that forces a new one (a hard, lumpy, long-lead capital item).
- **Equipment** — trucks/chippers/lifts per crew, replacement cycle, capex timing.
- **The constraint question:** which of these binds first? The $24M plan work already found **production, not sales, is the binding constraint** → [[24m-operating-plan]].

## Anchors we already have (use these, don't re-derive)
- **TPH** is the productivity spine — **contract = blended · segment = productive** → [[trimit-stack-and-tph]]. Target 130.
- Field labor rates → [[gsts-field-labor-rate]] · revenue by geography → [[gsts-revenue-by-geography]].
- Municipal book (measured 2026-07-26): **11 cities · 65,793 all-paid field hrs · $8.10M** — Irvine alone ≈45%.
- Total field: **87,189 hrs / $11.1M production in 6 months** (all segments).
- Zero-revenue hours are a **measurement artifact** (two crews on one job), not idle capacity — do **not** model them as recoverable time. → [[trimit-db-gotchas]]

## Rules for this build
- **Bottom-up, measured, and say which numbers are assumptions.** Same discipline as the decks — the audience is the same people.
- **Every ratio stated per unit** (crews per $1M, managers per crew, trucks per crew) so it scales without re-deriving.
- Cross-check against the revenue ramp in [[gsts-operating-plan-2026-2031]] and the $50M target in [[50m-growth-goal]].
- ⚠️ **BLACK** — deal-aware. Never surface to Aspen/Herman/MuniBot/team.

## 📏 v0.1 BASELINE — measured 2026-07-26 (trailing 12 mo to 2026-07-22)
**The four ratios everything derives from:** production per crew **$861,600/yr** · field hours per crew **6,990** · **1.16 crews per $1M** · **3.3 field employees per crew**.
- **25 core crews** (100+ working days) produce **98.5%** of output: 174,686 hrs · **$21,539,106** · blended **TPH $123.30** (target 130).
- **3 yards** (`CrewNames.SiteAssigned` 1/2/3), **8.3 crews per yard**. Site 2 = 10 crews/$11.3M/TPH 132 · Site 1 = 12 crews/$9.1M/TPH 117 · Site 3 = 3 crews/$1.1M/TPH 101. **Site 2 beats Site 1 with two fewer crews.**
- **Fleet: 210 of 435 units Active** — core rig ≈ **5.2 units per crew** (chipper 1.64 · dump 1.48 · boom 1.20 · crew truck 0.92).
- **⚠️ TRIM IT cannot cost the fleet** — `Equipment.PurchasePrice` empty on all 435 records. Capex must come from the fixed-asset schedule / CFO.

### ▶️ The headline answer to "$50M"
**Crews 25 → 59** (56 at TPH 130) · **field staff 83 → ~195** (+112, ≈20 net hires a year for five years) · **yards 3 → 7** · field DL cost $6.4M → **$14.8M**.
**Growth is a build-out problem, not a productivity problem** — hitting TPH 130 saves only 3 crews and ~10 hires. The lumpy, long-lead constraint is **yards**.
⭐ **Biggest unexploited lever, not yet modelled: the core fleet runs TPH $22 → $183.** Closing the bottom toward the median needs no capital — but needs the job-mix explanation first.

### ❓ Blocking v0.2 (cannot be measured)
1. **Which physical yard is Site 1/2/3, and how many crews each holds** (8.3 is current practice, not capacity).
2. **Span of control** — `StaffMembers.StaffRole` is NULL on every active record; crews per foreman/supervisor/manager is not derivable.
3. **Equipment capital cost + replacement cycle.**

## Related
- [[gsts-operating-plan-2026-2031]] — the plan this must make physically credible.
- [[trimit-investor-case]] — the administrative half of the same story.
