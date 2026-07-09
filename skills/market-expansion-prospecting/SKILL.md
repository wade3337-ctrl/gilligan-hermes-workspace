---
name: "market-expansion-prospecting"
description: "Research a new geographic market for BD prospects (HOA/commercial), verify the management-company contacts, and drip a deduped target pipeline into Bigin CRM."
---

# Market-Expansion Prospecting → CRM Pipeline

Turn "we want to expand into **<area>**" into a **verified, deduped, rep-ready prospect pipeline** in the CRM — and keep it filling on a weekly drip. Proven on the Great Scott Tree Care **Inland Empire** expansion (2026-07-08).

## When to use
- The user wants to expand the business into a new **geographic market / territory** and needs a **target list** a salesperson/BD rep will actually work (property → who manages it → how to reach them).
- Also fits: "build me a prospect list for <segment> in <area>", "populate our CRM pipeline with leads", "who should <rep> be calling in <region>".

## Scope it FIRST (don't research blind — ask, then proceed)
Nail these before fanning out (one question at a time; propose sensible defaults):
1. **Segment(s):** managed HOAs / master-planned communities, commercial (office/retail/industrial), municipal, or a mix.
2. **Geographic box:** get the user's boundary in their own words, then formally define the area + state an explicit target box (name the included/excluded cities). Flag contested edges honestly.
3. **What makes a target worth it:** affluence, size/scale, "tree density" or the relevant asset density, contract-budget potential — usually a blend.
4. **Hard filters:** e.g. property age (established ≥3-4 yrs so there's mature work to do); exclude brand-new builds.
5. **List depth + cadence:** tight top-N now, or a broad database; drip N/week vs one dump.

## THE core strategic insight (this is what makes it work)
**Go through the management companies that control the portfolios — not scattershot individual properties.** One management company runs dozens of communities/properties. Individual on-site manager names are rarely public and churn constantly; the *management-company office* is the real, reachable door. Structure the CRM so one management-company Account carries many property deals.

## Method
### 1) Research (deep-research workflow)
- Use the `deep-research` workflow (fan-out web search → fetch → **adversarial 3-vote verification** → synthesize). Pass a detailed brief: the box, segments, ranking criteria, hard filters, and any field hypotheses the user wants tested.
- Deliverables: (a) formal definition of the area + the target box; (b) sub-area/city ranking by the agreed criteria; (c) test the user's hypotheses with evidence; (d) the verified **management-company "doors"** with live contacts; (e) a starter named-target list.
- **Verify the property→management-company→contact chain adversarially** — directories go stale. Prefer primary sources (management-company rosters/sites, community portals, industry directories like CAI-GRIE for HOAs, county/HOA filings, LinkedIn for names; LoopNet/Crexi/CommercialCafe broker-of-record for commercial). Note each source's date.
- ⚠️ **deep-research resume is broken** (drops the `args` question) and it can stall on the final synthesis agent (N started / N-1 returned, 0-byte result). If so, **recover findings from the run journal** (`subagents/workflows/<wf>/journal.jsonl`, grep `"claim":"..."`) and synthesize by hand.

### 2) Confidence honesty (non-negotiable)
Flag every contact data point: **✅ VERIFIED** (2+ sources / current primary) vs **🟡 re-verify** vs **⚠️ unresolved**. **Never present a guessed manager name or phone as fact.** The report should read: "here's what's confirmed, here's what the rep confirms on the call."

### 3) Load into the CRM (Bigin) — dedup-safe
- Auth: OAuth self-client. Creds in `~/.secrets/bigin-oauth.json` (client_id/secret/refresh_token). Mint an access token: `POST https://accounts.zoho.com/oauth/v2/token` (grant_type=refresh_token). API base `https://www.zohoapis.com/bigin/v2`, header `Authorization: Zoho-oauthtoken <token>`.
- **Access is create + edit, NOT delete** — a safe guardrail; never rely on being able to delete. Design writes so you never need to.
- **DEDUP (the #1 lesson):** the CRM likely already has Accounts for the big management companies. ALWAYS `GET /Accounts?fields=Account_Name&per_page=200` and **link the deal to the existing Account** (oldest one) — only POST a new Account if none exists. Likewise `GET /Pipelines?fields=Deal_Name` and **skip any deal that already exists** (idempotent re-runs).
- Per target: (a) Account = management company (link existing / create if new); (b) Contact = the real person if known, else the management company as `Last_Name` (placeholder the rep replaces); (c) Deal in the module `Pipelines`.
- Deal create REQUIRES: `Deal_Name`, `Stage`, `Sub_Pipeline` (**picklist STRING**, e.g. "Inland Empire Expansion"), `Layout` `{id:<layoutId>}`, `Closing_Date` (~90d out), `Contact_Name`. Also set `Owner` `{id:<rep>}`, `Account_Name`, and a rich `Description` (segment / city / mgmt+phone / why it qualifies / confidence / wave#).
- Put IE work in its **own sub-pipeline** so the rep's existing deals are never disturbed. Read the target pipeline's layout (`GET /settings/layouts?module=Pipelines`) for the exact sub-pipeline name + first stage. **Pipeline creation itself is admin-UI only** (API can't create sub-pipelines) — have the user create the empty pipeline, then populate.
- **Always verify after writing:** read the deals back, confirm the right sub-pipeline/stage/owner, and check for duplicate Account names you introduced.

### 4) Weekly drip (optional)
- Keep a backlog file (`ie-pipeline-backlog.md` pattern): remaining targets grouped into **waves of N**, with a "LAST PUSHED" marker + the push procedure + the CRM IDs.
- Schedule a durable Gateway cron (`cron` tool, `sessionTarget:isolated`, `payload.kind:agentTurn`, `tz` in the user's timezone) that each period: reads the next un-pushed wave → web-verifies each target's mgmt/contact → loads them dedup-safe → updates the backlog → messages the user a summary. Add a `failureAlert`.

## Deliver + record
- Email the report to the user (draft → **express approval** before any send to third parties like leadership; CC the user).
- Log a project note (scope, findings, the CRM integration IDs, the backlog/cron) so it's recoverable.

## Reusable IDs from the IE build (template — re-read per environment)
- Bigin layout "Chad Pipeline" `5275136000002190772`; IE sub-pipeline "Inland Empire Expansion"; first stage "Potential Lead"; rep owner Chad Bouck `5275136000002097047`. (These are GSTS-specific; discover the equivalents for any new run.)
