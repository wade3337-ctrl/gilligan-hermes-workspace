---
title: MCPCFC — the open-source ColdFusion MCP server (evaluated at source level)
type: reference
domain: work
track: 1
status: evaluated — not installed, no decision
tags: [mcp, coldfusion, trimit, agents, open-source, security, arbor-core]
applies: ["[[arbor-mission-strategy]]", "[[build-principle-v1-first]]", "[[agent-comms-security-policy]]"]
links: ["[[coldfusion-2025-upgrade-case]]", "[[trimit-stack-and-tph]]", "[[herman-agent]]", "[[dashboard-auth-gate]]", "[[only-trustworthy-data]]"]
updated: 2026-07-28
---

# MCPCFC — open-source MCP server for ColdFusion

`github.com/revsmoke/mcpcfc` · `mcpcfc.dev` · **MIT license**.
Evaluated 2026-07-28 by **cloning and reading the source**, not from its README. Nothing installed.

## What it is
A Model Context Protocol server written in pure CFML. It lets an MCP host (Claude, Cursor, our own agents)
discover and call ColdFusion code as tools. **The point for us: it does this on the ColdFusion we already
own — no CF2025 license, no migration.** It is the free "try" against Adobe's paid "buy"
([[coldfusion-2025-upgrade-case]]).

## Measured facts (from the repo, not the marketing)
- **~6,082 lines of CFML total.** Split: **~3,069 lines of protocol core** (`MCPServer` · `JSONRPCHandler` ·
  `TransportManager` · `CapabilityManager` · the three registries · `SessionManager` · `AbstractTool` ·
  `Application.cfc` · `endpoints/mcp.cfm`) and **~1,253 lines of demo tools we would delete.**
- **MCP protocol `2025-06-18`**, with a real method surface: `initialize`, `tools/list`, `tools/call`,
  `resources/list`, `resources/read`, `prompts/list`, `prompts/get`, `ping`, `completion/complete`, plus
  `notifications/{initialized,progress,cancelled}`.
- **Transport:** Streamable HTTP (POST only — *no SSE implemented*), plus a stdio bridge script
  (`cf-mcp-bridge.sh`) for Claude Desktop.
- **Tool pattern:** a `.cfc` extending `AbstractTool` — set name/title/description, a JSON-Schema input
  schema, and an `execute()`. Register by adding the class to an array in `registerDefaultTools()`.
  Helpers given: `textResult()`, `jsonResult()`, `errorResult()`, `validateRequired()`, `logExecution()`.
- **Maturity: thin.** Single contributor, ~14 stars, **last commit 2026-02-06 — quiet ~5½ months.**
  Tested only on **macOS + Adobe CF2025**. Windows, Linux, Lucee and BoxLang all untested.

## ✅ It does NOT require CF2025 — checked, not assumed
Grepped the whole codebase for CF2025-only syntax and BIFs: **zero hits** for `??`, destructuring,
compound assignment, `structValueArray`, `getCSPNonce`, `interruptThread`, `CSVRead/Write/Process`,
`listGetDuplicates`, `generateArgon2Hash`. What it actually uses — `?:` elvis (CF11+), `queryExecute`,
`structNew("ordered")`, script components, `cfthread`, `cfhttp` — is all **CF2016+**.
**So CF2023 compatibility is likely and cheap to prove.** "Tested on CF2025" is the author's environment,
not a requirement.

## 🚨 Do NOT ship its bundled tools — all six are proof-of-concept
`hello` · `fileOperations` (sandboxed file I/O) · `httpRequest` (outbound HTTP) · `pdf` · `queryDatabase`
(raw SELECT) · `sendEmail` (SendGrid).
- **`sendEmail` is disqualifying on contact.** An agent-callable outbound email tool drives straight through
  the express-per-message approval rule → [[agent-comms-security-policy]]. Delete it, do not configure it.
- **There is no authentication in the server at all**, and CORS defaults to `*`. Its own docs say do not
  expose publicly without auth, CORS, rate limiting and per-tool authorization. **Localhost / stdio only.**

### ⚠️ Its SQL "safety" gate is a denylist, and I proved it fails both ways
`SQLValidator.cfc` regex-scans the query text. I re-implemented its exact rules and ran realistic TRIM IT SQL:

| Query | Verdict |
|---|---|
| `SELECT CAST(ProjectID AS VARCHAR(20)) …` | **REJECTED** — pattern `CHAR\s*\(` matches inside **VAR**CHAR |
| `SELECT CONVERT(CHAR(10), DateCompleted, 101) …` | **REJECTED** — same |
| `SELECT Resp_Party FROM Contacts` | **REJECTED** — pattern `sp_` matches the *substring* in `Re`**sp_**`Party` |
| `… WHERE Notes LIKE '%delete%'` | **REJECTED** — the word "delete" in *data* |
| `SELECT … FROM CrewSheets WITH (NOLOCK)` | allowed |
| our real TPH query | allowed |
| `SELECT * FROM Users; DROP TABLE Users` | rejected (correctly) |

**It blocks ordinary reporting SQL while giving only regex-deep protection.** The correct control is the one
we already have: **enforce read-only at the database login (`GSTSREADONLY`), not with a regex over SQL text.**
Generalized rule → LESSONS. If we adopt this, the DB tool gets rewritten against a read-only DSN with
allow-listed, parameterized queries — never free-form SQL from a model.

## How it applies to our work NOW
- **It replaces a workaround.** Today [[herman-agent]] and I act on TRIM IT by driving SQL through `gsql.sh`
  and reading rendered pages — which is why every agent task needs hand-verification. Declared tools with
  JSON-Schema inputs and `logExecution()` on every call give us **typed inputs and an audit trail we do not
  currently have for agent actions.**
- **Cost of exposing one capability ≈ a 50-line CFC**, not a project.
- **It is 3,000 lines and MIT** — small enough to read end to end and fork. Given a single quiet maintainer,
  **assume we fork and own it**; at this size that is realistic, not scary.

## How it applies GOING FORWARD — the strategic bit
- **It de-risks the CF2025 decision.** Adobe native MCP = the buy ($760–$2,930/yr **plus** the whole
  breaking-change migration). MCPCFC = the try ($0, no migration). Test the actual thesis — *is TRIM IT's
  business logic worth exposing as agent tools?* — **before** spending anything, then buy with evidence.
- ⭐ **The tool contracts are the durable asset, not the server.** Define TRIM IT capabilities as MCP tools
  now, and arbor-core can later implement **the same tool contracts** natively — agents keep calling the same
  names, the backend swaps underneath. **That is the strangler-fig seam expressed as a protocol**, and it is
  exactly [[build-principle-v1-first]]: prove the model in TRIM IT V1, then the proven model becomes the
  arbor-core framework.

## If we ever stand it up — the conditions
1. Play box only, **outside the webroot**, bound to localhost / stdio bridge. Never a public path.
2. Delete all six demo tools first — especially `sendEmail`.
3. DB tool rewritten against `GSTSREADONLY` with allow-listed parameterized queries, not model-authored SQL.
4. Prove CF2023 compatibility (expected to pass — see above).
5. Whatever it returns is still subject to [[only-trustworthy-data]] before it reaches anyone.

## Sources
- Source read at commit `526a3c9` (2026-02-06), cloned to `/tmp/mcpcfc` — `github.com/revsmoke/mcpcfc`
- `mcpcfc.dev`
