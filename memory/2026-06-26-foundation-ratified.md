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

## NEXT SESSION = produce schema v1.3 (apply the 8 fixes) → re-judge changed parts → then Docker skeleton.
(All foundation + schema docs committed to arbor-core repo + nightly backup.)
