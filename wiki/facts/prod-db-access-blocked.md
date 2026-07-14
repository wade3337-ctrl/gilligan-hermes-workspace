---
title: Prod read-only DB access (BLOCKED)
type: fact
domain: env
tags: [infra, prod, database, blocked, aws, security-group, jordan, access]
links: ["[[play-dev-access]]", "[[trimit-db-gotchas]]", "[[gstsreadonly-prod-dsn]]"]
updated: 2026-07-14
---

# 🔒 Prod read-only DB — DIRECT SQL still BLOCKED (but a CF-DSN path now exists)

> **UPDATE 2026-07-14:** this note is about **direct SQL** to prod from our box (gsql/Codex) — **still blocked** (AWS security group, Jordan). BUT Travis set up a **ColdFusion DSN `GSTSREADONLY` on the PLAY server** that reaches prod read-only from *inside* the allowed network — so CF pages on play CAN now query prod. Different path, now working (partially). → **[[gstsreadonly-prod-dsn]]**. The direct-SQL ask below is still open only if we ever need `gsql`-style direct access.

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`. The ask: `arbor-stack/dev-tasks/prod-db-access-ask-JORDAN.md`.

- **`GSTSREADONLY` @ 198.207.148.168**, login by Travis Jun 16; creds saved (`.secrets/prod-db.json`) — but **BLOCKED**.
- Port **times out from BOTH this host AND the in-network play/dev box** → very tight allowlist or wrong endpoint (cred note says "port/db assumed").

## OWNER = JORDAN, not Travis (Jun 29)
- Prod is **AWS-hosted**; its **security group** (default-deny firewall) doesn't allowlist our IP **76.32.188.157**.
- Jordan's "Amazon blocking AI access" = just an **un-allowlisted outside IP**, not an AI-specific block.

## The ask (WAITING ON JORDAN)
→ `arbor-stack/dev-tasks/prod-db-access-ask-JORDAN.md`: confirm real host/port + remote-TCP enabled + **add inbound TCP from `76.32.188.157/32`**.
- Opens realtime PROD reads (vs ~24h-behind PLAY) when done.

## Until then
Verify prod DB changes via the nightly **play refresh-from-prod** (play = full restore of the prior-day **3:00am Central** prod backup; technique proven Jun 29 for the IsMeasured check).

## Related
- [[play-dev-access]] — the working (play) path used as the stand-in.
