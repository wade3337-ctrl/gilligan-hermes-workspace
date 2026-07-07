---
title: arbor-core — DB + importers / nightly grains
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, postgres, rls, importers, nightly-cron, schema, confidential]
applies: []
links: ["[[arbor-core-onestop-ui]]", "[[arbor-core-rfp-automation]]", "[[arbor-core-cockpit-bidqueue-handoff]]", "[[arbor-core-strategy-foundation]]"]
updated: 2026-07-07
---

# arbor-core — DB + importers / nightly grains

**One-liner:** The Postgres RLS spine (`arbor_core` DB) — the frozen sales-engine schema (customer spine) applied live and tenant-isolated — plus the importers and nightly grain refreshes that feed it. **This is the foundation everything else runs against** (B2 match-or-create, the estimator, the bid handoff).
**Status:** 🟢 DB LIVE (as of 2026-06-30) · 🔵 importers / nightly grains active.
**📁 Location:** `arbor-core/migrations/` + `arbor-core/tools/refresh-*.sh`
**▶️ Resume:** `arbor-core/migrations/README.md`

## Applies / uses
- Foundation D9 multi-tenancy (RLS) + two-axis geography + `numeric` money + soft-delete/temporal + domain events (see [[arbor-core-strategy-foundation]]).
- Container `arbor_postgres` (postgres:16), DB `arbor_core` (isolated from n8n/`arbor` DBs). Owner role `arbor` (BYPASSES RLS, migrations only); **app/agent role `arbor_app`** (`NOSUPERUSER NOBYPASSRLS`) — never connect the app as `arbor`.

## State & flags
- **Tenant context REQUIRED on every connection:** `SET app.tenant_id = '1'` (1 = Great Scott) right after connect, before any query. Without it, RLS returns zero rows (fail-closed). Verified: tenant 2 sees 0 of tenant 1's rows; cross-tenant INSERT rejected.
- **Schema:** `0001_customer_spine.sql` (tenant · segment · customer · site · contact; UUIDv7 PKs; composite tenant FKs; segment lookup seeded) · `0002_app_role_force_rls.sql` (arbor_app + FORCE RLS). Migrations run 0001–0023 (0014 pricing reconciler, 0015/0016 price history, 0017 site rebid, 0018 access/equip, 0019 actual hours, 0020 tree risk, 0021/0022 bidqueue legacy ids, 0023 site_area source).
- **Nightly grain crons:** **price-history refresh 6:00 UTC** (`tools/refresh-price-history.sh`, ~2847 combos / 658 species from play) + **site-rebid refresh 6:05 UTC** (`tools/refresh-site-rebid.sh`, invoiced history per linked site). Both refresh-in-place, tenant-scoped RLS, reuse `species_key()`.
- **Zone import (2026-07-07):** `bidqueue_import.pull_site_zones()` now brings a site's real work areas over — TRIM IT `dbo.ZoneDefs.FusionTablePolygon` (KML `<coordinates>` = `lng,lat,alt` tuples) parsed to `[[lat,lng]]` rings → `site_area` rows (`source='trimit_zone'`, color from ColorCode/`_GSTS_COLORS`). So a pulled job **arrives with its color-coded zones already drawn** — no manual map-extraction needed. Then GPS'd trees are **point-in-polygon tagged** (`tree.area`=zone name) so per-zone counts populate. **Gotchas solved:** (1) sqlcmd truncates `varchar(max)` at 256 → fetch the polygon in ≤160-char **bracket-wrapped chunks** (survives `-W` trailing-trim) + reassemble per zone; (2) ZoneDefs `Desc1` is often a bare number that **repeats across zones** → globally de-dupe names (`"1"`, `"1 (2)"`…) so every polygon survives the `lower(name)` unique index. Called at the end of `import_job`; idempotent. Verified on 1274228 La Paz (4 zones, 205/217 GPS trees tagged) + 1283100 (5 same-named zones all kept).
- ⚠️ **Next (B2):** load real GSTS customers (verified CustomerList dump) so match-or-create is meaningful; swap the CSV proxy → live read-only TRIM IT query (**blocked on Jordan/AWS prod access**).

## Related
- [[arbor-core-onestop-ui]] — the app reads/writes this spine (migrations 0001–0023 back the estimator + grains).
- [[arbor-core-rfp-automation]] — B2 match-or-create runs against this DB.
- [[arbor-core-cockpit-bidqueue-handoff]] — the importer upserts pulled jobs here (idempotent on legacy ids).
