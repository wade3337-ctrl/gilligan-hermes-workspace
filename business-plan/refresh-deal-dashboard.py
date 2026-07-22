#!/usr/bin/env python3
# 🔒 CONFIDENTIAL/BLACK — regenerates deal-tracker-dashboard.html from LIVE TRIM IT + set goals.
# Revenue-productivity board: monthly GOAL vs live ACTUAL vs what's ON THE SCHEDULE (booked), + pace.
# Runs on a cron (see crontab). Read-only gateway pulls: invoiced revenue + scheduled crew work.
import subprocess, os, pathlib, datetime

ROOT = pathlib.Path(__file__).parent
GATEWAY = os.path.expanduser("~/herman-gateway/trimit-ro-query.sh")            # read-only login: Invoices + CrewSheets + (since 7/22) Workbench.SalesGoal
# Municipal forecast — pulled from Brent's CANONICAL City Budgets forecast engine (all-cities CSV), so this
# board can't drift from his dashboard. Read-only GET, ZUserID cookie (same as view.sh).
MUNI_CSV_URL = "https://play.greatscotttreeservice.com/GSTS/Dashboard-CityBudgets.cfm?ZProjectID=all&ZTab=forecast&exportForecastAllCSV=1"
TPH_TARGET = 130
FIELD_STAFF = 83
WEEK_CAP_HRS = FIELD_STAFF * 40                # ~3,320 weekday crew-hrs/week

# --- Monthly revenue goals: pulled LIVE from Workbench.dbo.SalesGoal (edit in TRIM IT → dash follows). ---
# FALLBACK if the admin read path is unavailable (keep current so the board never shows stale/blank goals).
FALLBACK_TARGET = {1:2534354, 2:1829430, 3:1831427, 4:2117795, 5:1950446, 6:1987524,
                   7:2087119, 8:2200000, 9:2200000, 10:2200000, 11:2200000, 12:2050000}  # snapshot 2026-07-22
