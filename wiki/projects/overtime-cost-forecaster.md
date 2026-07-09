---
title: Overtime-Cost Forecaster (Herman-run)
type: project
domain: work
track: 1
status: active
tags: [overtime, labor-cost, herman, coo, revenue, scott-argument, tph]
applies: ["[[gsts-field-labor-rate]]"]
links: ["[[anomaly-monitor-suite]]", "[[analysis-north-yard-hours]]", "[[herman-agent]]", "[[gsts-field-labor-rate]]"]
updated: 2026-07-08
---

# Overtime-Cost Forecaster (Herman-run)

**One-liner:** An on-demand analysis Boss Herman runs against the live TRIM IT DB — *"if we cut overtime for [a yard / N guys] in [month], what's the gross-dollar forecast and the cost savings?"* — to settle the Skipper-vs-Scott overtime argument with honest, month-by-month numbers.
**Status:** 🔵 active — **method built + validated live on June 2026; Herman taught + proven (2026-07-08).** Not a wired tool by Skipper's choice — Herman reasons it from the DB each time. Next = shoulder + surge months.
**📁 Location:** teaching prompt `boss-herman-ot-prompt.txt` (workspace root) · Herman runs it via his read-only DB (`trimit-query.sh`). Engine validated gilligan-side against the anomaly-monitor endpoint.
**▶️ Resume:** this note + `memory/2026-07-08.md` (PIVOT + VALIDATED sections). Run **May 2026** (shoulder) + **Sept/Oct 2025** (fall surge) for the seasonal spread.

## The argument it settles
- **Scott's case:** OT drives high monthly gross + the guys are happier (OT pay → retention).
- **Skipper's case:** OT hurts the bottom line.
- **Skipper's key fact (unlocks the model):** GSTS does **not lose the work** when it cuts OT — it just produces slower (straight-time later). So **OT buys speed, not revenue** → the true cost of OT is the **premium**, not the whole OT wage.
- **Honest verdict (from the June data): both are partly right.** Each OT hour still makes $130 for ~$48 = profitable per hour; the only waste is the ~$11/hr premium vs waiting. The real win is **month-by-month**: cut OT in slow/no-deadline months (premium ≈ pure waste — Skipper right), keep it for the fall surge / hard-deadline work (real value — Scott right). Reframes "OT good vs bad" into "OT here yes, there no."

## Model & rates
- Loaded field-labor rates → [[gsts-field-labor-rate]]: straight **$36.57/hr**, OT **~$48/hr** ($46–50), **premium ~$11.43/hr**.
- Revenue rule: production $ = productive crew hours × **TPH (target $130/hr)**.
- **Cut-OT savings:** wage avoided now = OT hrs × $48; **durable/true saving = OT hrs × $11.43 (premium)** because the work still gets done later at straight time. Report both.
- **Gross those OT hrs made** = OT hrs × $130 — **retained** (shifts later), not lost.

## Data & method (TRIM IT)
- **Hours:** `dbo.CrewMemberCalendars.TotalHours` joined to `dbo.Calendars` (CalDate) for the month. ⚠️ **`OTHours`/`RegularHours`/`OTTotal`/$ columns are NULL** — must compute OT: per person-day `MAX(0, TotalHours−8)` (refine: 6th+ worked day in a Mon–Sun week = whole-day OT).
- **Yard split:** `dbo.CrewMembers.CrewNameID → dbo.CrewNames.SiteAssigned` (1=North, 2=South, else Other/Flex). Attribution = home crew, not day-by-day job location (close enough; tighten for per-job).
- **Specific guys:** filter `CrewMemberID` / `CrewMembers.FullName`.
- **Field-only filter:** Herman scopes to the field-labor GL (500100) → 86 field workers (matches the curated anomaly-monitor count; raw crew-table join gives ~92–93 incl. supervisors, but supervisors clock 0 OT so OT hrs are unaffected).
- Sanity check: company June ≈ 1,950–2,020 OT hrs / ~86 field workers (~12% of paid hours).

## Validated numbers — June 2026 (live)
- **Company:** 86 field workers · 16,088–16,765 paid hrs · **~1,951–2,020 OT hrs (~12%)** · OT wage **~$97K** · **premium ~$23K** (peak summer; June alone = ~43% of the ~$219K annual OT budget → running well over plan).
- **By yard (the hotspot = North):** North 51 ppl(¹) / **1,126 OT hrs (12.6%)** / premium **$12,870** / TPH ~127 · South 38 ppl / **825 OT hrs (11.2%)** / premium **$9,430** / TPH ~146 · Other/Flex 3 / 68 OT hrs.
- **Read:** North is worse on *both* counts — more OT hours **and** higher OT rate — *and* lower TPH. → cut North first (surgical ~$13K/mo, spares high-TPH South).
- (¹) Herman's field-only count = 46 North (GL-filtered); OT hrs identical either way.

## Herman — taught & proven
- Skipper handed Herman the teaching prompt 2026-07-08 16:58; Herman ran it live and **matched the verified North/South OT hrs to the unit**, improved the headcount with a GL-500100 field filter, and **independently reproduced the honest peak-season caveat** (refused to call June OT "avoidable" without shoulder months) — proof he grasped the method, not just echoed the example.
- Prompt is chat-only for now. **Pending (offered):** save it into Herman's `trimit-knowledge` vault for permanence (aggregate rates only — individual wages stay OUT per confidentiality).

## Next
- Run **May 2026** (shoulder) + **Sept/Oct 2025** (fall surge) → 3-point seasonal spread = the actual evidence for Scott (one June number alone reads as cherry-picked).
- Optional: monthly baseline surfaced **to the Skipper** (not the team-CC'd COO email — this is his analysis for Scott).
- Optional durability: fold the method into Herman's vault.

## Related
- [[anomaly-monitor-suite]] — the COO daily email; already carries OT *hours* (this adds *cost* + the with/without-OT view). Same PLAY endpoint / `CrewMemberCalendars` source.
- [[analysis-north-yard-hours]] — the one-off 45→40h analysis that first established the backlog-vs-route-constrained framing + the loaded rates; this operationalizes it.
- [[herman-agent]] — Boss Herman's DB access + knowledge-vault mechanics.
- [[gsts-field-labor-rate]] — the $36.57 straight / ~$48 OT / ~$11.43 premium rates.
