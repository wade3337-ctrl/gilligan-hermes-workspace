#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
derive-financials.py - standing monthly derivation from the CFO's locked P&L.

🔒 CONFIDENTIAL (Track 2 / BLACK - Fort Point). Computes earnout position.
   Do NOT surface to Aspen, Boss Herman, MuniBot, Brent, or the team.

WHY THIS EXISTS
  The Skipper (2026-07-30): "can we calculate all this out from the documents we
  have? I'm tired of asking for data from these people."
  Mostly yes. This script rebuilds - from Steve's file alone - everything that IS
  derivable, and says plainly which two items are NOT.

WHAT IT PROVES (rather than assumes)
  * the CFO's reclass adjustment, rebuilt from the account numbers named in his
    own row label. On the 07-29-26 file this matched to $0.00.
  * Adjusted Gross Profit, and the DEAL AGP used for the earnout thresholds.
  * the earnout position at any revenue scenario.

DESIGN RULES (learned the hard way)
  1. Find rows by LABEL, never by row index. Account 4210 (Fuel Surcharge) appeared
     for the first time in the June file and shifted every row beneath it.
  2. Parse the reclass ACCOUNT NUMBERS out of the CFO's own label text, so if he
     adds or drops an account the derivation follows him automatically.
  3. Annualize by the number of months actually present, so the July/August files
     work with no edit.
  4. Every control is checked and reported. Exit code = number of FAILED controls,
     so this can gate anything downstream.
  5. MEASURED and INFERRED are labelled separately and never blended.

USAGE
  python3 derive-financials.py [path/to/GSTS Financials ....xlsx]
  (with no argument it uses the newest file in arbor-stack/inbox-pull/steve-financials-*/)

