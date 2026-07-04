---
title: CSV export = mandatory on every data page
type: fact
domain: how-we-work
tags: [ui-standard, csv, export, dashboards, build-checklist, feedback]
links: ["[[repair-contract]]", "[[rc-04-spm]]"]
updated: 2026-07-04
---

# CSV export = mandatory on every data page

**Skipper standing rule (reaffirmed 2026-07-04):** *"We always bake in a CSV export function to our pages — some people still like those."* Any page that shows a table/list/metric a user might want in a spreadsheet gets a CSV export, wired **up front**, not as an afterthought.

**Why:** real users (e.g. CFO Steve) work in Excel; a page without export forces hand-copying. It's cheap to add and expected.

**How to apply (the house pattern — already documented):**
- Spec: `arbor-stack/gsts-ui-spec-v1.0.md` **§CSV Export**.
- Helper: `<cfinclude template="csv-export-include.cfm">` → `csvField()` (safe quoting + Excel formula-injection guard).
- Button: small **"⬇ Export CSV"** at the top; links back to the same page with `exportCSV=1` + current filters preserved.
- Handler (after queries, before HTML): `cfheader` Content-Disposition + `cfcontent type="text/csv"` reset, build rows with `csvField()`, `cfabort`.
- Reference impls: `Dashboard-RevenuePerformance.cfm`, `SalesProductionMeeting$Results.cfm`, `Exec$PercentagePerformed2$NEW.cfm`.

**Miss to avoid:** the standard existed but I shipped a new page without it (see [[LESSONS]] 2026-07-04). Treat CSV export as a build-checklist line item on every data page.
