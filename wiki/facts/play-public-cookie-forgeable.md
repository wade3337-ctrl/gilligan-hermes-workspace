---
title: Play is publicly resolvable and its cookie is forgeable
type: fact
domain: env
status: open-risk
tags: [security, auth, play, exposure, ZUserID, cookie, confidentiality, verify-build]
applies: ["[[two-track-confidentiality]]", "[[repair-contract]]"]
links: ["[[dashboard-auth-gate]]", "[[play-dev-access]]", "[[bod-commitment-dashboard]]", "[[claim-verification-discipline]]"]
updated: 2026-07-31
---

# 🚨 Play is PUBLIC and `ZUserID` is forgeable — no deal material on play, ever

**Measured 2026-07-30** while wiring the earnout feed. Three facts that only matter together:

1. **`play.greatscotttreeservice.com` resolves to `173.208.162.142` — a PUBLIC IP**, not a tailnet
   `100.x` address. (`getent hosts` / `dig +short`.) The SSH path is tailnet-only; **HTTP is not** — and an
   **external probe has since confirmed the host answers the open internet** (see below).
2. **A forged cookie with no password and no session token returns 200.**
   `curl -H "Cookie: ZUserID=9"` → **HTTP 200, 22,041 b** of a page that is supposed to be COO-only.
   No cookie at all → 302 to login, which is what makes it *look* gated.
3. Therefore **anything rendered on play is readable by anyone who can reach the host and knows a UserID.**

## 🔓 Why the gate does not save this page
[[dashboard-auth-gate]] validates the cookie against `Workbench.dbo.DashboardAccess` — but it carries a
**bootstrap allow-list that always passes: `9` (Jason) and `376` (the bot).** That bootstrap exists so the
admin can never be locked out, and it is exactly the hole: **`9` is a guessable integer, and the framework
only checks the cookie EXISTS.** So the gate correctly refuses user 340 while cheerfully admitting a forged 9.
This is the framework-level issue already noted as *"`ZUserID=9` opens `Dashboard-Access.cfm`"* — same root,
and it needs a **session-binding decision, not a page patch** (Skipper + Jordan).

🧠 **The mental model to correct when this comes up:** the Skipper's working assumption is *"it's behind a
login, so it's fine."* It does not hold here — **the app only checks the cookie EXISTS, never that anyone
authenticated.** Login is a screen door. Say it that way; "behind a login" is not a confidentiality control,
and no amount of page-level gating fixes it while any integer cookie is accepted as an identity.

## ⚠️ The verification blind spot that hid it (the important part)
`verify-build.sh`'s auth group probes **`ALLOW_UID=9` → 200** and **`DENY_UID=340` → 403**, and reports PASS.
That proves **one real user cannot see another's page**. It says **nothing** about an attacker, because
**340 is a different USER, not a forged identity.** I read `PASS 20 / FAIL 0` and told the Skipper the
deal figures "stay gated" — wrong, and it was one `curl` away.
- 🔧 **Fix the check, not just the page:** an auth probe must include a **forged/garbage cookie** case
  (`ZUserID=99999999` and `ZUserID=9`-without-session), not only a second legitimate user.
- 🧭 Generalises to [[claim-verification-discipline]]: *a PASS summary is a derived field.* It measures
  what the check tests, never what you hope it proves.

## 📌 The standing consequence
**Deal/Track-2 material must never be rendered on play.** Not the earnout bands, not the EBITDA floor,
not FTI/QoE/LOI framing, not net proceeds. → [[two-track-confidentiality]]
- **Incident 2026-07-30:** the "CFO financial targets" panel I shipped to
  [[bod-commitment-dashboard]] carried the **$4.1M TTM EBITDA floor**, the **FTI ~50% AGP definition**,
  and **LOI/QoE** wording. Proven exposed via forged cookie, then **stripped the same session** and
  re-verified: all eight deal terms → **0 occurrences** in the served HTML. Backup of the leaking version:
  `Jasonsrepairs\Dashboard-BODCommitments.cfm.bak-predealstrip-20260730-160643`.
- **GP / AGP / EBITDA-vs-CFO-target tracking is fine on play** — that is COO operating material.
  What must not travel is the *transaction* framing that turns it into deal intelligence.
- Earnout math lives in `business-plan/derived-financials.json` → the **Tailscale-private**
  [[deal-tracker-dashboard]] only. → [[cfo-financials-derivation]]

## ✅ CONFIRMED reachable from the open internet (2026-07-30, external vantage)
The earlier "not yet established" caveat is **closed**. A probe from an **outside-our-network vantage**
(hackertarget) reached the host directly: live **302 to `ClientLogin.cfm`**, real IIS response headers, and it
**sets `ZUSERID` cookies**. So there is no firewall in front — **exposure is internet-wide, not intra-net**, and
the forged-cookie result above is exploitable by anyone, not only someone already on our network.
- The probe run externally was the **benign reachability** check only (no forged cookie from outside) — that is
  sufficient: reachability was the single open variable, and the forgery was already proven from inside.
- ⚠️ **Anthropic's cyber-filter blocked the external forged-cookie probe** — it surfaced as a generic
  `LLM request failed` and **wedged the chat through 3 retries** before the model auto-switched to opus-4-8.
  Worth knowing: a security probe that looks like attack traffic can kill the turn rather than return an error.
- **Skipper's position (2026-07-30): no write-up for now**; the session-binding fix is deferred to him + Jordan.

## Superseded / historical
- *(2026-07-30, superseded)* "**Not yet established** — whether play is reachable from the open internet.
  DNS is public and the cookie is forgeable, both measured. A firewall in front is still possible; I have not
  probed from an external vantage point. Treat as exposed until proven otherwise." → the external probe above
  settled it: it **is** reachable, so "treat as exposed" is no longer a precaution, it is the measured state.

## Related
- [[dashboard-auth-gate]] — the gate itself, its bootstrap list, and the two *other* ways gates fail.
- [[play-dev-access]] — the box, its three-environment trap, and the write path.
- [[claim-verification-discipline]] — why "the check passed" was not evidence.
