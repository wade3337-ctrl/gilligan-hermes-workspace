---
title: Capabilities — v1
type: note
track: 1
updated: 2026-07-11
---

# Capabilities — v1

What the first real version does. Deliberately small — earn trust, then widen.

> **Update 2026-07-22:** grounding widened to the **count-once path-to-goal** (Track-1 figures only) and the read-only posture was intentionally crossed for a tiny **write surface** — see "Write-actions (B1)" below. The rest of this note is the original v1 scope.

## Write-actions (B1, live 2026-07-22)
- ✅ **Personal to-dos & notes** — "add a to-do to…", "remind me to…", "note that…", "show my to-dos/notes". Stored in isolated **Workbench** tables (`AssistantTodo`/`AssistantNote`), keyed by the caller's cookie ZUserID. **No live TRIM IT record is touched.**
- ✅ **Set-goal = deep-link**, not a direct write (goals feed every dashboard → navigate to `Dashboard-SalesGoals.cfm`).
- 🔒 Safety: parameterized inserts only (the CF datasource is `sa` → zero SQL-injection surface allowed), user-scoped, length-capped, confirmation echo.
- ⏭️ Not yet: role-gating (C), "mark to-do done".

## Can (read-only, grounded, in-scope)
- Answer plain-English questions whose answer lives on an in-scope page → [[scope-map]]:
  - "Are we on pace to goal this month?" / "TPH this week?" (Revenue Performance)
  - "Budget left in Anaheim this FY?" / "invoiced vs budgeted, Long Beach?" (City Budgets)
  - "How much is in the pipeline?" / "what sold last week?" (SPM)
  - "When did we last work site X?" / "CBRE sites for rep Garrett?" (Sales Cockpit)
- Explain what a dashboard/metric means (from this vault): "what's TPH?", "what's Work-at-Hand?"
- Point a user to the right page when a question is broader than a single number.

## Cannot (v1 — by design)
- ❌ Change anything in TRIM IT (no edits, no bids sent, no records touched). Read-only.
- ❌ Answer outside [[scope-map]] or outside the user's role node. Refuses + redirects.
- ❌ Cross-reference private/HR/financial data not on the landing page.
- ❌ Free-form web/general-knowledge chat — it's a work tool, not a search engine.

## Graduation path (later, not v1)
- Bigger local model or route to **Arbor/Hermes** for tool-use + actions (draft a follow-up, start a bid). → [[architecture]] swap point.
- Add pages to scope one at a time as dashboards ship.
