#!/usr/bin/env python3
"""
Municipal Bid Engine — The actual tool.
Run with: /opt/data/.venv/bin/python bid_engine.py --city "Long Beach" --rfp-dir "/path/to/rfp"

Produces: priced bid spreadsheet + cost floor analysis + competitor intel + filled PDF form.

Used by MuniBot (for Brent) and Boss Hermes.
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

TRIMIT_PIPE = "/opt/data/home/trimit-query.sh"
WAREHOUSE = "/opt/data/municipal-archive"
OUTPUT_DIR = "/opt/data/home/muni-scratch/bid_output"
VENV_PYTHON = "/opt/data/.venv/bin/python"

def run_trimit(sql):
    """Run a SQL query against TRIM IT and return parsed pipe-delimited rows."""
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
    # Find header line
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
    """Step 2: Pull our current schedule-of-comp rates from TRIM IT."""
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
    
    # Compute averages across projects
    from collections import defaultdict
    rate_groups = defaultdict(list)
    for r in rows:
        key = (r.get('LineItem',''), r.get('SizeCode',''), r.get('UOM',''))
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
    print(f"  [Step 2] Averaged into {len(averages)} unique line items across projects")
    return list(averages.values())


def extract_nearby_rates(city):
    """Step 3: Pull nearby city rates for competitive context."""
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
    """Step 4: Find and extract competitor bid data from the warehouse."""
    # Find the city folder in the warehouse
    city_results = []
    for county_dir in Path(WAREHOUSE).iterdir():
        if not county_dir.is_dir():
            continue
        for city_dir in county_dir.iterdir():
            if city_dir.is_dir() and city_dir.name.lower() == city.lower():
                # Look for Bid Results files
                for bid_file in city_dir.rglob("*Bid Results*"):
                    if bid_file.suffix in ('.pdf', '.xlsx'):
                        city_results.append({
                            'file': str(bid_file),
                            'type': 'bid_results',
                            'name': bid_file.name
                        })
                for sched_file in city_dir.rglob("*Schedule of Compensation*"):
                    if sched_file.suffix == '.pdf':
                        city_results.append({
                            'file': str(sched_file),
                            'type': 'schedule',
                            'name': sched_file.name
                        })
                for award_file in city_dir.rglob("*Award*"):
                    if award_file.suffix == '.pdf':
                        city_results.append({
                            'file': str(award_file),
                            'type': 'award',
                            'name': award_file.name
                        })
    print(f"  [Step 4] Found {len(city_results)} competitor/contract files in warehouse")
    return city_results


def extract_price_buddy():
    """Step 5: Pull Price Buddy cost floor from WorkOrderLines."""
    sql = """SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH BandData AS (
    SELECT
        wol.Price,
        wol.TotalMinutes,
        wol.EstTPH,
        wol.TrimMinutes,
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
    AND lst.ServiceClassID = 1
    AND wo.DateCompleted >= '2023-01-01'
)
SELECT
    Band,
    COUNT(*) AS N,
    ROUND(AVG(Price), 2) AS AvgPrice,
    ROUND(AVG(EstTPH), 0) AS AvgEstTPH,
    ROUND(AVG(NULLIF(TrimMinutes,0)), 0) AS AvgTrimMinutes,
    CASE WHEN AVG(EstTPH) > 0
         THEN ROUND(AVG(Price) / AVG(EstTPH), 3) ELSE NULL END AS EstHours,
    CASE WHEN AVG(EstTPH) > 0
         THEN ROUND(AVG(Price) / AVG(EstTPH) * 130.0, 2) ELSE NULL END AS BlendedFloor,
    CASE WHEN AVG(EstTPH) > 0
         THEN ROUND(AVG(Price) / AVG(EstTPH) * 130.0 * 0.75, 2) ELSE NULL END AS GridFloor
