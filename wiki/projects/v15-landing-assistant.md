---
title: V1.5 Landing Assistant
type: project
domain: work
tags: [v15, landing, assistant, trimit, ui]
track: 1
status: live-on-play
model: llama3.2:3b (Ollama, localhost:11434)
applies: ["[[repair-contract]]", "[[gsts-ui-spec]]", "[[only-trustworthy-data]]"]
links: ["[[v15-landing-page]]", "[[rc-02-revenue-performance]]", "[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[sales-cockpit]]", "[[trimit-dual-webroot-shadow]]", "[[arbor-core-arbor-ai-system]]"]
updated: 2026-07-29
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

## ✍️ 2026-07-22 — write-actions B1: personal to-dos + notes (first write surface) — `addTodo`/`saveNote`
Skipper B1: the assistant was deliberately **read-only** in v1; this is the first, intentionally-tiny write surface. It can now take **personal to-dos & notes** ("add a to-do to…", "remind me to…", "note that…", "show my to-dos/notes") and **deep-link** to the goals editor for "change the goal" (goals feed every dashboard → navigate, not mutate).
- **Storage:** to-dos write to the **pre-existing "Get it done today" table `Workbench.dbo.Todo`** (keyed `UserID`, the same table the home-page widget + `ZTest-Todo.cfm` use) → a chat-added item **appears on the V1.5 home page** (Skipper follow-up 2026-07-22). Notes → `dbo.AssistantNote`. **No live TRIM IT record touched.** Revert: `recovery/workbench-assistant-tables-revert-20260722.sql`.
- **Safety (the key point):** the CF "GSTS" datasource connects as **`sa`** — so every write MUST be **parameterized `queryExecute`** (chat text is never concatenated into SQL) and **scoped to the caller's cookie ZUserID** (not the message). Router runs before figure routing so "remind me to check Anaheim's budget" saves a to-do, not a City Budgets lookup (verified).
- **Not yet:** role-gating (C) · "mark done" (add + list only for v1). See [[LESSONS]] for the sa-datasource injection-safety note.

## 🗣️ 2026-07-29 — he got a personality (Skipper: *"give the lil fella some personality"*)
**The complaint:** *"it's easy to ask it a question and have it go to the stock answer… Like how about the Raiders? It should say Raiders SUCK!"* — and explicitly **not** a big build.
**The diagnosis:** `AI-Chat.cfm` routed to **nine data handlers** and dropped everything else onto one canned line (*"That's outside my canopy"*). llama3.2:3b was always able to chat — **our code was gagging it.** No model download; the answer was a system prompt.
- **Built `answerBanter()` + `ai-kb/_persona.md`.** The persona lives in the KB, so the Skipper can rewrite the character with **no code change and no redeploy** (`?kbreload=1`). The nine handlers still own every data question — SQL is still the only source of a number.
- 🚨 **First guard FAILED in testing.** Free chat replied *"about 80 folks in the field and around 70 more in the office."* Two faults: I had left "about 80 people in the field" **in the persona file itself**, and the guard was a **blocklist of business nouns** that missed "folks" and "office". **A blocklist cannot work — the model always finds a word you didn't think of.** Replaced with **zero digits allowed in banter** (sole exception: OC freeways by name, so *"the 405 is a nightmare"* survives), and every company fact stripped from the persona. → [[LESSONS]] · [[only-trustworthy-data]]
- **Fixed something worse than deflecting:** the semantic fallback forced unmatched questions into the nearest of nine buckets, so *"how many people work here?"* returned **top crews by TPH** — a confident answer to a *different* question, with real numbers. The classifier is now told a nearly-fitting category is a serious error and `none` is a good answer — safe only because `none` now leads to banter instead of a dead end.
- **Jokes moved into his hands.** 8 tree jokes → **56** (48 added) plus **32 dad jokes**, all in `ai-kb/_persona.md` so every future joke edit happens in one file he owns; the handler pools the `## Tree jokes` section from **both** `_site.md` and `_persona.md`. **Counted from the served files: 56 + 32 = 88, 0 exact duplicates.** He laughs at his own jokes now (a rotating `😂 I slay me.` / `😂 Timber! Sorry. Sorry.`).
- 🔁 **Checking the neighbours caught two more:** the joke *counter* still advertised "8 tree jokes" while 41 were loaded, and both the joke and laugh pickers were **clock-based** — two asks in the same second returned the same joke. Both now ride an `application.ahJokeN` counter that advances per ask, at different strides so the joke↔laugh pairing never repeats either.
- **Verified live:** Raiders → *"total dumpster fire this season"* · traffic → *"the 405 is like a living thing"* · "how many people work here?" → *"Look it up yourself, I don't have a branch on that info!"* · every data question still routes to SQL.
- ⚠️ **Known trait:** he will invent **sports** facts (claimed a loss to the Bengals). Harmless — the digit guard only protects company data — but he is not a sports oracle.
- ⏭️ **Open:** *"how many crews/trucks do we have?"* still mis-routes to a crew-TPH answer — a deterministic keyword branch grabs it before the classifier. Needs a headcount/roster handler or a narrower keyword test. Backup `D:\GSTS\Jasonsrepairs\2026-07-29-AI-Chat-prebanter.bak`.

## 😄 2026-07-29 — PERSONALITY (Skipper: *"give the lil fella some personality... Raiders SUCK!"*)
**Root cause of "it goes to the stock answer":** nine data handlers own every data question; **everything
else hit one canned line.** llama3.2:3b was already installed and perfectly able to chat — **our code was
gagging it. Nothing needed downloading.**
- `answerBanter()` + **`ai-kb/_persona.md`** — the persona is a KB file, so the Skipper rewrites the
  personality with **no code change and no redeploy** (`?kbreload=1` to pick it up).
- **Jokes: 56 tree + 32 dad = 88**, zero duplicates. Tree jokes pool from `_site.md` **and** `_persona.md`
  so all future joke edits happen in the one file he owns. He laughs at his own jokes (8 rotating laughs).
- **Also fixed something worse than deflecting:** the semantic fallback forced unmatched questions into the
  nearest of nine buckets, so *"how many people work here?"* returned **top crews by TPH** — a confident
  answer to a different question, with real numbers. Classifier now told a near-fit is a serious error.
  Only safe because `none` now leads to conversation instead of a dead end.

### 🚨 The guard that failed, and why it matters
First numeric guard was a **blocklist of business nouns** (`crew|employees|accounts`). Free chat walked
straight past it: *"about 80 folks in the field, and around 70 more in the office."* Two faults — **"folks"
and "office" were not on the list**, and the **80 came from a stray fact I had written into the persona
file myself**. Now: **banter may contain NO digits at all**, sole exception OC freeway names, and the
persona holds zero company facts. **A blocklist cannot work — enumerate what is permitted.**

⏭️ **Still open:** *"how many crews/trucks do we have?"* still mis-routes to a crew-TPH answer (a
deterministic keyword branch grabs it before the classifier). Needs a headcount/roster handler.
He will also invent **sports** facts — harmless, the guard only protects company data.
