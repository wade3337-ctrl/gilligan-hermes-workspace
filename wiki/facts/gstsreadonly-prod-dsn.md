---
title: GSTSREADONLY — read-only DSN to PRODUCTION (on play)
type: fact
domain: environment
tags: [trimit, coldfusion, dsn, production, read-only, data-access, travis]
links: ["[[email-infrastructure]]", "[[trimit-stack-and-tph]]", "[[revenue-goal-close]]"]
updated: 2026-07-14
---

# GSTSREADONLY — read-only DSN to PRODUCTION (on the play server)

**Travis Walters (Data Processing, LLC) set this up 2026-07-14** (email "FW: Play Server Update", fwd by Jason). On the **play** ColdFusion server there is now a DSN **`GSTSREADONLY`** that connects to the **production** SQL Server database with a **read-only** login.

- Normal pages use the **`GSTS`** datasource = the **play** copy (nightly-refreshed from prod; can be ~24h stale). `GSTSREADONLY` = **live prod, read-only.**
- Test page: `https://play.greatscotttreeservice.com/zDBTest.cfm` (root, NOT under `/GSTS/`). Verified 2026-07-14: dumps `SELECT TOP 1 * FROM GSTS.dbo.InventoryDetail` from prod. ✅
- Usage: `<cfquery name="x" datasource="GSTSREADONLY">SELECT ... FROM GSTS.dbo.Table</cfquery>`
- **First query is slow (20–30s cold warm-up), then fast.** Don't put it on a hot path uncached; best for specific live lookups.
- Travis explicitly framed it for **"building an AI Assistant that wants to query the production server (read-only)"** → intended for our Arbor AI / dashboard work.

## Nuances / when to use
- **Read-only → safe** (no prod-write risk).
- ⚠️ **Play-only side tables are NOT on prod.** The refresh-proof **`Workbench`** DB (SalesGoal, `rgc.*`, DashboardAccess, WorkKanban) lives on the **play** SQL Server. `GSTSREADONLY` reaches **prod's `GSTS`** db only — a page can't 3-part-JOIN across the two different servers. So a dashboard that mixes GSTS operational data + Workbench config (e.g. [[revenue-goal-close]]) can't just swap the DSN; adopting live-prod there needs design.
- Good immediate fit: one-off live figures (inventory, a live customer number) where the ~24h play staleness matters.

## Open question (Skipper, 2026-07-14)
What to do with it — leave as a known capability, wire specific live lookups, or factor into the RGC/dashboard "live numbers" story. Pending his call.
