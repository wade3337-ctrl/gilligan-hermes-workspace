---
title: Pricing Guide → History-Aware Bid Prefill
type: project
domain: work
track: 1
status: active
tags: [pricing, price-buddy, bid-prefill, rebid, tph, estimating-engine]
applies: ["[[gsts-ui-style-guide]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[bid-process-reengineering]]", "[[sales-cockpit]]"]
updated: 2026-07-02
---

# Pricing Guide → History-Aware Bid Prefill

**One-liner:** Evolve "Price Buddy" into a tool that **pre-fills a bid sheet from a site's own invoiced history** so the arborist adjusts a draft instead of building each bid from scratch — the estimating engine that feeds the arbor-core Stage-3 pricing.
**Status:** 🔵 active — **Ph1 + Ph2 (rebid) done + live** on play; **5 defects flagged** by the 4-lab crew review to fix on BOTH V1 + arbor-core; Ph3 (AI species) deferred.
**📁 Location:** `Maint.InventoryGroups.Pricing.cfm` + `Maint.InventoryCategories.Pricing.cfm` + `js/pricing-helper-v2.js` + `api/PricingChartData/SiteSearch/SiteHistory.cfm`
**▶️ Resume:** `arbor-stack/pricing-guide/PROJECT-pricing-bid-prefill.md`

## Applies / uses
- [[gsts-ui-style-guide]] — UI/brand rules; welcome modal + "?" pro-tips (no permanent technical text).
- [[gsts-ui-spec]] — tokens/styling; emoji `.cfm` → UTF-8 BOM.
- [[repair-contract]] — backup-first, render-verify the served output, log to ship-log (#17-#23).
- Source: `dbo.GetLevel4PriceRange$TPH` (per-tree price, bucketed $5, AVG TPH) off real `InvoiceLines` at species × service class × size, joined to `Projects`/`Locations` for area.

## State & flags
- **Ph1 DONE + live:** data-backed species dropdown (only priced-history species) + area focus (city → county auto-broaden, scope badge).
- **Ph2 (rebid) DONE + live:** "Rebid — Site History" card — pick customer/site → invoiced history by species/size (price, TPH, last date, **suggested rebid price = price × target/TPH**, freshness-weighted 18-mo half-life). Area box = radius tiers (job / 5 / 10 / 25mi / All) via STDistance.
- **Reframe (Skipper):** rebid engine reads **INVOICED work, not bids** — sidesteps the win/loss disposition gap (71% of proposals never marked Won/Lost); prior AvgTPH below target IS the "raise it" signal.
- ⚠️ **OPEN — needs Skipper re-test:** he reported radius "wasn't affecting pricing"; root cause was inline `chartUrl()` reloading without ZProjectID/ZRadius (fixed + deployed + `[scope]` tag added). Awaiting confirmation.
- ⚠️ **5 crew-flagged defects (fix on V1 + arbor-core):** (1) **backwards TPH filter** `HAVING AVG(TPH) < Target+20` keeps LOW-TPH, discards HIGH — replace w/ IQR/MAD + time-decay; (2) thin-combo noise → min n≥5, show N, hierarchical fallback; (3) selection bias (won-work only) → label "a floor, not a ceiling"; (4) DBH-only sizing → add canopy/access multiplier; (5) show the work (N, date range, variance). Detail: `arbor-core/docs/reviews/2026-07-01-plan-review-SYNTHESIS.md`.
- **Ph2 remaining:** actual bid-sheet PREFILL (the big "arborist just tweaks it" goal). **Ph3 deferred:** AI species/size photo ID.

## Related
- [[bid-process-reengineering]] — this IS the Stage-3 estimating engine.
- [[sales-cockpit]] — plugs in at the bid on-ramp.
