---
title: Arbor Helper — Overnight Build Plan + Checkpoint (2026-07-11)
type: checkpoint
status: in-progress
updated: 2026-07-11
---

# Arbor Helper — overnight build (Skipper job, he's asleep)

**Goal by morning:** finished, friendly Arbor Helper on the V1.5 landing page that (1) explains + answers figures for EVERY V1.5 dashboard, (2) does fun/utility (time/date/identity/help/joke/poem/weather), (3) takes safe actions (navigate/add-todo/save-note/set-goal + extras), (4) is polished (mascot, chips, tight wording). Design = 3-lab panel (gemini/glm/fable) synthesized → `/tmp/dash/design_*.md`.

## Locked architecture (synthesis)
- **Prime directive:** CF composes every fact; the 3B only decorates; if reword fails validation, ship CF's exact sentence. Nothing breaks if Ollama is down.
- **KB files** `ai-kb/*.md` (one per page + `_site.md`): `key: value` frontmatter (id/title/role/url/aliases/figures/datasource/params) + fixed `##` sections (What it does / How to use / Numbers explained / Figure map / Sample questions). CF loads at startup into application scope.
- **Router (deterministic-first, 3B never routes a number):** 1 utility/fun regex → 2 action verbs → 3 page match (aliases, longest-first) → 3a figure match (period/entity parser + cached rep/city lists) → 4 figure-without-page (reverse index) → 5 3B tiebreak (explainer-only, JSON) → 6 out-of-scope friendly redirect.
- **Endpoint returns JSON** `{text, action, confirm, chips, source}`. Reads+nav = button/immediate; writes = one-tap confirm w/ server-frozen params + token.
- **Grounding:** each page `?aisummary=1` (reuse page query). Figure map slug→jsonKey→template.
- **Reword guard:** generalize Revenue validator — primary number + entity/period guards verbatim; no foreign month/entity; length cap; temp 0 (fun temp 0.7). keep_alive.
- **Actions:** navigate(button), add-todo, save-note, set-goal(confirm), + pin-figure/remind-me if time. New tables `Workbench.dbo.AH_Todo`/`AH_Note` (SalesGoal exists). Verbatim payload extraction, never 3B-rewritten.
- **Fun:** curated tree-joke bank in `_site.md`; poem temp 0.7 + fallback; weather = wttr.in via cfhttp (Orange County) or honest canned dodge; time/date CF-computed.

## Increments (each deployable, test before next)
- [x] v2.0 — KB files (7) + router + explainers (all 6) + meta/fun. DONE + verified.
- [x] v2.1 — grounded Revenue + **City Budgets** + **Production Performance** (per-city + aggregates). Exec/SPM/Cockpit = explainer-only (next).
- [~] v2.2 — actions: **navigate DONE** (button). add-todo/save-note/set-goal = designed, NOT built (needs confirm-card UI) → next session.
- [x] v2.3 — UI polish: mascot, tappable chips, nav buttons, warmer copy. DONE.
- [x] v2.4 — 3-lab adversarial review (gemini/glm/kimi) → fixes applied (val() cookie, weather cache, 'may' guard, CRLF). Final battery green.

## Status by morning: SHIPPED (see report). 3 dashboards grounded + all 6 explained + meta + fun + navigate + polish, crew-reviewed. Gaps documented: Exec/SPM/Cockpit figures, write-actions, role-gating.

## Pages (served files; ⚠ = C:\-shadow, deploy BOTH webroots)
- Revenue Performance `Dashboard-RevenuePerformance.cfm` ⚠ — aisummary DONE.
- Production Performance `Dashboard-ProductionPerf.cfm` — Jobs/Prod$/TPH/Diff-130, city drill.
- City Budgets `Dashboard-CityBudgets.cfm` — per city+FY Budgeted/Invoiced/CallIns/Scheduled/Remaining + Forecast.
- Executive Review `Executive$Financial$Overview$Frame$Beta.cfm` (iframe shell, 5 tabs).
- SPM `SalesProductionMeetingDashboard.cfm` (iframe shell, 4-layer funnel).
- Sales Cockpit `ZTest-SalesPipeline.cfm` — explainer-first.

## Progress log
- 2026-07-11 ~06:05 UTC: crew upgraded (gemini-3.5-flash, kimi-k2.7, codex code+review), all pinged green. 3-lab design panel done + synthesized. Plan locked. Starting v2.0.
- ~07:1x UTC: **v2.0 DONE + deployed on play.** 7 KB files (crew-drafted, refined) + router `AI-Chat.cfm` v2: explainers for all 6 pages, meta (time/date/identity/purpose/help), fun (joke bank/poem/weather via wttr.in), Revenue figures+goals (proven engine), navigate(button), out-of-scope. Returns `{ok,reply,source,intent,chips,action}`. Bugs squashed: `var` illegal outside functions; emoji needs `<cfprocessingdirective pageencoding="utf-8">`; **CF `##` in a string = literal `#` → use `####` for two hashes** (cost ~30min); `find(chr(10)&"## ")` unreliable → line-loop parse. Next: v2.3 UI polish, v2.1 ground City Budgets/Prod-Perf/Exec.
