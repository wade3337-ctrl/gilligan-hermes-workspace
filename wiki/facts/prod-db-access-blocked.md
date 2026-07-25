---
title: Prod read-only DB access (BLOCKED)
type: fact
domain: env
tags: [infra, prod, database, blocked, aws, security-group, jordan, access]
links: ["[[play-dev-access]]", "[[trimit-db-gotchas]]", "[[gstsreadonly-prod-dsn]]", "[[prod-backup-chain]]", "[[vendor-fieldapp-build]]", "[[data-freshness-contract]]"]
updated: 2026-07-25
---

# 🔒 Prod read-only DB — DIRECT SQL still BLOCKED (but a CF-DSN path now exists)

> **UPDATE 2026-07-14:** this note is about **direct SQL** to prod from our box (gsql/Codex) — **still blocked** (AWS security group, Jordan). BUT Travis set up a **ColdFusion DSN `GSTSREADONLY` on the PLAY server** that reaches prod read-only from *inside* the allowed network — so CF pages on play CAN now query prod. Different path, now working (partially). → **[[gstsreadonly-prod-dsn]]**. The direct-SQL ask below is still open only if we ever need `gsql`-style direct access.

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`. The ask: `arbor-stack/dev-tasks/prod-db-access-ask-JORDAN.md`.

- **`GSTSREADONLY` @ 198.207.148.168**, login by Travis Jun 16; creds saved (`.secrets/prod-db.json`) — but **BLOCKED**.
- Port **times out from BOTH this host AND the in-network play/dev box** → very tight allowlist or wrong endpoint (cred note says "port/db assumed").

## OWNER = JORDAN, not Travis (Jun 29)
- Prod is **AWS-hosted**; its **security group** (default-deny firewall) doesn't allowlist our IP **76.32.188.157**.
- Jordan's "Amazon blocking AI access" = just an **un-allowlisted outside IP**, not an AI-specific block.

## The ask — RE-TIERED 2026-07-25 (the firewall is NO LONGER the main item)
Full doc: `arbor-stack/dev-tasks/prod-db-access-ask-JORDAN.md`.

| Tier | Ask | Network change? | Owner |
|---|---|---|---|
| 🟢 **0 — the real one** | Grant the **existing** `GSTSREADONLY` login `db_datareader` on `GSTS` (or ≥ SELECT on **`flow`**) | **none** | **Travis** |
| 🟢 1 | Explain/fix the heavy-query timeout on that DSN (linked-server hop?) | none | Travis |
| 🟡 2 | Confirm real host/port, remote-TCP on, + inbound TCP from `76.32.188.157/32` | one `/32` allowlist row | Jordan |
| 🔵 3 | Put our host on the private tailnet instead of opening a DB port | nothing public | Jordan |

**Tier 0 is the entire practical blocker** — [[gstsreadonly-prod-dsn]] already reaches prod from inside the network and **3 of 5 metrics work live today**; the 2 failures are purely the missing `flow` grant. **No new account, no write access, no port.**

⚠️ **Six months of stall is partly a ROUTING error: Tiers 0/1 are Travis's work, but the whole ask sat with Jordan**, who owns only the (probably unnecessary) Tier 2.

## 🛡️ The "hosts block AI tools" claim — how to answer it
Jordan has framed this as the hosting provider blocking AI (June: *"Amazon blocking AI access"*; July: *"the people hosting the server block AI tools"*). The counter, used in the 2026-07-25 email:
- **A database or file server cannot detect what software is at the other end of a connection** — it sees an account and a permission set. There is no AI-specific block in AWS or any standard host.
- Risk is controlled by **account scope**: named accounts, read-only where read-only suffices, logged, revocable.
- **Ask for the policy in writing** — who the provider is, and the text. The claim has never been made concrete.
- 🥊 **Strongest rebuttal: our own vendor built it for this.** Travis set up the read-only prod DSN on 14 July describing it as for *"an AI Assistant that wants to query the production server (read-only)"* → [[gstsreadonly-prod-dsn]].

## Why it now matters more, not less
Reporting off play is only as fresh as a copy chain that **fails roughly weekly** → [[prod-backup-chain]]. Live read-only prod makes reporting **independent of that chain** — that is the argument, not convenience.

## Until then
Verify prod DB changes via the nightly **play refresh-from-prod** (play = full restore of the prior-day **3:00am Central** prod backup; technique proven Jun 29 for the IsMeasured check).

## Related
- [[play-dev-access]] — the working (play) path used as the stand-in.
