# 2026-07-31 — claude-local transport BUILD (Skipper chose Option A)

**Goal:** make Claude Gilligan-on-Hermes's MAIN brain, on the Max subscription, with tools, **zero metered cost** — by routing inference through the official `claude` CLI subprocess (which Anthropic keeps in the Max lane) instead of Hermes's direct `/v1/messages` call (which 400s the instant `tools` are attached).

## ✅ PROVEN THIS SESSION (feasibility locked)
- Driving `claude -p` on the sub **works with tools**: forced a real Bash tool call → `TOOLS_WORK_ON_SUB`, exit 0. This is the exact tools-carrying shape that 400s on the direct API. **Subprocess path dodges the wall.**
- **Long-lived token minted (valid 1 YEAR):** `claude setup-token` → stored at `~/.secrets-gilligan-hermes/claude-code-oauth.env` (chmod 600, var `CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-…`). Ideal for an adapter — no 30h refresh dance. NOT echoed in chat.
- `rate_limit_event` in stream-json confirms: `status:"allowed"`, `isUsingOverage:false` even though `overageDisabledReason:"org_level_disabled"` — i.e. served from Max lane.

## ❌ SHORTCUTS RULED OUT (all tested)
- **`hermes proxy`** — upstreams are only `nous` + `xai`. No Anthropic. Dead.
- **`claude-code` provider id** — only *surfaces the CLI token* into the SAME direct-API OAuth path that 400s. Credential source, not a CLI engine. Dead.
- **ACP as main brain** — `hermes acp` serves Hermes OUT to IDEs (wrong direction); only ACP *client* Hermes ships drives **Copilot**, not Claude.
- **Live middle option (NOT chosen):** `delegate_task acp_command:'claude'` spawns Claude as a delegation CHILD (works, but main brain stays gbt). Skipper chose A instead.

## 🏗️ ARCHITECTURE DECISION — SHIM, not core-patch
- Subprocess providers (copilot-acp, codex) are **woven into `run_agent.py`** with custom `api_mode` handling — NOT clean plugins. Patching core = image rebuild + redo on every Hermes update. Fragile, against the "escape instability" goal.
- **CHOSEN: build a local OpenAI-compatible shim server** backed by the `claude` CLI. Gilligan points at it via Hermes's **custom endpoint** (`model.base_url` + `model.api_key` — already supported, uses the standard `chat_completions` transport). **No core patch, no image rebuild, isolated to gilligan, survives Hermes updates.** It's `hermes proxy` but claude-CLI-backed.

## 🔌 claude CLI stream-json CONTRACT (captured from real runs)
- Invoke: `claude -p "<prompt>" --output-format stream-json --verbose --model <m>` (add `--input-format stream-json` for bidirectional).
- Env: `CLAUDE_CODE_OAUTH_TOKEN` from the secrets file.
- **Output events (one JSON object per line):**
  - `system/init` — lists Claude Code's native tools (Task, Bash, Read, Write, Edit, Grep, WebFetch…), `mcp_servers` (empty unless `--mcp-config`), model, session_id.
  - `rate_limit_event` — `rate_limit_info.status`, `isUsingOverage`, etc.
  - `assistant` — `message.content[]` = array of `{type:"text",text}` and (when tools used) `{type:"tool_use",id,name,input}` blocks; `message.usage` (input/output/cache tokens); `stop_reason`.
  - `result` — final `result` text, `stop_reason` (end_turn/tool_use), `usage`, `total_cost_usd`, `modelUsage`.
- **Input (stream-json):** newline-delimited `{"type":"user","message":{"role":"user","content":[...]}}` objects.

## ⚠️ THE HARD DESIGN FORK (unresolved — decide before coding the tool path)
When you drive `claude -p`, **Claude Code is a FULL AGENT that executes its OWN tools** (Bash/Read/Write…). To make it Gilligan's brain using **Hermes's** toolset + guards, two models:
- **Model 1 — raw-LLM shim (Hermes stays the agent loop):** suppress Claude's native tools, expose Hermes's tools to Claude via `--mcp-config` → `hermes_tools_mcp_server.py` (EXISTS in agent/transports/). Translate stream-json `tool_use` ↔ OpenAI `tool_calls`. This is the **codex_app_server pattern** (the reference to copy). Cleanest fit with Hermes identity/memory/compression, but most translation code.
- **Model 2 — Claude Code IS the agent:** let it run its own loop; feed SOUL+context via `--append-system-prompt`, Hermes tools via `--mcp-config`, restrict `--allowedTools` to the mcp ones. Simpler wiring, but Hermes's outer loop (memory injection, session mgmt) is bypassed — Claude Code's own session/memory runs.
- **Leaning Model 1** (keeps Gilligan = Hermes with its guards, Claude as the pure brain). Reference: `agent/transports/codex_app_server_session.py` (55KB) + `hermes_tools_mcp_server.py`.

