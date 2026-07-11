---
title: V1.5 Landing Assistant
type: project
domain: work
track: 1
status: scaffold
model: llama3.2:3b (Ollama, localhost:11434)
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[only-trustworthy-data]]"]
links: ["[[v15-landing-page]]", "[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[sales-cockpit]]", "[[arbor-core-arbor-ai-system]]"]
updated: 2026-07-11
---

# V1.5 Landing Assistant

**One-liner:** Turns the V1.5 landing page's "in-house lite-LLM AI chat" placeholder into a real assistant — local **llama3.2:3b** (Ollama, already on this box), grounded on **live** TRIM IT data but scoped to **only pages reachable from the landing page** (so it inherits the existing role-gate and adds no new data/security surface).
**Status:** 🟢 GROUNDED on Revenue Performance — live numbers end-to-end (2026-07-11, ship-log #118 wire + #119 grounding). `AI-Chat.cfm` pulls the dashboard's own `?aisummary=1` JSON, pre-formats a fact list in CF, llama3.2 rephrases. Live: "on pace? → ahead by $63,253"; "TPH → $179.44 ABOVE $130"; out-of-scope → redirects. Warm ~1-2s. **Along the way root-caused the [[trimit-dual-webroot-shadow]]** (CF serves C:\ shadow over D:\ — 8 GSTS .cfm affected, audit pending). **2026-07-11 overnight: full "Arbor Helper" rebuild (crew-built, ship-log #124).** KB-driven router (`AI-Chat.cfm` v2 + `ai-kb/*` 7 files) — explains ALL 6 dashboards; live figures for 3 (Revenue, City Budgets, Production Performance via `?aisummary=1`); meta (time/date/identity/help); fun (jokes/poem/weather); navigate; polished (mascot, chips, nav buttons). Crew: 3-lab design + adversarial review. **Gaps (next):** figures for Exec/SPM/Cockpit; write-actions (add-todo/save-note/set-goal); role-gating. See `landing-assistant/OVERNIGHT-BUILD-2026-07-11.md`.

**2026-07-11 — "less scripted" intelligence pass (ship-log #120):** (1) **Semantic fallback** — `classifyIntent()` lets the 3B map a fuzzy question to ONE handler from a closed list when the deterministic router misses (model picks a *category*, SQL still supplies the number → no-hallucination guard intact); dead paraphrases now answer. (2) **Annual gap-to-goal** fixed (was answering monthly goal for "this year"). (3) **Company identity** grounded — name/founded/50yrs/owner/**mission**/**vision**/**core values** (Quality, Integrity, Safety, Innovation, Caring), verbatim from [[gsts-employee-handbook-2026]] + Skipper, in `ai-kb/_site.md` + a `company-identity` handler → see [[skipper-and-company]]. (4) joke-count meta + `jokes?` plural. (5) fixed meta-count over-greedy ("what does the X page do" hijack). All deployed + verified.

**Chat box LIVE in the landing page** (`Dashboard-V15Home.cfm`, #120). **Any-period TPH/revenue/pace** via CF period-parse + trust-guarded compose (#121). **Real seasonal sales goals** now via a durable table [[gsts-2026-sales-goals-monthly]] (`Workbench.dbo.SalesGoal`) with an import/editor page `Dashboard-SalesGoals.cfm` (linked from the dashboard) — assistant + Revenue dashboard both read it, so they agree (#122/#123). **Next = role-gating (inherit landing-page Title gate); repurpose dashboard's old goal input; exec-gate + prod-create the goals table; ground more scope-map pages; audit the 8 shadowed .cfm.**
**📁 Vault (the assistant's brain):** `landing-assistant/` → open `landing-assistant/HOME.md`
**▶️ Resume:** `landing-assistant/open-questions.md` (decisions owed) → then `landing-assistant/architecture.md` build order.

## The idea in one breath
The chat box is a UI shell with no brain. We give it a brain (llama3.2) + a wire (a server-side CF page) + grounding. Because a 3B model knows nothing about GSTS, it **only ever speaks from data injected at query-time** — which is exactly the Skipper's scope rule: reuse the *same queries* the landing-page dashboards already run. The model narrates; SQL is the truth.

## Scope contract (the heart of it)
- **Landing-page-reachable data only.** If a user couldn't click to it from the landing page, the assistant can't say it. → `landing-assistant/data-scope-contract.md`
- Inherits the page's role-gate (`COOKIE.ZUserID → Users.Title`): a rep can't pull exec figures via chat.
- In-scope set is finite + listed: Revenue Performance, City Budgets, SPM, Sales Cockpit, Arborist Workbench/My Jobs, Executive Review → `landing-assistant/scope-map.md`.

## State & flags
- ✅ Local model confirmed live: `llama3.2:3b` on Ollama `localhost:11434` (3B Q4 — fast, tiny → grounding is mandatory).
- ✅ Vault written (8 notes): HOME · identity · data-scope-contract · scope-map · architecture · guardrails · capabilities-v1 · open-questions.
- Guardrails bake in the GSTS data-quality traps: **invoiced≠paid**, **TPH target 130**, fuzzy manager identity, `Locations` not `Projects.Lat/Long`, only-trustworthy-data-leaves.
- ⏭️ **Next:** answer open-questions (name; Ollama box location vs CF server; play-first) → build `AI-Chat.cfm` smoke-test → ground ONE page (rec: Revenue Performance) → add role check → widen.
- Follows [[repair-contract]]: `AI-Chat.cfm` is a NEW file on play, backup-first, render-verify, log to ship-log.

## Related
- [[v15-landing-page]] — the host page; this fills its lite-LLM chat placeholder.
- [[arbor-core-arbor-ai-system]] — the graduation target: swap the brain from llama3.2 to Hermes for tool-use/actions.
