# 2026-06-26 — arbor-core FOUNDATION RATIFIED (black-ops working session)

Skipper + Gilligan worked through all of BUILD-PLAN's open A1–A5 decisions in one session.
Full detail + the *why* for each: `~/arbor-core/build/FOUNDATION-DECISIONS.md` (D1–D7).
Build plan bumped DRAFT v0.1 → **v1.0, FOUNDATION RATIFIED**.

## Decisions locked
- **D1 Auth = Keycloak** (self-hosted, OIDC, admin UI, one container). Buy-not-build; self-host not SaaS (black boundary).
- **D2 RBAC = authz-in-the-brain** (Keycloak authenticates only) + **atomic perms → composable/additive roles** (UNION).
  Sales-slice roles: **Sales Arborist** (prices) · **Inventory QC** (the bid QC step) · **Sales Manager** · **Contracts
  Admin** · **Branch/Area Mgr** = narrow scoped add-on only (emergency/add-on pricing). Full 19-role org = registry,
  activated per domain. Manager/Admin pairs already embody the ≥2-holders governance law.
- **D3 Approval tiers + graduated-trust DIAL governs HUMANS too, not just agents.** QC pricing gate is per-arborist:
  new rep → hard gate (QC approves before send); proven rep → advisory. Fixes a real pain (QC = sales-delay source).
  → the performance/track-record layer is ONE shared mechanism (humans + agents).
- **D4 Migration** (on the lazy/on-demand import): (a) light customer-SPINE pull **gated by data-quality criteria**
  — Skipper flagged the customer list is dirty; only passing records enter, junk quarantined [reuse the 414/414
  customer-verifier muscle]; (b) un-rebuilt domains = on-demand + scheduled **batch** (not CDC); (c) cutover trigger
  = first bid/opportunity created for a customer in arbor-core.
- **D5 Secrets = Infisical** (self-hosted; kills the TRIM IT plaintext-password sin).
- **D6 CI = GitHub Actions + self-hosted runner**; envs local→arbor-play→arbor-prod, own Docker stacks, separate from TRIM IT infra.
- **D7 Gap check:** + decimal money (never float) · soft-delete/temporal history · domain events/outbox · MinIO blob
  store · track-record pillar. **🌎 BIG FINDING — two independent geographic axes, NOT a hierarchy:** **Branch =
  service area** (who does the work; cross-branch trading → reassignable w/ history) ⟂ **Sales Territory** (rep's
  selling geo; spans branches, overlaps). A bid carries BOTH owning arborist + servicing branch, need not align;
  reporting rolls up either axis. Naïve Branch→Area→Rep tree would've forced a total rebuild.

## Open WORK items (not foundation-blocking)
1. Define customer-spine **data-quality criteria** [D4a] — own session, reuse customer-verifier + crew.
2. Pick the **physical host box** for arbor-play/prod [D6].

## Schema progress (same session)
- Drafted **`schema/sales-schema-v1.2.md`** = v1.1 + foundation decisions (two-axis geography Branch⟂Territory,
  process-agnostic layer [sales_policy/state_transition], domain_event outbox, attachment/MinIO keys, soft-delete
  standard, Keycloak+RBAC tables, actor_autonomy dial).
- **3-lab crew review** (`schema/v1.2-crew-review-2026-06-26.md`): Gemini BLOCK · Codex BLOCK · GLM pass-w-fixes;
  **Kimi TIMED OUT** (slow reasoning model, read timeout — didn't count). **Headline: NO foundation decision (D1–D8)
  was wrong** — all findings are implementation-level relational fixes → next = **v1.3 integrity-hardening** (NOT a
  redesign). Convergent fixes: exclusive-arc typed FKs (kill polymorphic entity_type/id), branch-trade history on
  `engagement` grain not proposal, append-only ledger (drop is_current), **ENFORCE reference-don't-copy structurally
  + CI test** (Codex worst-flaw), lookup registries for type strings, unify human+agent into one `actor`, surrogate
  PKs for soft-deletable links, territory `priority` tie-break.
- **One open Skipper call for v1.3:** sales_policy scope = strict typed FKs (Gilligan rec, integrity) vs fully
  data-driven (GLM). Defaulting to strict unless Skipper overrides.

## Schema v1.3 + re-judge (same session)
- **v1.3 drafted** (`schema/sales-schema-v1.3.md`) = the 8 fixes C1–C8 applied. Skipper decision: **sales_policy
  scope = STRICT typed FKs** (not data-driven). Headline win: **Design Law #1 now machine-enforced** (opaque keys,
  validated event payloads, build-blocking CI test banning copied identity).
