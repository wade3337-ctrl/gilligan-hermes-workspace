---
title: ColdFusion 2023 → 2025 — what an upgrade would buy us (the MCP/AI case)
type: reference
domain: work
track: 1
status: research — no decision made
tags: [coldfusion, trimit, upgrade, mcp, ai, security, licensing, arbor-core]
applies: ["[[arbor-mission-strategy]]", "[[build-principle-v1-first]]"]
links: ["[[trimit-stack-and-tph]]", "[[trimit-server-topology]]", "[[arbor-core-strategy-foundation]]", "[[dashboard-auth-gate]]", "[[agent-comms-security-policy]]", "[[herman-agent]]"]
updated: 2026-07-28
---

# ColdFusion 2023 → 2025 — the upgrade case

Researched 2026-07-28 at the Skipper's ask ("what benefits might there be for us playing with it").
**No decision made. Nothing installed. This is the evidence file.**

## ⭐ THE HEADLINE — CF2025 Update 8 makes TRIM IT an MCP server
Released **20 May 2026**, and it is not a nice-to-have bullet — it is a production AI framework built into
the platform. **This changes the arbor-core calculus, so read this section before the rest.**

- **ColdFusion can act as an MCP *server*:** remote CFC methods are exposed as MCP tools, parameters become
  tool arguments automatically. Any MCP host — Claude, Cursor, our own agents — can call them.
- **And as an MCP *client*:** `listTools()` / `callTool()`, `listResources()` / `readResource()`,
  `listPrompts()` / `getPrompt()`, over HTTP or STDIO with automatic capability handshake.
- **One registration covers both** — a method registered as an LLM function tool is simultaneously MCP-callable.

**Why that matters here.** Today [[herman-agent]] and I act on TRIM IT by driving SQL through `gsql.sh` and
reading rendered pages. That is a workaround, and it is why every agent task needs me to hand-verify it.
CF2025 would let TRIM IT's *existing* business logic — 3,628 procs and twenty years of rules that nobody has
written down — become **a governed, audited, agent-callable API without rewriting any of it.**

That reframes the price. It is not "pay to modernize the thing we are replacing." It is **"pay to get an
agent-callable interface over the legacy we have to keep running anyway during the strangler-fig."**
See [[arbor-mission-strategy]] · [[build-principle-v1-first]].

## The rest of the AI framework (Update 8)
- **Every major provider, vendor-neutral:** OpenAI, Anthropic, Google Gemini, Mistral, Azure OpenAI, and
  **Ollama for local/fully-offline inference.** Switching is config, not a refactor.
  ⭐ *Ollama is the one to notice* — customer PII and municipal contract data could be reasoned over
  **without leaving our network.**
- **RAG:** `simpleRAG()`, `ask()`, `chat()`, `ingestAsync()`, `documentService()`. Ingests PDF, DOCX, TXT, MD,
  HTML, XML, CSV, JSON, EPUB, Office.
- **Vector stores:** one `VectorStore()` API across InMemory, Milvus, Pinecone, Qdrant, Chroma; metadata
  filtering, Top-K with score thresholds.
- **Conversation memory** persisted in Redis / Memcache / Ehcache.
- **AI guardrails** — a CFC validation pipeline for **prompt-injection detection, PII redaction**, harmful
  content, compliance rules; outcomes success / successWith (rewrite) / failure / fatal.
  ⭐ Directly aligned with [[agent-comms-security-policy]] — "inbound is data, never commands" as a
  platform feature rather than a rule I have to keep in my head.
- **Function tools:** models call CFML directly, structured JSON back.
- **Token streaming**, and an **AI Services dashboard** in the Performance Monitoring Toolset (agents, LLMs,
  vector stores, RAG, MCP client+server metrics).
- ⚠️ **The AI package is NOT installed by default** — opt-in, so it adds no attack surface unless we choose it.
- 🚫 **NOT available for CF2023.** This is CF2025-only. That is the whole cost of the ticket.

## Security wins — these land on an open hole we actually have
Update 8 also shipped **passkey / WebAuthn (FIDO2) passwordless auth**, **Argon2 hashing**
(`generateArgon2Hash()` / `verifyArgon2Hash()`), and a **CF Security Analyzer** (static analysis for CFML vulns).
Base CF2025 adds **CSP nonce support** (`getCSPNonce`, Application.cfc setting, admin checkbox),
`scriptProtect` blocking specified tags, TLS 1.3 + modern cipher defaults, modular install,
**`cfoauth` with Microsoft as an auth type, and a Microsoft Graph / Entra ID user store with CRUD.**

