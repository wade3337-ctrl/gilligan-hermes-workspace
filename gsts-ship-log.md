
### 2026-07-22 — GRANT HermanRO SELECT on Workbench.dbo.SalesGoal (play)
- **What:** Created `HermanRO` user in `Workbench` + `GRANT SELECT ON dbo.SalesGoal`. Additive; pre-state had no user/grants.
- **Why:** Lets the read-only login pull live monthly sales goals for the deal/revenue dashboard (was using the admin integrated-auth path). Privilege separation.
- **Durable?** Yes — `Workbench` is NOT in the nightly refresh (only GSTS is restored; verified via msdb restorehistory). Grant persists.
- **Revert:** `recovery/workbench-hermanro-grant-revert-20260722.sql`.
- **Verified:** RO gateway now reads SalesGoal; `refresh-deal-dashboard.py` switched to RO login, regenerated live ($25.19M), container serving HTTP 200.