- **Re-judge** (`schema/v1.3-rejudge-2026-06-26.md`): Gemini PASS-WITH-FIXES (8/8 C-fixes RESOLVED) · Codex
  PASS-WITH-FIXES · GLM BLOCK (strictest). **C1–C8 structural fixes CONFIRMED landed; no foundation decision reopened.**
  Remaining = bounded **second-order v1.4 list**: F1 status-registry cross-entity leak (→ per-entity transition
  tables), F2 ledger↔current-branch drift (→ ledger is sole truth, monotonic seq), F3 actor CHECK+system semantics,
  F4 declare exclusive-arc targets (incl engagement_id), F5 sales_policy UNIQUE(scope,…), F6 C8 priority direction
  (lean lower-wins). GLM's C7 "collision" = a non-issue (intended dedup).

## Schema v1.4 + FINAL GATE CLEARED ✅ (same session)
- **v1.4 drafted** (`schema/sales-schema-v1.4.md`) = F1–F6 applied. Gilligan's design calls (Skipper said "go"):
  **F1 = per-entity transition tables** (kills polymorphic status + the reintroduced discriminator); **F2 = trade-
  ledger is sole truth** for current servicing branch (dropped mutable column; `DISTINCT ON ... ORDER BY monotonic
  assignment_id`; view). F3 actor CHECK+named system_code; F4 explicit arc targets incl engagement_id; F5 sales_policy
  UNIQUE; F6 territory priority LOWER-WINS.
- **Final gate** (`schema/v1.4-finalgate-2026-06-26.md`): **GLM PASS (no new findings) · Codex PASS-w-fixes (only a
  `kind`→`actor_kind` typo, fixed)** · Gemini API-timed-out (not counted). **GATE CLEARED.** GLM went BLOCK→BLOCK→PASS.
