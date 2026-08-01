---
title: Mixture of Agents (MoA) — Hermes feature
type: reference
domain: env
status: reference
tags: [hermes, moa, models, technique]
links: ["[[gilligan-pilot-model-setup]]"]
updated: 2026-07-31
---

# 🧠 Mixture of Agents (MoA)

**What:** a panel of models instead of one. Several **reference** models each draft an answer to the same
prompt independently; a final **aggregator** model reads all the drafts and synthesizes one answer. Like a
panel of advisors + a lead editor. An ensemble → better median answer on hard problems, catches single-model
blind spots.

**Hermes specifics:**
- **Reference models** = advisors; Hermes tells them they're advisors, NOT the actor (they draft, don't
  execute tools).
- **Aggregator / orchestrator** = the one model that actually acts (calls tools, gives the answer). It gets
  the full references.
- Configure the lineup: `hermes moa configure` (interactive) or write `moa.presets.<name>` in config.yaml
  (`reference_models: [{provider,model}...]`, `aggregator: {provider,model}`). Non-recursive (a MoA preset
  can't be a slot inside another).
- Invoke: **`/moa <prompt>`**. NOT a per-turn default — it's **3-5x cost/latency** (each reference + the
  aggregator). Hermes bills each reference at its own model's rate.

**Use it for:** the occasional "get this RIGHT" call — a thorny analysis or high-stakes decision. Overkill
for routine chat.

**Gilligan's parked trio:** references gbt + glm-5.2 + kimi-k3, aggregator gbt → [[gilligan-pilot-model-setup]].
