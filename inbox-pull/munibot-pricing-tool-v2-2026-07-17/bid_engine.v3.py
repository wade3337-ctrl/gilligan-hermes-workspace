#!/usr/bin/env python3
"""
Municipal Bid Engine v2 — Patched with guardrails.
Fixes: no blank lines, $130 floor enforcement, variable discount, species differentiation.

Run: /opt/data/.venv/bin/python bid_engine.py --city "Long Beach" --rfp-dir "..." --incumbent "WCA"
"""
import argparse
import json
import os
import subprocess
import re
from pathlib import Path
from collections import defaultdict

TRIMIT_PIPE = "/opt/data/home/trimit-query.sh"
WAREHOUSE = "/opt/data/municipal-archive"
OUTPUT_DIR = "/opt/data/home/muni-scratch/bid_output"
TPH_TARGET = 130  # fully-loaded: labor + equipment + overhead + profit

# ============ PRICING GUARDRAILS ============
VOLUME_BANDS = {"13-18", "19-24", "24-30"}  # drive 70%+ of revenue — price to WIN
LOW_VOLUME_BANDS = {"0-6", "31+"}  # <10% of trees — protect margin
CROWN_RAISE_RATIO = 0.35  # Crown Raise is ~35% of Full Prune (lighter work)
STUMP_REMOVAL_RATIO = 0.35  # Stump grinding is ~35% of removal (less work)
ESCALATION_RATE = 0.035  # 3.5% CPI per year for incumbent estimate
STANDARD_DISCOUNT = 0.08  # 8% under WCA estimate on standard lines
VOLUME_DISCOUNT = 0.10   # 10% under WCA on high-volume bands
LOW_VOL_DISCOUNT = 0.05  # 5% under WCA on low-volume bands (protect margin)


def run_trimit(sql):
    """Run a SQL query against TRIM IT and return parsed rows."""
    sql_file = "/opt/data/home/muni-scratch/_engine_query.sql"
    with open(sql_file, "w") as f:
        f.write(sql)
    result = subprocess.run(
        ["bash", TRIMIT_PIPE],
        input=open(sql_file).read(),
        capture_output=True, text=True, timeout=60
    )
    output = result.stdout.strip()
    lines = output.split('\n')
    header_idx = None
    for i, line in enumerate(lines):
        if '|' in line and not line.startswith('Pseudo') and not line.startswith('Msg'):
            header_idx = i
            break
    if header_idx is None:
        return [], []
    headers = [h.strip() for h in lines[header_idx].split('|')]
    rows = []
    for line in lines[header_idx + 2:]:
        line = line.strip()
        if not line or line.startswith('(') or line.startswith('Msg') or line.startswith('Pseudo'):
            continue
        values = line.split('|')
        if len(values) == len(headers):
            rows.append(dict(zip(headers, [v.strip() for v in values])))
    return headers, rows


def extract_current_rates(city):
    """Pull current schedule-of-comp rates from TRIM IT, averaged across projects."""
    sql = f"""SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT p.Desc1 AS ProjectName, l.City, lst.Desc1 AS LineItem,
       lst.SizeCode, lst.BasePrice, u.Desc1 AS UOM,
       lst.ServiceClassID, sc.Desc1 AS ServiceClass
FROM dbo.ProjectGroups pg WITH (NOLOCK)
JOIN dbo.Projects p WITH (NOLOCK) ON pg.ProjectID = p.ProjectID
LEFT JOIN dbo.Locations l WITH (NOLOCK) ON p.LocationID = l.LocationID
JOIN dbo.LocationServiceTypes lst WITH (NOLOCK) ON p.LocationID = lst.LocationID
LEFT JOIN dbo.UOMDefs u WITH (NOLOCK) ON lst.UOMDefID = u.UOMDefID
LEFT JOIN dbo.ServiceClasses sc WITH (NOLOCK) ON lst.ServiceClassID = sc.ServiceClassID
WHERE pg.ProjectGroupDefID = 11
AND lst.StatusDefID = 500 AND lst.BasePrice > 0
AND l.City = '{city}'
ORDER BY p.Desc1, lst.SeqOrder;"""
    headers, rows = run_trimit(sql)
    print(f"  [Step 2] Current rates: {len(rows)} line items from TRIM IT")

    rate_groups = defaultdict(list)
    for r in rows:
        key = (r.get('LineItem', ''), r.get('SizeCode', ''), r.get('UOM', ''))
        try:
            price = float(r.get('BasePrice', 0))
            if price > 0:
                rate_groups[key].append(price)
        except:
            pass

    averages = {}
    for key, prices in rate_groups.items():
        avg = sum(prices) / len(prices)
        averages[key] = {
            'line_item': key[0], 'size_code': key[1], 'uom': key[2],
            'avg_price': round(avg, 2), 'min': min(prices), 'max': max(prices),
            'n_projects': len(prices)
        }
    print(f"  [Step 2] Averaged into {len(averages)} unique line items")
    return list(averages.values())


