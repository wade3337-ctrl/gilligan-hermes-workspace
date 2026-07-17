---
title: MuniBot Smart Municipal Bidding Tool
type: project
domain: work
track: 1
status: READY — prompt final, warehouse mounted into Boss Hermes; handing over
tags: [munibot, bidding, pricing, municipal, brent, boss-hermes, price-buddy, tph, rfp]
applies: ["[[only-trustworthy-data]]", "[[trimit-stack-and-tph]]", "[[repair-contract]]"]
links: ["[[munibot-data-warehouse]]", "[[pricing-guide-bid-prefill]]", "[[brent-agent]]", "[[aspen-retention-agent]]"]
updated: 2026-07-17
---

# MuniBot Smart Municipal Bidding Tool

**One-liner:** an AI-in-the-loop tool that auto-populates a municipal tree-care bid from a dropped RFP packet (e.g. City of Long Beach PW25-648) so Brent + team review a priced draft instead of building each bid from scratch. Used by **MuniBot (for Brent), Brent, and Boss Hermes**. **Boss Hermes builds it.**

## Vision (Skipper, 2026-07-17)
- **Not a static calc — true AI every run** (each city's pricing schedule is structured differently → live mapping + pricing).
- **Two layers:** (1) **Pricing Brain** — standing, always-current knowledge base; (2) **Bid Filler** — per-RFP agent that fills a specific city's form.
- **North star:** *win the bid at the lowest price that still clears our margin floor.* Win-first (market comps + historically competitive/winning prices), **margin floor = TPH**.
- **TPH is a runtime parameter** — $130/hr this year, rises over time; confirm current rate every run, never hardcode.
- **Multi-year fixed-price = the Irvine trap:** floor set against TPH across the *whole term*, cross-checked vs the RFP's renewal escalation caps (Long Beach has "increase shall not exceed __%/renewal"). If cap < our TPH growth → base price must be higher. Don't lock into a losing contract.

## Three data signals (the Brain)
- **Schedules of comp** — the 11 municipal contracts in TRIM IT (`LocationServiceTypes`, ServiceTypeID 149/47/21, `ProjectGroupDefID=11`). Normalized benchmark (median headline).
- **Price Buddy engine** — existing [[pricing-guide-bid-prefill]] tool (`dbo.GetLevel4PriceRange$TPH`, reads INVOICED history → per-tree $ at species×service×size + AvgTPH). Wire in as a weighted signal + cost floor; **don't rebuild**.
- **Historical bids** — from the **[[munibot-data-warehouse]]** (`/opt/data/municipal-archive/`, ~42GB), NOT TRIM IT (~71% of proposals lack Won/Lost disposition).

## Key methodology (fold in 5 prior crew-flagged fixes)
Time-decay + inflation-normalize vintages; min n≥5 + hierarchical fallback; "floor not ceiling" (selection bias); canopy/access multiplier beyond DBH; show-the-work (N, date range, variance). Store prices at finest size granularity → roll up to any city's brackets.

## Status / resume
- ✅ **Prompt FINAL** → `smart-bidding-tool/PROMPT-for-boss-hermes.md`. Skipper approved to run (2026-07-17); handing to Boss Hermes.
- ✅ **Access wired:** warehouse bind-mounted **read-only** into the `hermes` container at **`/warehouse/`** (NOT under `/opt/data` — the boot wrapper `chown -R /opt/data` collides with a ro submount). Compose `hermes-sandbox`; backup `docker-compose.yml.bak-premount-*`. ⚠️ Recreate hermes ONLY with `HERMES_UID=1000 HERMES_GID=1000` set (default is 10000 → breaks it). Verified read-only + Boss Herman healthy.
- Origin: Skipper drafted a benchmark prompt with Fable-5; asked Gilligan to perfect it for Boss Hermes (crew+loop). Gilligan restructured it from a one-time benchmark into the two-layer agentic tool above.
- Acceptance test = a worked proof-run filling **Long Beach Attachment AA** (packet saved: `inbox-pull/long-beach-pricing-2026-07-16/`).
- ▶️ **NEXT:** Skipper hands the final prompt to Boss Hermes → Hermes builds (crew+loop). Watch for: (1) `.lnk` cities re-sync ([[munibot-data-warehouse]]), (2) Long Beach proof-run as acceptance.

## Related
- [[pricing-guide-bid-prefill]] — the Price Buddy engine this weights in.
- [[munibot-data-warehouse]] — the historical-bid source.
- [[brent-agent]] · [[aspen-retention-agent]] — municipal BD context.