FROM BandData
WHERE Band IS NOT NULL
GROUP BY Band
ORDER BY CASE Band WHEN '0-6' THEN 1 WHEN '7-12' THEN 2 WHEN '13-18' THEN 3 WHEN '19-24' THEN 4 WHEN '24-30' THEN 5 WHEN '31+' THEN 6 END;"""
    headers, rows = run_trimit(sql)
    print(f"  [Step 5] Price Buddy: {len(rows)} bands with cost floor data")
    
    result = {}
    for r in rows:
        band = r.get('Band', '')
        result[band] = {
            'n': int(r.get('N', 0)),
            'avg_price': float(r.get('AvgPrice', 0)),
            'est_tph': float(r.get('AvgEstTPH', 0)),
            'trim_mins': float(r.get('AvgTrimMinutes', 0)),
            'est_hours': float(r.get('EstHours', 0)),
            'blended_floor': float(r.get('BlendedFloor', 0)),
            'grid_floor': float(r.get('GridFloor', 0)),
        }
    return result


def extract_inventory(rfp_dir):
    """Step 6: Extract tree inventory from RFP packet."""
    rfp_path = Path(rfp_dir)
    inventory_files = []
    
    # Look for inventory/pricing worksheet files
    for pattern in ["*Pricing*Worksheet*", "*Inventory*", "*inventory*", "*Cost*Proposal*", "*Bid*Results*"]:
        for f in rfp_path.rglob(pattern):
            if f.suffix in ('.pdf', '.xlsx'):
                inventory_files.append(f)
    
    print(f"  [Step 6] Found {len(inventory_files)} inventory/RFP files")
    for f in inventory_files:
        print(f"         {f.name}")
    
    return inventory_files


def run_engine(city, rfp_dir, incumbent=None, tph=130):
    """Run the full bid engine."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print(f"\n{'='*60}")
    print(f"MUNICIPAL BID ENGINE — {city}")
    print(f"{'='*60}")
    print(f"RFP Directory: {rfp_dir}")
    print(f"TPH Target: ${tph}/hr (fully-loaded)")
    if incumbent:
        print(f"Incumbent: {incumbent} (we are CHALLENGER)")
    else:
        print(f"Incumbent: US (we are defending)")
    print()
    
    # Step 1: Find RFP files
    print("STEP 1: Parse RFP form")
    rfp_files = extract_inventory(rfp_dir)
    
    # Step 2: Current rates
    print("\nSTEP 2: Pull current rates from TRIM IT")
    current_rates = extract_current_rates(city)
    
    # Step 3: Nearby rates
    print("\nSTEP 3: Pull nearby city rates")
    nearby_rates = extract_nearby_rates(city)
    
    # Step 4: Competitor bids
    print("\nSTEP 4: Find competitor bids in warehouse")
    competitor_files = extract_competitor_bids(city)
    
    # Step 5: Price Buddy
    print("\nSTEP 5: Pull Price Buddy cost floor")
    price_buddy = extract_price_buddy()
    
    # Save all signals
    signals = {
        'city': city,
        'tph': tph,
        'incumbent': incumbent,
        'current_rates': current_rates,
        'nearby_rates': nearby_rates[:100],  # limit for JSON size
        'competitor_files': competitor_files,
        'price_buddy': price_buddy,
        'rfp_files': [str(f) for f in rfp_files],
    }
    
    signals_path = os.path.join(OUTPUT_DIR, f"{city.replace(' ', '_')}_signals.json")
    with open(signals_path, 'w') as f:
        json.dump(signals, f, indent=2, default=str)
    print(f"\n{'='*60}")
    print(f"Signals saved to: {signals_path}")
    print(f"{'='*60}")
    print(f"\nNEXT STEPS (for the agent):")
    print(f"1. Read {signals_path} for all pricing signals")
    print(f"2. Extract competitor actual bid prices from the warehouse files")
    print(f"3. Extract tree inventory from the RFP packet")
    print(f"4. Set prices using the pricing engine logic")
    print(f"5. Build the spreadsheet output")
    print(f"6. Crew review (Fable + GBT)")
    print(f"7. Deliver to Skipper/Brent")
    print(f"\nLoad the municipal-bid-pricing skill for the full workflow.")
    return signals


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Municipal Bid Engine")
    parser.add_argument("--city", required=True, help="City name (e.g., 'Long Beach')")
    parser.add_argument("--rfp-dir", required=True, help="Path to RFP packet directory")
    parser.add_argument("--incumbent", default=None, help="Incumbent contractor name (if not us)")
    parser.add_argument("--tph", type=int, default=130, help="TPH target (default: 130)")
    args = parser.parse_args()
    
    run_engine(args.city, args.rfp_dir, args.incumbent, args.tph)