def extract_nearby_rates(city):
    """Pull nearby city rates for competitive context."""
    sql = f"""SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT l.City, lst.Desc1 AS LineItem, lst.SizeCode, lst.BasePrice, u.Desc1 AS UOM
FROM dbo.ProjectGroups pg WITH (NOLOCK)
JOIN dbo.Projects p WITH (NOLOCK) ON pg.ProjectID = p.ProjectID
LEFT JOIN dbo.Locations l WITH (NOLOCK) ON p.LocationID = l.LocationID
JOIN dbo.LocationServiceTypes lst WITH (NOLOCK) ON p.LocationID = lst.LocationID
LEFT JOIN dbo.UOMDefs u WITH (NOLOCK) ON lst.UOMDefID = u.UOMDefID
WHERE pg.ProjectGroupDefID = 11
AND lst.StatusDefID = 500 AND lst.BasePrice > 0
AND lst.ServiceClassID = 1 AND u.Desc1 = 'EA'
AND l.City != '{city}'
ORDER BY l.City, lst.Desc1, lst.SizeCode;"""
    headers, rows = run_trimit(sql)
    print(f"  [Step 3] Nearby rates: {len(rows)} line items from other cities")
    return rows


def extract_competitor_bids(city):
    """Find competitor bid data files in the warehouse."""
    city_results = []
    for county_dir in Path(WAREHOUSE).iterdir():
        if not county_dir.is_dir():
            continue
        for city_dir in county_dir.iterdir():
            if city_dir.is_dir() and city_dir.name.lower() == city.lower():
                for pattern in ["*Bid Results*", "*Schedule of Compensation*", "*Award*"]:
                    for f in city_dir.rglob(pattern):
                        if f.suffix in ('.pdf', '.xlsx'):
                            city_results.append({'file': str(f), 'type': pattern.strip('*'), 'name': f.name})
    print(f"  [Step 4] Found {len(city_results)} competitor/contract files in warehouse")
    return city_results


