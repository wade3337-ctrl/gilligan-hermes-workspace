---
title: V1.5 Landing Assistant
type: project
domain: work
track: 1
status: live-on-play
model: llama3.2:3b (Ollama, localhost:11434)
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[only-trustworthy-data]]"]
links: ["[[v15-landing-page]]", "[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[sales-cockpit]]", "[[trimit-dual-webroot-shadow]]", "[[arbor-core-arbor-ai-system]]"]
updated: 2026-07-12
---

# V1.5 Landing Assistant

**One-liner:** Turns the V1.5 landing page's "in-house lite-LLM AI chat" placeholder into a real assistant — local **llama3.2:3b** (Ollama, already on this box), grounded on **live** TRIM IT data but scoped to **only pages reachable from the landing page** (so it inherits the existing role-gate and adds no new data/security surface).
**Status:** 🟢 GROUNDED on Revenue Performance — live numbers end-to-end (2026-07-11, ship-log #118 wire + #119 grounding). `AI-Chat.cfm` pulls the dashboard's own `?aisummary=1` JSON, pre-formats a fact list in CF, llama3.2 rephrases. Live: "on pace? → ahead by $63,253"; "TPH → $179.44 ABOVE $130"; out-of-scope → redirects. Warm ~1-2s. **Along the way root-caused the [[trimit-dual-webroot-shadow]]** (CF serves C:\ shadow over D:\ — 8 GSTS .cfm affected, audit pending). **2026-07-11 overnight: full "Arbor Helper" rebuild (crew-built, ship-log #124).** KB-driven router (`AI-Chat.cfm` v2 + `ai-kb/*` 7 files) — explains ALL 6 dashboards; live figures for 3 (Revenue, City Budgets, Production Performance via `?aisummary=1`); meta (time/date/identity/help); fun (jokes/poem/weather); navigate; polished (mascot, chips, nav buttons). Crew: 3-lab design + adversarial review. **Gaps (next):** figures for Exec/SPM/Cockpit; write-actions (add-todo/save-note/set-goal); role-gating. See `landing-assistant/OVERNIGHT-BUILD-2026-07-11.md`.

**2026-07-11 — "less scripted" intelligence pass (ship-log #120):** (1) **Semantic fallback** — `classifyIntent()` lets the 3B map a fuzzy question to ONE handler from a closed list when the deterministic router misses (model picks a *category*, SQL still supplies the number → no-hallucination guard intact); dead paraphrases now answer. (2) **Annual gap-to-goal** fixed (was answering monthly goal for "this year"). (3) **Company identity** grounded — name/founded/50yrs/owner/**mission**/**vision**/**core values** (Quality, Integrity, Safety, Innovation, Caring), verbatim from [[gsts-employee-handbook-2026]] + Skipper, in `ai-kb/_site.md` + a `company-identity` handler → see [[skipper-and-company]]. (4) joke-count meta + `jokes?` plural. (5) fixed meta-count over-greedy ("what does the X page do" hijack). All deployed + verified.

**Chat box LIVE in the landing page** (`Dashboard-V15Home.cfm`, #120). **Any-period TPH/revenue/pace** via CF period-parse + trust-guarded compose (#121). **Real seasonal sales goals** now via a durable table [[gsts-2026-sales-goals-monthly]] (`Workbench.dbo.SalesGoal`) with an import/editor page `Dashboard-SalesGoals.cfm` (linked from the dashboard) — assistant + Revenue dashboard both read it, so they agree (#122/#123).

**2026-07-12 — grounded on EVERY V1.5 dashboard + shipped in the deploy package (#125–#130).** Live figures now for all 6: Revenue, City Budgets, Production Performance, **Executive** (Sales-by-Rep, Sales-by-Market penny-tied, Crew Performance — historical years work), **SPM all 4 tabs** (Pipeline/Sold/Production drill-down/Results incl. municipal), **Sales Cockpit** (exclusive stage buckets: 1,559 follow-up / 1,411 bidding / 73 won / 243 active / 52 done = 3,338, + 1,619 running-dry overlay, $40.9M open bids) + **derived math** (gap-to-goal, per-day-to-goal, ahead/behind, at-this-rate). Mascot = sticky voice on/off TTS toggle. **Security hardened:** shared `dashboard-auth-gate.cfm` on all 20 leak surfaces (real `flow.Users` user + authorized set; JSON/HTML 403 for garbage cookie) — see [[LESSONS]] broken-access-control + [[PLAYBOOK]] shared auth-gate. Assembled `DEPLOY-PACKAGE-V15-DASHBOARDS.md`; all 6 mobile-verified (iPhone 390px). **Herman handoff:** Dashboards submenu on `Profile$Main.HiRes.cfm` (Jason pilot). **Next = role-gating on the assistant; ZTest/Beta renames; exec-gate + prod-create the goals table; prod-side execution safety; audit remaining shadowed .cfm.**
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

## 🧠 2026-07-18 — "sharpen the brain" pass (Skipper: "it feels super limited") — ships #194/#195
Root cause of the limited feeling: the router only had **canned "top/best" cuts** and the 3B just *rewords* — so "least productive crew" gave the TOP crews, "who sold the least" gave top reps, "most budget left" listed OVER-budget cities, and "how are we doing / should I worry" deflected.
- **Model decision:** benchmarked a local **qwen2.5:7b** — warm 5.6s, but cold-load 120s AND it **mis-ranked** a small list (picked 71.8 as "lowest" over 61.0). Lesson: **never let the LLM do selection/math.** Kept **llama3.2:3b** (fast, GPU-resident); removed the 7B to keep the box lean for the agents (Skipper's call).
- **Fix (the pattern): CODE selects the right slice, the 3B only narrates.** Added direction-aware branches — crew/rep **least** (bottom of the sorted list), City Budgets **most/least remaining** (min/max), each code-computed (#194).
- **Cross-dashboard STATUS synthesis (#195):** `answerStatus()` pulls Revenue pace (`actual_vs_paced_gap`, TPH vs 130) + City Budgets over-budget flags → holistic "how are we doing / should I worry" answer. Router branch catches how-are-we-doing / rundown / should-i-worry / everything-ok.
- Live-verified all: least crew Jose Ortiz $65.2, lowest rep Rebekah Barker, most-left Newport Beach $1.92M, "how are we doing" → pace + TPH + 3 cities over budget. **Pattern established** → adding more cuts/synthesis is now fast. Next candidates: more "least/bottom" cuts on the other pages, trend/compare ("vs last month"), and write-actions.

## 🎯 2026-07-22 — grounded on the count-once path-to-goal (ship #, A1) — `answerCoverage()`
Skipper A1: teach the team assistant the new count-once revenue model (behind the BLACK [[deal-tracker-dashboard]]) **as Track-1 figures only** — no deal/EBITDA/valuation framing. New `answerCoverage()` handler answers "are we on track to the goal / what's the uncovered gap / how much is covered / firm sold / undated work / aging proposals."
- **Live SQL mirrors [[count-once-revenue-ledger]]** (`business-plan/refresh-deal-dashboard.py`) to the dollar: adjusted actual (acct-period invoices + `GetPeriodAccrual` bridge) + muni forecast (config $3.741M) + firm sold WOs (46/109, dated ≤12/31, muni-excluded) + risk-adj pipeline (GoAheads 49, <90d, deduped, ×40%). Verified: goal $25.05M · covered $20.31M · **uncovered $4.73M**.
- **Perf fix (the lesson):** `GetPeriodAccrual` UDF = ~90s (the whole cost; other layers ~3s). Cached in application scope — accrual 4h, figures 30min — so warm calls are 0.23–0.33s. `landing-assistant/warm-coverage.sh` cron `*/15` keeps it primed; no human eats the cold hit. → see [[LESSONS]].
- Router placed before the monthly-revenue keyword router so annual "hit our goal" ≠ monthly pace; `meta-date` guarded against "sold work with no date." Backup `ah-coverage-20260722-032049`.
- **Next:** write-actions (B, in progress) · role-gate the assistant (C) · keep muni config in sync with the ledger script.
