---
title: Herman companion agent (+ Hermes laptop decommissioned)
type: fact
domain: env
tags: [infra, herman, hermes, agent, arduino, decommissioned]
links: ["[[crew-llms-and-helpers]]", "[[env-host-and-tooling]]"]
updated: 2026-07-02
---

# 🤖 Herman agent

Specs: `arbor-stack/herman-agent-specs.md`. Snapshot: `arbor-stack/gilligan-environment-snapshot.md`.

- **Herman** = companion agent on **Arduino** (`herman@100.121.177.31`, **rrsync-only** key → `~/herman-store/`).

## 💾 Hermes LAPTOP (`desktop-4v2p8at`) — DECOMMISSIONED 2026-06-23
- Arduino Hermes removed the laptop instance after the GLM-brain experiment dead-ended (z.ai **metered** endpoint blocked on the plan + a Hermes↔z.ai **anthropic-endpoint** "no final response" compatibility wall).
- → The Arduino↔laptop **failover is now MOOT** (`Hermes_Owner_Watchdog` / `Hermes_Gateway` gone); `~/laptop-store/` sync + `~/.ssh/laptop_hermes_ed25519` are **dead**.
- ✅ **Laptop z.ai/GLM key REVOKED 2026-06-23** (Skipper; it had been pasted in chat — now dead).
- (Pre-decommission detail: `memory/2026-06-19-2302.md`.)

**Herman ≠ Hermes — different machines.**

## Related
- [[crew-llms-and-helpers]] — the LLM crew (distinct from Herman the companion agent).