MONTHS = ["", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

# --- Deal-context constants (collapsed strip). Update when a new financials deck / QoE lands. ---
DEAL = dict(ttm_ebitda=3.80, ebitda_floor=4.1, ebitda_target=4.8,
            earnout_est=2.7, earnout_max=5.0, net_close=33.4, jason_close=1.0,
            eip_lo=1.44, eip_hi=2.48)

def q(sql):
    r = subprocess.run(["bash", GATEWAY], input=sql, capture_output=True, text=True, timeout=120)
    return r.stdout

def muni_forecast_remaining():
    """All-cities grand-total 'Remaining' from Brent's canonical forecast engine (contracted, not-yet-invoiced/scheduled)."""
    try:
        r = subprocess.run(["curl","-s","-k","--max-time","30","-H","Cookie: ZUserID=376", MUNI_CSV_URL],
                           capture_output=True, text=True, timeout=40)
        for line in r.stdout.splitlines():
            if line.startswith('"GRAND TOTAL'):
                cols = [c.strip().strip('"') for c in line.split(",")]
                return float(cols[-1])          # Remaining = last column
    except Exception:
        pass
    return None

def rows_of(out, ncol):
    """parse pipe-delimited gateway output into lists of stripped fields (data rows only)."""
    res = []
    for line in out.splitlines():
        p = [x.strip() for x in line.split("|")]
        if len(p) == ncol and p[0] not in ("", "-") and not p[0].startswith("-") and "=" not in line:
            res.append(p)
    return res

# --- live pull 0: 2026 monthly revenue GOALS from Workbench.dbo.SalesGoal (fallback to snapshot) ---
TARGET, goals_live = dict(FALLBACK_TARGET), False
try:
    got = {}
    for p in rows_of(q("SET NOCOUNT ON; SELECT MonthNum, CAST(Goal AS decimal(14,0)) FROM Workbench.dbo.SalesGoal WHERE FiscalYear=2026 ORDER BY MonthNum;"), 2):
        if p[0].isdigit(): got[int(p[0])] = float(p[1])
    if len(got) == 12:            # only trust a complete 12-month pull
        TARGET, goals_live = got, True
except Exception:
    pass
GOAL = sum(TARGET.values())

# --- live pull 1: 2026 monthly invoiced revenue (ACTUAL) ---
rev = {}
for p in rows_of(q("SELECT MONTH(InvoiceDate),CAST(SUM(Total) AS decimal(14,0)) FROM dbo.Invoices WHERE YEAR(InvoiceDate)=2026 GROUP BY MONTH(InvoiceDate);"), 2):
    if p[0].isdigit(): rev[int(p[0])] = float(p[1])

# --- live pull 2: 2026 scheduled crew work by month (ON SCHEDULE / booked-not-done) ---
sched = {}
for p in rows_of(q("SELECT MONTH(WorkDate),CAST(SUM(ScheduledTotal) AS decimal(14,0)) FROM dbo.CrewSheets WHERE YEAR(WorkDate)=2026 GROUP BY MONTH(WorkDate);"), 2):
    if p[0].isdigit(): sched[int(p[0])] = float(p[1])

# --- live pull 3: next 28 days scheduled $ + hours, by week ---
wk_out = q("SELECT MIN(CAST(WorkDate AS date)),CAST(SUM(ScheduledTotal) AS decimal(14,0)),"
           "CAST(SUM(ScheduledHours) AS decimal(12,0)) FROM dbo.CrewSheets "
           "WHERE WorkDate>=CAST(GETDATE() AS date) AND WorkDate<DATEADD(day,28,CAST(GETDATE() AS date)) "
           "GROUP BY DATEDIFF(day,CAST(GETDATE() AS date),CAST(WorkDate AS date))/7 ORDER BY 1;")
weeks = []
for p in rows_of(wk_out, 3):
    if "-" in p[0] and p[0][:4].isdigit():
        weeks.append((p[0], float(p[1] or 0), float(p[2] or 0)))

today = datetime.date.today()
cur_mo = today.month if today.year == 2026 else 12
ytd_actual = sum(rev.values())
remaining_to_goal = GOAL - ytd_actual
pct = ytd_actual / GOAL * 100

# pace through COMPLETE months only
complete = [m for m in range(1, 13) if m < cur_mo]
actual_complete = sum(rev.get(m, 0) for m in complete)
target_complete = sum(TARGET[m] for m in complete)
pace_delta = actual_complete - target_complete
last_complete = max(complete) if complete else 0

# coverage of the remaining goal, 3 ways: booked (on schedule) · forecasted muni (contracted) · still-to-sell (open)
booked_remaining = sum(sched.get(m, 0) for m in range(cur_mo, 13))    # current+future scheduled crew backlog (all work)
muni_fc = muni_forecast_remaining()                                   # Brent's engine; None if fetch failed
muni_live = muni_fc is not None
muni_fc = muni_fc or 0.0                                              # contracted muni remaining (excl. already-invoiced & already-scheduled → no overlap w/ booked/actual)
still_to_sell = max(0, remaining_to_goal - booked_remaining - muni_fc)
den = remaining_to_goal if remaining_to_goal else 1
booked_pct = booked_remaining / den * 100
muni_pct   = muni_fc / den * 100
sell_pct   = still_to_sell / den * 100

ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
def m2(x): return f"${x/1e6:.2f}M"
def k(x):  return f"${x/1e3:.0f}K"

# ---------- monthly table ----------
rows = ""
for m in range(1, 13):
    goal = TARGET[m]; act = rev.get(m); sc = sched.get(m, 0)
    if m < cur_mo:                                   # complete: judged on actual vs goal
        d = (act or 0) - goal; pctm = (act or 0)/goal
        st, cl = (("✅ hit","gok") if pctm>=1 else ("◑ close","gwarn") if pctm>=0.95 else ("✗ missed","gbad"))
        actd = m2(act) if act is not None else "$0"
        oncol = "—"; sell = f"{'+' if d>=0 else '−'}{m2(abs(d))}"
    elif m == cur_mo:                                # in progress: invoiced + still booked
        cover = (act or 0) + sc; gap = max(0, goal - cover)
        st, cl = "◐ in progress", "gcur"
        actd = m2(act or 0); oncol = m2(sc); sell = (k(gap) if gap else "covered")
    else:                                            # upcoming: booked vs still-to-sell
        gap = max(0, goal - sc)
        st, cl = "upcoming", "gsoft"
        actd = "—"; oncol = m2(sc) if sc else "$0"
        sell = m2(gap)
    rows += (f'<tr class="{cl}"><td>{MONTHS[m]}</td><td>{m2(goal)}</td><td>{actd}</td>'
             f'<td>{oncol}</td><td>{sell}</td><td class="stcell">{st}</td></tr>')

# remaining-period totals row (current..Dec)
rg = sum(TARGET[m] for m in range(cur_mo,13))
ra = rev.get(cur_mo,0)
rows += (f'<tr class="gtot"><td>Jul–Dec</td><td>{m2(rg)}</td><td>{m2(ra)}</td>'
         f'<td>{m2(booked_remaining)}</td><td>{m2(still_to_sell)}</td><td class="stcell">to sell</td></tr>')

# ---------- next-weeks schedule strip ----------
wk_rows = ""
for (ws, sc, hrs) in weeks[:4]:
    try: lbl = datetime.date.fromisoformat(ws).strftime("%b %-d")
    except Exception: lbl = ws
    caputil = hrs / WEEK_CAP_HRS * 100 if WEEK_CAP_HRS else 0
    wk_rows += (f'<tr><td>Week of {lbl}</td><td>{m2(sc)}</td><td>{hrs:,.0f} hrs</td>'
                f'<td>{caputil:.0f}% of crew capacity</td></tr>')

pace_word = "AHEAD of plan" if pace_delta >= 0 else "BEHIND plan"

html = f"""<!DOCTYPE html>
<!-- 🔒 CONFIDENTIAL / BLACK — Fort Point revenue tracker. Skipper only. Auto-generated; do not hand-edit. -->
<html lang="en"><head><meta charset="utf-8"><meta http-equiv="refresh" content="900"><title>GSTS Revenue Tracker</title>
<style>
 body{{background:#0d1117;color:#e6edf3;font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:0;padding:28px}}
 h1{{font-size:22px;margin:0 0 2px}} .sub{{color:#8b949e;font-size:13px;margin-bottom:22px}} .live{{color:#3fb950}}
 .hero{{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:16px}}
 @media(max-width:800px){{.hero{{grid-template-columns:1fr}}}}
 .card{{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:18px}}
 .card .lab{{color:#8b949e;font-size:12px;text-transform:uppercase;letter-spacing:.5px}}
 .card .big{{font-size:32px;font-weight:700;margin:6px 0 2px}} .card .tgt{{color:#8b949e;font-size:13px}}
 .bar{{height:7px;background:#21262d;border-radius:5px;margin-top:12px;overflow:hidden}} .fill{{height:100%;border-radius:5px;background:#3fb950}}
 .gk{{color:#3fb950}} .gb{{color:#ff7b72}}
 .covwrap{{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:18px;margin-bottom:8px}}
 .covwrap .lab{{color:#8b949e;font-size:12px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:10px}}
 .cov{{display:flex;height:26px;border-radius:6px;overflow:hidden;font-size:12px;font-weight:700;color:#0d1117}}
 .cov .b{{background:#3fb950;display:flex;align-items:center;justify-content:center}}
 .cov .m{{background:#58a6ff;display:flex;align-items:center;justify-content:center}}
 .cov .s{{background:#d29922;display:flex;align-items:center;justify-content:center}}
 .covleg{{color:#8b949e;font-size:12px;margin-top:8px}}
 h3{{margin:26px 0 6px;font-size:15px}}
 table{{width:100%;border-collapse:collapse;font-size:13px}}
 td,th{{padding:9px 12px;border-bottom:1px solid #21262d;text-align:left}} th{{color:#8b949e;font-weight:600;text-transform:uppercase;font-size:11px;letter-spacing:.5px}}
 .stcell{{font-weight:600}}
 tr.gok .stcell{{color:#3fb950}} tr.gbad .stcell{{color:#ff7b72}} tr.gwarn .stcell{{color:#e3b341}}
 tr.gcur{{background:#12233d}} tr.gcur .stcell{{color:#58a6ff}} tr.gsoft td{{color:#8b949e}}
 tr.gtot{{background:#171d26;font-weight:700}} tr.gtot .stcell{{color:#e3b341}}
 .note{{margin-top:14px;background:#161b22;border:1px solid #30363d;border-left:4px solid #e3b341;border-radius:10px;padding:14px;font-size:13px}} .note b{{color:#e3b341}}
 details{{margin-top:26px;background:#12161c;border:1px solid #262c34;border-radius:10px;padding:6px 16px;color:#8b949e;font-size:12px}}
 details summary{{cursor:pointer;color:#8b949e;font-size:12px;padding:8px 0;user-select:none}}
 details td{{padding:6px 10px;font-size:12px;border-bottom:1px solid #1c2128}} details .dk{{color:#c9d1d9}}
 .foot{{color:#6e7681;font-size:11px;margin-top:16px}}
</style></head><body>
<h1>🎯 GSTS Revenue Tracker — 2026 goal $25.1M</h1>
<div class="sub"><span class="live">● LIVE</span> actuals + schedule + {'goals' if goals_live else 'goals(snapshot)'} from TRIM IT · goal ${GOAL/1e6:.2f}M · updated {ts} · auto-refresh 15 min. Confidential (Skipper only).</div>

<div class="hero">
 <div class="card"><div class="lab">Booked YTD (invoiced)</div><div class="big">{m2(ytd_actual)}</div><div class="tgt">of $25.1M goal · {pct:.0f}% · through {MONTHS[cur_mo]} (partial)</div><div class="bar"><div class="fill" style="width:{min(100,pct):.0f}%"></div></div></div>
 <div class="card"><div class="lab">Remaining to hit goal</div><div class="big">{m2(remaining_to_goal)}</div><div class="tgt">to reach $25.1M by Dec 31</div></div>
 <div class="card"><div class="lab">Pace vs plan (thru {MONTHS[last_complete]})</div><div class="big {'gk' if pace_delta>=0 else 'gb'}">{'+' if pace_delta>=0 else '−'}{m2(abs(pace_delta))}</div><div class="tgt">{pace_word} · booked ${actual_complete/1e6:.1f}M vs goal ${target_complete/1e6:.1f}M</div></div>
</div>

<div class="covwrap"><div class="lab">Coverage of the {m2(remaining_to_goal)} remaining — booked · forecasted muni · still to sell</div>
 <div class="cov"><div class="b" style="width:{max(5,booked_pct):.0f}%">{m2(booked_remaining)} booked</div><div class="m" style="width:{max(5,muni_pct):.0f}%">{m2(muni_fc)} muni</div><div class="s" style="width:{max(5,sell_pct):.0f}%">{m2(still_to_sell)} to sell</div></div>
 <div class="covleg">▶ <b style="color:#3fb950">{m2(booked_remaining)}</b> on the schedule (booked crew work) · <b style="color:#58a6ff">{m2(muni_fc)}</b> forecasted municipal (contracted city budget still to invoice{'' if muni_live else ' — snapshot, live fetch failed'}) · <b style="color:#e3b341">{m2(still_to_sell)}</b> still to sell. <span style="color:#6e7681">Muni forecast is FY-based per city (some invoices past Dec) — pulled live from Brent's City Budgets forecast, so it matches that dashboard.</span></div>
</div>

<h3>Monthly goal · actual · on schedule · still to sell</h3>
<table>
 <tr><th>Month</th><th>Goal</th><th>Actual (invoiced)</th><th>On schedule</th><th>Δ / still to sell</th><th>Status</th></tr>
 {rows}
</table>

<h3>📅 On the schedule — next 4 weeks (booked crew work)</h3>
<table>
 <tr><th>Week</th><th>Scheduled $</th><th>Crew-hours</th><th>Utilization</th></tr>
 {wk_rows}
</table>

<div class="note"><b>▶ Read:</b> far-out months (Sep, Dec) look empty because booking fills in closer to the date — big recurring HOA/contract work lands in specific months, one-offs get scheduled a few weeks out. The lever: convert the <b>{m2(still_to_sell)} "still to sell"</b> into booked schedule, weighted to high-margin HOA/commercial, invoiced before month-end. Each $1 of revenue also ≈ $0.20 of earnout.</div>

<details>
 <summary>▸ Deal context — why the goal matters (from the deck · updated manually, not live)</summary>
 <table>
  <tr><td class="dk">Land $25.1M revenue</td><td>→ full <b>$5.0M earnout</b> (currently pacing ~${DEAL['earnout_est']:.1f}M) + defends the $55M price</td></tr>
  <tr><td class="dk">TTM Adj EBITDA</td><td>${DEAL['ttm_ebitda']:.2f}M · floor ${DEAL['ebitda_floor']}M · target ${DEAL['ebitda_target']}M — revenue push rebuilds this</td></tr>
  <tr><td class="dk">Net proceeds @ close</td><td>~${DEAL['net_close']:.1f}M to sellers (stock) · <b>your payout ~${DEAL['jason_close']:.1f}M</b> (placeholder — confirm w/ Gary)</td></tr>
  <tr><td class="dk">Your rollover upside @ exit</td><td>EIP / MIP = 15% of key-personnel pool → <b>~${DEAL['eip_lo']:.2f}M–${DEAL['eip_hi']:.2f}M</b> (few → more FPC add-ons, 3.5x)</td></tr>
 </table>
</details>

<div class="foot">Live: invoiced revenue + scheduled crew work + monthly goals (TRIM IT, nightly mirror; goals {'read live from SalesGoal' if goals_live else 'from 2026-07-22 snapshot — live read unavailable this run'}). Deal constants: Cam datapack 7/21, FTI QoE. Detail: GSTS-50M-Growth-Plan.md §9.</div>
</body></html>"""

(ROOT / "deal-tracker-dashboard.html").write_text(html)
print(f"regenerated: goals {'LIVE' if goals_live else 'FALLBACK'} ${GOAL:,.0f}; YTD {m2(ytd_actual)} ({pct:.0f}%); "
      f"remaining {m2(remaining_to_goal)}; on-schedule {m2(booked_remaining)} ({booked_pct:.0f}%); "
      f"muni-forecast {'LIVE' if muni_live else 'FAIL→0'} {m2(muni_fc)} ({muni_pct:.0f}%); "
      f"still-to-sell {m2(still_to_sell)}; pace {'+' if pace_delta>=0 else '-'}{m2(abs(pace_delta))} thru {MONTHS[last_complete]}")
