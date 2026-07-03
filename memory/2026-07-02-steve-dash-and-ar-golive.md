# 2026-07-02 — Steve's diligence dashboard (feedback build) + AR digest go-live

## Steve's Sales Performance Report — his 5-ask feature list BUILT on play (awaiting sign-off)
- `FinancialReport/FinancialReportDashboard.cfm` + `FinancialReportExport.cfm`. All render-verified, 0 CF errors.
- Rename Treatment(s)→**Tree Health Care** (label only, PHC logic intact).
- **Proposal Detail table** under the Sales Performance tab (view=2): new `SalesPerfDetail` cfquery, proposal grain,
  20 cols incl. Years (actual)/Type/Win Status/invoice realized cols. **Reconciles exactly** with the summary
  (1805 rows == SUM(WrittenN), 1429 Won both ways, no OUTER APPLY fan-out).
- view=2 got its **own Columns dropdown + Export-to-Excel** (new `mode=salesperf` export path); view-aware JS
  (own storage key + table selector; gave invoice table an id).
- **TPH width fix** (Skipper): `$` was wrapping above the number — `NumberFormat(v,'___,___')` mask emits leading
  spaces that break in a narrow cell. Fix = `white-space:nowrap` + switch detail money cells to `NumberFormat(v,',')`
  ("$135"), propagated to the sibling $ cols + the summary table for uniformity. Crew-reviewed (GLM/Kimi/Gemini).
- First time I pointed the headless browser at a TrimIT PLAY page (cert valid, ZUserID cookie auth) for a real
  click-through screenshot. Detail in `steves-projects/diligence-sales-history/CHECKPOINT-STEVE-DASH.md`; ship-log #99.
- Summary-for-Steve drafted (his to forward): `steves-projects/diligence-sales-history/SUMMARY-FOR-STEVE-2026-07-02.md`.

## AR Collections digest — property breakdown + WENT LIVE per-rep (Scott's ask)
- Scott (President): show the actual property/community, not just the PM company. The invoice-level "AR Aging
  Subtotals" sheet carries the community in each invoice **Memo** (+ per-invoice days + balance). Enhanced
  `ar-collections-monitor.js` to nest behind-properties under each account. Account totals still from the reviewed
  summary; property lines tie (Powerstone 7 props = $79,344 exactly; 29/31 accounts reconcile ≤$2). Capped 8 + "+N more".
- **Went LIVE per-rep (Skipper):** each salesperson gets ONLY their own section; complete digest → jwade + Nate
  Perkins. Routing in `ar-report/rep-emails.json` (blank=SKIP, never guess-send); `--live` flag (runner passes it),
  `--dry` shows routing. Cron tightened 2×/day → hourly business-window so it fires ~1h after Dimitry's email.
- **First live send done** 2026-07-02: 5 emails (Chesley/Cornish/Barker/Griffiths own + jwade+Perkins complete).
  ship-log #100. Confirmed addresses: e/g/r + sgriffiths + nperkins @gstsinc.com.

## Next on the email to-do list (Skipper's inbox triage, in order)
- ✅ Steve (built) · ✅ Scott AR (live)
- 🟡 **Brent — City Budgets review** (NEXT): wants updated Play link ~Jul 8–9 for apples-to-apples spot-check
  (we're 24h behind him), or he sends his report Jul 9 to compare. Needs a reply + plan by ~Jul 8.
- 🟢 Rosa — 3 example RFPs (Paradise Palms HOA / Main Place Mall / Altamar) = Cockpit bid-intake test cases (attachments).
- 🟢 Nate — "Sales Numbers 6/29–7/3" embedded chart image (informational).
