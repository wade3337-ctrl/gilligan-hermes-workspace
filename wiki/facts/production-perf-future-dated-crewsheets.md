---
title: Production Perf — future-dated crew sheets inflate production
type: fact
domain: work
track: 1
status: held
tags: [production-performance, crew-sheets, data-quality, trimit, held, brent, dashboard]
applies: ["[[dashboard-metric-standards]]", "[[repair-contract]]"]
links: ["[[rc-04-spm]]", "[[shared-engine-kills-dashboard-drift]]", "[[municipal-budgets-po-gated]]"]
updated: 2026-07-16
---

# 🚧 Production Perf — future-dated crew sheets inflate production (HELD 2026-07-16)

**Status:** ⏸️ **HELD** — Skipper is asking the team *why* the future-dated crew sheets exist before we change the dashboard. Do NOT ship the fix until he says go. Revisit later.

## What the Skipper saw
On the **Production Performance** tab (`Dashboard-ProductionPerf.cfm?ZProjectID=1105030` = City of Irvine, FY 25/26), **August 2026 shows real production** — 10 jobs / **$81,403.90** / 476.7 hrs / TPH 170.8 — even though **today is July 16, 2026** (server clock + `GETDATE()` both confirm). Irvine's FY is **Sep–Aug**, so Aug-2026 is the last (future) month of FY25/26; it should be ~$0.

## Root cause — it's DATA, not a display bug
Production is binned by **`cs.WorkDate`** (`CrewSheets`) filtered to `HoursEntered=1 AND IsCheckedIn=1 AND StatusDefs.Desc1 IN ('Active','Complete')`, summing **`cs.ActValue`** (see `ProductionPerf.data.cfm` ~line 132, filter identical at year/period/day grains). There are crew sheets with **future WorkDates**, already checked-in + hours-entered + Complete — impossible for real "produced" work. Company-wide (checked-in production $) by month:
- 2026-06 $1,613,786 (past ✓) · 2026-07 $694,713 (current, partial ✓)
- **2026-08 $469,308** · **2026-09 $78,564** · **2026-10 $9,898** — all FUTURE ❌ (~**$557K** total; max future WorkDate = **2026-10-05**).

Irvine's Aug slice = the $81,403.90 (e.g. "Service Request Trimming", "Citywide Tree Limbs" sheets dated Aug 4–11 2026, Complete).

## Proposed fix (NOT yet applied — held)
**Cap production at today**: add `AND cs.WorkDate < DATEADD(day,1,CAST(GETDATE() AS date))` (WorkDate ≤ today) to the production filter **at all three grains** (year / period / day — they must stay identical or grains drift, per the file header). Effect: future months across ALL cities → $0; Irvine year total drops $81,403.90 → ~$2.70M. "Production" then honestly means *work done to date*. Future months still list at $0 like any not-yet-happened month.

- ⚠️ This changes **headline production for every city** (excludes ~$557K company-wide) — that's why it needs the Skipper's + team's OK.
- 🔎 Same future-dated `CrewSheets` likely also touch **SPM Production/Results** ([[rc-04-spm]]) and any crew-sheet-fed surface — check those when we act.

## 🔬 DIAGNOSIS 2026-07-28 — it is NOT how TRIM IT schedules; 148 sheets were flipped
Skipper asked *"how do I have crew sheets for the future?"* The status split of **every** future-dated
crew sheet answers it:
- **741 sheets — `Pending`, `IsCheckedIn` NULL, `HoursEntered` NULL, ActValue $0.** ← the **correct** state
  for scheduled future work. The schedule exists; nothing is claimed as produced.
- **148 sheets — `Complete` + `IsCheckedIn=1` + `HoursEntered=1`, carrying $671,137** (of which $644,086
  falls in Aug/Sep/Oct; the rest is Jul 29–31).
- 21 more are `Pending` yet checked-in with hours = $64,937.

**So the system does it right 741 times and wrong 148 times — "that's just how scheduling works" is refuted.**

~~🔑 **The hours on those 148 are the ESTIMATE, copied.** `ActHours = EstHours` on **144 of 148 (97%)**
vs 20% for genuinely completed June work.~~
❌ **STRUCK 2026-07-28 — this evidence was invalid.** I compared future-sheet **hours** against past-sheet
**dollars**. The true baseline is **`ActHours = EstHours` on 98.2% of June sheets** — indeed 98–99% of
*every* month — because **`ActHours` is the estimate on every crew sheet, always**
→ [[crewsheet-acthours-is-the-estimate]]. So 97% is entirely normal and proves nothing here.
**The finding below stands on its real evidence — 741 future sheets correctly `Pending`/$0 versus 148
flipped to `Complete`+checked-in+hours-entered.** Dollars remain the meaningful signal
(`ActValue = EstValue` on only 9/148, matching the ~20% norm).
*Compare like with like: same field, same population.*

