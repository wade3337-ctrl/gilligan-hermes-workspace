# City Bid Pricing Files (2025–2026) — sorted for the MuniBot pricing-tool test

From Brent, 2026-07-17. Each city had a BLANK bid/pricing form (the "before" — what Brent receives & must price) and a FILLED "(Submitted)" version (GSTS's actual bid — the answer key). Classified by extractable price count (blank = 0 unit prices; filled = many).

## BEFORE-bids/ — the INPUT (feed these to MuniBot, "as Brent would")
| Year | City | File | Notes |
|---|---|---|---|
| 2025 | Bell Gardens | Bid Form.pdf | blank (2p) |
| 2025 | Glendale | Pricing Form.pdf | ⚠️ SCANNED/image — 0 extractable text prices; MuniBot may need OCR |
| 2025 | Rosemead | Pricing Forms.pdf | blank (3p) |
| 2025 | West Covina | Cost File.pdf | blank (5p) |
| 2026 | Gardena | Bid Form.pdf | blank (4p) |
| 2026 | Norwalk | Exhibit A - Bid Form.pdf | blank (2p) |
| 2026 | Pomona | Cost Proposal.pdf | blank (11p) |
| 2026 | Riverside | Pricing Schedule.pdf | blank (1p) |

## WINNING-answers/ — the ANSWER KEY (GSTS's submitted bids; DON'T show MuniBot)
| Year | City | File | Notes |
|---|---|---|---|
| 2025 | Bell Gardens | Bid Form (Submitted).pdf | filled, total $351,990.00 |
| 2025 | Glendale | Pricing Form (Submitted).pdf | ⚠️ scanned — prices in image, need OCR to compare |
| 2025 | Rosemead | Pricing Forms (Submitted).pdf | filled |
| 2025 | West Covina | Cost File (Submitted).pdf | filled |
| 2026 | Gardena | Bid Form (Submitted).pdf | filled |
| 2026 | Norwalk | Exhibit A-Bid Form - Submitted.pdf | filled |
| 2026 | Pomona | Cost Proposal (Submitted).pdf | filled |
| 2026 | Riverside | RFP_2535_Cost_Summary.pdf | filled (this is Riverside's answer — no "(Submitted)" tag) |

## Test plan
For each city: feed MuniBot the BEFORE pricing form as the RFP (`bid_engine.py --city "X" --rfp-dir <BEFORE/city>`) → MuniBot prices the unit line items → compare MuniBot's unit prices to the city's WINNING-answers submitted prices, line by line. Caveat: these are pricing SCHEDULES (unit rates), not full RFP packets with tree inventory, so the comparison is unit-price vs unit-price (not extended contract totals).
