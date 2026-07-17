#!/usr/bin/env python3
"""
Competitor Bid Extractor v2 — Parses Long Beach-style bid results PDFs.
Format: Description / 1 / UNIT / $price1 / $total1 / $price2 / $total2

Run: /opt/data/.venv/bin/python competitor_extractor.py "Long Beach"
"""
import re
import sys
import json
from pathlib import Path

def extract_bid_results(pdf_path):
    """Extract bidder prices from a Bid Results PDF.
    
    Long Beach format (7 lines per item):
    L0: DESCRIPTION (e.g., FULL PRUNE 0-6" DSH)
    L1: 1 (qty)
    L2: UNIT (EACH, FOOT, MAN HOUR, DAY, CREW HOUR)
    L3: $XX.00 (bidder 1 unit price)
    L4: $XX.00 (bidder 1 total = same since qty=1)
    L5: $YY.00 (bidder 2 unit price)
    L6: $YY.00 (bidder 2 total)
    """
    import pymupdf
    
    doc = pymupdf.open(pdf_path)
    full_text = ""
    for page in doc:
        full_text += page.get_text()
    doc.close()
    
    lines = [l.strip() for l in full_text.split('\n')]
    results = []
    
    # Find bidder names (usually at the end of the document)
    bidder1_name = "Bidder 1"
    bidder2_name = "Bidder 2"
    for i, line in enumerate(lines):
        if 'GSTS' in line.upper() and 'WCA' in lines[i+1].upper() if i+1 < len(lines) else False:
            # Check which column is which
            pass
        if 'PRICING' in line.upper() and i > 0:
            # Try to find bidder name labels
            if 'WCA' in line.upper():
                bidder1_name = "WCA"
    
    # Scan for line items
    # Pattern: a description line followed by '1' then unit then 4 dollar amounts
    i = 0
    while i < len(lines) - 6:
        line = lines[i]
        
        # Skip headers/noise
        if not line or line in ('DESCRIPTION', 'QTY', 'UNIT', 'TOTAL', 'UNIT PRICE', 'CITY OF LONG BEACH'):
            i += 1
            continue
        
        # Check if this is a description line:
        # Must not start with $, must not be a number, must not be a unit
        if line.startswith('$') or line.isdigit() or line in ('EACH', 'FOOT', 'MAN HOUR', 'DAY', 'CREW HOUR', 'INCH'):
            i += 1
            continue
        
        # Check if next lines match the pattern: 1, UNIT, $, $, $, $
        if (i + 6 < len(lines) and
            lines[i+1] == '1' and
            lines[i+2] in ('EACH', 'FOOT', 'MAN HOUR', 'DAY', 'CREW HOUR', 'INCH', 'PER FOOT', 'PER DAY', 'PER HOUR') and
            lines[i+3].startswith('$') and
            lines[i+4].startswith('$') and
            lines[i+5].startswith('$') and
            lines[i+6].startswith('$')):
            
            desc = line
            unit = lines[i+2]
            
            try:
                p1 = float(lines[i+3].replace('$', '').replace(',', ''))
                p2 = float(lines[i+5].replace('$', '').replace(',', ''))
            except ValueError:
                i += 1
                continue
            
            results.append({
                'description': desc,
                'unit': unit,
                'bidder1_price': p1,
                'bidder2_price': p2,
            })
            i += 7  # Skip past this item
        else:
            i += 1
    
    # Try to identify bidder names from the document
    if 'GSTS' in full_text.upper() and 'WCA' in full_text.upper():
        # In Long Beach 2021, column 1 was WCA (winner), column 2 was GSTS
        # Verify: WCA won, and their prices are in column 1
        for r in results:
            r['bidder1_name'] = 'WCA'
            r['bidder2_name'] = 'GSTS'
    
    return results


def find_bid_results_files(city):
    """Find Bid Results files for a city in the warehouse."""
    warehouse = Path("/opt/data/municipal-archive")
    files = []
    for county_dir in warehouse.iterdir():
        if not county_dir.is_dir():
            continue
        for city_dir in county_dir.iterdir():
            if city_dir.is_dir() and city_dir.name.lower() == city.lower():
                for f in city_dir.rglob("*Bid Results*"):
                    if f.suffix == '.pdf':
                        files.append(f)
    return files


if __name__ == "__main__":
    city = sys.argv[1] if len(sys.argv) > 1 else "Long Beach"
    
    files = find_bid_results_files(city)
    print(f"Found {len(files)} Bid Results files for {city}\n")
    
    all_results = {}
    
    for pdf_file in files:
        results = extract_bid_results(str(pdf_file))
        if results:
            print(f"{'='*70}")
            print(f"FILE: {pdf_file.name}")
            print(f"  Path: {pdf_file.parent.name}")
            print(f"  Items: {len(results)}")
            print(f"{'='*70}")
            print(f"{'Description':45s} {'Unit':12s} {'Bidder1':>10s} {'Bidder2':>10s}")
            print("-" * 80)
            for r in results:
                b1 = f"${r['bidder1_price']:,.0f}" if r['bidder1_price'] else "---"
                b2 = f"${r['bidder2_price']:,.0f}" if r['bidder2_price'] else "---"
                print(f"{r['description']:45s} {r['unit']:12s} {b1:>10s} {b2:>10s}")
            
            key = str(pdf_file.parent)
            all_results[key] = results
            print()
    
    # Save all extracted bid results as JSON
    output = f"/opt/data/home/muni-scratch/bid_output/{city.replace(' ', '_')}_competitor_bids.json"
    Path(output).parent.mkdir(parents=True, exist_ok=True)
    with open(output, 'w') as f:
        json.dump(all_results, f, indent=2)
    print(f"\nSaved to: {output}")