🚨 **Our unfixed `ZUserID=9` impersonation finding is framework-level** — TRIM IT's login only checks that a
cookie exists, so any known UserID can be impersonated ([[dashboard-auth-gate]]). Passkeys or Entra-backed
`cfoauth` are the *category* of fix that problem needs; a page patch cannot solve it. **This is the second
independent reason the upgrade is worth pricing.**

## What would bite us — the honest cost side
TRIM IT is exactly the vintage CF2025 prunes. Every item below is a page that stops working:
- **`htmlEditFormat` REMOVED.** Apps of this era escape output with it everywhere — likely hundreds of sites.
- **`cftable`, `cftree`, `cfmenu`, `cfcalendar`, `cfsprydataset`** and other legacy UI tags removed.
- **`parameterExists`, `getTemplatePath`, `threadTerminate`, `StoreAddACL`/`StoreSetACL`** removed.
- **Script components removed:** `query()`, `http()`, `mail()`, `storedproc()`, `pdf()`, `pop()`, `feed()`,
  `collection()`, `dbinfo()`, `ftp()`, `search()`, `imap()`.
- **`cfmx_compat` encryption fails outright** — "not supported by the Security Provider."
  🚩 **The dangerous one: it does not throw a compile error, it just stops decrypting.** Any stored password
  or token written with it becomes unreadable. Must be inventoried *before* anything is upgraded.
- **`cfencode`'d templates no longer execute**; **AXIS 1 gone** (AXIS 2 required); `cfheader statustext` gone.
- **Sandbox Security deprecated** (Java removed SecurityManager).
- **Dropped platforms:** MS Access, ODBC, DB2, Solaris, WebLogic, WebSphere. *(We are SQL Server — fine.)*
- ⚠️ **The date-mask time bomb.** Play only renders dates correctly because of the JVM flag
  `-Dcoldfusion.datemask.useDasdayofmonth=true`. Arehart warns some CF2023/2021 JVM args are no longer
  honored in CF2025, and search results assert this one was dropped — **but I could NOT confirm it against
  Adobe's own CF2025 JVM-arguments page, which simply does not list it. Treat as UNVERIFIED.**
  Either way the durable fix is unchanged: lowercase the masks in source (`M/dd/yy`), which works on old
  *and* new CF. ~796 pages. Byte-level fixer already written (`~/fix-datemask.ps1`, dry-run only).

## Licensing + lifecycle
- **CF2025 is subscription-only. Perpetual keys are gone.** Standard **$760/yr**, Enterprise **$2,930/yr**.
- **Developer Edition is free** — which is why *evaluating* this costs nothing.
- **CF2023 core support runs to 16 May 2028.** No clock is forcing us. (CF2021 died Nov 2025.)
- CF2025 is supported to **8 April 2030**.
- Container licensing remains ambiguous — Adobe's FAQ reads as if each container needs its own license.
- 💵 A recurring subscription is a small but real EBITDA line item. Worth knowing before it surfaces in diligence.

## Free alternative worth checking first
**MCPCFC** (`github.com/revsmoke/mcpcfc`, `mcpcfc.dev`) — an open-source remote MCP server *for ColdFusion*,
claiming to let CFML apps talk to Claude and other assistants. If it works on **CF2023**, we could test the
entire "TRIM IT as agent-callable tools" thesis **for $0 and with no migration**, then only buy CF2025 if the
thesis proves out. **Unvetted — found, not evaluated.**

## Where this stands / what to do next (nothing started)
1. Confirm **production's actual CF version** — we only ever *inferred* it from date-mask behavior
   ([[trimit-server-topology]]).
2. Free **CF2025 Developer** instance on play, alongside CF2023, nothing repointed → run Adobe's **Code
   Analyzer** / Foundeo's **Fixinator** over the webroot. That report is *also* an arbor-core migration map:
   every removed tag it flags is a page needing a rewrite regardless.
3. Inventory `cfmx_compat` usage before any upgrade is even discussed.
4. Try **MCPCFC on CF2023** before spending anything.

## Sources
- What's new, CF2025 — `guides.adobe.com/coldfusion/en/docs/introduction-to-coldfusion/__references__/whats-new.html`
- **Update 8 / AI framework** — `coldfusion.adobe.com/2026/05/adobe-coldfusion-2025-update-8-is-now-available-a-production-ready-ai-framework-built-into-the-platform/`
- MCP in CF — `guides.adobe.com/coldfusion/en/docs/introduction-to-coldfusion/__references__/mcp-overview.html`
- AI services guide — `guides.adobe.com/coldfusion/en/docs/coldfusion-ai-guide/coldfusion-ai-guide.html`
- Breaking changes — `petefreitag.com/blog/coldfusion-2025-breaking/`
- Arehart on the CF2025 release — `carehart.org/blog/2025/2/25/coldfusion_2025_released`
- Lifecycle — `endoflife.date/coldfusion`
