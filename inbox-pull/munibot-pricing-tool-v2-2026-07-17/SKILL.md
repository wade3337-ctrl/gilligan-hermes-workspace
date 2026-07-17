---
name: municipal-bid-pricing
description: "Price municipal tree-care bids to win and make money. Synthesize Price Buddy cost floor, competitive comps, historical bids, inventory weighting, and TPH floor into specific recommended prices — not options."
version: 1.1.0
author: Boss Hermes
platforms: [linux]
metadata:
  hermes:
    tags: [municipal, bidding, pricing, tree-care, trim-it, price-buddy, crew-review]
    related_skills: [trim-it-operations, crew-orchestration, rfp-flow]
---

# Municipal Bid Pricing — Win the Bid AND Make Money

> The tool's job is to come back with **specific recommended prices and why** — not a table of options for the Skipper to decide. Synthesize all signals into one call.

## Trigger

When the Skipper says "price this bid," "fill out this RFP," "what should we bid for [city]," or hands you a municipal RFP packet.

## The Pricing Philosophy

**Win the bid at the lowest price that still clears our margin floor.**

- Lead with competitiveness — price to WIN on the bands that drive the most revenue
- Hard floor = TPH. **$130/hour is FULLY-LOADED** (labor + equipment + overhead + profit). Do NOT add equipment on top. This IS the all-in number.
- Weight by tree inventory — the bands with the most trees and revenue get the most competitive pricing
- Protect margin on low-volume lines where the city can't shop around

## The Pricing Engine — Step by Step

### Step 1: Extract the RFP form

Parse the city's cost-proposal form (usually a PDF) to get:
- Every line item, unit, and size band
- Contract term (base years + renewal periods)
- Escalation cap fields (may be blank — needs to be proposed)
- Any "submit AS IS, no alterations" language

Extract PDF text with pymupdf (`/opt/data/.venv/bin/python` — pymupdf is installed in the venv, not system Python).

### Step 2: Pull current contract rates from TRIM IT

```sql
SELECT p.Desc1, l.City, lst.Desc1 AS LineItem, lst.SizeCode, lst.BasePrice, u.Desc1 AS UOM
FROM dbo.ProjectGroups pg
JOIN dbo.Projects p ON pg.ProjectID = p.ProjectID
LEFT JOIN dbo.Locations l ON p.LocationID = l.LocationID
JOIN dbo.LocationServiceTypes lst ON p.LocationID = lst.LocationID
LEFT JOIN dbo.UOMDefs u ON lst.UOMDefID = u.UOMDefID
WHERE pg.ProjectGroupDefID = 11 AND lst.StatusDefID = 500 AND lst.BasePrice > 0
AND l.City = '<city>'
ORDER BY p.Desc1, lst.SeqOrder;
```

**A city may have MULTIPLE projects with different rates.** Average them or use a weighted average. Long Beach had 5 separate projects (Alamitos Bay, Grand Prix, Queensway Bay, Beach/Marinas, Parks & Rec) with rates ranging 30%+ apart.

### Step 3: Pull nearby city rates for competitive context

Query TRIM IT for the same service types in nearby cities. Use DBH-banded rates only (skip flat rates and species-specific rates for comparison). The competitive column tells you the market floor and ceiling.

### Step 4: Pull historical bids from the warehouse

The municipal-archive warehouse at `/opt/data/municipal-archive/` has our prior bid submissions and competitor pricing. Extract with pymupdf. Look for:
- `Schedule of Compensation.pdf` files (our prior contract rates)
- `Bid Proposal.pdf` and `Bid Results.pdf` (competitor pricing)

### Step 5: Pull Price Buddy cost floor (MANDATORY)

The Price Buddy cost floor tells us what it ACTUALLY COSTS US to do each size of tree. See `references/price-buddy-cost-floor.md` in trim-it-operations for the full method.

**Critical:** The `GetLevel4PriceRange$TPH` SQL function returns 0 rows on DEV/PLAY (Workbench DB inaccessible). Rebuild the cost floor from WorkOrderLines directly.

### Step 6: Pull tree inventory from the RFP packet

The city's pricing worksheet has species × DBH band tree counts. Weight every pricing decision by volume. The bands with the most trees drive the most revenue and determine whether we win.

### Step 7: Synthesize into specific prices