- **`sales-schema-v1.4` = FROZEN** as the approved clean sales-engine schema (pending Skipper's glance).

## 🆕 D9 — MULTI-TENANCY + arbor-core IS A PRODUCT (Skipper, 2026-06-26, end of session)
- **Strategic shift:** arbor-core = **the Skipper's OWN product**, a **vertical SaaS for tree-care companies he
  intends to SELL**. **Great Scott = the first tenant / "test model" / dogfooding ground, NOT the owner.** It's his
  IP → reinforces Track-2 black (keep off all GS team/vendor surfaces). **STRATEGY.md + CHARTER.md need updating** to
  this product framing (currently frame arbor-core as GS's internal Agent OS).
- **Decision LOCKED:** bake **multi-tenancy into the foundation NOW** (run single-tenant for GS first, but design
  tenant-aware). Why: multi-tenancy = the #1 un-retrofittable thing (same lesson as branch-scoping, one level up).
- **Schema reopens: v1.4 (frozen) → v1.5** = add `tenant` table ABOVE branch + `tenant_id` on every scoped table +
  **Postgres Row-Level Security** for hard isolation (recommended; DB filters every query to the tenant). Decide
  per-tenant-vs-global lookups. Then re-gate. **Do this BEFORE the Docker skeleton.** (Full: FOUNDATION-DECISIONS.md D9.)

## Multi-tenancy DONE same session: schema v1.5 → v1.6, tenant gate CLEARED
- **v1.5** = tenant layer (tenant table, tenant_id everywhere, RLS, scoped-vs-global split, copy-on-provision,
  TRIM IT importer = GS-tenant-only connector). **Tenant gate: GLM+Codex BOTH BLOCK** — caught REAL cross-tenant leak
  vectors (owner/BYPASSRLS bypass, single-col FKs crossing tenants, unprotected `tenant` table, fail-OPEN default).
- **v1.6** = isolation hardening TI1–TI9: FORCE RLS + non-owner `arbor_app` role, composite tenant FKs, RLS on
  `tenant` table, fail-CLOSED `-1` default + `SET LOCAL` + `app_tenant()`, USING+WITH CHECK, server-side tenant from
  JWT + **realm-per-tenant**, tenant-scoped legacy keys, polymorphic tenant-match, global tables immutable+SELECT-only.
  **Re-gate: Codex PASS ("no remaining leaks"), GLM PASS-w-fixes** (3 items folded in: REVOKE on globals, NULLIF/COALESCE
  app_tenant, +TI10 deploy role-segregation). **✅ TENANT GATE CLEARED.**
- **`sales-schema-v1.6` = FROZEN** = the approved MULTI-TENANT clean sales-engine schema. Tenant isolation DB-enforced,
  fails closed.
- **Gemini FIXED (end of session):** the "flaky all night" was a HELPER BUG — `gemini-ask.py` had `timeout=120` +
  only caught HTTPError → big reasoning prompts (~121s) died with a raw TimeoutError. Patched to 300s + retry
  (`GEMINI_TIMEOUT`/`GEMINI_RETRIES`). Backfilled the tenant re-gate: **Gemini PASS-w-fixes, TI1–TI9 confirmed**, AND
  caught **2 MAJOR the others missed** → **TI2b** (universal tenant-scoped UNIQUE constraints — UNIQUE checked outside
  RLS = existence-probe leak; folded into v1.6) + SQLi/GUC-spoof threat model (deferred). Lesson+Playbook logged.
- **v1.6 residue (judgment items for build/v1.7):** SQLi/GUC threat model (lean: parameterized-only + scope the claim);
  **UUIDv7 vs bigint PKs** (sequence side-channel) — real choice at migrations; SECURITY DEFINER CI lint.

## Schema v1.7 cleanup (same session) — FROZEN at v1.7
- 4 real refinements: **K1 define the `agent` table** (Kimi CRITICAL — actor.agent_id referenced a table that never
  existed); **K2 money = `numeric(19,4)`** everywhere; **K3 keycloak_subject NOT NULL** (legacy created-by → system
  actor, not a fake user); **K4 UUIDv7 PKs** on tenant-scoped tables (close the cross-COMPETITOR volume side-channel;
  UUIDv7 = time-ordered so branch_assignment "latest" still works). Global vocab tables + tenant_id stay small/bigint.
- Build-phase standards captured: parameterized-queries-only (kills SQLi→tenant-spoof), SECURITY DEFINER lint, CI
  checks (money precision, no-copied-identity, every tenant UNIQUE includes tenant_id). D4a now also folds Kimi's
  source_system/trust_tier spine columns.
- ⚠️ v1.7 NOT yet crew-re-gated (light re-gate pending — confirm agent-table FKs + UUIDv7 ordering). My stale-prompt
  goof: fed Kimi the OLD v1.2 lens → most findings already-fixed; LESSON logged (rebuild evidence from CURRENT version).

## 🔧 REPORTING-DESIGN FIX (Skipper complaint → solved + proven): stop using in-turn background Bash for long crew
## work (dies on turn preemption + needs me to manually speak). USE `sessions_spawn` background SUB-AGENT sessions —
## independent of my chat turn, OpenClaw pushes completion back THROUGH me to digest in my voice (user never sorts raw
## replies). PROVEN live: spawned Kimi confirmation as a sub-agent, it ran to completion + reported. Crew helper bugs
## also fixed: gemini-ask.py + kimi-ask.py both had too-short timeouts (120/180s) + only caught HTTPError → big
## reasoning prompts died with raw TimeoutError; now 300s + retry (GEMINI_TIMEOUT/KIMI_TIMEOUT, *_RETRIES).

## ⭐ NEXT SESSION = (1) light re-gate v1.7 → (2) update STRATEGY.md/CHARTER.md to PRODUCT framing (arbor-core =
## Skipper's vertical SaaS, GS = tenant #1) → (3) Docker skeleton (Postgres · FastAPI · Keycloak[realm-per-tenant] ·
## Infisical · MinIO) + first migrations FROM v1.7. Parked: customer-spine data-quality [D4a]; arbor-play/prod host box;
## MEMORY.md truncation tidy (2% clipped — trim to lean index).
## Parked work items still open: customer-spine data-quality criteria [D4a]; pick arbor-play/prod host box.
(ALL docs committed to arbor-core repo + nightly backup. Tonight's commits: 07bad70..HEAD, ~10 commits.)