def extract_price_buddy():
    """Pull Price Buddy cost floor from WorkOrderLines.
    
    Uses CycleTimeEach (full per-tree cycle: trim + clean + chip + travel)
    as the primary floor source. This is the real production time per tree.
    
    EstTPH is WRONG — it's a WO-level estimate (same value on every line).
    TrimMinutes UNDERSTATES cost (excludes cleanup/chip/travel).
    CycleTimeEach is the correct measure of what it costs per tree.
    """
    sql = """SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH BandData AS (
    SELECT
        wol.Price,
        wol.TrimMinutes,
        wol.CycleTimeEach,
        wol.SizeCode,
        CASE
            WHEN wol.SizeCode IN ('0-6','00-03','04-06','0-4','0-2','4-6') THEN '0-6'
            WHEN wol.SizeCode IN ('07-12','7-12','4-10') THEN '7-12'
            WHEN wol.SizeCode IN ('13-18','10-17') THEN '13-18'
            WHEN wol.SizeCode IN ('19-24','17-24') THEN '19-24'
            WHEN wol.SizeCode IN ('25-30','24-30','25-36') THEN '24-30'
            WHEN wol.SizeCode IN ('31+','31-36','30-37','37+','37-42','42+','>30','>28.5') THEN '31+'
            WHEN wol.SizeCode IN ('SML','S','XSML') THEN '0-6'
            WHEN wol.SizeCode IN ('MED','M') THEN '13-18'
            WHEN wol.SizeCode IN ('LRG','L') THEN '19-24'
            WHEN wol.SizeCode IN ('XLRG','XL','XXLRG','XXXLRG') THEN '31+'
            ELSE NULL
        END AS Band
    FROM dbo.WorkOrderLines wol WITH (NOLOCK)
    JOIN dbo.WorkOrders wo WITH (NOLOCK) ON wol.WorkOrderID = wo.WorkOrderID
    JOIN dbo.LocationServiceTypes lst WITH (NOLOCK) ON wol.LocationServiceTypeID = lst.LocationServiceTypeID
    WHERE wo.StatusDefID = 48
    AND wol.StatusDefID = 68
    AND wol.Price > 0
    AND wol.Qty = 1
    AND lst.ServiceClassID = 1
    AND wo.DateCompleted >= '2023-01-01'
)
SELECT
    Band,
    COUNT(*) AS N,
    ROUND(AVG(Price), 2) AS AvgPrice,
    ROUND(AVG(NULLIF(TrimMinutes, 0)), 0) AS AvgTrimMinutes,
    ROUND(AVG(NULLIF(CycleTimeEach, 0)), 0) AS AvgCycleMinutes,
    -- PRIMARY FLOOR: from CycleTimeEach (full production cycle per tree)
    CASE WHEN AVG(NULLIF(CycleTimeEach, 0)) > 0
         THEN ROUND((AVG(NULLIF(CycleTimeEach, 0)) / 60.0) * 130.0, 2)
         ELSE NULL END AS BlendedFloor,
    -- SECONDARY: from TrimMinutes only (cutting time, understates cost)
    CASE WHEN AVG(NULLIF(TrimMinutes, 0)) > 0
         THEN ROUND((AVG(NULLIF(TrimMinutes, 0)) / 60.0) * 130.0, 2)
         ELSE NULL END AS GridFloor,
    -- Hours per tree from cycle time
    CASE WHEN AVG(NULLIF(CycleTimeEach, 0)) > 0
         THEN ROUND(AVG(NULLIF(CycleTimeEach, 0)) / 60.0, 3) ELSE NULL END AS EstHours,
    -- Derived TPH from actual price and cycle time
    CASE WHEN AVG(NULLIF(CycleTimeEach, 0)) > 0
         THEN ROUND(AVG(Price) / (AVG(NULLIF(CycleTimeEach, 0)) / 60.0), 0) ELSE NULL END AS EstTPH
FROM BandData
WHERE Band IS NOT NULL
GROUP BY Band
ORDER BY CASE Band WHEN '0-6' THEN 1 WHEN '7-12' THEN 2 WHEN '13-18' THEN 3 WHEN '19-24' THEN 4 WHEN '24-30' THEN 5 WHEN '31+' THEN 6 END;"""
    headers, rows = run_trimit(sql)
    print(f"  [Step 5] Price Buddy: {len(rows)} bands with cost floor data (CycleTimeEach method)")
    result = {}
    for r in rows:
        band = r.get('Band', '')
        result[band] = {
            'n': int(r.get('N', 0)), 'avg_price': float(r.get('AvgPrice', 0)),
            'est_tph': float(r.get('EstTPH', 0)),
            'trim_mins': float(r.get('AvgTrimMinutes', 0)),
            'est_hours': float(r.get('EstHours', 0)),
            # BlendedFloor = full cycle cost (trim+clean+chip+travel) × $130
            'blended_floor': float(r.get('BlendedFloor', 0)),
            # GridFloor = trim-only cost (cutting time only) × $130
            'grid_floor': float(r.get('GridFloor', 0)),
        }
    return result


def extract_inventory_files(rfp_dir):
    """Find RFP and inventory files."""
    rfp_path = Path(rfp_dir)
    files = []
    for pattern in ["*Pricing*Worksheet*", "*Inventory*", "*Cost*Proposal*", "*Bid*Results*", "*Appendix*"]:
        for f in rfp_path.rglob(pattern):
            if f.suffix in ('.pdf', '.xlsx'):
                files.append(f)
    print(f"  [Step 6] Found {len(files)} inventory/RFP files")
    return files


# ============ THE PRICING ENGINE ============

def apply_floor(price, floor, tph=TPH_TARGET):
    """Enforce the $130 TPH floor on labor/day rates."""
    if floor and price < floor:
        return floor
    return price


def price_grid_pruning(wca_est, band, grid_floor):
    """Price grid pruning lines with variable discount by volume band."""
    if band in VOLUME_BANDS:
        discount = VOLUME_DISCOUNT  # 10% under WCA on high-volume bands
    elif band in LOW_VOLUME_BANDS:
        discount = LOW_VOL_DISCOUNT  # 5% under WCA on low-volume bands
    else:
        discount = STANDARD_DISCOUNT  # 8% standard

    target = round(wca_est * (1 - discount))

    # Floor check — don't go below grid floor on high-volume bands
    if grid_floor and band in VOLUME_BANDS and target < grid_floor:
        target = round(grid_floor + 2)  # $2 above floor

    return target


def price_crown_raise(full_prune_price):
    """Crown Raise is lighter work — 35% of Full Prune."""
    return round(full_prune_price * CROWN_RAISE_RATIO)


def price_stump(removal_price):
    """Stump grinding is less work — 35% of removal price."""
    return round(removal_price * STUMP_REMOVAL_RATIO)


def price_labor(wca_est):
    """Labor rate — enforce $130 TPH floor. Never below."""
    target = round(wca_est * (1 - STANDARD_DISCOUNT))
    return max(target, TPH_TARGET)  # Floor at $130