**It is concentrated, not scattered** — this is a handful of recurring municipal/HOA route blocks, not
148 independent mistakes:
- **City of Industry — 44 sheets · $353,949 · 1,693 hrs · all Aug 4–19 · one crew (Daniel Cruz Aranda) ·
  WOs 166631 + 166670 · created Mar–Jul.** That alone is **~53% of the whole problem.**
- City of Irvine (2024 Import) 34 · $80,004 · WOs 167561/167259 — Isahi M Vazquez
- Del Prado HOA 9 · $45,190 · Sep 7–18 · City of Fountain Valley 21 · $36,587 · WO 166685
- Vista Pointe Ridge 7 · $33,374 · Baker Ranch HOA 6 · $23,895 · Pacific Hills East 5 · $20,219
- **Oldest outlier: Windflower Community Association — 1 sheet, $15,786, NULL hours, `WorkDate` 2026-07-31
  but `Created` 2025-09-24.** A ten-month-old placeholder.

## 🔄 REVISED 2026-07-28 (evening) — it is ROUTINE PRACTICE, not a bulk action
The Skipper supplied a live example, **WO 168010 (City of Irvine 2024 Import)**, and it reframes everything.

**What that one work order shows:**
- WO is **Active, StartDate 7/13/26, EndDate 7/31/26** — but **11 of its 12 crew sheets are dated
  8/4 → 8/26, past the work order's own end date.**
- **All 12 sheets were created in a single batch on 7/13 at 15:03–15:06** when the schedule was generated.
- Within this one WO you can see the whole gradient: 1 past-dated Complete · 2 future-dated **Complete** ·
  3 future-dated **`Pending` but checked-in with dollars** ($1,485/$990/$340) · 1 partial · 5 clean `Pending`/$0.
- `LastModified` never moved off 7/13 15:0x, so the populated "actuals" were **written at generation**.

**Who is credited with completing the 148 future-dated sheets — FIVE different people:**
| CompletedByID | Name | Sheets | Value |
|---|---|---|---|
| 340 | Larry Baldwin | 60 | $299,069 |
| 209 | Celeste Armenta | 39 | $171,471 |
| 190 | Omar Sanchez | 29 | $117,170 |
| 119 | Manuel Perez | 18 | $72,319 |
| 37 | Victoria Farias | 2 | $11,109 |

**Five people independently doing the same thing = normal practice, not a rogue action or a script.**
(Also checked and rejected: the shared `LastUpdateDate` of 2026-07-23 08:50 is *not* a batch sweep — it
covers only 11 sheets among dozens of ordinary timestamps that day.)

🚨 **So my earlier framing was wrong twice over.** It is not "someone bulk-flipped a route block," and the
question is not "who did this." **The real question is a PROCESS one:** when a crew finishes work ahead of
the generated schedule, does the crew sheet keep its original future date? If it does, production is being
booked to the wrong month systematically — the total is right and the *timing* is wrong.

⛔ **THEREFORE: DO NOT SHIP THE CAP-AT-TODAY FIX YET.** If this is real completed work carrying a stale
scheduled date, capping production at today **deletes real revenue from the numbers** instead of correcting
them. The cap is only the right fix if the work genuinely has not happened.

**The question that settles it, and it is not a database query** — ask any of the five:
*"When you complete a crew sheet dated August 11, has the crew already done that work?"*
- **Yes** → the work is real and misdated; fix is to stamp the actual completion date, not to hide the row.
- **No** → the work is being pre-completed; the cap is right and the entry practice needs to change.

*Supporting hint, not proof: June clocked attendance was 16,765 hrs against only 12,228 hrs of June-dated
crew-sheet time — a 4,537-hour gap consistent with real work whose sheets are dated elsewhere.*

## How to SEE them (Skipper, 2026-07-28)
- **SPM dashboard** → set **From `2026-08-01`, To `2026-12-31`**, then the **Production** or **Results** tab.
  Any non-zero figure is work that has not happened.
- **Production Performance** for a single project (`Dashboard-ProductionPerf.cfm?ZProjectID=…`) — future
  months show non-zero. This is how the Irvine case was originally spotted.
- Straight to the biggest offender: **work orders 166631 and 166670 (City of Industry)**.

## Upstream question for the team
Why is ~$557K of work logged as **Complete + checked-in** with **Aug–Oct 2026** dates while it's still July? Crew-sheet WorkDate entry pattern (crews pre-dating? scheduled sheets mis-flagged checked-in?). Fixing the entry is the real cure; the dashboard cap only hides the symptom.

## Related
- [[dashboard-metric-standards]] — TPH target 130; production definition.
- [[rc-04-spm]] — shares the CrewSheets source.
- [[shared-engine-kills-dashboard-drift]] — the year/period/day filter-parity principle to preserve when editing.
