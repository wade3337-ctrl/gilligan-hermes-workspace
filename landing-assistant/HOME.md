---
title: V1.5 Landing Assistant — Vault Home
type: moc
domain: work
track: 1
model: llama3.2:3b (Ollama, localhost:11434)
status: scaffold
updated: 2026-07-11
---

# 🏝️ V1.5 Landing Assistant — Vault Home

This folder **is the assistant's brain.** It is an Obsidian vault: plain-markdown, `[[linked]]`, model-agnostic. The local model (`llama3.2:3b`) reads these notes as its knowledge + operating rules. Real numbers come from live TRIM IT queries at answer-time; these notes tell it *what it is, what it may read, and how to behave*.

**The one law:** the assistant may only surface data that a user could already see on a page reachable from the V1.5 landing page — nothing more. → [[data-scope-contract]]

## Map of the vault
- [[identity]] — who the assistant is: name, role, who it serves, tone.
- [[data-scope-contract]] — 🚦 the hard boundary: landing-page-reachable data only, and it inherits the page's role-gate.
- [[scope-map]] — the exact in-scope pages, what each exposes, and the query file behind it.
- [[architecture]] — how a question becomes an answer: chat box → CF endpoint → retrieve → ground → llama3.2 narrates.
- [[guardrails]] — never fabricate, cite the page, the data-quality traps (invoiced≠paid, TPH=130), refuse-out-of-scope.
- [[capabilities-v1]] — what it can and can't do in the first real version.
- [[open-questions]] — decisions still owed before/during the wire-up.

## Status
📝 **Scaffold** — vault written 2026-07-11. Model confirmed live locally. Next step is the *wire* (a ColdFusion endpoint that carries a message from the chat box to the model and back) — not yet built. See [[architecture]] + [[open-questions]].
