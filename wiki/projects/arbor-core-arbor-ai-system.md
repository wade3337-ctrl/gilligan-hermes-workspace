---
title: arbor-core — Arbor AI System / Hermes brain
type: project
domain: work-arbor-core
track: 2
status: proposal
tags: [arbor-core, hermes, agent-os, ai-brain, confidential]
applies: []
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-crew-infra]]", "[[arbor-core-ai-tree-vision]]"]
updated: 2026-07-03
---

# arbor-core — Arbor AI System / Hermes brain

**One-liner:** The **AI operating-system layer** on top of arbor-core — where the product owns app/API/UI/DB, this layer owns the **agent system**: Boss Hermes brain config (routing/policies/toolsets), agent definitions, role templates, employee-partner agents, prompts, workflows, domain knowledge, structured memory, integrations, operations. This is the **product's moat** per the strategic pivot — the agents are the product, the schema serves them.
**Status:** 📝 proposal — scaffold only, **no live agents.** Playground / planning stage. **First milestone: Hermes runs ONE process (B1) live.**
**📁 Location:** `arbor-core/arbor-ai-system/`
**▶️ Resume:** `arbor-core/arbor-ai-system/00-overview/README.md` (→ `architecture.md`, `source-plans/`, `open-questions.md`, `roadmap.md`)

## Applies / uses
- Two-layer split: `arbor-core/` = product/application layer; `arbor-core/arbor-ai-system/` = AI brain layer (started as a subfolder — inherits nightly backup + secret-guard; graduate to its own repo later if proven).
- Numbered structure: `00-overview` · `10-hermes-brain` · `20-agents` · `30-workflows` · `40-prompts` · `50-knowledge` · `55-memory` · `60-integrations` · `70-operations` · `80-prototypes` · `90-archive`.
- Guardrails: real business/employee data stays out of git (schemas/templates/examples only); no secrets; personal details not in agent memory.

## State & flags
- Designed by the Skipper with Hermes (Jun 2026); scaffolded by Gilligan as a local playground before anything runs for real.
- **Roadmap:** Step 0 scaffold ✅ (2026-06-24) → Step 1 settle orchestration (Q0) + permission specifics (Q1–Q5) in `open-questions.md` → Step 2 first employee-partner agent on paper (candidate: an **estimator**, since the sales/bid engine is the first arbor-core slice) → Step 3 first workflow + checkpoint → Step 4 one supervised Phase-1 loop (draft-only, human click-to-send).
- **Strategic anchor:** per the Skipper's session-end challenge, the agent layer IS the product — first agent chosen = the **Bid Follow-Up Agent**; B1 (RFP intake) is the candidate first live Hermes process.
- ⚠️ Open Q0 (orchestration / Hermes↔Gilligan role) must land before `10-hermes-brain/` is more than a placeholder.

## Related
- [[arbor-core-strategy-foundation]] — the strategic pivot that makes this layer the product/moat.
- [[arbor-core-rfp-automation]] — B1 = the candidate first live Hermes process.
- [[arbor-core-crew-infra]] — the build-time crew (distinct from these runtime agents).
- [[arbor-core-ai-tree-vision]] — a vision agent/toolset would live under this layer.
