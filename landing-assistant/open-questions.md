---
title: Open Questions
type: note
track: 1
updated: 2026-07-11
---

# Open Questions — decisions owed

Held for the Skipper; the vault is buildable without them but the wire-up needs them.

1. **Name** — what do we call the assistant on the page? (placeholder: "the V1.5 Assistant"). → [[identity]]
2. **First grounded page** — recommend **Revenue Performance** as the v1 proof (pace/TPH — high-value, single clean query). Agree, or start elsewhere?
3. **Role source for the assistant** — reuse the landing page's existing `COOKIE.ZUserID → Users.Title` gate verbatim? (recommended — one source of truth). → [[data-scope-contract]]
4. **Where the wire lives** — build `AI-Chat.cfm` on **play** first (per [[repair-contract]], backup-first, render-verify), never prod until proven. Confirm play-first.
5. **Network path** — ✅ RESOLVED: **Tailscale**. Different locations, same tailnet. CF → `http://100.82.161.7:11434` (this box = `gilligan`), encrypted by WireGuard. Proven working 2026-07-11. → [[architecture]]
7. **Confirm the CF/TRIM IT node** — is it `gstsdatabase` (100.86.97.46)? Needed to point the ACL + know where `AI-Chat.cfm` lives.
8. **🔴 BLOCKER — Tailscale ACL (Skipper's console).** gstsdatabase (tagged device) is NOT in gilligan's allowed-source list, so `gstsdatabase → gilligan:11434` is filtered (tailnet path is up; only the port is blocked). This is *also* the security lock we wanted. Add to the tailnet policy (login.tailscale.com → **Access Controls**):
   ```json
   { "action": "accept", "src": ["100.86.97.46"], "dst": ["100.82.161.7:11434"] }
   ```
   (Cleaner with names/tags if the policy uses them: `src` = gstsdatabase's tag, `dst` = `gilligan:11434`.) After saving, `AI-Chat.cfm` goes green with no code change. Optional extra hardening: bind Ollama to `100.82.161.7` so it's not also open on gilligan's physical LAN.
9. **Keep-warm** — set Ollama `keep_alive` (e.g. `-1` / long) so users don't hit the ~21s cold start; warm is ~2s.
6. **Latency** — 3B is fast but CF→Ollama round-trip adds up; set a "thinking…" state + a timeout in the chat box.

## Answered
- ✅ Chat-only vs grounded → **grounded**, scoped to landing-page-reachable pages (Skipper, 2026-07-11).
- ✅ Which model → local **llama3.2:3b** on Ollama.
