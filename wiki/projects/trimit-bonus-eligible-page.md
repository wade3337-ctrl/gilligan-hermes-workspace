---
title: TRIM IT Bonus-Eligible (Emergency) payroll report page — for Dimitry
type: project
domain: work
track: 1
status: 🟢 BUILT + live on play 2026-08-05, gated (UserID 9/376/228); prod deploy pending Jordan
tags: [trimit, coldfusion, payroll, bonus, per-diem, dimitry, dashboard, accounting]
applies: ["[[repair-contract]]", "[[dashboard-auth-gate]]", "[[csv-export-standard]]", "[[gsts-ui-style-guide]]"]
links: ["[[trimit-db-gotchas]]", "[[crewsheet-acthours-is-the-estimate]]", "[[v15-landing-page]]", "[[dashboard-auth-gate]]"]
created: 2026-08-06
updated: 2026-08-06
---

# TRIM IT Bonus-Eligible (Emergency) payroll report page

**One-liner:** Replaces Dimitry's manual Day-Sheet-scan for payroll — he printed the TRIM IT **Day Sheet** for every day of a pay period and eyeballed the **red lines** to find bonus-eligible emergency work. This is a configurable-date-window page that surfaces them directly.

- **LIVE (play):** `https://play.greatscotttreeservice.com/GSTS/Dashboard-BonusEligible.cfm`
- **Webroot:** `D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\` · **Repo:** `arbor-stack/production-dashboard/bonus-eligible/` (gilligan-arborstack — **commit+push separately** from the workspace).
- **On the V1.5 landing** under the **Accounting** node → [[v15-landing-page]].
- **Access:** gated to **UserID 9 (Skipper) + 376 (bot) + 228 (Dimitry Rabyy)**; others 403 (verified). `dashboard-auth-gate.cfm` include + explicit allow-list → [[dashboard-auth-gate]].

## ⭐ The marker — CONFIRMED on the 2nd pass (first guess was WRONG)
- ❌ **`EmergencyTimeEntry` was WRONG** (first guess). Source `CrewLeaderDashboard.API.cfm` proves it's an **auto clock-anomaly flag** (set when someone clocks in >30 min early OR after scheduled end) → 1,606 rows, nothing to do with bonus. The Skipper caught it: *"7/20–8/2 dimitry said there should only be 2."*
- ✅ **REAL marker = `dbo.CrewAssignments.IsPerDiemEligible = 1`** — the crew-leader **"Is Bonus Eligible?"** checkbox (writes via CrewLeaderDashboard: `IsPerDiemEligible = FORM.bonusEligible EQ '1' ? -1 : 0`; bit → 1). **Verified against anchor crew sheet 541351** (Skipper's screenshot): 2 crew members (CrewMemberID 5403, 5400) both `IsPerDiemEligible=1`, 2.0 hrs each → **exactly Dimitry's 2 for 7/20–8/2** (Jose Santos Juarez Carrera + Juan Rodrigo Vazquez, Citywide Tree Limbs, 7/25).
- Both of the above gotchas are also captured in [[trimit-db-gotchas]].

## Data model (reuse recipe)
`CrewAssignments ca` (**IsPerDiemEligible** = bonus bit · CrewMemberID · CrewSheetID · **ActHours**) →
`CrewSheets cs` (WorkOrderID · **CalendarID**) → `Calendars cal` (**CalDate**, via `cs.CalendarID`) +
`WorkOrders wo` (Desc1=job · YardTypeID · ProjectID) + `CrewMembers cm` (**FullName**, via `ca.CrewMemberID`) +
`Projects p → GeoMarkets gm` (market). Yard from `dbo.YardTypes` (**1=North, 2=South**).

🐞 **KEY GOTCHA:** `CrewAssignments.CalendarID` and `CrewAssignments.WorkDate` are **NULL** → the date MUST come from `CrewSheets.CalendarID → Calendars.CalDate`, NOT from CrewAssignments. (This is why the window count kept returning 0.) → [[trimit-db-gotchas]]. ⚠️ NOT UserCalendars/flow.Users — that was the wrong-marker model.

## The page
- **Two views (toggle):** Per-employee rollup (bonus hrs/person for payroll, default) + Detail lines (each entry; job links to the work order `Profile.WorkOrder.Detail.cfm?ZWorkOrderID=` — verified 200).
- **CSV export** of the current view + filters (Content-Disposition attachment) → [[csv-export-standard]].
- **Filters:** Yard (North/South) + **Market → 4 buckets** from GeoMarkets: **Municipal** (Cities/Counties/Parks/Schools) · **HOA** · **Retail** · **Commercial** (everything else incl. Universities/Property Mgmt). Skipper-approved split.
- **Pay period = pre-configured dropdown** (Skipper: the earlier anchor+length config editor was confusing — removed). Table `Workbench.dbo.PayrollBonusPeriods` (biweekly, aligned 7/20-8/2; PeriodID 31 = 7/20-8/2). Page defaults to the current period; manual From/To kept. ⚠️ **Cadence (biweekly) is a GUESS — confirm GSTS actual pay calendar.**
- **Designator = employee CAPABILITY CODES, ALL of them** (Skipper: set on crew-member Capabilities tab). Source `dbo.Capabilities.CodeDesc1` (Driver=**D**, Groundsman=**G**, Climber/Trimmer=**T**, Bucket/Rolloff=D, Crew Leader=CL) via `dbo.CrewMemberCapabilities`. Report shows the **full comma-separated distinct list**, alphabetized — `STUFF((SELECT ', '+x.CodeDesc1 FROM (SELECT DISTINCT cap.CodeDesc1 …) x ORDER BY x.CodeDesc1 FOR XML PATH('')),1,2,'')`. Verified vs Skipper's report: Jose(5400)=**D, T**; Juan(5403)=**CL, D, T**. (Earlier single-code collapse w/ T>D>G priority was WRONG.) → [[PLAYBOOK]].
- **Bonus is FIXED yes/no** (not hours). "Hours Worked" = actual clock `ca.ActStart`-`ca.ActEnd` (e.g. 9:30–11:30 AM), NOT summed; KPIs = Bonus entries / Employees. `ca.ActHours` kept in CSV. (⚠️ ActHours is the estimate → [[crewsheet-acthours-is-the-estimate]].)
- Style = green brand package (`assets/css/gsts-tokens.css` + inline tokens), app-bar header, matches BOD dashboard look → [[gsts-ui-style-guide]].
- The historic Day Sheet report is a ColdFusion **binary `.cfr`**, not on play → confirmed the marker via source + the anchor record instead.

## ▶️ OPEN / TODO
- **Deploy to PROD via Jordan** when the Skipper approves (so Dimitry runs real payroll off it; currently play-only). Log to `gsts-ship-log.md` + the Reference page per the repair contract at deploy.
- Confirm the actual GSTS **pay calendar** (biweekly is a guess — drives the pre-configured periods).
- Possible enhancement if asked: compute the **dollar bonus amount** (needs the bonus rate/rule from Dimitry).

## Related
- [[trimit-db-gotchas]] — the two marker/date gotchas that made or broke this build.
- [[v15-landing-page]] — where it lives (Accounting node).
