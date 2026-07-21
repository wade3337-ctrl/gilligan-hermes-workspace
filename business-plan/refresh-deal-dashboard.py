#!/usr/bin/env python3
# 🔒 CONFIDENTIAL/BLACK — regenerates deal-tracker-dashboard.html from LIVE TRIM IT + deal constants.
# Runs on a cron (see crontab). Pulls 2026 monthly invoiced revenue via the read-only gateway.
import subprocess, datetime, os, pathlib

ROOT = pathlib.Path(__file__).parent
GATEWAY = os.path.expanduser("~/herman-gateway/trimit-ro-query.sh")
TPH_TARGET = 130
CAPACITY_HRS = 14400          # ~83 field staff x 40hr x 4.33 wk (standard weekday crew-hours/mo)

# Deal constants — update when a new financials deck / QoE lands (currently: Cam datapack 7/21, FTI QoE 4/29)
DEAL = dict(ttm_ebitda=3.80, ebitda_target=4.8, ebitda_floor=4.1,
            agp_ttm=10.7, agp_lo=11.4, agp_hi=12.5,
            earnout_est=2.7, earnout_max=5.0,
            net_close=33.4, jason_close=1.0, rollover_exit=27.0)
GOAL = 25_100_000

def q(sql):
    r = subprocess.run(["bash", GATEWAY], input=sql, capture_output=True, text=True, timeout=120)
    return r.stdout

# --- live pull: 2026 monthly invoiced revenue ---
out = q("SELECT MONTH(InvoiceDate) Mo, CAST(SUM(Total) AS decimal(14,0)) Rev FROM dbo.Invoices WHERE YEAR(InvoiceDate)=2026 GROUP BY MONTH(InvoiceDate) ORDER BY Mo;")
rev = {}
for line in out.splitlines():
    p = [x.strip() for x in line.split("|")]
    if len(p) == 2 and p[0].isdigit():
        rev[int(p[0])] = float(p[1])
ytd = sum(rev.values())
last_mo = max(rev) if rev else 0
remaining = GOAL - ytd
# hours needed across remaining months (last_mo+1 .. 12) at target TPH
months_left = max(0, 12 - last_mo)
hrs_needed = remaining / TPH_TARGET if remaining > 0 else 0
pct = ytd / GOAL * 100
ts = subprocess.run(["date", "-u", "+%Y-%m-%d %H:%M UTC"], capture_output=True, text=True).stdout.strip()

def card(pill, pcls, lab, big, tgt, fill, fcls):
    return f'<div class="card"><span class="pill {pcls}">{pill}</span><div class="lab">{lab}</div><div class="big">{big}</div><div class="tgt">{tgt}</div><div class="bar"><div class="fill {fcls}" style="width:{fill}%"></div></div></div>'

rev_pill = "AHEAD" if pct >= (last_mo/12*100) else "BEHIND"
rev_pcls = "green" if pct >= (last_mo/12*100) else "amber"
cards = "\n".join([
 card("BELOW FLOOR","red","TTM Adjusted EBITDA",f"${DEAL['ttm_ebitda']:.2f}M",
      f"target ${DEAL['ebitda_target']}M · floor ${DEAL['ebitda_floor']}M · +${DEAL['ebitda_floor']-DEAL['ttm_ebitda']:.1f}M→floor",
      round(DEAL['ttm_ebitda']/DEAL['ebitda_target']*100), "fred"),
 card("BELOW BAND","amber","2026 Adj Gross Profit (earnout metric)",f"~${DEAL['agp_ttm']:.1f}M",
      f"band ${DEAL['agp_lo']}–{DEAL['agp_hi']}M · full $5M at ${DEAL['agp_hi']}M", round(DEAL['agp_ttm']/DEAL['agp_hi']*100),"famber"),
 card(rev_pill,rev_pcls,"2026 Revenue (LIVE)",f"${ytd/1e6:.2f}M",
      f"of $25.1M goal · {pct:.0f}% · through month {last_mo} · remaining ${remaining/1e6:.1f}M", round(pct),"famber" if rev_pcls=="amber" else "fgreen"),
 card("~MID-BAND","amber","2026 Earnout (est.)",f"~${DEAL['earnout_est']:.1f}M",
      f"of ${DEAL['earnout_max']}M max · full $5M needs ~$25.1M · each $1 rev ≈ $2.27 earnout", round(DEAL['earnout_est']/DEAL['earnout_max']*100),"famber"),
 card("CONFIRMED","green","Net proceeds to sellers @ close",f"~${DEAL['net_close']:.1f}M",
      f"stock, pre-tax · your payout ~${DEAL['jason_close']:.1f}M (placeholder — confirm w/ Gary)",100,"fgreen"),
 card("UPSIDE","green","Rollover equity @ exit (2030–31)",f"${DEAL['rollover_exit']:.0f}M",
      "$9M × 3.0x · after-tax ~$17.0M · + your MIP (up to 15%)",100,"fgreen"),
])

