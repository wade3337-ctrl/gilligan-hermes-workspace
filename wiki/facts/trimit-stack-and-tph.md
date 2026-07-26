---
title: TRIM IT stack & TPH central metric
type: fact
domain: work
tags: [trimit, coldfusion, sql-server, tph, stack, schema]
links: ["[[arbor-mission-strategy]]", "[[dashboard-metric-standards]]", "[[build-principle-v1-first]]"]
updated: 2026-07-02
---

# TRIM IT stack & TPH central metric

**TRIM IT** = Adobe **ColdFusion 2023** + **SQL Server** (`GSTS` db).
- **~948 tables / 3,628 procs**; menu is **DB-driven**.
- **Central metric = TPH** (Trim-Per-Hour, $/crew-hour); **2026 target = 130** (higher is better).

## ⚖️ WHICH TPH — the rule (COO ruling, 2026-07-26)
Two measures, and they tell **opposite stories**. Using the wrong one inverts the conclusion.

| Use | Measure | Why |
|---|---|---|
| **A CONTRACT's cost** (Irvine, Long Beach) | **Blended / "true" TPH** — revenue ÷ **all paid hours** | That is what the contract actually costs us in labor, not just the hours that carried revenue. **This is the COO's number.** |
| **SEGMENT comparison** (municipal vs commercial) | **Productive TPH** — revenue ÷ **revenue-generating hours** | Segments carry very different non-revenue loads (commercial 24.4% vs municipal 14.5%); blending them **inverts** the comparison. |

**Measured (trailing 12 mo to 2026-07-22, `ProjectGroupDefID=11`):** municipal book = 11 cities · 65,793 all-paid hrs · 56,189 productive hrs · $8.10M → **blended $123 · productive $144.** City of Irvine = 29,245 hrs / $3.37M → **blended $115 · productive $132** — i.e. Irvine looks *below* target on blended and *above* it on productive. **Always state which one is in use.**

⚠️ I got this wrong once by treating "blended is misleading" as universal — it is scoped to *segment* comparison only. → [[trimit-investor-case]]

## Sources
- Schema detail: `arbor-stack/Arbor AI/Trim IT Repairs/` + live `Reference-TrimITArchitecture.cfm`.
- Metric rules that use TPH → [[dashboard-metric-standards]].
