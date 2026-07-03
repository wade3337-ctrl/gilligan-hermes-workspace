---
title: Flag every fix for REVIEW before prod
type: fact
domain: how-we-work
tags: [review, deploy, prod, lifecycle, review-pile]
links: ["[[contracts-map]]", "[[division-of-labor]]", "[[dev-handoff-contract]]"]
updated: 2026-07-03
---

# 🚦 Flag every fix for REVIEW before prod

Every fix goes to `arbor-stack/REVIEW-PILE.md` — **never auto-route** to prod.

## Whole-dashboard rule
Exec dashboard prod deploy goes as the **WHOLE dashboard after full review** (prod is far behind play) — **no piecemeal pushes**.

## Page lifecycle
- `release-candidates/` (**RC-##**, reviewed / parked) →
- `live-in-prod/` (**LP-##**, shipped + collecting feedback).

## ⚠️ Held page
`Dashboard-SalesPipeline.cfm` is **deliberately held — do NOT deploy to prod** (its Customer-Leads link **dead-links on prod** until it ships).
