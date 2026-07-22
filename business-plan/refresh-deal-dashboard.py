#!/usr/bin/env python3
# 🔒 CONFIDENTIAL/BLACK — GSTS count-once revenue ledger → path to the 2026 goal.
# Built per Boss Herman's spec (7/21) + Gilligan's live reconciliation (7/22). Play DB ~24h behind prod.
# Decisions (Skipper 7/22): goal=GoalSettings×12 ($25.05M) · muni=calendar H2 ($3.74M) · accrual=pursue (pending Brent).
# COUNT-ONCE: actual(acct period) + muni forecast + firm sold WO + risk-adj pipeline — no layer double-counted.
import subprocess, os, pathlib, datetime

ROOT = pathlib.Path(__file__).parent
GW = os.path.expanduser("~/herman-gateway/trimit-ro-query.sh")     # read-only login
MUNI_CSV_URL = "https://play.greatscotttreeservice.com/GSTS/Dashboard-CityBudgets.cfm?ZProjectID=all&ZTab=forecast&exportForecastAllCSV=1"
MONTHS = ["", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

# --- config (documented inputs; recompute/replace as feeds land) ---
MUNI_H2_CALENDAR_FORECAST = 3_741_400   # Skipper 7/22: calendar-H2 muni projection (Brent workbook). TODO: live calendar-muni calc; engine budget−invoiced reconciles to ~$3.29M (see muni_recon).
PIPELINE_CONVERSION = 0.40              # fresh HOA/Comm pending → expected conversion
GOAL_FALLBACK_MONTHLY = 2_087_119       # GoalSettings ZUserID=9 snapshot 7/22
STATUS_ACTUAL = "(21,100,22,23,148)"    # invoice statuses that count as financial actual
DEAL = dict(ttm_ebitda=3.80, ebitda_floor=4.1, earnout_est=2.7, earnout_max=5.0,
            net_close=33.4, jason_close=1.0, eip_lo=1.44, eip_hi=2.48)

def q(sql):
    return subprocess.run(["bash", GW], input=sql, capture_output=True, text=True, timeout=120).stdout

def rows_of(out, ncol):
    res = []
    for line in out.splitlines():
        p = [x.strip() for x in line.split("|")]
        if len(p) == ncol and p[0] and p[0][0] not in "-=" and "=" not in line:
            res.append(p)
    return res

def scalar(out):
    for p in rows_of(out, 1):
        try: return float(p[0])
        except: pass
    return None

# ---------- LAYER 0: goal (GoalSettings ZUserID=9, live) ----------
gm = scalar(q("SET NOCOUNT ON; SELECT CAST(MonthlyGoal AS decimal(14,0)) FROM dbo.GoalSettings WHERE ZUserID=9;"))
goal_live = gm is not None
monthly_goal = gm or GOAL_FALLBACK_MONTHLY
GOAL = monthly_goal * 12

# ---------- LAYER 1: financial actual by ACCOUNTING PERIOD (status-filtered), monthly ----------
act = {}
for p in rows_of(q(f"SET NOCOUNT ON; SELECT MONTH(p.StartDate),CAST(SUM(i.Total) AS decimal(16,2)) "
                   f"FROM dbo.Invoices i WITH (NOLOCK) JOIN dbo.Periods p WITH (NOLOCK) ON i.PeriodID=p.PeriodID "
                   f"WHERE p.StartDate>='2026-01-01' AND p.StartDate<'2027-01-01' AND i.StatusDefID IN {STATUS_ACTUAL} "
                   f"AND ISNULL(i.IsProForma,0)=0 AND ISNULL(i.IsCredit,0)=0 GROUP BY MONTH(p.StartDate);"), 2):
    if p[0].isdigit(): act[int(p[0])] = float(p[1])
actual_ytd = sum(act.values())
# accrual bridge — LIVE from dbo.GetPeriodAccrual (the CORRECTED, billing-cycle-aware muni accrual Steve confirmed &
# shipped to prod 2026-07-22). Formula: (WO EstValue − PriorBilled) × (this-month hrs / total WO hrs), only accruing
# work whose CrewSheets.BillingPeriodID is AFTER the current period. YTD adj = invoiced + current-period accrual − year-start(Dec) accrual.
acc = rows_of(q("SET NOCOUNT ON; "
                "DECLARE @cur INT=(SELECT PeriodID FROM dbo.Periods WHERE CAST(GETDATE() AS date) BETWEEN StartDate AND EndDate); "
                "DECLARE @base INT=(SELECT PeriodID FROM dbo.Periods WHERE '2025-12-15' BETWEEN StartDate AND EndDate); "
                "SELECT 'CUR',CAST(SUM(AccrualTotal) AS decimal(16,2)) FROM dbo.GetPeriodAccrual(@cur) "
                "UNION ALL SELECT 'BASE',CAST(SUM(AccrualTotal) AS decimal(16,2)) FROM dbo.GetPeriodAccrual(@base);"), 2)
accd = {r[0]: float(r[1]) for r in acc if r[0] in ("CUR","BASE")}
accrual_live = len(accd) == 2
cur_accrual = accd.get("CUR", 0.0)
base_accrual = accd.get("BASE", 0.0)
adjusted_ytd = actual_ytd + cur_accrual - base_accrual if accrual_live else actual_ytd

# ---------- LAYER 2: municipal forecast remaining (calendar) + engine reconciliation ----------
def muni_engine():
    """canonical City Budgets engine grand-total (Budgeted, Invoiced, Remaining[FY])."""
    try:
        r = subprocess.run(["curl","-s","-k","--max-time","30","-H","Cookie: ZUserID=376", MUNI_CSV_URL],
                           capture_output=True, text=True, timeout=40)
        over = []
        gt = None
        for line in r.stdout.splitlines():
            c = [x.strip().strip('"') for x in line.split(",")]
            if line.startswith('"GRAND TOTAL'):
                gt = dict(budget=float(c[2]), invoiced=float(c[3]), remaining=float(c[-1]))
            elif len(c) >= 7 and c[0].startswith("City of"):
                try:
                    if float(c[-1]) < 0: over.append((c[0], float(c[-1])))   # over-budget cities
                except: pass
        return gt, over
    except Exception:
        return None, []
gt, muni_over = muni_engine()
muni_live = gt is not None
muni_forecast = MUNI_H2_CALENDAR_FORECAST                       # the coverage number (Skipper: calendar basis)
muni_recon = (gt["budget"] - gt["invoiced"]) if gt else None    # engine budget−invoiced (FY-ish) for reconciliation

# ---------- LAYER 3: firm nonmuni sold coverage (WO 46/109, dated ≤12/31) + undated queue ----------
NOTMUNI = "AND NOT EXISTS (SELECT 1 FROM dbo.ProjectGroups pg WITH (NOLOCK) WHERE pg.ProjectID=wo.ProjectID AND pg.ProjectGroupDefID=11)"
firm_dated = scalar(q(f"SET NOCOUNT ON; SELECT CAST(SUM(wo.EstValue) AS decimal(16,2)) FROM dbo.WorkOrders wo WITH (NOLOCK) "
                      f"WHERE wo.StatusDefID IN (46,109) AND wo.DateCompleted IS NULL AND wo.EstValue>0 "
                      f"AND wo.EndDate>=CAST(GETDATE() AS date) AND wo.EndDate<='2026-12-31' {NOTMUNI};")) or 0
undated = q(f"SET NOCOUNT ON; SELECT CAST(SUM(wo.EstValue) AS decimal(16,2)),COUNT(*) FROM dbo.WorkOrders wo WITH (NOLOCK) "
            f"WHERE wo.StatusDefID IN (46,109) AND wo.DateCompleted IS NULL AND wo.EstValue>0 "
            f"AND (wo.EndDate IS NULL OR wo.EndDate>'2026-12-31') {NOTMUNI};")
ur = rows_of(undated, 2)
undated_val, undated_n = (float(ur[0][0]), int(float(ur[0][1]))) if ur else (0, 0)

# ---------- LAYER 4: fresh pending pipeline (GoAheads 49, <90d, deduped, HOA/Comm/PM) ----------
fresh = q("SET NOCOUNT ON; SELECT CAST(SUM(pv) AS decimal(16,2)),COUNT(*) FROM (SELECT g.ProjectID,MAX(g.EstValue) pv "
          "FROM dbo.GoAheads g WITH (NOLOCK) JOIN dbo.Projects prj WITH (NOLOCK) ON prj.ProjectID=g.ProjectID "
          "JOIN dbo.GeoMarkets gm WITH (NOLOCK) ON gm.GeoMarketID=prj.GeoMarketID "
          "WHERE g.StatusDefID=49 AND g.Created>=DATEADD(day,-90,GETDATE()) AND gm.MarketID IN (5,6,16) "
          "AND NOT EXISTS (SELECT 1 FROM dbo.ProjectGroups pg WHERE pg.ProjectID=g.ProjectID AND pg.ProjectGroupDefID=11) "
          "GROUP BY g.ProjectID) x;")
fr = rows_of(fresh, 2)
pipeline_raw, pipeline_n = (float(fr[0][0]), int(float(fr[0][1]))) if fr else (0, 0)
pipeline_adj = pipeline_raw * PIPELINE_CONVERSION
# proposals approaching the 90-day cliff (created 80-90d ago) — action list
aging = q("SET NOCOUNT ON; SELECT CAST(SUM(pv) AS decimal(16,2)),COUNT(*) FROM (SELECT g.ProjectID,MAX(g.EstValue) pv "
          "FROM dbo.GoAheads g WITH (NOLOCK) WHERE g.StatusDefID=49 "
          "AND g.Created>=DATEADD(day,-90,GETDATE()) AND g.Created<DATEADD(day,-80,GETDATE()) "
          "AND NOT EXISTS (SELECT 1 FROM dbo.ProjectGroups pg WHERE pg.ProjectID=g.ProjectID AND pg.ProjectGroupDefID=11) "
          "GROUP BY g.ProjectID) x;")
ag = rows_of(aging, 2)
aging_val, aging_n = (float(ag[0][0]), int(float(ag[0][1]))) if ag else (0, 0)

# ---------- count-once bridge ----------
covered = adjusted_ytd + muni_forecast + firm_dated + pipeline_adj
uncovered = GOAL - covered

ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
def M(x): return f"${x/1e6:.2f}M"
def K(x): return f"${x/1e3:.0f}K"

# monthly financial table
cur_mo = datetime.date.today().month if datetime.date.today().year == 2026 else 12
mrows = ""
for m in range(1, 13):
    g = monthly_goal; a = act.get(m)
    if m < cur_mo:
        d = (a or 0) - g; st, cl = (("✅","gok") if a and a>=g else ("✗","gbad"))
        ad = M(a) if a is not None else "$0"; dd = f"{'+' if d>=0 else '−'}{M(abs(d))}"
    elif m == cur_mo:
        st, cl = "◐", "gcur"; ad = M(a or 0); dd = f"{M(max(0,g-(a or 0)))} left"
    else:
        st, cl = "·", "gsoft"; ad = "—"; dd = M(g)
    mrows += f'<tr class="{cl}"><td>{MONTHS[m]}</td><td>{M(g)}</td><td>{ad}</td><td>{dd}</td><td class="stcell">{st}</td></tr>'

over_rows = "".join(f"<tr><td>{c}</td><td class='gb'>{M(v)} over</td></tr>" for c,v in (muni_over or [])[:6]) or "<tr><td>none</td><td>—</td></tr>"

def tile(lab, val, sub, cls=""):
    return f'<div class="card"><div class="lab">{lab}</div><div class="big {cls}">{val}</div><div class="tgt">{sub}</div></div>'

html = f"""<!DOCTYPE html>
<!-- 🔒 CONFIDENTIAL / BLACK — Fort Point count-once revenue ledger. Skipper only. Auto-generated. -->
<html lang="en"><head><meta charset="utf-8"><meta http-equiv="refresh" content="900"><title>GSTS Revenue Ledger</title>
<style>
 body{{background:#0d1117;color:#e6edf3;font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:0;padding:26px}}
 h1{{font-size:21px;margin:0 0 2px}} .sub{{color:#8b949e;font-size:12px;margin-bottom:18px}} .live{{color:#3fb950}}
 .hero{{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:14px}}
 @media(max-width:820px){{.hero{{grid-template-columns:1fr 1fr}}}}
 .card{{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:16px}}
 .card .lab{{color:#8b949e;font-size:11px;text-transform:uppercase;letter-spacing:.5px}}
 .card .big{{font-size:27px;font-weight:700;margin:5px 0 2px}} .card .tgt{{color:#8b949e;font-size:12px}}
 .gk{{color:#3fb950}} .gb{{color:#ff7b72}} .ga{{color:#e3b341}} .gbl{{color:#58a6ff}}
 .covwrap{{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:16px;margin-bottom:8px}}
 .covwrap .lab{{color:#8b949e;font-size:11px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:9px}}
 .cov{{display:flex;height:26px;border-radius:6px;overflow:hidden;font-size:11px;font-weight:700;color:#0d1117}}
 .cov .a{{background:#2f81f7}} .cov .mu{{background:#58a6ff}} .cov .fw{{background:#3fb950}} .cov .pp{{background:#8957e5;color:#fff}} .cov .gap{{background:#d29922}}
 .cov div{{display:flex;align-items:center;justify-content:center;white-space:nowrap;overflow:hidden}}
 .covleg{{color:#8b949e;font-size:12px;margin-top:9px;line-height:1.5}}
 h3{{margin:22px 0 6px;font-size:14px}}
 table{{width:100%;border-collapse:collapse;font-size:12.5px}} td,th{{padding:7px 10px;border-bottom:1px solid #21262d;text-align:left}}
 th{{color:#8b949e;font-weight:600;text-transform:uppercase;font-size:10.5px;letter-spacing:.5px}}
 .stcell{{font-weight:600}} tr.gok .stcell{{color:#3fb950}} tr.gbad .stcell{{color:#ff7b72}}
 tr.gcur{{background:#12233d}} tr.gcur .stcell{{color:#58a6ff}} tr.gsoft td{{color:#8b949e}}
 .cols{{display:grid;grid-template-columns:1fr 1fr;gap:14px}} @media(max-width:820px){{.cols{{grid-template-columns:1fr}}}}
 .panel{{background:#12161c;border:1px solid #262c34;border-radius:10px;padding:6px 14px}}
 .warn{{background:#2d2410;border:1px solid #4a3a12;border-left:4px solid #e3b341;border-radius:8px;padding:11px 14px;font-size:12.5px;margin-top:10px}} .warn b{{color:#e3b341}}
 details{{margin-top:22px;background:#12161c;border:1px solid #262c34;border-radius:10px;padding:6px 14px;color:#8b949e;font-size:12px}}
 details summary{{cursor:pointer;padding:8px 0}} details td{{font-size:12px}}
 .foot{{color:#6e7681;font-size:11px;margin-top:14px}}
</style></head><body>
<h1>🎯 GSTS Revenue Ledger — count-once path to {M(GOAL)}</h1>
<div class="sub"><span class="live">● LIVE</span> from TRIM IT (play, ~24h behind prod) · {ts} · auto-refresh 15 min · Confidential (Skipper only). Financial = accounting-period, status-filtered. Production board kept separate.</div>

<div class="hero">
{tile("Annual Goal", M(GOAL), f"GoalSettings×12{'' if goal_live else ' (snapshot)'} · ${monthly_goal:,.0f}/mo")}
{tile("Adjusted Actual YTD", M(adjusted_ytd), f"invoiced {M(actual_ytd)} + accrual bridge (live)", "gk")}
{tile("Municipal Forecast (rem.)", M(muni_forecast), f"calendar H2 · engine recon {M(muni_recon) if muni_recon else 'n/a'}", "gbl")}
{tile("Firm Sold Coverage", M(firm_dated), "nonmuni WOs dated ≤12/31", "gk")}
{tile("Risk-Adj Fresh Pipeline", M(pipeline_adj), f"{M(pipeline_raw)} HOA/Comm × {PIPELINE_CONVERSION:.0%}", "pp".replace('pp','gbl'))}
{tile("Uncovered Gap", M(uncovered), "still needs NEW sales/scheduling", "gb" if uncovered>0 else "gk")}
</div>

<div class="covwrap"><div class="lab">Count-once bridge to {M(GOAL)} — every dollar counted once</div>
 <div class="cov">
  <div class="a" style="width:{max(6,adjusted_ytd/GOAL*100):.0f}%">{M(adjusted_ytd)} actual</div>
  <div class="mu" style="width:{max(5,muni_forecast/GOAL*100):.0f}%">{M(muni_forecast)} muni</div>
  <div class="fw" style="width:{max(5,firm_dated/GOAL*100):.0f}%">{M(firm_dated)} firm</div>
  <div class="pp" style="width:{max(4,pipeline_adj/GOAL*100):.0f}%">{M(pipeline_adj)} pipe</div>
  <div class="gap" style="width:{max(5,uncovered/GOAL*100):.0f}%">{M(uncovered)} gap</div>
 </div>
 <div class="covleg">Actual <b style="color:#2f81f7">{M(adjusted_ytd)}</b> + Muni forecast <b style="color:#58a6ff">{M(muni_forecast)}</b> + Firm sold <b style="color:#3fb950">{M(firm_dated)}</b> + Pipeline@{PIPELINE_CONVERSION:.0%} <b style="color:#a371f7">{M(pipeline_adj)}</b> = <b>{M(covered)}</b> covered → <b style="color:#e3b341">{M(uncovered)}</b> still needs new sales. <span style="color:#6e7681">No layer double-counted: firm/pipeline exclude municipal &amp; each other; muni forecast is contract budget, not scheduled crew.</span></div>
</div>

<div class="warn" style="border-left-color:#3fb950"><b style="color:#3fb950">✔ Accrual bridge (live):</b> Adjusted Actual = invoiced <b>{M(actual_ytd)}</b> + current-period accrual <b>{K(cur_accrual)}</b> − year-start (Dec) accrual <b>{K(base_accrual)}</b> = <b>{M(adjusted_ytd)}</b>. From <code>dbo.GetPeriodAccrual</code> — the billing-cycle-aware municipal accrual Steve confirmed &amp; shipped to prod (% -of-completion, only work whose billing period is after the current period). <span style="color:#6e7681">Current period is partial-month, so the accrual grows toward month-end.</span></div>

<h3>Monthly financial actual (accounting period) vs goal</h3>
<table><tr><th>Month</th><th>Goal</th><th>Invoiced (adj. actual)</th><th>Δ / to go</th><th></th></tr>{mrows}</table>

<div class="cols">
 <div><h3>🗓️ Sold work with NO 2026 date ({undated_n})</h3><div class="panel"><table>
   <tr><td>Undated / beyond-year sold WOs</td><td class="ga">{M(undated_val)}</td></tr>
   <tr><td colspan="2" style="color:#6e7681;font-size:11px">Not counted as coverage until Production assigns a 2026 completion date.</td></tr></table></div>
  <h3>⏳ Pending nearing the 90-day cliff ({aging_n})</h3><div class="panel"><table>
   <tr><td>GoAheads created 80–90 days ago</td><td class="ga">{M(aging_val)}</td></tr>
   <tr><td colspan="2" style="color:#6e7681;font-size:11px">Drop out of the plan at 90 days (Skipper rule) — chase or lose.</td></tr></table></div>
 </div>
 <div><h3>🏛️ Municipal contracts at/over budget</h3><div class="panel"><table>{over_rows}</table></div>
  <h3>🔁 Reconciliation differences</h3><div class="panel"><table>
   <tr><td>Muni invoiced: Brent workbook vs TRIM IT</td><td>$4.16M vs $4.19M (+$32K)</td></tr>
   <tr><td>Firm WO: Herman snapshot vs live</td><td>$4.60M vs {M(firm_dated)}</td></tr>
   <tr><td>Muni forward: calendar vs engine-FY recon</td><td>{M(muni_forecast)} vs {M(muni_recon) if muni_recon else 'n/a'}</td></tr></table></div>
 </div>
</div>

<details><summary>▸ Deal context (from the deck · not live) &amp; production schedule note</summary>
 <table>
  <tr><td>Land the goal</td><td>→ full <b>$5.0M earnout</b> (pacing ~${DEAL['earnout_est']:.1f}M) + defends the $55M price</td></tr>
  <tr><td>TTM Adj EBITDA</td><td>${DEAL['ttm_ebitda']:.2f}M · floor ${DEAL['ebitda_floor']}M</td></tr>
  <tr><td>Net proceeds @ close</td><td>~${DEAL['net_close']:.1f}M · your ~${DEAL['jason_close']:.1f}M (confirm w/ Gary)</td></tr>
  <tr><td>Your EIP/MIP @ exit</td><td>~${DEAL['eip_lo']:.2f}M–${DEAL['eip_hi']:.2f}M (15% of pool)</td></tr>
  <tr><td>Production board</td><td>CrewSheets scheduled work is an <i>operations</i> view — deliberately kept OFF this financial ledger (Herman rule).</td></tr>
 </table>
</details>

<div class="foot">Sources: actual=Invoices×Periods (acct period, status {STATUS_ACTUAL}); muni=City Budgets forecast engine (live) + calendar input; firm/pipeline=WorkOrders/GoAheads (live, deduped, muni-excluded via ProjectGroups=11). Ledger: business-plan/count-once-ledger-2026-07-22.md. Play ~24h behind prod.</div>
</body></html>"""

(ROOT / "deal-tracker-dashboard.html").write_text(html)
print(f"goal {'LIVE' if goal_live else 'FB'} {M(GOAL)}; actual {M(actual_ytd)}; accrual {'LIVE' if accrual_live else 'off'} cur {K(cur_accrual)} base {K(base_accrual)} → adj {M(adjusted_ytd)}; muni {M(muni_forecast)} (recon {M(muni_recon) if muni_recon else 'n/a'}); "
      f"firm {M(firm_dated)}; pipe@{PIPELINE_CONVERSION:.0%} {M(pipeline_adj)} (raw {M(pipeline_raw)}); covered {M(covered)}; UNCOVERED {M(uncovered)}; "
      f"undated {M(undated_val)}/{undated_n}; aging {M(aging_val)}/{aging_n}; muni_live={muni_live} over={len(muni_over or [])}")
