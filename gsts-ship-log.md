
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
