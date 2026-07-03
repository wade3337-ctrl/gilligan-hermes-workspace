---
title: Prod read-only DB access (BLOCKED)
type: fact
domain: env
tags: [infra, prod, database, blocked, aws, security-group, jordan, access]
links: ["[[play-dev-access]]", "[[trimit-db-gotchas]]"]
updated: 2026-07-02
---

# 🔒 Prod read-only DB — BLOCKED

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
