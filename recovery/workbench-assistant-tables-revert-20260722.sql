-- Revert for Arbor Helper write-actions (B1), 2026-07-22.
-- Drops the two isolated, refresh-proof assistant tables (personal to-dos + notes).
-- Safe: no live TRIM IT data depends on these; they are additive to Workbench.
USE Workbench;
IF OBJECT_ID('dbo.AssistantTodo') IS NOT NULL DROP TABLE dbo.AssistantTodo;
IF OBJECT_ID('dbo.AssistantNote') IS NOT NULL DROP TABLE dbo.AssistantNote;
