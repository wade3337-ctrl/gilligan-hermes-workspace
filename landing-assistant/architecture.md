---
title: Architecture — how a question becomes an answer
type: note
track: 1
updated: 2026-07-11
---

# Architecture — question → answer

Plain-English walk-through, then the pieces. The golden rule for a 3B model: **it never answers from memory — only from data we inject at that moment.**

## The flow
```
[chat box on Dashboard-V15Home.cfm]
        │  user's question + who they are (ZUserID → role)
        ▼
[AI-Chat.cfm]  ← the "wire": a server-side ColdFusion page
        │  1. ROLE CHECK   — is this user allowed the topic?  → [[data-scope-contract]]
        │  2. ROUTE        — which in-scope page answers this? → [[scope-map]]
        │  3. RETRIEVE     — run THAT page's own query (live numbers)
        │                    + pull relevant vault notes (definitions/caveats)
        │  4. GROUND       — build a prompt: {rules} + {retrieved data} + {question}
        ▼
[Ollama  localhost:11434  →  llama3.2:3b]
        │  narrates the injected data in plain English (adds no facts)
        ▼
[answer + "source: <page>" back into the chat box]
```

## Two machines (important)
The model and the data are **NOT on the same box** (confirmed 2026-07-11):
- **TRIM IT / ColdFusion server** — has the data (SQL) + serves the landing page.
- **This OpenClaw box** — runs Ollama + `llama3.2:3b` (listening `*:11434`).

So the query runs *on TRIM IT* (data stays home) and only **{question + the rows already on screen}** travel over the network to Ollama here for wording. The answer comes back. Data locality is preserved; the only thing crossing the wire is chat traffic.

**Connecting them — RESOLVED (2026-07-11): Tailscale.** The two boxes are in different physical locations but on the same **Tailscale** tailnet (WireGuard mesh — private, encrypted, stable IPs). So they behave like one LAN; no SSH tunnel needed, Tailscale *is* the encrypted tunnel.
- **This box (model):** `gilligan` = **100.82.161.7** — Ollama on `:11434`.
- **TRIM IT / CF server (data):** almost certainly `gstsdatabase` = **100.86.97.46** (windows, tagged-devices, online) — *pending Skipper confirm*.
- `AI-Chat.cfm` calls **`http://100.82.161.7:11434/api/chat`**. Encrypted end-to-end by WireGuard automatically.
- 🔒 **Lock it down** (11434 is unauthenticated): (1) Tailscale **ACL** so only `gstsdatabase` may reach `gilligan:11434`; (2) bind Ollama to the tailscale interface (`OLLAMA_HOST=100.82.161.7`) so it's not also exposed on this box's physical LAN. → [[open-questions]]

## Proven end-to-end (2026-07-11)
Live test — a grounded chat call to `100.82.161.7:11434` with data injected in the system prompt:
- ✅ Correctly computed "Anaheim remaining = $187,550" from injected budget/invoiced figures.
- ✅ Obeyed a guardrail ("never say paid") — said invoiced, not paid.
- ⏱️ **Latency: cold ~21s (first call = model load), warm ~2s.** Mitigation: set Ollama `keep_alive` to hold the model in memory so users don't hit cold starts; show a "thinking…" state + timeout in the chat box.
- ⚠️ **Finding:** the 3B model *guesses* metric meanings if not told — it rendered "TPH" as "tons per hour"/"throughput per hour". **Metric definitions must be injected** (TPH = the GSTS productivity metric, target 130), never left to the model. → [[guardrails]]

## The pieces
- **The wire (`AI-Chat.cfm`)** — a small ColdFusion page on the TRIM IT server. It holds the logic and talks to Ollama at whichever address the network path above gives it. The browser never talks to the model directly (keeps everything server-side and inside the role-gate). This is the one new file to build; nothing else on the landing page changes.
- **The model** — `llama3.2:3b`, already running on this machine. Swappable later (bigger local model, or route to Arbor/Hermes) without touching the chat box — only `AI-Chat.cfm` changes.
- **Two grounding modes:**
  - **Live/structured** (numbers): re-use the dashboard's existing query → inject rows → model phrases them. Truth = SQL, model = wording.
  - **Doc/RAG** (how-things-work): retrieve from this vault → model explains. This is why the vault exists.

## Why route-then-retrieve (not "let the model query")
- A 3B model can't be trusted to write safe SQL or pick tables. We **pre-wire** each in-scope page to its known-good query. The model only ever sees results, never the keys to the database. That is what makes [[data-scope-contract]] actually hold.

## Build order (proposed)
1. **Wire smoke-test** — `AI-Chat.cfm` that just relays chat box ↔ llama3.2 (no data yet). Proves the plumbing.
2. **First grounded page** — pick ONE (recommend Revenue Performance): wire its query in, model narrates real numbers.
3. **Add role check + refuse-out-of-scope.** → [[guardrails]]
4. **Widen** one page at a time per [[scope-map]].

*Server work follows the [[repair-contract]]: backup-first, render-verify the served output, log to ship-log. `AI-Chat.cfm` is a NEW file (touches nothing existing) → low-risk.*