def price_day_rate(wca_est, n_persons=3, n_hours=8):
    """Day rate — enforce floor: personnel × hours × $130."""
    target = round(wca_est * (1 - STANDARD_DISCOUNT))
    floor = n_persons * n_hours * TPH_TARGET  # 3 × 8 × $130 = $3,120
    return max(target, floor)


def price_emergency(wca_est, after_hours=False):
    """Emergency crew rate — enforce floor + premium."""
    target = round(wca_est * (1 - STANDARD_DISCOUNT))
    # Floor: 3 persons × $130 = $390/hr minimum, plus 25% after-hours premium
    floor = 3 * TPH_TARGET * (1.25 if after_hours else 1.0)
    return max(target, round(floor))


def price_standard(wca_est, discount=STANDARD_DISCOUNT):
    """Standard line — X% under WCA."""
    return round(wca_est * (1 - discount))


def run_engine(city, rfp_dir, incumbent=None, tph=TPH_TARGET):
    """Run the full bid engine."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"MUNICIPAL BID ENGINE v2 — {city}")
    print(f"{'='*60}")
    print(f"TPH Target: ${tph}/hr (fully-loaded)")
    print(f"Incumbent: {incumbent or 'US (defending)'}")
    print()

    print("STEP 1: Parse RFP form")
    rfp_files = extract_inventory_files(rfp_dir)

    print("\nSTEP 2: Pull current rates from TRIM IT")
    current_rates = extract_current_rates(city)

    print("\nSTEP 3: Pull nearby city rates")
    nearby_rates = extract_nearby_rates(city)

    print("\nSTEP 4: Find competitor bids in warehouse")
    competitor_files = extract_competitor_bids(city)

    print("\nSTEP 5: Pull Price Buddy cost floor")
    price_buddy = extract_price_buddy()

    # Save signals
    signals = {
        'city': city, 'tph': tph, 'incumbent': incumbent,
        'current_rates': current_rates, 'nearby_rates': nearby_rates[:100],
        'competitor_files': competitor_files, 'price_buddy': price_buddy,
        'rfp_files': [str(f) for f in rfp_files],
        # Pricing guardrails for the output generator
        'guardrails': {
            'tph_target': tph,
            'volume_bands': list(VOLUME_BANDS),
            'low_volume_bands': list(LOW_VOLUME_BANDS),
            'crown_raise_ratio': CROWN_RAISE_RATIO,
            'stump_removal_ratio': STUMP_REMOVAL_RATIO,
            'escalation_rate': ESCALATION_RATE,
            'standard_discount': STANDARD_DISCOUNT,
            'volume_discount': VOLUME_DISCOUNT,
            'low_vol_discount': LOW_VOL_DISCOUNT,
            'labor_floor': tph,
            'day_rate_floor': 3 * 8 * tph,
            'emergency_day_floor': 3 * tph,
            'emergency_night_floor': round(3 * tph * 1.25),
        }
    }

    signals_path = os.path.join(OUTPUT_DIR, f"{city.replace(' ', '_')}_signals.json")
    with open(signals_path, 'w') as f:
        json.dump(signals, f, indent=2, default=str)

    print(f"\n{'='*60}")
    print(f"Signals + guardrails saved to: {signals_path}")
    print(f"{'='*60}")
    print(f"\nPRICING GUARDRAILS ACTIVE:")
    print(f"  TPH floor: ${tph}/hr (fully-loaded)")
    print(f"  Labor floor: ${tph}/hr per person")
    print(f"  Day rate floor: ${3*8*tph:,}/day (3p × 8hr × ${tph})")
    print(f"  Emergency floor: ${3*tph}/hr day, ${round(3*tph*1.25)}/hr night")
    print(f"  Volume discount: {VOLUME_DISCOUNT*100:.0f}% under WCA on {VOLUME_BANDS}")
    print(f"  Standard discount: {STANDARD_DISCOUNT*100:.0f}% under WCA")
    print(f"  Low-volume discount: {LOW_VOL_DISCOUNT*100:.0f}% under WCA (margin protection)")
    print(f"  Crown Raise: {CROWN_RAISE_RATIO*100:.0f}% of Full Prune")
    print(f"  Stump Grinding: {STUMP_REMOVAL_RATIO*100:.0f}% of Removal")
    print(f"\nLoad the municipal-bid-pricing skill for the full workflow.")
    print(f"Run competitor_extractor.py to get actual bid prices.")
    print(f"Run bid_output.py to build the spreadsheet.")
    return signals


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Municipal Bid Engine v2")
    parser.add_argument("--city", required=True)
    parser.add_argument("--rfp-dir", required=True)
    parser.add_argument("--incumbent", default=None)
    parser.add_argument("--tph", type=int, default=130)
    args = parser.parse_args()
    run_engine(args.city, args.rfp_dir, args.incumbent, args.tph)