# hours gauge table (remaining months at target TPH vs weekday capacity)
hrs_rows = ""
if remaining > 0 and months_left > 0:
    per_mo_rev = remaining / months_left
    hrs = per_mo_rev / TPH_TARGET
    over = hrs - CAPACITY_HRS
    hpw = hrs / 83 / 4.33
    hrs_rows = f"<tr><td>Each of the {months_left} remaining months (avg)</td><td>${per_mo_rev/1e6:.2f}M</td><td>{hrs:,.0f} hrs</td><td>{over:+,.0f} vs capacity</td><td>~{hpw:.0f} hr/wk/person</td></tr>"

html = f"""<!DOCTYPE html>
<!-- 🔒 CONFIDENTIAL / BLACK — Fort Point deal tracker. Skipper only. Auto-generated; do not hand-edit. -->
<html lang="en"><head><meta charset="utf-8"><meta http-equiv="refresh" content="900"><title>GSTS Deal Tracker</title>
<style>
 body{{background:#0d1117;color:#e6edf3;font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:0;padding:28px}}
 h1{{font-size:22px;margin:0 0 2px}} .sub{{color:#8b949e;font-size:13px;margin-bottom:22px}}
 .grid{{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}}
 @media(max-width:800px){{.grid{{grid-template-columns:1fr}}}}
 .card{{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:18px;position:relative}}
 .card .lab{{color:#8b949e;font-size:12px;text-transform:uppercase;letter-spacing:.5px}}
 .card .big{{font-size:30px;font-weight:700;margin:6px 0 2px}} .card .tgt{{color:#8b949e;font-size:13px}}
 .bar{{height:7px;background:#21262d;border-radius:5px;margin-top:12px;overflow:hidden}} .fill{{height:100%;border-radius:5px}}
 .pill{{position:absolute;top:16px;right:16px;font-size:11px;font-weight:700;padding:3px 9px;border-radius:20px}}
 .red{{background:#3d1418;color:#ff7b72}} .amber{{background:#3d2f12;color:#e3b341}} .green{{background:#12331d;color:#3fb950}}
 .fred{{background:#f85149}} .famber{{background:#d29922}} .fgreen{{background:#3fb950}}
 table{{width:100%;border-collapse:collapse;margin-top:16px;font-size:13px}} td,th{{padding:8px 10px;border-bottom:1px solid #21262d;text-align:left}} th{{color:#8b949e;font-weight:600}}
 .play{{margin-top:20px;background:#161b22;border:1px solid #30363d;border-left:4px solid #e3b341;border-radius:10px;padding:16px}} .play b{{color:#e3b341}}
 .foot{{color:#6e7681;font-size:11px;margin-top:18px}} .live{{color:#3fb950}}
</style></head><body>
<h1>🔒 GSTS Deal Tracker — the numbers the $55M rides on</h1>
<div class="sub">Confidential (Skipper only). <span class="live">● LIVE</span> revenue from TRIM IT · deal metrics from Cam datapack (FTI QoE). Updated {ts} · auto-refresh 15 min.</div>
<div class="grid">
{cards}
</div>
<div class="play"><b>▶ The play — defend the $4.8M EBITDA (= defend the price):</b> trailing EBITDA (${DEAL['ttm_ebitda']:.2f}M) is below the ${DEAL['ebitda_floor']}M floor. Rebuild it to ~$4.5–4.8M before diligence (~Sept/Oct): hit $25.1M, weight to <b>high-margin HOA/commercial</b>, and <b>invoice before the cutoff</b>. One push defends the $55M AND earns the $5M.</div>
<h3 style="margin-top:24px">⏱️ Crew-hours to close the ${remaining/1e6:.1f}M remaining (at $130 TPH)</h3>
<table><tr><th>Window</th><th>Revenue</th><th>Crew-hours</th><th>vs weekday capacity</th><th>Intensity</th></tr>{hrs_rows}</table>
<div class="foot">Live: 2026 invoiced revenue (TRIM IT, read-only). Deal constants refresh when a new financials deck lands. Detail: GSTS-50M-Growth-Plan.md §9.</div>
</body></html>"""

(ROOT / "deal-tracker-dashboard.html").write_text(html)
print(f"regenerated: YTD ${ytd:,.0f} ({pct:.0f}% of $25.1M) through month {last_mo}; remaining ${remaining:,.0f}")
