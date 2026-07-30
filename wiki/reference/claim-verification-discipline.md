---
title: Claim-verification discipline — name the command
type: reference
domain: how-we-work
tags: [discipline, verification, claims, method, guardrail, derived-fields, retrieval]
applies: ["[[repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[self-improvement-loop]]", "[[play-public-cookie-forgeable]]", "[[data-freshness-contract]]"]
updated: 2026-07-30
---

# ✅ NAME THE COMMAND — the domain-independent claim test

**Standing rule (Skipper, 2026-07-29 · widened 2026-07-30).** The canonical short form lives in
`MEMORY.md`; this note is the detail and the worked failures.

> Before ANY claim about the state of a system — a number, a duration, a count, a cause, who's paying,
> what's running, what broke — **I must be able to name the command that produced it, run THIS session.**
> No command → I say **"I'm inferring"** out loud.

## Why it was widened (2026-07-30)
The original wording was *"every FIGURE I report must come from a query I ran this session"*, and it sat
inside [[repair-contract]]. Two structural failures, both hit the same morning:
- **It was domain-bound.** I open the repair contract when starting GSTS/TRIM IT work. A Discord-glitch
  question didn't look like that, so the rule never fired.
- **"Figure" was too narrow.** *"You're on metered API billing"* is not a figure — it is a **label** —
  so the rule as written did not cover the error the Skipper caught.

The fix was to rebind the trigger from a **project** to the **act of claiming**, so it fires inside the
sentence and needs no document lookup.

## 🔻 Sub-check: derived & summary fields are not measurements
**A rollup or a label ≠ the underlying record. Go pull the record.** Burned three times in one day:

| I read | I claimed | What one query showed |
|---|---|---|
| `consecutiveErrors: 4` on a cron | "failed 4 nights, 4 days of work lost" | `cron runs` → 1 run + 3 retries in **7 minutes**; Jul 26/27/28/29 all `ok`. Nothing lost. |
| `provider: "anthropic"` in a run log | "we've moved to metered API billing" | `openclaw models status` → `sk-ant-oat…`, `mode=token`, 334d = **still the subscription**. The field names the ROUTE, not the WALLET. |
| `verify-build.sh` → `PASS 20 / FAIL 0` | "the deal figures stay gated" | One `curl -H "Cookie: ZUserID=9"` → **200**. The check tests a second *user*, never an *attacker*. → [[play-public-cookie-forgeable]] |

**The tell in all three:** the field was one abstraction level above the thing I described.
Counters count attempts, not calendar days. Routing labels name transport, not billing. A PASS measures
what the check tests, not what I hope it proves.

## 🔁 Retrieval, not capture, is the failing loop
`LESSONS.md` is 400+ lines / 178 KB / 31 CRITICAL entries. AGENTS.md says *"check the relevant tag before
a task"* — at that size, **that instruction is not executable in the moment.** Evidence: I re-committed an
error whose lesson I had written **four minutes earlier** (a probe exiting non-zero firing a scary card),
and repeated a blocklist-vs-allowlist failure I had documented the day before in a different domain.
- **Writing lesson N+1 is not the fix.** A sentence-level test is, because it fires without remembering
  a document.
- Corollary for [[self-improvement-loop]]: capture is working; **retrieval is the bottleneck.** Prefer
  consolidating and *promoting rules into always-loaded guardrails* over appending another line.

## 🛠️ Mechanical habits that need no memory
- **Probes that may legitimately find nothing** get `|| true` / `|| echo "0 (clean)"`. A `grep -c`
  returning 0 exits 1, and the shell reports the whole chain as failed — which surfaces to the Skipper as
  a red "Exec failed" card and costs him a question. Absence must not look like breakage.
- **Never retype a path or credential read off displayed output** — the display elides
  (`KEY=/home/…5519`). Resolve from the source file at runtime and gate on readability.
- **Report a non-zero exit honestly, in the first line**, not buried after a wall of green checkmarks.
  If I generate cards he learns to dismiss, a real one gets ignored.
- **Repairs additionally:** run `arbor-stack/production-dashboard/verify-build.sh` before saying
  "verified", and **check the neighbours, not just the change** → [[repair-contract]].

## The honest limit
This makes the trigger cheaper and always-loaded. It does **not** make the error impossible. On
2026-07-30 the thing that actually caught the billing claim was the Skipper pushing back on a statement
about his own money. **That backstop should not have to be him.**

## Related
- [[repair-contract]] — the build-specific verification gate this generalises from.
- [[only-trustworthy-data]] — the outbound counterpart: omit and flag rather than ship a wonky metric.
