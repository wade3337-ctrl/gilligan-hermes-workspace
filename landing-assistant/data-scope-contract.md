---
title: Data Scope Contract
type: contract
track: 1
status: binding
updated: 2026-07-11
---

# 🚦 Data Scope Contract

**The rule the Skipper set:** the assistant may only surface real TRIM IT data that is **available on a page reachable from the V1.5 landing page.** If a user couldn't get to the number by clicking through the landing page, the assistant can't say it either.

## Why this boundary (the *why*)
- **No new security surface.** The assistant reads the *same queries* that already power those pages. We're not opening a new door into the database — we're putting a microphone in front of a door that's already open.
- **It inherits the role-gate for free.** The landing page already gates nodes by role (SALES / PRODUCTION / ACCOUNTING / EXECUTIVE, off `COOKIE.ZUserID → Users → Title`). The assistant must respect the **same** gate: if the signed-in user's role can't see the Accounting node, the assistant must refuse Accounting questions for them. Scope = *that user's* reachable pages, not all pages.
- **It's enforceable and auditable.** "In scope" is a finite, listed set → [[scope-map]]. Anything not on that list is out of scope by definition. No judgement calls.

## The three tests every request must pass
1. **Page test** — does the answer live on a page in [[scope-map]]? If no → refuse, point elsewhere.
2. **Role test** — is that page in a node this signed-in user's role can open? If no → refuse.
3. **Freshness test** — the number comes from a **live query run now**, not from the model's memory or an old note. → [[architecture]]

## Hard don'ts
- ❌ No querying tables/pages outside [[scope-map]] — even if technically reachable in the DB.
- ❌ No cross-role leakage (a rep must not learn exec-only figures via the chat box).
- ❌ No fabricated or "estimated" numbers. Out-of-scope = say so. → [[guardrails]]

*When the scope list grows, it grows **here and in [[scope-map]] only** — never by the model deciding on its own.*
