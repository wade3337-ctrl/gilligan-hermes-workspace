---
title: Bigin ↔ Gilligan via Zoho MCP (native tool access)
type: project
domain: work
track: 1
status: ✅ LIVE 2026-08-06 — 69 Bigin tools authenticated, live reads verified
tags: [bigin, mcp, zoho, integration, aspen, gilligan]
applies: ["[[external-comms-contract]]", "[[agent-comms-security-policy]]"]
links: ["[[bigin-api-capabilities]]", "[[aspen-cockpit-to-bigin-push]]"]
updated: 2026-08-06
---

# Bigin ↔ Gilligan via Zoho MCP

**Goal (Skipper 2026-08-06):** bring the **Zoho MCP server for Bigin** online so Gilligan (and later Aspen) can act on Bigin through native MCP tools instead of the hand-rolled OAuth token. Cleaner, officially supported, permission-scoped per tool.

## ✅ LIVE 2026-08-06 — verified end-to-end
- Server `bigin-gilligan` wired into OpenClaw `mcp.servers` (config patched backup-first: `openclaw.json.bak-premcp-20260806045837`). `transport: streamable-http`, `auth: oauth`, all 69 tools selected (`toolFilter.include *`).
- OAuth completed via `openclaw mcp login` (manual PKCE: Skipper approved in browser → copied `code=` from the failed 127.0.0.1:8989 redirect → `--code`). Tokens stored `~/.openclaw/mcp-oauth/bigin-gilligan-*.json`. Server URL secret at `~/.secrets/bigin-mcp.json`.
- `openclaw mcp probe` → **69 tools + resources**. Live read PROVEN: `Bigin_recordsCount` Pipelines = **1,340 deals**; `Bigin_getRecords` returned real cards (Lale forest woods / Indian hill @ Garretts new Pipeline, Proposal Sent).
- **Scope granted (Skipper 2026-08-06, "trusted, everything except send email"):** full read+WRITE+DELETE across modules/notes/tags/users, bulk, notifications, COQL, layouts, ownership change. **NO send-mail scope.** ⚠️ Broad — Gilligan self-guardrail: read/query/draft freely, but NO create/move/delete on live CRM without asking first.
- **Tool arg shape (Zoho MCP quirk):** args nest under `path_variables` + `query_params`, e.g. `Bigin_getRecords` needs `{path_variables:{module_api_name:'Pipelines'}, query_params:{fields:'...',per_page:N}}`. OpenClaw's runtime maps this; raw JSON-RPC callers must nest.
- **69 tool names** incl: getRecords, searchRecords, getRecordsUsingCoqlQuery, recordsCount, addRecords, updateRecords, upsertRecords, deleteRecords, changeRecordOwner, add/getNotes, tags CRUD, enable/disableNotifications (webhooks), getLayoutsMetadata, getFieldsMetadata, bulk read/write, users CRUD, getSpecificRecord, getRelatedListRecords.

## How it works (verified from Zoho + OpenClaw docs 2026-08-06)
- Zoho hosts a **remote MCP server**. You create one in the **Zoho MCP console** (`zoho.com/mcp`), add the **Bigin tools** you want it to expose, and it generates a **Server URL**:
  `https://[server-name]-[org-id].zohomcp.com/mcp/[api-key]/message`
- The Server URL = **password-equivalent** (anyone with it can use the enabled tools). Store as secret, never commit. Regenerate the api-key if exposed.
- **OpenClaw is an MCP client** → wire the URL under `mcp.servers` (`openclaw mcp add`). Then Gilligan's runtime discovers the Bigin tools and can call them. Config: `transport: streamable-http`, optional `auth: oauth` + `openclaw mcp login <name>`, `toolFilter` to whitelist tool names.

## DIVISION OF LABOR
- **Phase A — Skipper (UI-only, ~5 min, his Zoho admin login):**
  1. Go to `zoho.com/mcp` → log in → **Create MCP server** (name e.g. `bigin-gilligan`).
  2. **Add Tools** → search **Bigin** → **enable READ-only tools first** (get/list Contacts, Companies, Pipelines/deals, reports/analytics). **Do NOT enable any send-email / create / update / delete tools yet** (least-privilege + owner comms policy).
  3. **Connect** tab → copy the **Server URL** → paste it to Gilligan privately.
- **Phase B — Gilligan (once URL arrives):**
  1. `openclaw mcp add bigin-gilligan --url <ServerURL> --transport streamable-http` (store URL via secretref, not plaintext in config).
  2. `openclaw mcp probe bigin-gilligan` → confirm live connection + tool list. If it demands OAuth, `openclaw mcp login bigin-gilligan`.
  3. `toolFilter.include` = the read-only tool names as a belt-and-suspenders guard.
  4. Verify a read (e.g. list a few deals) → report.

## SECURITY (owner-set, non-negotiable)
- **Read-only to start.** No tool that can send email or mutate/delete records until the Skipper explicitly widens scope. This preserves the outbound-email = draft-then-approve rule ([[external-comms-contract]]).
- Server URL is a credential → secretref/`.secrets`, never in the workspace repo, never in shared/team contexts.
- Every MCP action runs through the Bigin API → subject to its permissions, credit limits, and audit log.

## Notes
- Existing hand-rolled token (`~/.secrets/bigin-oauth.json`) stays as the low-level fallback for scripted reads; MCP becomes the primary path once verified.
- claude.ai "Connectors" flow is a DIFFERENT client (not our path) — we connect through OpenClaw's `mcp.servers`.