## ✅ DECISION: MODEL 1 (Skipper, 2026-07-31 19:36) + MECHANISM PROVEN
**Model 1 = Hermes stays the agent loop; Claude is the pure brain that EMITS tool calls; Hermes executes them with its own tools/guards.** (Not Model 2 — we keep Hermes's agent-layer: orchestration, auto-skills, memory. That's what the migration is FOR.)

**Decisive experiment PASSED:** ran `claude -p ... --output-format stream-json --allowedTools Read`, and confirmed the `tool_use` block is emitted as a discrete, capturable stream-json event **before** execution:
`assistant` event → `content[]` block `{type:"tool_use", id:"toolu_...", name:"Read", input:{...}}`. Tool RESULT comes back as a `user` event with a `tool_result` block (`tool_use_id` + content). So I can intercept the tool_use, hand it to Hermes, and feed the result back.

### PROVEN BUILD DESIGN (Model 1a — stateless, capture-and-hand-back; matches Hermes's loop)
Each Hermes turn = one fresh `claude -p` invocation (multi-turn history re-sent flattened; cache makes it cheap — saw cache_read 16.8k tokens):
1. Hermes → shim with `messages` + `tools` (OpenAI format).
2. Shim exposes those tool **schemas** to Claude via an **MCP server it hosts** (names + input_schema from the OpenAI tools), launch `claude --mcp-config <that> --allowedTools "mcp__<srv>__*"` (ONLY mcp tools — Claude's native Bash/Read/etc. disabled so it can't self-execute Hermes's domain).
3. Monitor stream-json:
   - `text` blocks → accumulate as assistant content.
   - `tool_use` for an mcp tool → **capture {id,name,input}, TERMINATE claude, return to Hermes as OpenAI `tool_calls` with `finish_reason:"tool_calls"`.** (The MCP round-trip never completes — that's how we stop Claude executing.)
   - `result` with no tool_use → return as final assistant text, `finish_reason:"stop"`.
4. Hermes executes the tool with ITS tools + guards → appends `tool` result msg → calls shim again.
5. Shim flattens the updated history (incl. the tool result) into the next `claude -p` → Claude continues. Repeat until final text.

**All unknowns now retired:** pipe works ✓ · tools work on sub ✓ · tool_use capturable from stream-json ✓. Remaining = code (MCP schema server + tool_use↔tool_calls translation + history flattening w/ tool results), no more unknowns.

### ⚠️ Open impl details to settle while coding
- MCP transport for schemas: stdio vs HTTP `--mcp-config`. Verify the `--mcp-config` JSON shape claude expects; confirm `--allowedTools` pattern for mcp tools (`mcp__<server>__<tool>`).
- Tool-name mapping: Hermes tool `foo` → mcp name `mcp__hermes__foo` and back.
- Capture-and-kill timing: read the `assistant` tool_use event, then kill before the MCP call resolves; make the hosted MCP tool handler block/never-return so Claude can't proceed even if not killed instantly.
- Multi tool_use in one assistant turn (parallel calls): capture ALL tool_use blocks in the event, return as multiple tool_calls.
- History flattening must render prior `tool` results so Claude sees them (v1 shim already has a `[tool result]` branch — extend it).

## 🏗️ BUILD STATUS (2026-07-31 ~19:50) — SHIM BUILT, tools hit an MCP-timing race
**Files (all on host):** `~/gilligan-hermes/claude-shim/` — `server.py` (OpenAI-compat shim + Model-1 capture), `mcp_tools_server.py` (stdio MCP schema server), `run-shim.sh` (sources token, launches). Shim runs on host `127.0.0.1:8828`; gilligan container (network_mode:host) can reach it.
- ✅ **Pipe (no tools): WORKS** — `curl /v1/chat/completions` → Claude → OpenAI response. Proven `PIPE_OK.`
- ✅ **MCP wiring proven** — stdio server registers, Claude calls `mcp__hermes__<tool>`, capture-from-stream-json works. Naming: `mcp__hermes__<name>`; strip prefix on hand-back.
- ✅ **allowedTools semantics learned:** must include `ToolSearch` in `--allowedTools` (it's Claude's tool-DISCOVERY mechanism; without it Claude can't reach the mcp tools and narrates `<tool_use>` as prose). `--disallowedTools <natives>` is fine (RUN B worked with it). Only capture `mcp__hermes__*`; let ToolSearch run internally.
- ⚠️ **THE REMAINING BUG — MCP stdio connection RACE (non-deterministic):** `claude -p` spawns a FRESH stdio MCP server every call; it shows `status:"pending"` at init. Sometimes Claude persists (retries ToolSearch until it connects, then calls the tool → RUN A/B worked) and sometimes it gives up fast, says "the hermes MCP server is still connecting," and returns a text narration with `finish_reason:stop` (shim test failed twice this way). Flaky = unusable as-is.
- ⚠️ Note: `mcp_tools_server.py` `tools/call` sleeps 30s then returns `__HERMES_PENDING__`. Irrelevant to capture (we kill on the tool_use stream event, before the call result), but may worsen Claude's "pending" perception — revisit.

### 🔬 ROOT CAUSE NAILED (20:08) — it's a COLD-START spawn race, measured
- Ran the EXACT shim invocation manually 3× with MCP_TIMEOUT=20000: **2/3 called the tool, 1/3 raced** → genuinely flaky ~33%, NOT a shim bug. Earlier "4/4 manual" was luck on the good side; shim "0/3" luck on the bad side.
- Shim retry-loop test (4 attempts, caching-cheap): **Test1 = 4/4 attempts RACED (exhausted), Test2 = 4/4 RACED, Test3 = recovered on attempt 2.** Failing attempts were only **~4–5s apart** → claude is NOT waiting the 20s MCP_TIMEOUT; it gives up fast. First ~40s after shim start everything raced, then it started working = **classic COLD-START**: first fresh `python3 mcp_tools_server.py` spawns are slow (cold interpreter), lose the race; once OS page-cache warms, spawns win. `MCP_TIMEOUT`/`MCP_TOOL_TIMEOUT` do NOT make it deterministic.
- Retry band-aid is IN the shim (`_run_claude_turn_with_retry`, detects the narrate-instead-of-call signature via `_MCP_RACE_RE`, 4 attempts) — helps after warmup but the first few calls after a shim (re)start still exhaust. **Not production-grade alone.**

### ▶️ THE REAL FIX (building next) — ALWAYS-ON MCP server, kill the per-call spawn
**Decision: co-host an always-on MCP server in the shim and have claude connect over HTTP** (`claude mcp add --transport http` shape / mcp-config `{"type":"http","url":...}`). No per-call python spawn → no cold start → no race. Server is live before any claude call, connection is a localhost HTTP handshake (near-instant, reliable). Needs MCP **Streamable-HTTP** transport in stdlib: POST JSON-RPC in, JSON or SSE out, `Mcp-Session-Id` header session mgmt. The schema still comes from the OpenAI `tools` of each request — so the HTTP MCP server must serve the CURRENT request's tool set (keyed per request/session). Keep the retry loop as belt-and-suspenders.
Alt if HTTP-MCP proves fiddly: persistent `claude` stream-json INPUT session (connect MCP once, reuse) — the codex_app_server_session.py pattern; more lifecycle code.

### ▶️ OLD FIX NOTES (superseded by the above)
Two robust options, pick one:
1. **Always-on HTTP MCP server** co-hosted in the shim (fixed port), so it's ALREADY connected when claude starts — no per-call spawn, no `pending`. Cost: implement MCP Streamable-HTTP transport (POST JSON-RPC + SSE) vs the easy stdio. **Leaning this.**
2. **Persistent `claude` session** (stream-json INPUT mode, one long-lived process) so the MCP server connects ONCE and stays. This is the `codex_app_server_session.py` pattern (why Hermes keeps Codex persistent). More lifecycle/concurrency code.
- Interim cheap try: nudge patience — stronger system-prompt instruction to "retry tool discovery until available," and/or make `tools/call` return instantly (not sleep) so tool calls don't look like they're failing. May reduce flakiness but not a real fix.

## ⏭️ BUILD PLAN (resume here)
1. **Pipe first (no tools):** write shim `~/gilligan-hermes/claude-shim/server.py` — OpenAI `/v1/chat/completions` in → `claude -p --output-format stream-json` → stream OpenAI SSE back. Prove Gilligan replies on the Claude brain end-to-end (custom endpoint in config.yaml). De-risks the whole pipe.
2. **Tools (Model 1):** launch claude with `--mcp-config` → hermes_tools_mcp_server; map `tool_use`↔`tool_calls`; restrict `--allowedTools` to mcp_*. Test a tools-carrying turn.
3. Wire gilligan config: `model.provider=custom`, `base_url=http://127.0.0.1:<port>/v1`, `model.default=claude-opus-4-8`. Backup config first.
4. Run shim as its own service (systemd --user or a container sidecar); keep it isolated to gilligan.
5. Test: basic reply → tools turn → over Telegram. Keep gbt as fallback in the chain.
6. Persist + document; update `wiki/projects/gilligan-hermes-migration.md`.

## KEY PATHS/FACTS
- Host `claude` CLI: v2.1.161, on PATH. Token: `~/.secrets-gilligan-hermes/claude-code-oauth.env`.
- gilligan container on `hermes-agent:v2026.7.30`; anthropic-oauth-2 cred exists but its DIRECT inference is 400-walled (leave gbt active until shim works).
- Hermes worktree (for reading reference code): `~/hermes-build-v2026.7.30`. Reference files: `agent/transports/base.py`, `codex_app_server_session.py`, `hermes_tools_mcp_server.py`, `plugins/model-providers/copilot-acp/`.
- ⚠️ `claude -p` runs in whatever cwd → it can spawn its own tools; must sandbox/limit when used as pure brain.
- Self-kill bug: never `pkill -f "<pattern that matches own cmdline>"`. Tripped it once this session.
