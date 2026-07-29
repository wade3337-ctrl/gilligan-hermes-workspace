---
title: V1.5 Landing Page
type: project
domain: work
track: 1
status: parked
tags: [ui, landing-page, v1.5, role-gating, login, home-base, responsive]
applies: ["[[gsts-ui-style-guide]]", "[[gsts-ui-spec]]", "[[repair-contract]]"]
links: ["[[sales-cockpit]]", "[[rc-03-city-budgets]]", "[[rc-04-spm]]", "[[rc-02-revenue-performance]]", "[[v15-landing-assistant]]", "[[revenue-goal-close]]"]
updated: 2026-07-29
---

# V1.5 Landing Page

**One-liner:** A new menu tab in current TRIM IT that opens a role-gated, responsive V1.5 home base (SALES · PRODUCTION · ACCOUNTING nodes) — the strangler-fig front door routing employees into the reorganized V1.5 structure, plus a premium new login page.
**Status:** ⏸️ parked — design phase; Phase-1 role-gated node hub built + live on play; needs R2/R3-class gaps closed before the next build push.
**📁 Location:** `arbor-stack/v1.5-landing-page/` (`Dashboard-V15Home.cfm` + mockups)
**▶️ Resume:** `arbor-stack/v1.5-landing-page/PROJECT-v1.5-landing-page.md`

## Applies / uses
- [[gsts-ui-style-guide]] — brand floor: slate bg `#f7f9fb`, white cards, green gradient `#5C743D→#405528`, system fonts, mobile-first 44px taps, no 3rd-party UI libs, tokens not hex. Landing page earns a more elevated "home" treatment on top.
- [[gsts-ui-spec]] — welcome modal / pro-tip pattern; `.cfm` with emoji/non-ASCII needs a UTF-8 BOM (this page uses numeric entities instead — UTF-8 clean, no BOM).
- [[repair-contract]] — backup-first, render-verify the served output, dual-webroot watch, log to ship-log.

## State & flags
- ✅ **Phase 1 live on play** — `Dashboard-V15Home.cfm`, real role-gating off live login table (`COOKIE.ZUserID → Users` → FullName/Title/SalesRepID), greets by name/time-of-day, 0 CF errors, verified across 8 users.
- Role rule is title-driven (defaults ALL). **Bug caught + fixed:** `CONTAINS "coo"` matched "**coo**rdinator" → wrongly execs; fixed with padded whole-word checks.
- Jun 29: **SALES node consolidated to a single [[sales-cockpit]] link**; EXECUTIVE node gained Sales Cockpit + Sales Production Meeting. Node items are hardcoded HTML in the page; the menu TAB is the AppForms part.
- Nodes populate as dashboards finish (real links now: City Budgets, SPM, Revenue Performance, Executive Review). No fake data on a real page.
- **Design decisions D1–D17** locked: 3-node lifecycle IA, role-gated landing, home-base (node hub + TODAY list + in-house lite-LLM AI chat + messaging), phased build 1→4, phone+iPad responsive (D9 hard req), premium/light-airy feel with photographic canopy hero + 50th-anniversary logo login.
- ⚠️ **Open gaps:** R2 (which T&A system + hourly-crew login/kiosk tension), R3 crew photography (50th logo ✅ resolved), no dedicated Accounting role in `RoleDefs` (map the ~20 logins by hand). **Login stays visual-only** — real auth wiring is the one security-sensitive step (do with Jordan/dev; fix plaintext-password then).
- ⏭️ Next: add the menu tab (INSERT `dbo.AppForms` + `dbo.MyAppForms`), decide login→home wiring, keep populating nodes.

## 2026-07-29 — the Executive node's RGC link: pulled, then restored
The Skipper: *"remove revenue goal because it doesnt work"* → `showRGC` hard-`false` in
`Dashboard-V15Home.cfm` (backup `D:\GSTS\Jasonsrepairs\2026-07-29-Dashboard-V15Home-preRGCremoval.bak`).
**Diagnosed the same session and it was not the page** — the RGC proc was failing closed on a goal
mismatch, so every tile rendered an em-dash → [[revenue-goal-close]]. Goal re-based, page returned real
numbers, **link restored to the Executive tab the same day.**
🪧 **Worth keeping:** a landing-page link is the only thing most users see — *"it doesnt work"* about a
destination is a report about the destination's DATA at least as often as its code. Pull the link if he
asks, but diagnose before treating the removal as the fix.

Also on this page today: its chat assistant got a personality and a KB-owned joke file
→ [[v15-landing-assistant]].

## Related
- [[sales-cockpit]] — the SALES node's single consolidated destination.
- [[rc-03-city-budgets]], [[rc-04-spm]], [[rc-02-revenue-performance]] — dashboards linked from the nodes.
