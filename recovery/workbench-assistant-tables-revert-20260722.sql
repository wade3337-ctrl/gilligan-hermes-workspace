-- Revert for Arbor Helper write-actions (B1), 2026-07-22.
-- NOTE: to-dos were UNIFIED onto the pre-existing V1.5 "Get it done today" table
--   Workbench.dbo.Todo (created by ZTest-Todo.cfm) — DO NOT drop that; it predates B1.
-- The only B1-created table left is AssistantNote (notes have no on-page widget).
USE Workbench;
IF OBJECT_ID('dbo.AssistantNote') IS NOT NULL DROP TABLE dbo.AssistantNote;
-- (dbo.AssistantTodo was already dropped once to-dos moved to dbo.Todo.)
