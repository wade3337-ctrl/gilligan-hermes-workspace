---
title: arbor-core — V1.5 Auth Global Gate
type: project
domain: work-arbor-core
track: 2
status: active
tags: [arbor-core, auth, security, global-gate, coldfusion, confidential]
applies: []
links: ["[[arbor-core-strategy-foundation]]", "[[arbor-core-crew-infra]]", "[[v15-landing-page]]"]
updated: 2026-07-03
---

# arbor-core — V1.5 Auth Global Gate

**One-liner:** A global gate ("bouncer") in `Application.cfc` at the play web root that authenticates EVERY page — real users log in with email+password, the gate owns identity (closing the legacy `ZUserID` back-door), and beta users see ONLY curated V1.5 pages. All infra in `.cfm` + the `Workbench` DB (survives nightly refresh); we own/deploy all of it, **no IT dependency.**
**Status:** 🔵 active — spec **CREW-APPROVED to build** (conditional on §10 R1–R11). **R1–R11 mandatory during P0–P2; P2 needs crew re-sign-off before any pilot user.**
**📁 Location:** `arbor-core/docs/decisions/V15-AUTH-BUILD-SPEC.md`
**▶️ Resume:** `arbor-core/docs/decisions/V15-AUTH-BUILD-SPEC.md`

## Applies / uses
- Data model: `Workbench.dbo.V15Users` / `V15Sessions` (store TOKEN HASH) / `V15AuditLog` / `V15Nav` (data-driven nav).
- Crypto/cookie spec: PBKDF2-HMAC-SHA256, per-user 128-bit salt, ~300k iterations; `__Host-V15Session` (Secure + HttpOnly + SameSite=Lax).
- Foundation D2 RBAC (role sandbox) — beta = exact-match `V15_ALLOWED_ROUTES` code constant, default DENY.

## State & flags
- **The gate** (`onRequestStart`): canonicalize path FIRST (reject traversal/double-ext/PATH_INFO) · allow-list bypass (login/auth/logout + static dirs, never by extension) · validate session → bounce if invalid · set `cookie.ZUserID` + `request.ZUserID` server-side on every authed request · hard role allow-list (admin=all, beta=listed routes only, `.cfc` denied by default) · every `<cflocation>` followed by `<cfabort>` · 1-command kill-switch (rename Application.cfc).
- **Decisions resolved (Skipper 2026-06-28):** D1 log in from anywhere → NO VPN / NO IP allowlist (the gate + strong auth + role sandbox IS the control → gate MUST be airtight + adversarially tested) · D2 beta sees only V1.5 · D3 "TEST DATA ~1 day old" banner.
- ⚠️ **R1–R11 (mandatory build conditions):** R1 🚨 legacy-subdir `Application.cfc` bypass (map the whole web root first) · R2 🚨 static-dir = RCE (disable `.cfm`/`.cfc` execution there) · R3 ZUserID race (set server-side) · R4 forced password reset · R5 in-memory throttling · R6 session revocation / IsActive check · R7 `SecureRandom` tokens · R8 two timeouts (12h absolute + 30min idle) · R9 CSRF on all state-changing actions · R10 CFC allow-list on method+verb · R11 pre-pilot adversarial test suite.
- **Build order:** P0 gate+lockdown → P1 login → P2 hardening (**crew re-review here**) → P3 pilot (1–2 trusted users).
- Residual risks: legacy pages still on `sa`; play data stale; gate = single point of failure for all play traffic (mitigated by kill-switch + testing).

## Related
- [[v15-landing-page]] — the role-gated V1.5 home this gate lands users on (Track-1 counterpart).
- [[arbor-core-crew-infra]] — the crew that reviewed the spec (Codex/GLM/Gemini) and re-verifies at P2.
- [[arbor-core-strategy-foundation]] — realizes foundation D2 (role sandbox) on the play beta env.
