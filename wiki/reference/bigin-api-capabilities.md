---
title: Bigin API v2 — full capability reference (what we can/can't do)
type: reference
domain: work
track: 1
tags: [bigin, api, crm, reference, aspen]
applies: ["[[external-comms-contract]]"]
links: ["[[aspen-cockpit-to-bigin-push]]"]
source: https://www.bigin.com/developer/docs/apis/v2/ (read 2026-08-06) + live probes on our org
updated: 2026-08-06
---

# Bigin API v2 — capability reference

Read end-to-end 2026-08-06 (Skipper asked "learn everything the API can do" before we build). Verified key facts against our LIVE org with the saved OAuth token. Auth scope we hold = `ZohoBigin.modules.ALL settings.ALL users.READ` (admin).

## 0) The data model (CONFIRMED LIVE — architecture-critical)
Bigin's deals live in the **`Pipelines` module**. Each deal record carries a **3-level hierarchy**:
- **`Pipeline`** (data_type `bigint`, = a "Team Pipeline") — one per *layout*. e.g. `Garretts new Pipeline`, `Ethan Pipeline`, `Chad Pipeline`.
- **`Sub_Pipeline`** (data_type `picklist`) — a lightweight container INSIDE a Team Pipeline. Today every rep pipeline has ONE default sub, e.g. `Garretts new Pipeline Standard`. A Team Pipeline can hold MULTIPLE sub-pipelines, each with its own Stage set.
- **`Stage`** (picklist) — e.g. `Proposal Sent`, `Go Ahead`.
- **`Deal_Name` + `Sub_Pipeline` + `Stage` are the 3 system-mandatory fields** to create a deal.

➡️ **This gives us TWO ways to build the Aspen feed** (decide with Nate):
- **Model A (separate Team Pipelines):** Aspen = its own Team Pipeline(s); "rep pulls a card" = move the record to the rep's Team Pipeline. Heavier, cleanest isolation.
- **Model B (sub-pipeline inside each rep's pipeline):** Aspen feed = a NEW Sub-Pipeline inside the rep's existing Team Pipeline; "pull" = just flip the `Sub_Pipeline`/`Stage` picklist on the same record — no cross-pipeline move. Much lighter; card stays in the rep's board the whole time.

## 1) What the API CANNOT do (hard limits — verified/doc-confirmed)
- **Cannot CREATE Team Pipelines / layouts** (UI-only). API layout endpoints are READ-only. → the pipeline SHELLS must be made in the Bigin web UI (loop Nate). Sub-pipeline/stage picklist creation is also a UI/settings action.
- **Cannot create custom modules/fields** via this API surface (settings are mostly read + record CRUD).
- **COQL** = SELECT only (no INSERT/UPDATE via query); max 10,000 rows via paging, max 2 joins, 25 WHERE criteria; no multi-line/File/Tags/Notes/multiselect-lookup columns.
- **Modules NOT API-supported:** Documents, Projects, Social (read-only).

## 2) What the API CAN do (the useful surface)
### Records (module = Contacts · Accounts[=Companies] · Pipelines[=deals] · Products · Tasks · Events · Calls · Notes)
- **GET list** `GET /bigin/v2/{Module}?fields=a,b&per_page=200&page=N` — max 200/page; >2000 via `page_token`; `sort_by`,`sort_order`,`cvid`,`approved`.
- **GET one** `GET /bigin/v2/{Module}/{id}`
- **INSERT** `POST /bigin/v2/{Module}` — up to 100/call. `trigger:[]` suppresses workflows.
- **UPDATE** `PUT /bigin/v2/{Module}` (batch, each row needs `id`) or `PUT /{Module}/{id}` — up to 100/call.
- **UPSERT** `POST /bigin/v2/{Module}/upsert` — dedup via `duplicate_check_fields`; up to 100/call. ⭐ our idempotency lever.
- **DELETE** `DELETE /bigin/v2/{Module}?ids=a,b` or `/{Module}/{id}` — up to 100/call; `wf_trigger=false` to skip workflows.
- **SEARCH** `GET /bigin/v2/{Module}/search?criteria=((field:comparator:value)and(...))` — also `?email=` / `?phone=` / `?word=`. Needs extra scope `ZohoSearch.securesearch.READ`. Comparators: equals, not_equal, starts_with, in, greater/less_than, between.
- **COQL** `POST /bigin/v2/coql` body `{"select_query":"select ... from Pipelines where ... limit N"}` — SQL SELECT, dot-notation joins.

### Attach context to a deal (all supported)
- **Notes** `POST /bigin/v2/{Module}/{id}/Notes` (+ get/update/delete). → Aspen posting "why surfaced" context.
- **Tags** create/update/delete + add/remove on records (1 credit / 50 recs). → running-dry / re-sell flags.
- **Attachments** upload/download/delete; record photo upload/download/delete.
- **Tasks / Events / Calls** are full record modules → Aspen can create a "next action" task on a deal.
- **Related lists** get/update/delink; **Associated Products** link.

### Metadata (READ) — how we self-discover the org
- Modules list + per-module meta; **Fields meta** `GET /bigin/v2/settings/fields?module=X` (api_name, data_type, picklist values, mandatory/unique); **Layouts** `?module=X` (this is how we pulled every pipeline's stage list); custom views; related-list meta; roles; profiles; users (`GET /bigin/v2/users`); org.
- **Tags** list + record count per tag.

### Users (we hold READ only)
- `GET /bigin/v2/users` works. Add/Update/Delete user needs `users.ALL/CREATE/WRITE/DELETE` (we don't have write).

### Bulk (async, for big loads/backups)
- **Bulk Read** — POST job → callback/poll → download CSV/ICS ZIP. 50 credits/init. Good for full-book exports w/o burning per-call credits.
- **Bulk Write** — upload zipped CSV (≤25,000 recs) → insert/update/upsert job → poll → download result. 500 credits/init.

### Notifications (webhooks) — real-time, replaces polling
- `POST enable` a webhook channel on a module (channel id, notify URL, expiry, events) → Bigin POSTs us on record change. → **this is how a rep "pulling a card" or editing a deal notifies Aspen** instead of Aspen polling. Enable / get / update / disable endpoints.

## 3) Limits & cost (credit + concurrency model — NOT per-minute)
- **Credits/24h rolling:** Express/Zoho One/Bigin360 = 50,000 + (250 × user licenses), cap 100,000. Free = 5,000.
- **Credit cost:** most calls = 1 credit. **Insert/Update/Upsert = 1 credit per 10 records** (so a 100-record batch = 10 credits). Get-with-cvid = 3. Bulk Read init = 50, Bulk Write init = 500. Send Mail = 20.
- **Concurrency:** 10 simultaneous calls/user/app (Free=5). Sub-concurrency 10 for cvid/sort + large insert/update. No per-minute cap — throttle is concurrency-based.
- ➡️ For our scale (a few thousand deals) we are nowhere near limits. Batch writes in 100s + upsert = cheap. Use notifications instead of tight polling.

## 4) DC / host / auth (as wired on jdog1)
- **api_domain** `https://www.zohoapis.com` · **accounts_domain** `https://accounts.zoho.com` (US DC).
- Token refresh: `POST accounts/oauth/v2/token` (refresh_token grant) → access token ~1h.
- **Auth header:** `Authorization: Zoho-oauthtoken <access_token>`. ⚠️ Bigin returns a generic `400 INVALID_REQUEST "verify method/parameter"` when the header SCHEME is wrong (not a clear auth error) — see LESSON.
- Creds: `~/.secrets/bigin-oauth.json` (client_id/secret/refresh_token/api_domain/accounts_domain). End state = these move to Aspen's own runtime.

## 5) Working probe snippet
`/tmp/bigin_ok.js` pattern (kept): refresh token → `GET /bigin/v2/settings/fields?module=Pipelines` (field discovery) + `GET /bigin/v2/Pipelines?fields=Deal_Name,Stage,Pipeline,Sub_Pipeline,Owner&per_page=N` (sample deals). Reusable for read-only inspection.
