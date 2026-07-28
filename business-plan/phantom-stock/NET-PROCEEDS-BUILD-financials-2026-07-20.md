# 🔒 Net-Proceeds Build — Dimitry's financials (6/30/26) — CONFIDENTIAL / BLACK

**Source:** Skipper forwarded Dimitry's "FW: Balance sheet" 2026-07-20 (gilligan.gsts inbox uid 126): *June 2026 Financials Presentation (IS 1/1/23–6/30/26 + BS 6/26)* + *Loan List & Payment Projection*. Raw files held in local scratch only (`~/arbor-stack/anomaly-monitor/_pull/dimitry-2026-07-20/`), NOT committed. Governs under [[fort-point-confidentiality]]. Feeds [[fort-point-phantom-stock]] Net-Proceeds build + [[gsts-adjusted-ebitda]].

## 1. NET DEBT as of 6/30/26 — essentially debt-neutral
**Cash:** $4.18M (CBB checking/savings/sweep, Total Checking/Savings 4,182,639.21).

Interest-bearing debt (definition-dependent):
| Definition | Gross debt | Net (debt)/cash |
|---|---|---|
| Core term + equipment loans only | $2.43M | **~$1.75M NET CASH** |
| + insurance premium financing ($1.42M) | $3.85M | **~$0.33M NET CASH** |
| + all lease liabilities ($0.52M) | $4.37M | **~$0.19M net debt** |

**Takeaway:** across any reasonable definition GSTS sits within **±$1.75M of zero net debt** — a cash-free/debt-free-neutral balance sheet.

### Component detail (6/30/26)
- Term/equipment notes payable (full principal, N/P 2685–2723): **$2,430,668** (= Total LT Liab 1,896,329 + current-portion contra 802,665 − LT lease 268,326).
- 2350 CBB ST Loan 51619: $3,046
- 2352.1 CBB Insurance Loan 53622 (insurance premium financing): $1,419,056
- ST Lease Liability (2500): $250,035 · LT Lease Liability (2800): $268,326 (ROU: Court Ave, Monroe, Simplex)
- **LOC 8100199 reads UNDRAWN** on the BS; the **Raffles letter of credit $1,020,276** is a commitment against it, not funded debt (confirm).

### Judgment calls for counsel/Steve (why it's a range)
- **Insurance premium financing ($1.42M):** self-liquidates vs a prepaid-insurance asset → M&A convention usually treats as working capital, not net debt (exclude → more net cash).
- **Lease liabilities ($0.52M):** operating ROU leases → normally excluded from net debt.
- **Raffles L/C ($1.02M):** confirm contingent, not drawn.
- **Cash sweep:** in a cash-free/debt-free deal the seller keeps the ~$4.18M cash → changes how cash offsets debt in the Net-Proceeds base. Counsel.

### Impact on the phantom
Payout = **(Net Proceeds − $10M) ÷ 30**; Net Proceeds = gross − debt assumed − fees. **The feared debt haircut is ~nil** (debt≈cash). Only remaining chisels = **transaction fees** (banker/legal/QoE) + the **"taxes" reading** (both pending Steve/attorney). → pushes the Skipper toward the **TOP of the ~$1.17–1.40M range**, not the bottom.

## 2. The "Net Income drop" ($2.54M→$0.20M on the BS) — mostly an artifact
Income statement (annual, from IS sheet; 2026 = H1 Jan–Jun):
| Line | 2023 | 2024 | 2025 | 2026 H1 |
|---|---|---|---|---|
| Total Income (revenue) | $22.56M | $22.63M | $21.32M | **$11.22M** ⚠️ *(was $11.88M — corrected 2026-07-28)* |
| Gross Profit | $6.83M | $6.22M | $6.55M | $3.86M |
| Total Expense (overhead) | $5.03M | $5.24M | $5.66M | $3.64M |
| **Net Ordinary (operating) Income** | **$1.80M** | **$0.98M** | **$0.90M** | **$0.21M** |
| Net Other Income (below the line) | $0.05M | −$0.27M | **$2.31M** | −$0.09M |
| **Net Income** | $1.85M | $0.71M | **$3.21M** | $0.13M |

- **2025's $3.21M net income was pumped by ~$2.31M of one-time non-operating items** — chiefly **7900 Other Income $3.06M** (+ interest $0.49M + dividend $0.30M, less $1.30M other expense). Non-recurring. **2026 H1 has ~$0 below-the-line**, so the YoY "drop" is largely apples-to-oranges.
- **The REAL issue = operating-margin compression:** revenue flat-to-down ($22.6M→$21.3M) while overhead climbed ($5.03M→$5.66M); gross profit held (~COGS fine) → the squeeze is **overhead, not cost of sales.** Operating income has slid $1.80M→$0.98M→$0.90M→$0.21M(H1).

### Connections / flags
- **Adjusted-EBITDA thread ([[gsts-adjusted-ebitda]]):** book operating income ~$0.9M vs deal-adjusted EBITDA ~$4.1M — the gap is add-backs (owner comp, D&A ~$1.15M/yr, interest, one-timers). **The 2025 $3.06M "Other Income" must be NORMALIZED OUT** (non-recurring) — identify it with Steve (asset sale? Raffles captive distribution? settlement?).
- **The incentive gates I helped design are AGGRESSIVE vs. this trajectory** ([[key-employee-incentive-plan]]):
  - **Gate 1 = $25M/2026:** 2026 H1 = **$11.22M → run-rate ~$22.4M**; needs an H2 of **~$13.88M** and **~+18% over 2025's $21.3M**. Has teeth — **more than first written.**

> 🚨 **CORRECTION 2026-07-28.** The "$11.88M H1" above was **wrong: it summed a stray partial `Jul 26` column ($654,744) into Jan–Jun.** True Jan–Jun Total Income = **$11,222,433**. Run-rate is **$22.44M, not $23.8M**, so Gate 1 is harder than this doc originally claimed. The IS sheet is labelled `01.01.23 - 06.30.26` but **carries a July column anyway** — never trust a sheet's title for its date range; sum only the columns you have named and print them.
> ✅ **Reconciliation done the same day (good news):** TRIM IT invoiced (accounting-period basis, status-filtered) H1 = **$11,078,312** vs book **$11,222,433** — **TRIM IT runs just $144K / 1.28% light**, with individual months swinging ±$183K in both directions (pure timing). **So the ERP is a sound proxy for the books at the half-year, within ~1%.** Detail → [[count-once-revenue-ledger]].
  - **Gate 2 = $28.75M/2027:** requires **reversing a multi-year flat/declining revenue trend** — a real stretch. Good for alignment/cost discipline; employees may read it as hard to hit.

## 3. Open
- Identify the **2025 $3.06M Other Income** with Steve (normalize out of EBITDA).
- Confirm Raffles L/C not drawn; confirm cash treatment (seller sweep) with counsel.
- Plug final Net Proceeds into (NP − $10M)/30 once fees + "taxes" reading land.
