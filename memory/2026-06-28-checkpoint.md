# SESSION CHECKPOINT — 2026-06-28 (pre-gateway-restart, "don't lose our place")

## WHERE WE ARE — resume here
**Active thread:** building the **V1.5 beta-login + global-gate** system (the strangler-fig proving ground). It's **PARKED
at a clean spot: spec is CREW-APPROVED TO BUILD.**
- **Spec:** `~/arbor-core/docs/decisions/V15-AUTH-BUILD-SPEC.md` — status CREW-APPROVED TO BUILD (conditional on §10 R1–R11).
- **Decisions (Skipper-resolved):** D1 = login from ANYWHERE, **no VPN/IP allowlist** (gate+strong-auth is the control);
  D2 = **beta users see ONLY V1.5 pages, never old TRIM IT** (role-based route allow-list; we=admin keep full access);
  D3 = "TEST DATA ~1 day old" banner.
- **Crew gate (4 labs):** APPROVED to build, with 11 build conditions (§10 R1–R11). The 2 sharpest:
  **R1** map the whole web root — a legacy subdir `Application.cfc` could BYPASS the gate (first build task);
  **R2** static-dir RCE — allow only static extensions, no `.cfm`/`.cfc` execution in `/Art`, `/v15/assets`.
- **NEXT when we resume:** build **P0** (Workbench tables + least-priv `V15App` SQL login + the `Application.cfc` gate +
  test session), starting with R1 (web-root mapping). Then P1 login, P2 hardening (crew re-review), P3 pilot.

## TOOLING FIXES DONE THIS SESSION (the "work right before we build" pass)
- **🛰️ COMMS RULE (the big one):** run crew gates **FOREGROUND, in-turn** — NOT background-shell (Skipper blind to the
  result) and NOT a sessions_spawn sub-agent (I'm blind to the result). Foreground in-turn = BOTH of us see it (result
  is a normal reply + in my context). Proven 2026-06-28. **Finish line = Skipper confirms he got it; if a result ever
  doesn't land, re-send.** Very-long runs may still auto-background → chunk them into in-turn pieces.
- **Kimi:** `~/arbor-core/crew/kimi-ask.py` default `max_tokens` 8000→16000→**40000** (K2 reasoning was eating the budget
  before the answer; "ran out of budget" = THIS helper cap, NOT the Skipper's Kimi account, which is at ~1%). Tested OK.
- **Bootstrap caps:** `~/.openclaw/openclaw.json` `agents.defaults.bootstrapMaxChars`=40000, `bootstrapTotalMaxChars`=160000
  (were unset → MEMORY.md clipped at ~20k). Config backed up `openclaw.json.bak-20260628-bootstrap`. **This restart applies it.**

## ALSO STILL PARKED (separate, from earlier today)
- **SPM/dashboard PROD deploy package for Travis+Jordan** → `~/arbor-stack/DEPLOY-PACKAGE-CHECKPOINT.md` (12-file batch +
  IsMeasured DB fix, all on play + crew-cleared, awaiting Skipper review → Jordan/Travis deploy).
- **Open project (not yet built):** live "still-working" visibility during a crew run (I can't message mid-turn) — scope next.
