-- REVERT for: HermanRO read access to Workbench.dbo.SalesGoal (applied 2026-07-22, play only)
-- Pre-state: HermanRO had NO user and NO grants in Workbench (verified before apply).
-- To undo, run via admin (gsql.sh):
USE Workbench;
REVOKE SELECT ON dbo.SalesGoal FROM HermanRO;
DROP USER HermanRO;
