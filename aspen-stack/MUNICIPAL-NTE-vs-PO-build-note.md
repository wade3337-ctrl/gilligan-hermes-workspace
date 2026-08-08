# Municipal NTE vs PO — build requirement for the Aspen/Bigin layer
**Captured:** 2026-08-08 (Skipper, during FPC diligence prep)
**Why it's here:** this is a real gap the Bigin/Aspen sales-pipeline layer should fill. TRIM IT structurally cannot forecast forward municipal revenue.

## The core fact (Skipper-confirmed)
- **NTE (Not-To-Exceed) = the full municipal contract ceiling** — the max a city could spend with us over the contract.
- **TRIM IT has NO NTE field.** It only ever stores the **PO amount**, and only **once Brent physically has the PO in hand** (no PO → nothing in TRIM IT).
- The TRIM IT "budget" field = **PO amounts Brent enters** (realized/authorized), NOT the contract ceiling.
- **Cities drip-feed POs** against the NTE ceiling over the year. So at any moment TRIM IT shows only the slice authorized so far, never the forward ceiling.

## What this means
- **Forward municipal revenue is invisible to TRIM IT by design.** The city NTE ceilings live only in Nate/Brent's contract knowledge + spreadsheets.
- The §4 sales-report municipal forecast ($5.06M "sold") = **NTE ÷ 12 spread** (budget-based forecast). Far months (Oct/Nov/Dec) flat-line at an identical figure because they fall back to the pure NTE÷12 default; near months carry actual bookings.
- That's why the report **can't reconcile to TRIM IT** — it's a definitional mismatch (NTE forecast vs PO-realized), not an error.
- **Completed/realized municipal reconciles to live within ~2%** (report Jan–Jun $4.16M vs live invoiced $4.26M). The system is accurate for what it holds; it just holds nothing forward.

## The build requirement (what Bigin/Aspen should add)
1. **Store the NTE ceiling per municipal contract** (city, contract term, start/end, NTE $, provider being displaced). TRIM IT never will — the CRM layer is the natural home.
2. **Track PO issuance against the ceiling** — remaining-to-issue = NTE − Σ POs issued. This makes drip-feed visible: how much ceiling is still unclaimed.
3. **Forecast forward municipal from the ceiling, not a flat ÷12** — pace POs by contract seasonality / historical draw pattern per city, so the number isn't a naive even spread.
4. **Feed the coverage/forecast rollup** — this is the credible "forward municipal toward goal" number FPC's §3 wants, and the honest answer to §11 "how locked-in is municipal revenue" (anchored by NTE, realized via drip-fed POs).

## Data source note — NTE SOURCE FOUND (2026-08-08)
- Realized POs / billing: TRIM IT (live, reliable) — `CompanyContracts` table (`TotalPrice`, `HTDBilled`, `AmountRemaining`, `Year01Budget`..`Year05Budget`) + Brent's City Budgets engine. **These fields = PO amounts Brent entered, NOT the NTE** (Skipper confirmed: a number is there only because we hold a PO for it).
- **NTE ceilings = IN THE MUNIBOT WAREHOUSE** → `~/.munibot/municipal-archive/<County>/<City>/<term> CONTRACT/` (185 cities, bind-mounted to MuniBot `/opt/data/municipal-archive`; see [[munibot-data-warehouse]]). The NTE is stated verbatim in the **Contract Agreement + Amendment PDFs** (and Schedule of Compensation xlsx).
  - **Proven example — Fountain Valley** (`==2021-2027 CONTRACT==/Contract Renewal/FY 25-27/Amend 2 CON-21-19.pdf`): current NTE = **$374,487.75/yr base + $25,000 contingency**; escalation history $310,500 (2021) → $349,334.50 (FY23-25) → $374,487.75 (FY25-27).
  - Cross-check: TRIM IT `CompanyContracts` Year budget for FV = $374,335 ≈ the NTE (off ~$153) → this city's PO was cut for the full year. **Drip-feed cities will show TRIM IT PO < warehouse NTE** — that's the whole point.
  - ✅ Warehouse VERIFIED COMPLETE 2026-08-08: the 6 previously-missing .lnk cities are now present — Long Beach (3,935 files/6.4G), Anaheim (2,327/1.2G), Aliso Viejo (275/256M), Cerritos (485/1.2G), Lake Forest (122/109M), Stanton (855/589M). The old known-gap in [[munibot-data-warehouse]] is CLOSED; full active municipal book is in the warehouse.

## The extraction task (this is the AI build)
NTE is locked in contract PROSE, not a structured field. Build = **parse each active city's Contract Agreement + latest Amendment PDF → extract {NTE base, contingency, term start/end, escalation, contract #} → structured record in Bigin.** Then: NTE (warehouse) − POs-drawn (TRIM IT `CompanyContracts`) = true remaining ceiling → the forward municipal forecast. This is a natural AI-layer job (PDF → structured contract record); pdf-parse already works on these docs (`arbor-stack/pdf-tools`).

## Cross-refs
- FPC prep: `inbox-pull/fpc-meeting-2026-08-10/PREP-BRIEF.md` §3 municipal.
- Project: `[[aspen-cockpit-to-bigin-push]]`, `bigin-pipeline-blueprint.md` (Collections lane already anticipates AR; this adds the FORWARD municipal-contract lane/visibility).