This is the core step. The tool makes THE CALL — specific dollar amounts with a one-sentence "why" per line. Not a comparison table. Not options.

**For challenger bids (we don't hold the contract):**
1. Start from the incumbent's inflation-adjusted bid (Step 4 competitor extraction)
2. Target 5-10% under the escalated estimate on volume bands (bands driving >15% of revenue)
3. Check against Price Buddy grid floor (Step 5) — never below grid floor unless accepting a strategic loss on a low-volume band
4. Price low-volume bands (<5% of trees) above all comps — protect margin, won't hurt bid score
5. The 24-30 band is typically the hardest: it's 25-35% of revenue but the grid floor may exceed the incumbent's bid. Accept the gap and bet on grid efficiency.

**For incumbent bids (we hold the contract):**
1. Start from current rates
2. Hold or slightly raise, keeping under the most expensive comp
3. Use Price Buddy to verify margin on every band
4. This is the easier scenario — we're not fighting to take the contract

**For all bids, per line type:**
1. **High volume + high revenue** (e.g., 13-18, 19-24, 24-30) → **price to WIN**. Thin margin OK — volume covers it.
2. **Low volume** (e.g., 0-6, 31+) → **price for MARGIN**. Won't hurt bid score at 3-6% of volume.
3. **Premium lines** (hourly, emergency, arborist) → **HOLD at current**. City can't shop around. No reason to cut.
4. **Single-tree/service-request** → **Price ABOVE all grid rates** to prevent adverse selection.
5. **Removals/stumps** → If pricing basis changed (per-inch → per-tree), convert using band midpoints and flag for review.

### Step 8: Crew review (Fable + GBT)

Send the pricing to Fable and GBT independently for review. They catch:
- Bands priced below cost floor
- Structural issues (flat pricing where progression needed, adverse selection traps)
- Premium lines being unnecessarily cut
- Escalation cap inadequacy

Synthesize their feedback, fix real issues, finalize.

### Step 9: Deliver

Build an Excel spreadsheet (openpyxl in `/opt/data/.venv/bin/python`) with:
- Sheet 1: Cost Proposal (all line items with tree counts, annual values, editable price column)
- Sheet 2: Cost Floor Analysis (Price Buddy data per band)
- Sheet 3: Volume Analysis (DBH distribution + contract projections)
- Sheet 4: Regional Comparison (our prices vs nearby cities)
- Sheet 5: Top Species (inventory breakdown)

**No internal change notes, version history, or crew review details in the deliverable.** Those are for us, not the team.

## Key Rules (Skipper-confirmed)

1. **THE TOOL DECIDES.** Come back with recommended prices and the reasoning. Do not present option tables for the Skipper to choose from. The Skipper said: "The idea of this tool is to come up with numbers that will win us the bid and make us money. You are presenting data for us to decide."
2. **TPH = $130 is FULLY-LOADED.** Labor + equipment + overhead + profit. Do NOT add equipment on top. Skipper confirmed this explicitly when crew review models incorrectly assumed it was labor-only.
3. **Weight by tree inventory.** Volume-weighted pricing is mandatory. The Skipper asked "did we weight the number of trees in each line item?" — it's a core expectation.
4. **Use Price Buddy cost floor.** It's a core signal, not optional. The Skipper asked "has the pricing buddy tool been used to weight these prices at all?" — if it wasn't used, that's a failure of the tool.
5. **Hold premium lines at current.** Emergency, hourly, arborist rates — city can't shop around.
6. **No change notes in deliverables.** Internal rationale stays internal. The Skipper said "remove the pricing change notes from the spreadsheet the team doesn't need those."
7. **Average multiple project rates.** A city may have several TRIM IT projects with different rates. The Skipper said "I would use an average" when we discovered Long Beach had 5 different rate cards.
8. **Crew review catches real issues.** Fable + GBT independently. Synthesize, don't just relay.
9. **DIR prevailing wage = same labor costs for everyone.** Competitor hourly rates are their TPH, not cheaper labor. Skipper corrected this when we wrongly assumed WCA had a labor cost advantage.
10. **Don't be too aggressive with price cuts.** The Skipper flagged this after reviewing challenger pricing. Bump thin bands up. Check Price Buddy floor on every line.
11. **Deliver a spreadsheet, not a PDF.** The Skipper said "it would be better to extract the info from the pdf into a spreadsheet and populate that so we can manipulate the numbers easily."
12. **Include Price Buddy data in the deliverable.** The Skipper said "you should include the pricing buddy results in our worksheet too for us to understand where the math comes from."

## Pitfalls

1. **pymupdf is in the venv, not system Python.** Use `/opt/data/.venv/bin/python` for PDF extraction.
2. **Himalaya does NOT support attachments.** Use Python `smtplib` directly for file attachments.
3. **WorkOrderLines StatusDefID = 68** for completed lines (NOT 48, which is WO-level).
4. **SizeCodes use BOTH formats** in WorkOrderLines: DBH bands (`0-6`, `07-12`, `13-18`) AND S/M/L/XLRG. Map both.
5. **Pricing Worksheet.xlsx may be 30MB+** (contains full tree inventory embedded). It will time out openpyxl. Use the PDF version instead.
6. **Blended Price Buddy data overstates large-band cost** (inflated by slow service requests). For precision, filter to grid-only WOs.
7. **31+ is an unbounded band.** A 32" and a 60" tree can't share one price. Flag for extraordinary-size provision.
8. **Single-tree line is an adverse selection trap.** Price it ABOVE all grid rates so the city always saves by routing through grid trimming.
9. **Escalation at 5% per renewal ≠ 5% per year.** 3 renewals × 5% = 16% cumulative. Propose annual CPI adjustment.
10. **NEVER leave Crown Raise or Stump Grinding blank.** Crown Raise = 35% of Full Prune. Stump = 35% of Removal. Always populate.
11. **NEVER price labor below $130/hr.** This is the fully-loaded TPH floor. Day rate floor = 3 persons × 8 hrs × $130 = $3,120.
12. **Differentiate palm species.** Date Palm clean ≠ Fan Palm clean. Date is premium work, Fan is easier. Price Date Palm clean at 8% under WCA. Price Fan Palm clean at 40% under WCA (WCA overcharges for fan palm clean — it's fast work).
13. **Variable discount by volume band.** Do NOT apply a flat 7% discount everywhere. 10% under WCA on volume bands (13-18, 19-24, 24-30), 8% standard, 5% on low-volume bands (0-6, 31+) to protect margin.
14. **MuniBot HOME=/root.** Scripts must run by full path (`/opt/data/home/bid_engine.py`), not `~/`.
15. **Crew review models may wrongly assume TPH is labor-only.** When Fable/GBT say "add equipment on top of $130," they are WRONG. $130 is fully-loaded. Ignore their recommendation to add equipment/overhead — it double-counts.
16. **Competitor hourly rates are their TPH, not their labor cost.** On DIR prevailing wage jobs, everyone pays the same Davis-Bacon rates. WCA's $94/hr in 2021 was their fully-loaded TPH — same metric as our $130 today. Their TPH has risen alongside ours.
17. **Determine incumbent status BEFORE pricing.** Ask the Skipper who holds the contract. If we are the challenger, the benchmark is the incumbent's actual prior bid (from warehouse Bid Results), not our own current rates. Getting this wrong leads to pricing as an incumbent when you should be pricing as a challenger.
18. **Competitor bid data is in the warehouse.** Bid Results PDFs show actual bidder unit prices side by side. This is the most valuable competitive intel available. The `competitor_extractor.py` script parses these automatically.
19. **MuniBot first test (2026-07-17) found 4 bugs:** blank Crown Raise/Stump lines, labor below $130 floor, flat 7% discount, no palm differentiation. All fixed in v2 scripts — verify the output prints "VERIFIED: All 46 line items priced. No blanks." after every run.

## Email Attachment Pattern

Himalaya `template send` does NOT support `--attachment`. For file attachments, use Python SMTP:

```python
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

msg = MIMEMultipart()
msg['From'] = 'bossherman.gsts@gmail.com'
msg['To'] = 'jwade@gstsinc.com'
msg['Subject'] = 'Subject here'
msg.attach(MIMEText(body, 'plain'))

with open(filepath, 'rb') as f:
    part = MIMEBase('application', 'octet-stream')
    part.set_payload(f.read())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', 'attachment', filename=filename)
    msg.attach(part)

with open('/opt/data/.secrets/gmail-app.txt') as f:
    password = f.read().strip()
server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login('bossherman.gsts@gmail.com', password)
server.send_message(msg)
server.quit()
```

## Challenger Pricing — When We're Not the Incumbent (2026-07-17)

**CRITICAL:** Before pricing, determine whether we HOLD the contract or are trying to WIN IT BACK. The pricing strategy is completely different.

### Determine incumbent status

1. Search the warehouse for `Notice of Intent to Award` or `Staff Report - Contract Award` — these name the winner
2. If TRIM IT shows active rates for us on that city/contract, we may still hold it — but verify the specific contract (Parks vs Public Works may be held by different companies)
3. **Ask the Skipper** if unclear — he knows who holds what

### If we are the CHALLENGER

The benchmark is the **incumbent's actual prior bid**, not our own current rates. Steps:

1. **Find the incumbent's actual bid prices** in the warehouse `Bid Results.pdf`. This shows BOTH bidders' unit prices side by side.
2. **Inflation-adjust** the incumbent's prices to current year:
   - 5-year-old bid: multiply by ~1.19 (3.5% CPI/year)
   - 10-year-old bid: multiply by ~1.50-1.70
3. **Price 5-15% under** the incumbent's inflation-adjusted estimate on volume bands
4. **Accept we may not beat them on every line** — price to win on the bands that drive 80%+ of revenue
5. **Lean on quality and track record** — RFPs are often qualification-weighted, not purely lowest-price

### Long Beach worked example

- WE held Public Works 2015-2021 (bid $29-129/tree)
- WCA took Public Works 2021-2026 (bid $44-174/tree — their actual bid from warehouse Bid Results PDF)
- WE still hold Parks & Rec (separate, higher rates)
- For 2027-2032 we are the CHALLENGER — must beat WCA's inflation-adjusted prices, not our own Parks rates

## DIR Prevailing Wage — Same Labor Costs for Everyone (2026-07-17)

**CORRECTION:** Municipal contracts with Davis-Bacon/DIR prevailing wage mean ALL contractors pay the same labor rates. There is NO labor cost advantage between bidders.

When you see a competitor's hourly rate (e.g., WCA bid $94/hr in 2021), that is their **TPH at that time** — their fully-loaded rate including overhead, equipment, and profit. It is NOT evidence of cheaper labor. Their TPH has risen alongside ours.

- WCA's $94/hr in 2021 ≈ our TPH from that era
- WCA's 2026 TPH is likely $110-130 — same range as our $130
- Do NOT assume "they have lower labor costs" — that is wrong on DIR jobs
- The only real cost differences between bidders are crew efficiency, route knowledge, and overhead structure

## Tool Scripts

This skill ships with three executable scripts in `scripts/`:

| Script | Purpose | Command |
|--------|---------|---------|
| `bid_engine.py` | Pulls all 5 pricing signals in one shot | `/opt/data/.venv/bin/python scripts/bid_engine.py --city "<city>" --rfp-dir "<path>" --incumbent "<name>"` |
| `competitor_extractor.py` | Parses warehouse Bid Results PDFs automatically | `/opt/data/.venv/bin/python scripts/competitor_extractor.py "<city>"` |
| `bid_output.py` | Builds the final spreadsheet from signals + prices | `/opt/data/.venv/bin/python scripts/bid_output.py --signals ... --prices ... --output ...` |

Also see `references/price-buddy-wol-query.sql` — the reusable SQL query that rebuilds the Price Buddy cost floor from WorkOrderLines.

## Related

- **`municipal-smart-bidding`** (gsts-operations) — the build/architecture skill (the tool itself: Pricing Brain, Bid Filler, Layer 1/2 design). This skill (`municipal-bid-pricing`) is the how-to-price methodology. They overlap and should eventually consolidate.
- `trim-it-operations` → `references/price-buddy-cost-floor.md` (cost floor derivation)
- `trim-it-operations` → `references/municipal-pricing-schema.md` (schedule of comp + canonical bands)
- `trim-it-operations` → `references/municipal-bid-warehouse.md` (warehouse map + extraction)
- `trim-it-operations` → `references/municipal-bid-extraction.md` (competitive range signal pipeline)
- `crew-orchestration` (Fable + GBT review pipeline)
