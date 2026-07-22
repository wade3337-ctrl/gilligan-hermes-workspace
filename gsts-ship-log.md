
### 2026-07-22 — Arbor Helper write-actions B1: personal to-dos + notes + set-goal deep-link (AI-Chat.cfm, play)
- **What:** Arbor Helper can now DO small things, not just report. New handlers `addTodo`/`saveNote`/`listTodos`/`listNotes` + a set-goal deep-link. "add a to-do to…" / "remind me to…" / "note that…" / "show my to-dos" / "show my notes" all work; "change the sales goal" navigates to `Dashboard-SalesGoals.cfm` (goals feed every dashboard → navigate, don't mutate from chat).
- **Why:** Skipper B1 (2026-07-22). The assistant was deliberately read-only (v1); this is the first, deliberately-tiny write surface.
- **Storage:** two NEW isolated tables in **Workbench** (refresh-proof) — `dbo.AssistantTodo` (6 cols) + `dbo.AssistantNote` (4 cols), indexed by ZUserID. Created via `gsql.sh` (sysadmin). **No live TRIM IT record is ever touched.**
- **Safety:** writes are **parameterized `queryExecute` only** (chat text NEVER concatenated into SQL — the CF "GSTS" datasource connects as `sa`, so injection-safety is non-negotiable), **scoped to the caller's ZUserID from the cookie** (not the message), body length-capped (todo 500 / note 2000), confirmation echo. Router placed BEFORE figure routing so "remind me to check Anaheim's budget" saves a to-do (verified) rather than firing City Budgets.
- **Revert:** `recovery/workbench-assistant-tables-revert-20260722.sql` (drops both tables).
- **Verified live (play, test user 999999, rows then deleted):** add/list/save/list/navigate all correct; write-vs-figure precedence correct; help text updated; monthly-pace, goal-read, City Budgets regressions intact.
- **Open:** not role-gated (option C) — any signed-in landing-page user gets their own private list; consistent with current posture. "Mark to-do done" not built yet (add + list only for v1).

### 2026-07-22 — Arbor Helper: count-once path-to-goal coverage answers (AI-Chat.cfm, play)
- **What:** New `answerCoverage()` handler in `AI-Chat.cfm` (V1.5 landing-page assistant). Grounds Arbor Helper on the count-once path-to-$25.05M goal: adjusted actual (acct-period invoices + accrual bridge) + municipal forecast + firm sold WOs + risk-adj pipeline = covered vs **uncovered gap**. Sub-intents: full bridge · uncovered gap · covered · firm sold · undated sold work · 90-day-aging proposals. Router + semantic-fallback ("coverage") wired; meta-date guarded so "sold work with no date" no longer hits the date handler.
- **Why:** Skipper A1 (2026-07-22) — team-facing assistant was blind to the new count-once model. **Figures ONLY, no deal/EBITDA/valuation framing** (Track-1; BLACK deal context excluded).
- **How:** All layers live `queryExecute` vs play GSTS, mirroring `business-plan/refresh-deal-dashboard.py` to the dollar. One documented config input = muni calendar-H2 ($3.741M, Skipper's call). Accrual UDF `GetPeriodAccrual` costs ~90s → cached in application scope (accrual 4h, figures 30min); `landing-assistant/warm-coverage.sh` cron `*/15` keeps it primed so users get <1s.
- **Backup:** `GSTS\Jasonsrepairs\ah-coverage-20260722-032049\AI-Chat.cfm` (72.8KB pre-change).
- **Verified live (play):** reconciles to canonical ledger — goal $25,045,428 · adjusted $11,908,495 · muni $3,741,400 · firm $3,113,468 · pipeline $1,550,837 · covered $20,314,200 · **uncovered $4,731,228** · undated $3.17M/251 · aging $0.55M/24. Warm calls 0.23–0.33s; monthly-pace + page-explainer regressions intact.
- **Open:** assistant not yet role-gated (option C) — any landing-page user can ask coverage; consistent with current un-gated posture but flagged.

### 2026-07-22 — GRANT HermanRO SELECT on Workbench.dbo.SalesGoal (play)
- **What:** Created `HermanRO` user in `Workbench` + `GRANT SELECT ON dbo.SalesGoal`. Additive; pre-state had no user/grants.
- **Why:** Lets the read-only login pull live monthly sales goals for the deal/revenue dashboard (was using the admin integrated-auth path). Privilege separation.
- **Durable?** Yes — `Workbench` is NOT in the nightly refresh (only GSTS is restored; verified via msdb restorehistory). Grant persists.
- **Revert:** `recovery/workbench-hermanro-grant-revert-20260722.sql`.
- **Verified:** RO gateway now reads SalesGoal; `refresh-deal-dashboard.py` switched to RO login, regenerated live ($25.19M), container serving HTTP 200.
