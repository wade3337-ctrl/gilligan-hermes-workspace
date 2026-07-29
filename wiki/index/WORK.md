---
title: WORK — MOC
type: index
domain: work
tags: [index, moc, work, great-scott, arbor-core]
links: ["[[HOME]]", "[[PROJECTS]]"]
updated: 2026-07-02
---

# 🛠️ WORK — Great Scott Tree Care / Arbor AI — map
**What we're building (status/resume/standards) → [[PROJECTS]].** Durable context facts:

- [[skipper-and-company]] — Skipper = COO of Great Scott (~$25M, OC CA); mechanic→COO. ([[USER]])
- [[arbor-mission-strategy]] — build arbor-core, a clean in-house Agent OS replacing TRIM IT (strangler-fig, sales first).
- [[two-track-confidentiality]] — Track 1 (TRIM IT/play, open) vs Track 2 (arbor-core, BLACK).
- [[build-principle-v1-first]] — prototype in TRIM IT V1 first → proven model becomes the arbor-core framework.
- [[trimit-stack-and-tph]] — TRIM IT = ColdFusion 2023 + SQL Server; central metric TPH, 2026 target 130.
- [[coldfusion-2025-upgrade-case]] — 🔍 research only, no decision. **CF2025 Update 8 (May 2026) turns ColdFusion into an MCP server/client** — TRIM IT's existing CFCs become agent-callable tools without a rewrite; plus local Ollama inference, RAG, prompt-injection guardrails, and passkey auth (the *category* of fix `ZUserID=9` needs). Cost: subscription-only ($760/$2,930 yr) and a real breaking-change list (`htmlEditFormat`, `cftable`/`cftree`, silent `cfmx_compat` decryption loss). CF2023 supported to May 2028 — no clock. Try free **MCPCFC on CF2023** first.
- [[trimit-db-cleanup]] — DB cleanup audited 2026-07-20: proposals 98% never-approved (66M derived rows), ~5.6GB dead tables; frozen `GSTS_cleanup` rehearsal DB feasible; blocked on prod write-access.
- [[sales-rep-attribution]] — dashboards attribute to the actual managing rep (`Projects.SalesRepID`).
- [[scheduled-revenue-date-basis]] — ⚖️ per-day vs by-end vs by-start (decision pending).
- [[june-invoicing-lag]] — 💵 month-end "billed" understates ~25%; invoicing finishes ~3–10 days into next month. Read produced/on-pace as the trustworthy close headline.
- 📋 **Q2 2026 COO Operating Plan — DELIVERED TO THE BOARD 2026-07-29.** Commitments now on record: **15 field hires** (76→91 working per weekday) · **+$1.38/paid hr** on rate · **5 min/person/day** of non-productive time returned · re-base H2 to **$2.31M/mo**. Productivity stated as **CFO revenue ÷ clocked hours** (Q1 $118.76 → Q2 $125.10, target $130) so the board cannot recompute a different answer. Frozen + basis of every figure → `board-reports/Q2-2026-coo-plan-SENT-20260729*.md`
- [[path-to-25m-2026]] — 📈 run-rate + capacity math to the 2026 goal. **H1 $11.22M = 91.6% of plan; TPH $130.19 vs target 130 → efficiency is ON target, the shortfall is VOLUME. $2.2M/mo lands $24.42M; required is $2.31M/mo = 17,792 crew hrs/mo (+29%).** ERP reconciles to Dimitry's books within 1.28%.
- [[50m-growth-goal]] — 🎯 North Star: $25M→$50M in 5yrs via Aspen BD engine; targets = Inland Empire + LA County + grow OC backyard.
- [[segment-margin-analysis]] — 📊 municipal vs HOA vs commercial: TPH equalized ~$123 all segments; muni "lower rate" = fixed-price erosion (~$6–9/hr mid-contract) + ~$6/hr wage top-up, NOT crew inefficiency. Cost half needs Steve. Feeds growth-plan mix + pricing tools.

## 🔒 BLACK — Fort Point M&A (need-to-know, main-session only; never Aspen/Herman/team/group)
Governed by [[fort-point-confidentiality]]. Detail in `business-plan/`.
- [[fort-point-acquisition]] — signed LOI 2026-07-15; Fort Point buys GSTS, EV $55M, earnouts, Skipper's 15% MIP.
- [[gsts-growth-plan-fort-point]] — deal-aware $24M→$50M plan (AGP/EBITDA-led); LA-leads architecture. **§9 (7/21): Cam datapack — AGP ≈50% CONFIRMED, net-proceeds ~$33.4M, TTM EBITDA $3.80M (below floor), defend-the-EBITDA play.**
- [[deal-tracker-dashboard]] — 🖥️ LIVE private dashboard (Tailscale, Docker `deal-dash` :8091). **Rebuilt 2026-07-22 as a count-once revenue ledger** (goal · adjusted actual w/ live accrual · muni forecast · firm sold · risk-adj pipeline → uncovered gap $4.73M). Methodology → [[count-once-revenue-ledger]] · accrual → [[trimit-accrual-formula]] · **▶️ what's left → [[revenue-ledger-polish-backlog]]**.
- [[gsts-2026-earnout]] — 2026 pressure test + H2 recovery (Herman's plan reconciled to the earnout).
- [[gsts-adjusted-ebitda]] — book (~$0.4–1.1M TTM) vs deal-adjusted ($4.1M); add-back bridge = open item (email to Steve).
- [[fort-point-phantom-stock]] — Skipper's legacy LTIP: 1/30 of the company, **(Net Proceeds − $10M) ÷ 30 ≈ $1.2–1.5M** at close, ON TOP OF the MIP. Full doc set in `business-plan/phantom-stock/`.
- [[key-employee-incentive-plan]] — the forfeited **3.3333%** as a **near-term (2026–2027) block** for ~10 key employees: 2026 close tranche + 2027 performance-hold tranche gated on $25M/'26 + $28.75M/'27 (draft, awaiting Scott's picks).
- [[five-year-incentive-model]] — the **separate** go-forward 5-yr incentive on Fort Point's cap table (blank page; negotiate into the MIP during exclusivity).
- [[fort-point-advisors-and-open-questions]] — **who answers which deal question** (Cam/banker=economics · Gary/attorney=phantom · Steve=EBITDA bridge · BDO=QoE) + LOI-settled terms + open items. Cam-call prep: `business-plan/cam-bryan-call-prep-2026-07-22.md`.

Standards these follow: [[dashboard-metric-standards]] · [[gsts-ui-style-guide]] · [[gsts-ui-spec]] · [[canonical-definition]] · [[deploy-playbook]] · [[dashboard-auth-gate]] (security gate + the rule: re-authorize headless consumers when you gate a surface).
- [[gsts-revenue-by-geography]] — revenue split by county (OC / LA / IE), the base for the geography plan.
- [[goahead-status-lifecycle]] — GoAhead statuses decoded from the SOP: **activation is a TWO-step flip (InProcess → Active), so a record left in `InProcess` is a half-finished activation.** 8 stuck ($121K) incl. **5 near-identical Irvine/Crystal Cove attempts at $22,649 each**. Also: future-year COs are activated by temporarily setting the wrong year (restore it or it bills wrong), and multi-season plans legitimately fan out into several go-aheads.
