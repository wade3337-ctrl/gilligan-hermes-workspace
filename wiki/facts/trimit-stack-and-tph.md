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

## Sources
- Schema detail: `arbor-stack/Arbor AI/Trim IT Repairs/` + live `Reference-TrimITArchitecture.cfm`.
- Metric rules that use TPH → [[dashboard-metric-standards]].