Dependencies: none. Python stdlib only (there is no pip on this host).
"""

import glob
import os
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from datetime import datetime

NS = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'

# Set once the TOTAL column is known. Everything RIGHT of TOTAL is annotation
# (the CFO types his FY targets there), not part of a row's name.
TOTAL_COL = None

# ---------------------------------------------------------------- deal terms
# From the Fort Point LOI bands. These are TERMS, not measurements - the only
# hardcoded figures in this file, and they change only if the LOI changes.
EARNOUT_FLOOR_AGP = 11_400_000.00
EARNOUT_CAP_AGP   = 12_500_000.00
EARNOUT_MAX       = 5_000_000.00

# Corroboration only - Cam/Augusta datapack 7/21/26, built on FTI's QoE.
FTI_AGP_RATE_HINT = 0.50

# Revenue scenarios to price. (label, revenue, note)
SCENARIOS = [
    ("FY2026 goal - Workbench.dbo.SalesGoal", 25_300_976.00, "authoritative"),
    ("CFO budget figure (Steve, 2025 budget)", 24_400_000.00, "NOT the LOI - his words"),
]


# ---------------------------------------------------------------- xlsx reader
def col_to_num(ref):
    letters = re.match(r'([A-Z]+)', ref).group(1)
    n = 0
    for ch in letters:
        n = n * 26 + ord(ch) - 64
    return n


def read_sheet(path):
    """Return (rows, sheet_name). rows = {rownum: {'label': str, 'vals': {col: float}}}"""
    z = zipfile.ZipFile(path)

    shared = []
    if 'xl/sharedStrings.xml' in z.namelist():
        root = ET.fromstring(z.read('xl/sharedStrings.xml'))
        for si in root.findall(f'{NS}si'):
            shared.append(''.join(t.text or '' for t in si.iter(f'{NS}t')))

    wb = ET.fromstring(z.read('xl/workbook.xml'))
    rels = ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))
    rid_target = {r.get('Id'): r.get('Target') for r in rels}
    RID = '{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id'

    sheets = []
    for sh in wb.find(f'{NS}sheets'):
        target = rid_target.get(sh.get(RID), '')
        if not target.startswith('/'):
            target = 'xl/' + target.lstrip('/')
        sheets.append((sh.get('name'), target))

    # Pick the sheet with the most populated rows - the P&L, not the "Export Tips" tab.
    best, best_rows, best_name = None, -1, ''
    for name, target in sheets:
        try:
            root = ET.fromstring(z.read(target))
        except KeyError:
            continue
        n = sum(1 for _ in root.iter(f'{NS}row'))
        if n > best_rows:
            best, best_rows, best_name = root, n, name

    if best is None:
        raise SystemExit("no readable worksheet found")

    rows = {}
    for row in best.iter(f'{NS}row'):
        rnum = int(row.get('r'))
        strings, vals = [], {}
        for c in row.findall(f'{NS}c'):
            ref, t = c.get('r'), c.get('t')
            v = c.find(f'{NS}v')
            if t == 'inlineStr':
                val = ''.join(x.text or '' for x in c.iter(f'{NS}t'))
            elif v is None:
                continue
            elif t == 's':
                val = shared[int(v.text)]
            else:
                try:
                    val = float(v.text)
                except (TypeError, ValueError):
                    val = v.text
            col = col_to_num(ref)
            if isinstance(val, str):
                if val.strip():
                    strings.append((col, val.strip()))
            elif val is not None:
                vals[col] = val
        if strings or vals:
            rows[rnum] = {
                'label': ' '.join(s for _, s in sorted(strings)),  # display only
                'strings': dict(strings),
                'vals': vals,
            }
    return rows, best_name


def head_label(row):
    """
    The row's NAME: string cells to the LEFT of the TOTAL column.

    Why this exists: row 10 is {C:'Total Income', T:'$24.4M'}. Joining every string
    cell produced 'Total Income $24.4M', so an anchored /^Total Income$/ silently
    found nothing. The annotation is not part of the name.
    """
    if TOTAL_COL is None:
        return row['label']
    return ' '.join(t for c, t in sorted(row['strings'].items()) if c < TOTAL_COL)


def annotation(row):
    """Text the CFO parked RIGHT of the TOTAL column - his own FY target wording."""
    if TOTAL_COL is None:
        return ''
    return ' '.join(t for c, t in sorted(row['strings'].items()) if c > TOTAL_COL)


# ---------------------------------------------------------------- row finding
def find_row(rows, pattern, flags=re.I):
    """First row whose label matches. Returns (rownum, rowdict) or (None, None)."""
    rx = re.compile(pattern, flags)
    for rnum in sorted(rows):
        if rx.search(head_label(rows[rnum])):
            return rnum, rows[rnum]
    return None, None


def account_value(rows, acct, total_col):
    """
    Value of a numbered account. If the account is a GROUP with a
    'Total NNNN - ...' row, that total wins - otherwise a group header
    (which carries no value) would silently contribute zero.
    """
    tot_rx = re.compile(r'^Total\s+' + re.escape(acct) + r'\b', re.I)
    for rnum in sorted(rows):
        if tot_rx.search(head_label(rows[rnum])):
            v = rows[rnum]['vals'].get(total_col)
            if v is not None:
                return v, f"r{rnum} (group total)"
    plain_rx = re.compile(r'^' + re.escape(acct) + r'\b')
    for rnum in sorted(rows):
        if plain_rx.search(head_label(rows[rnum])):
            v = rows[rnum]['vals'].get(total_col)
            if v is not None:
                return v, f"r{rnum}"
    return None, "NOT FOUND"


def detect_columns(rows):
    """Return (month_cols {col: label}, total_col)."""
    months, total_col = {}, None
    hdr = None
    for rnum in sorted(rows):
        lbl = rows[rnum]['label']
        if re.search(r'\b[A-Z][a-z]{2}\s?\d{2}\b', lbl):
            hdr = rnum
            break
    if hdr is None:
        return months, None

    z = zipfile.ZipFile(CURRENT_PATH)
    root = ET.fromstring(z.read(CURRENT_SHEET_PATH))
    for row in root.iter(f'{NS}row'):
        if int(row.get('r')) != hdr:
            continue
        shared = SHARED_CACHE
        for c in row.findall(f'{NS}c'):
            v = c.find(f'{NS}v')
            if v is None:
                continue
            txt = shared[int(v.text)] if c.get('t') == 's' else str(v.text)
            col = col_to_num(c.get('r'))
            txt = txt.strip()
            if re.fullmatch(r'[A-Z][a-z]{2}\s?\d{2}', txt):
                months[col] = txt
            elif txt.upper().startswith('TOTAL'):
                total_col = col
    return months, total_col


# ---------------------------------------------------------------- earnout
def earnout_for(agp):
    if agp <= EARNOUT_FLOOR_AGP:
        return 0.0
    if agp >= EARNOUT_CAP_AGP:
        return EARNOUT_MAX
    span = EARNOUT_CAP_AGP - EARNOUT_FLOOR_AGP
    return (agp - EARNOUT_FLOOR_AGP) / span * EARNOUT_MAX


def money(v):
    if v is None:
        return "n/a"
    return f"${v:,.2f}"


# ---------------------------------------------------------------- main
def main():
    global CURRENT_PATH, CURRENT_SHEET_PATH, SHARED_CACHE, TOTAL_COL

    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        pats = sorted(glob.glob(os.path.expanduser(
            '~/arbor-stack/inbox-pull/steve-financials-*/*.xlsx')))
        if not pats:
            raise SystemExit("no file given and none found in inbox-pull/steve-financials-*/")
        path = pats[-1]

    if not os.path.isfile(path):
        raise SystemExit(f"not a file: {path}")

    CURRENT_PATH = path

    # cache shared strings + sheet path for the header scan
    z = zipfile.ZipFile(path)
    SHARED_CACHE = []
    if 'xl/sharedStrings.xml' in z.namelist():
        r = ET.fromstring(z.read('xl/sharedStrings.xml'))
        for si in r.findall(f'{NS}si'):
            SHARED_CACHE.append(''.join(t.text or '' for t in si.iter(f'{NS}t')))
    best_target, best_n = None, -1
    wb = ET.fromstring(z.read('xl/workbook.xml'))
    rels = ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))
    rid_target = {x.get('Id'): x.get('Target') for x in rels}
    RID = '{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id'
    for sh in wb.find(f'{NS}sheets'):
        t = rid_target.get(sh.get(RID), '')
        if not t.startswith('/'):
            t = 'xl/' + t.lstrip('/')
        try:
            n = sum(1 for _ in ET.fromstring(z.read(t)).iter(f'{NS}row'))
        except KeyError:
            continue
        if n > best_n:
            best_target, best_n = t, n
    CURRENT_SHEET_PATH = best_target

    rows, sheet_name = read_sheet(path)
    months, total_col = detect_columns(rows)

    fails, warns = [], []

    print("=" * 78)
    print("  CFO FINANCIALS - DERIVED POSITION      🔒 CONFIDENTIAL (deal-aware)")
    print("=" * 78)
    print(f"  source : {os.path.basename(path)}")
    print(f"  sheet  : {sheet_name}   rows {len(rows)}")
    print(f"  run    : {datetime.now():%Y-%m-%d %H:%M} local")
    if months:
        print(f"  periods: {', '.join(months[c] for c in sorted(months))}  ({len(months)} months)")
    else:
        warns.append("could not detect month columns - annualization disabled")
    print()

    if total_col is None:
        if months:
            total_col = max(months) + 2
            warns.append(f"no TOTAL column found; assuming col {total_col}")
        else:
            raise SystemExit("cannot locate a TOTAL column - aborting rather than guess")

    TOTAL_COL = total_col   # row names are now resolved left of this column

    def val(pattern, required=True):
        rn, rw = find_row(rows, pattern)
        if rw is None:
            if required:
                fails.append(f"row not found: /{pattern}/")
            return None
        v = rw['vals'].get(total_col)
        if v is None and required:
            fails.append(f"row '{rw['label'][:40]}' has no value in the TOTAL column")
        return v

    revenue    = val(r'^Total Income$')
    cogs       = val(r'^Total COGS$')
    gp         = val(r'^Gross Profit$')
    reclass_rn, reclass_row = find_row(rows, r'Adjustment for relocating')
    reclass    = reclass_row['vals'].get(total_col) if reclass_row else None
    agp        = val(r'^Adjusted Gross Profit$')
    base_ebit  = val(r'^Base EBITDA$', required=False)
    adjustments= val(r'^Adjustments$', required=False)
    rev_ebit   = val(r'^Revised EBITDA$', required=False)
    dep_cogs, dep_where = account_value(rows, '5100', total_col)

    # ---------------------------------------------------------- MEASURED
    print("-" * 78)
    print("  MEASURED - read directly from the CFO's file")
    print("-" * 78)
    print(f"  Total Income                {money(revenue):>18}")
    print(f"  Total COGS                  {money(cogs):>18}")
    print(f"  Gross Profit                {money(gp):>18}"
          + (f"   = {gp/revenue*100:5.2f}% of revenue" if gp and revenue else ""))
    print(f"  Reclass to overhead         {money(reclass):>18}")
    print(f"  Adjusted Gross Profit       {money(agp):>18}"
          + (f"   = {agp/revenue*100:5.2f}% of revenue" if agp and revenue else ""))
    print(f"  Base EBITDA                 {money(base_ebit):>18}")
    print(f"  Adjustments                 {money(adjustments):>18}")
    print(f"  Revised EBITDA              {money(rev_ebit):>18}"
          + (f"   = {rev_ebit/revenue*100:5.2f}% of revenue" if rev_ebit and revenue else ""))
    print()

    # ---- the CFO's OWN targets, lifted from the annotation column ----
    cfo_targets = []
    for rn in sorted(rows):
        note = annotation(rows[rn])
        if note and re.search(r'\$|\bM\b', note):
            name = head_label(rows[rn])
            if name:
                cfo_targets.append((name, note))
    if cfo_targets:
        print("  CFO's stated FY targets (read from his annotation column, not hardcoded):")
        for name, note in cfo_targets:
            print(f"    {name:<34} {note}")
        print("    ⚠ his revenue line is a BUDGET figure, not the LOI - his words, 2026-07-29.")
        print()

    # ---------------------------------------------------------- CONTROLS
    print("-" * 78)
    print("  CONTROLS")
    print("-" * 78)

    def control(name, ok, detail=""):
        print(f"  [{'PASS' if ok else 'FAIL'}] {name}{('   ' + detail) if detail else ''}")
        if not ok:
            fails.append(name)

    if revenue and cogs and gp:
        control("Income - COGS = Gross Profit", abs((revenue - cogs) - gp) < 0.01,
                f"delta {revenue - cogs - gp:+,.2f}")

    # income accounts must foot to Total Income
    inc_sum, inc_n = 0.0, 0
    for rn in sorted(rows):
        lbl = rows[rn]['label']
        if re.match(r'^4\d{3}\b', lbl) and not lbl.lower().startswith('total'):
            v = rows[rn]['vals'].get(total_col)
            if v is not None:
                inc_sum += v
                inc_n += 1
    if revenue:
        control(f"{inc_n} income accounts foot to Total Income",
                abs(inc_sum - revenue) < 0.01, f"delta {inc_sum - revenue:+,.2f}")

    # ⭐ the reclass audit - rebuilt from the account numbers in the CFO's own label
    reclass_detail = []
    if reclass_row and reclass is not None:
        accts = re.findall(r'\b5\d{3}\b', reclass_row['label'])
        seen, rebuilt = set(), 0.0
        for a in accts:
            if a in seen:
                continue
            seen.add(a)
            v, where = account_value(rows, a, total_col)
            reclass_detail.append((a, v, where))
            if v is not None:
                rebuilt += v
        control(f"reclass rebuilt from {len(seen)} named accounts",
                abs(rebuilt - reclass) < 0.01, f"rebuilt {rebuilt:,.2f} vs stated {reclass:,.2f}")

    if gp is not None and reclass is not None and agp is not None:
        control("Gross Profit + reclass = Adjusted Gross Profit",
                abs(gp + reclass - agp) < 0.01, f"delta {gp + reclass - agp:+,.2f}")
    if base_ebit is not None and adjustments is not None and rev_ebit is not None:
        control("Base EBITDA + Adjustments = Revised EBITDA",
                abs(base_ebit + adjustments - rev_ebit) < 0.01,
                f"delta {base_ebit + adjustments - rev_ebit:+,.2f}")
    print()

    if reclass_detail:
        print("  reclass audit trail (rebuilt, not copied):")
        for a, v, where in reclass_detail:
            note = "" if v is not None else "   <- named by CFO but absent from the P&L (zero balance)"
            print(f"    {a}  {money(v):>16}  {where}{note}")
        print()

    # ---------------------------------------------------------- INFERRED
    print("-" * 78)
    print("  INFERRED - not stated by the CFO; derivation shown so it can be challenged")
    print("-" * 78)
    deal_agp = deal_rate = None
    if agp is not None and dep_cogs is not None and revenue:
        deal_agp = agp + dep_cogs
        deal_rate = deal_agp / revenue
        print(f"  Hypothesis: DEAL AGP excludes non-cash D&A, i.e. it is gross profit")
        print(f"              before depreciation. The CFO's 'Adjusted' GP stops one line short.")
        print()
        print(f"    Adjusted Gross Profit     {money(agp):>18}   {agp/revenue*100:5.2f}%")
        print(f"  + 5100 Depreciation (COGS)  {money(dep_cogs):>18}   {dep_where}")
        print(f"  = DEAL AGP (derived)        {money(deal_agp):>18}   {deal_rate*100:5.2f}%")
        print()
        gap_to_hint = abs(deal_rate - FTI_AGP_RATE_HINT) * 100
        print(f"    corroboration: FTI/QoE datapack implies ~{FTI_AGP_RATE_HINT*100:.0f}% of revenue")
        print(f"    two independent paths differ by {gap_to_hint:.2f} pts", end="")
        if gap_to_hint <= 0.5:
            print("  -> hypothesis HOLDS")
        else:
            print("  -> ⚠ DIVERGING, re-check before use")
            warns.append(f"derived AGP rate {deal_rate*100:.2f}% vs FTI hint "
                         f"{FTI_AGP_RATE_HINT*100:.0f}% - {gap_to_hint:.2f} pts apart")
    else:
        warns.append("could not derive deal AGP (missing AGP or account 5100)")
    print()

    # ---------------------------------------------------------- EARNOUT
    if deal_rate:
        n_months = len(months) if months else 0
        print("-" * 78)
        print("  EARNOUT POSITION")
        print("-" * 78)
        print(f"  terms: floor {money(EARNOUT_FLOOR_AGP)} AGP -> cap {money(EARNOUT_CAP_AGP)} AGP, "
              f"max {money(EARNOUT_MAX)}, linear")
        span = EARNOUT_CAP_AGP - EARNOUT_FLOOR_AGP
        print(f"  each $1 of revenue inside the band is worth "
              f"${1 * deal_rate / span * EARNOUT_MAX:.2f} of earnout at {deal_rate*100:.2f}%")
        print()
        print(f"  {'scenario':<44}{'FY AGP':>15}{'earnout':>14}")
        print("  " + "-" * 74)

        if n_months:
            ytd_rev = revenue
            annualized = ytd_rev / n_months * 12
            a = annualized * deal_rate
            print(f"  {'YTD annualized (' + str(n_months) + ' mo x 12) - ARITHMETIC ONLY':<44}"
                  f"{a:>15,.0f}{earnout_for(a):>14,.0f}")

        for label, rev_s, note in SCENARIOS:
            a = rev_s * deal_rate
            print(f"  {label:<44}{a:>15,.0f}{earnout_for(a):>14,.0f}")

        print()
        rev_for_cap = EARNOUT_CAP_AGP / deal_rate
        rev_for_floor = EARNOUT_FLOOR_AGP / deal_rate
        print(f"  revenue needed to CLEAR THE FLOOR : {money(rev_for_floor)}")
        print(f"  revenue needed to MAX THE EARNOUT : {money(rev_for_cap)}")
        best = SCENARIOS[0]
        print(f"  '{best[0]}' clears the cap by {money(best[1] - rev_for_cap)}")
        if len(SCENARIOS) > 1:
            d = earnout_for(SCENARIOS[0][1] * deal_rate) - earnout_for(SCENARIOS[1][1] * deal_rate)
            print(f"  choosing the goal over the budget figure is worth {money(d)}")
        print()
        print("  ⚠ 'annualized' is arithmetic, not a forecast - it assumes the remaining")
        print("    months repeat the YTD average. H2 is re-based higher and the work is")
        print("    seasonal, so read it as 'where the year lands if nothing changes'.")
        print()

    # ---------------------------------------------------------- NOT DERIVABLE
    print("-" * 78)
    print("  NOT DERIVABLE FROM THIS FILE - the only things still worth asking for")
    print("-" * 78)
    print("  1. Base EBITDA. Reconstruction from net ordinary income +/- D&A, interest and")
    print("     other income does not reproduce the stated figure. Something in the CFO's")
    print("     calculation is not visible in the P&L.")
    print("  2. The EBITDA 'Adjustments' line. No itemization exists anywhere in the")
    print("     workbook. These are QoE add-backs - third-party work product from")
    print("     FTI/BDO, not data the CFO is withholding.")
    print()
    if base_ebit is not None and rev_ebit is not None:
        print(f"     (stated: base {money(base_ebit)}, adjustments {money(adjustments)},")
        print(f"      revised {money(rev_ebit)} - carried through as given, flagged provisional)")
        print()

    # ---------------------------------------------------------- summary
    print("=" * 78)
    for w in warns:
        print(f"  ⚠ WARN  {w}")
    print(f"  CONTROLS FAILED: {len(fails)}")
    if fails:
        for f in fails:
            print(f"    FAIL  {f}")
        print("  -> do NOT use these figures until the failures are understood.")
    else:
        print("  -> every control passed; the derived figures foot to the CFO's own file.")
    print("=" * 78)

    return len(fails)


if __name__ == '__main__':
    sys.exit(main())
