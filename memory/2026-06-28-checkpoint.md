# SESSION CHECKPOINT — 2026-06-28 (pre-gateway-restart, "don't lose our place")

## WHERE WE ARE — resume here
**Active thread:** building the **V1.5 beta-login + global-gate** system (the strangler-fig proving ground).
**P0 FOUNDATION = BUILT + crew-fixed (2026-06-28).** Next = the gate (build standalone → test on throwaway page → wire w/ kill-switch).

### P0 progress (DONE this session):
- **R1 web-root mapped:** 9 Application files. LIVE = `wwwroot/Application.cfc` (gate goes here, governs /GSTS). 8 STALE (Apr-25) subdir apps = bypass risk: GSTS/Red, Yellow/Red, Tan/services, TanBackup/Tan, DemoDemo, 2×_mmServerScripts, + wwwroot/API (newer May-04 → verify live/dead).
- **Workbench tables BUILT + crew-hardened:** V15Users(15c) · V15Sessions(9c, LEAN—no denorm role, gate JOINs live) · V15ResetTokens · V15AuditLog(append-only DENY upd/del) · V15Nav. DATETIME2, CHAR(64) tokens, filtered-unique one-active-session index, FKs, CHECKs, RevokedAt, PasswordChangedAt.
- **V15App least-priv SQL login:** creds `~/.secrets/v15app.json` (0600). Grants: Users/Sessions/Reset SEL/INS/UPD (no DELETE), Audit INS-only+DENY, Nav SEL. CHECK_EXPIRATION=OFF.
- **Crew review (codex+GLM+kimi = FIX-FIRST, all applied):** record `arbor-core/docs/decisions/crew-reviews/V15-FOUNDATION-review-20260628.md`. Gemini 503 (retry).
- **⚠️ R1 RENAMES REVERTED 2026-06-28 (assumption was WRONG):** I'd renamed 8 subdir Application.cfc `.bak` thinking they were dead Apr-25 "themes." **They're NOT dead — the COLOR folders (Yellow, Red, Tan…) are likely OLD FIELD-APP VERSIONS** (Skipper: `/gsts/Yellow/index.cfm` is the old field app; `/gsts/FieldApp/` is the new one). All 8 renames UNDONE (Application.cfc restored, 0 `.bak` left); backups still in `GSTS\Jasonsrepairs\v15gate-stale-apps-20260628\`. **Lesson: don't assume "old mod-date subdir = dead"; verify what it serves.** When the gate ACTUALLY gets wired (it's parked), re-do R1 with this knowledge — gate-inject or block each subdir app deliberately, don't blanket-rename.
- **🌐 IIS TOPOLOGY (mapped):** Site `play.greatscotttreeservice.com` → root `D:\…\wwwroot\` (gate at `wwwroot\Application.cfc` governs `/GSTS`). Site `playapi.greatscotttreeservice.com` → root `D:\…\wwwroot\API` = a **Taffy REST API** (token/Authorization-header auth, NOT ZUserID cookie). `/API` reachable both as playapi host AND `play.../API/`.
- **✅ /API DISPOSITION:** leave as-is — separate token-auth domain, out of scope for the browser gate (gating it would break its app/integration consumers). **Follow-up (not P0 blocker):** verify Taffy API requires a real token & doesn't honor a bare ZUserID cookie.
- **✅ CFIDE (CF Admin) NOT exposed:** HTTP 404 on play, no CFIDE vdir in IIS (files only under CF's own wwwroot, unmapped). Ruled out.
- **✅ GATE v0.1 BUILT + PROVEN (standalone, NOT yet wired — zero live impact):** code = `arbor-core/build/v15/gate.cfm` (deployed to play `wwwroot\v15\gate.cfm` + test page `_gatetest.cfm`). Datasource="GSTS", 3-part `Workbench.dbo.*`; all time math in SQL/UTC. **7/7 tests pass:** no-session→302 login · valid→identity set · **tampered ZUserID→overwritten (back-door CLOSED)** · beta on non-V1.5 page→302 home (D2 sandbox) · revoked→302 · disabled IsActive=0→302 (R6 instant kill) · **CF CAN write filtered-index table (QUOTED_IDENTIFIER ON confirmed — login INSERTs will work).**
- **⚠️ GOTCHA:** any DML on V15Sessions needs SET QUOTED_IDENTIFIER ON (filtered index). sqlcmd defaults OFF (prefix scripts); **CF defaults ON (verified)**.
- **🧪 Test scaffold LIVE on play (purge before pilot):** V15Users `gatetest@gsts.local` (V15UserID=1, ZUserID=376, admin) + session token `TESTTOKEN123abc`. Low-risk (gate not wired; only reaches test page).
- **✅ GATE v0.1 CREW-REVIEWED → FIX-FIRST** (Codex+GLM converge; Gemini 503 all session; Kimi killed by msg-preempt). Record: `arbor-core/docs/decisions/crew-reviews/V15-GATE-v0.1-review-20260628.md`. **5 fixes for v0.2:** (1) judge `arguments.TargetPage` not `cgi.script_name` (confused-deputy — kills 2 bugs); (2) kill regex PATH_INFO truncation (`/home.cfm/../admin.cfm` bypass); (3) CLEAR ZUserID at top, set only after live session (forged cookie survives on public/static today); (4) static = extension-allowlist + deny dirs + IIS handler removal; (5) try/catch fail-closed. Confirmed-good: fails CLOSED on query throw, listFindNoCase exact-match.
- **🧹 PAUSE CLEANUP (2026-06-28 ~13:56):** test session REVOKED (0 active). Test user row `gatetest@gsts.local` (V15UserID=1) + `/v15/gate.cfm` + `_gatetest.cfm` still on play (harmless — gate NOT wired). Re-seed session to resume testing.

## ⏸️ PINNED — Skipper deciding (resume this evening 2026-06-28):
**THE OPEN DECISION = which wiring model.** He's mulling it during outdoor work. Question I posed: keep his CURRENT old-TRIM-IT login flow untouched, or one new login for all?
- **Model A (spec default, simplest/airtight):** gate guards EVERYTHING. Everyone (us + beta) logs in via the NEW V1.5 login. Admin role → full old-TRIM-IT access (nothing locked for us); beta → boxed to V1.5. Closes the ZUserID back-door fully. Cost: WE switch to the new login page on play (one-time). **← my recommendation.**
- **Model B (keep old admin login unchanged):** old TRIM IT login stays as-is; gate only fronts V1.5. To still lock beta OUT of old TRIM IT, must PATH-SCOPE the beta ZUserID cookie (Path=/v15) so old pages never receive it — fiddlier, more work.
- **Why it's forced:** D2 ("beta never sees old TRIM IT") requires the gate to sit in front of old TRIM IT, because old pages trust a bare ZUserID cookie that beta ends up holding. Gate must own identity to tell admin from beta.
- **RESUME:** get his Model A/B pick → build gate v0.2 (5 fixes) → re-test+re-review → P1 login → wire w/ kill-switch.

- **▶️ (after decision) NEXT:** build gate v0.2 → re-test → re-review → P1 login (PBKDF2 + session issue + landing + curated nav) → WIRE into `wwwroot\Application.cfc` w/ backup + kill-switch.
- **Gotchas hit (→LESSONS):** sqlcmd needs GO between DDL (filtered index ref'd new col → whole batch rejected); filtered index needs SET QUOTED_IDENTIFIER ON.

### (prior) spec status — still CREW-APPROVED TO BUILD:
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
