---
title: Gilligan voice platform — seamless voice + the real Gilligan brain (research + decision map)
type: project
domain: env
status: ✅ SOLVED 2026-08-01 — voice runs on the Hermes TELEGRAM bot (local whisper in · edge-TTS out). OpenJarvis path KILLED.
tags: [voice, gilligan, openjarvis, elevenlabs, claude-voice, chatgpt-voice, realtime, mcp, telegram]
links: ["[[gilligan-hermes-migration]]", "[[gilligan-pilot-model-setup]]", "[[claude-local-shim-spike]]", "[[moa-mixture-of-agents]]", "[[herman-agent]]"]
updated: 2026-08-01
---

# 🎙️ Gilligan voice platform — the map

## ✅ ANSWER (2026-08-01) — voice works, and it was one boolean in a config we already had
**Skipper, after a night of OpenJarvis fighting back:** *"this sucks. i give up. lets get rid of this whole
jarvis path… I was having better luck with voice through hermesagent."* He was right.

**The working setup = the Hermes Telegram bot `@Gilligan_gsts_bot`.** It was already ~90% configured in
`~/.gilligan-hermes/config.yaml`: **`stt: provider: local`** (local whisper — free, no key) and
**`tts: provider: edge`** (Microsoft edge-tts `GuyNeural` — free, no key). The **only** change required was
**`voice.auto_tts: false → true`** (line 363) so Gilligan replies *with voice*; backed up
(`config.yaml.bak-preautotts-*`) and restarted the container. Skipper confirmed: *"the voice works on telegram."*
- ⚠️ `auto_tts: true` speaks **every** reply, including typed ones. Offered to make it voice-back-only-on-
  voice-input if it gets noisy — **he hasn't asked yet**, so it stays as-is.
- ⭐ **The durable lesson:** a native app (Telegram) with a real mic and real audio playback beats a browser
  web UI — no `Permissions-Policy` header, no autoplay gate, no PWA service-worker cache, no CUDA. And read
  the config of a runtime you already operate **before** building an adapter for it.

### ⭐⭐ PROOF PASSED — the whole stack did real work, by voice (2026-08-01 ~03:56)
Skipper gave it a live proof task **by voice**: pull a real number from play and report it. **"he did it. he
reported the number accurately."** Voice in → local STT → gbt brain → `gsql.sh` live TRIM IT query → correct
number → edge-TTS voice out. First end-to-end validation that the Hermes/Telegram Gilligan can do the actual
work, not a canned demo — see [[gilligan-hermes-migration]] for the two enablers (live play DB + auto-current
wiki) that fired in the same task.

### 🪦 OpenJarvis — KILLED, code kept
Torn down, **nothing deleted**: `openjarvis-serve.service` + `gilligan-endpoint.service` stopped+disabled,
`tailscale serve --https=443 off`, port 8600 closed. Install still at `~/.openjarvis`, endpoint at
`~/gilligan-hermes/gilligan-endpoint/` if ever revisited (unlikely). What it cost, in order — each one a layer
that had to be beaten before the *next* one appeared:
1. **Mic "access denied" that was never a permission** — OpenJarvis's own middleware sends
   `permissions-policy: microphone=()` (empty allowlist) on every response, so the browser killed
   `getUserMedia` before OS/site permissions mattered; its `useSpeech.ts` then mislabelled the error. Nailed
   with `curl -sI` on the header. Patched to `microphone=(self)`.
2. **CUDA, twice** — faster-whisper (`libcublas.so.12` missing) then kokoro (`cudaErrorNoKernelImageForDevice`);
   jdog1's GTX 1050 Ti has no CUDA runtime and is too old for current torch kernels. Umbrella fix =
   `Environment=CUDA_VISIBLE_DEVICES=` on the unit, not per-library config.
3. **TTS wasn't shipped at all** — the serve API had only `/v1/speech/transcribe`; the "synthesis" strings in
   the frontend were research-timeline text. Building spoken-reply meant a source-patched `/v1/speech/synthesize`
   route (kokoro) **plus** React changes plus a rebuild.
4. **A PWA service worker kept serving the stale UI** even with the fix deployed. That was the third layer
   fighting back, and the point at which the Skipper called it.
- ⚠️ Everything in (1)–(3) was an **OpenJarvis SOURCE patch** (`middleware.py`, `api_routes.py`, `frontend/*`) —
  a `jarvis self-update` / `git pull` reverts them. Irrelevant now, but the reason this path was never durable.
- 🚨 **Teardown collateral (found by the nightly distill, 2026-08-01):** `tailscale serve --https=443 off`
  clears the **entire** serve config — it also took down Boss Herman's **Crew Meter** URL
  `https://gilligan.tail5807bd.ts.net/` → `127.0.0.1:8300`, live since 2026-07-10 and unrelated to this work.
  The service is fine (8300 answers `/healthz` 200); only the route is gone. **Needs one command to restore:**
  `tailscale serve --bg 8300`. → [[herman-agent]]

**Goal (Skipper, 2026-07-31/08-01):** seamless voice chat with Gilligan, as smooth as ChatGPT's Advanced
Voice felt — but keeping **Gilligan's actual brain** (memory, tools, autonomy), on **subscriptions** (no
metered). Also likes **Model #2** from the cowork chat: Claude/other as a **coworker Gilligan delegates to**,
not necessarily the brain.

## ⭐ The single insight that governs everything
Every viable path rides on **ONE shared build: expose Gilligan as an OpenAI-compatible HTTP endpoint**
(chat/completions). That one adapter unlocks *all four* voice options below AND the "Claude-as-coworker"
pattern.

### ✅ BUILT + PROVEN (2026-08-01) — the endpoint MVP is DONE
- **`~/gilligan-hermes/gilligan-endpoint/server.py`** — OpenAI-compat `/v1/chat/completions` on
  **127.0.0.1:8831** that runs a **FULL Gilligan AGENT turn** per request (`docker exec gilligan hermes -z`,
  gbt brain + identity/memory + all 28 tools), NOT a raw model call. Prompt fed via container STDIN (dodges
  ARG_MAX). systemd `--user` service **`gilligan-endpoint.service`** (enabled, localhost-only).
- **Proven:** identity turn → "I'm Gilligan… GPT-5.6-sol via openai-codex"; **tool turn** → ran a shell command
  and returned `GILLIGAN_ENDPOINT_TOOL_OK`; supervised service → `ENDPOINT_SERVICE_OK`. Binds 127.0.0.1 ONLY.
- ⚠️ **Security:** drives a tool-using agent (play SSH/email/deploys) — NEVER bind public without auth; voice
  front-ends reach it over localhost/tailnet. MVP caveats: non-streaming; one-shot per call (no cross-call
  chat memory yet — Hermes still loads durable identity/memory); large histories would hit ARG_MAX (fine for
  voice turns; fix later w/ persistent session). → next: point ElevenLabs custom-LLM or OpenJarvis `vllm` host
  at `http://127.0.0.1:8831/v1`.

Second governing truth: **anything where Gilligan does real work (SSH/TRIM IT/deploys) is slower per turn
than pure voice chit-chat.** ChatGPT voice felt magic partly because it does NO real work. Realistic target:
**snappy conversation, a short beat when it actually acts.** True for every path.

## The four voice paths (researched 2026-07-31/08-01)
| Path | Voice quality today | Uses Gilligan's brain/tools? | Cost | Verdict |
|---|---|---|---|---|
| **ChatGPT Advanced Voice** | smoothest | ❌ **NO — voice can't use tools** (TechCrunch 7/8) | sub | **Out** for Gilligan |
| **Claude voice + custom MCP** | good, less polished turn-taking | ✅ via connected MCP connectors | Max sub | Light; **linchpin unverified** (see below) |
| **ElevenLabs ElevenAgents + Custom LLM** | most polished/interruptible NOW | ✅ **"Custom LLM" = point at YOUR endpoint** | ~$0.05-0.10/min + your LLM | Turnkey-ish, paid, cloud |
| **OpenJarvis (`vllm` host → Gilligan)** | maturing (two-way loop still being built) | ✅ via OpenAI-compat `host` → Gilligan | local/free-ish (Cartesia opt) | High upside, local, GUI, younger |

### Claude voice + MCP — the linchpin: ❌ SETTLED = NO (LIVE-TESTED 2026-08-01)
**Claude VOICE mode does NOT use custom MCP connectors.** Proven two ways:
- **Live test:** stood up a public remote-MCP server (one benign tool `gilligan_voice_probe` returning a secret
  phrase) via a cloudflared quick-tunnel; Skipper added it as a custom connector in Claude Desktop. **TEXT
  (incl. mic-dictation) called the tool perfectly** (server logged `tools/call`, phrase returned). **VOICE MODE
  produced ZERO server activity** — never even attempted the connector; Claude said "you changed something and
  it didn't work."
- **Corroborated by Anthropic's own tracker:** `anthropics/claude-ai-mcp` issue **#146 "No registered MCP
  connectors are discovered in voice chat"** (bug, closed).
- ✅ Still TRUE: custom remote-MCP works in **text/Cowork/Desktop** (Free/Pro/Max), add by URL, auth optional.
  Handshake gotchas learned (for any future MCP-connector build): (1) return **404** on `/.well-known/oauth-*`
  to signal no-auth (else connect fails); (2) **echo the client's `protocolVersion`** on initialize (Claude
  sends `2025-11-25`; hardcoding an old version connects but skips `tools/list`).
**Consequence:** the "just point Claude VOICE at Gilligan's tools" path is DEAD. Seamless voice + Gilligan
REQUIRES a voice front-end WE control (ElevenLabs / OpenJarvis) + the Gilligan-as-an-endpoint build.
Text-only Claude+MCP could still reach Gilligan, but that's not the voice goal.

### OpenJarvis (Stanford, github.com/open-jarvis/OpenJarvis, ~8k stars, Apache-2.0, v1.0.0, Feb 2026)
- **Local-first personal-AI research framework** — Ollama by default, "cloud APIs optional." NOT a Hermes
  replacement (cloud engine = OpenAI/Anthropic/Google/MiniMax/DeepSeek via **metered API keys**, no GLM/Kimi,
  no subscription lanes).
- **The unlock:** engine backends are `ollama, vllm, llamacpp, sglang, cloud`. **`[engine.vllm] host = <any
  OpenAI-compatible URL>`** → point it at Gilligan's endpoint. Then OpenJarvis = local voice front-end,
  Gilligan (on the subscription brains) = the backend. Local voice + real Gilligan + sub cost.
- **Voice stack:** STT = `faster-whisper` (local, CPU near-real-time) or OpenAI Whisper (cloud); TTS =
  **Cartesia** (cloud, low-latency, high quality) + local options. ⚠️ Two-way conversational voice **still
  maturing** — feature request #250 (voice I/O) OPEN; whisper-STT PR #503 OPEN. Today = spoken briefings +
  emerging real-time, not yet ChatGPT-polished.
- Fits the Skipper: **Native Windows installer + Desktop GUI app** (matches his no-CLI preference).

### ElevenLabs ElevenAgents — the turnkey path
- Best-in-class voice, and **"Custom LLM"** officially supported (give it your endpoint + creds) → your agent
  is the brain. Most polished interruptible voice *today*. PAYG ~cents/min + your LLM cost (sub = ~free).

## Skipper's hardware — CONFIRMED clears the voice path (2026-08-01, from Task Manager)
- Intel **Core Ultra 7 256V** (Lunar Lake), 8c/8t, up to 3.85 GHz · **16 GB RAM** (on-package, NOT
  upgradeable — permanent ceiling) · **Intel Arc 140V integrated** GPU (no discrete/VRAM) · **Intel AI Boost
  NPU** · NVMe SSD · Win 11.
- **Voice-only path (brain = Gilligan endpoint): clears it easily** — STT + thin client is ~1-2 GB, TTS is
  cloud, no discrete GPU needed. Green light, buy nothing.
- **Full-local brain: don't** — only small (2-8B) models fit, weaker than the subs, and RAM is capped at 16 GB
  forever on this chip. NPU is nice future-proofing as frameworks add NPU accel.

## The reframe: TWO Gilligans (this is the real clarity)
1. **Work agent** — real GSTS/TRIM IT/arbor work, tools, autonomy, multi-channel, strong sub brains →
   Hermes/OpenClaw territory. KEEP on the subscription runtime.
2. **Personal voice AI** — seamless spoken assistant, briefings, on-device → OpenJarvis / Claude voice /
   ElevenLabs territory.
Friction all day came from trying to make ONE thing be BOTH (the shim's whole struggle). Let them be layers:
voice front-end → talks to → work-agent endpoint.

## ⏭️ Resume pointer / next step
**Voice is DONE and proven** (Telegram, top of note). Nothing is blocking. Open, only if asked:
1. Make TTS **voice-back-only-on-voice-input** if speaking every typed reply gets noisy — offered, not requested.
2. **Restore the Crew Meter serve route** (`tailscale serve --bg 8300`) — collateral from the OpenJarvis teardown.
3. ElevenLabs custom-LLM remains the fallback if the edge-TTS voice ever underwhelms; it would need the
   `gilligan-endpoint` service re-enabled (kept, currently stopped+disabled).

## Superseded / historical
- *(2026-08-01, superseded)* Resume pointer read: *"Linchpin SETTLED (Claude voice can't use custom
  connectors) → … seamless voice + Gilligan **requires** the shared build: Gilligan-as-an-OpenAI-compatible-
  endpoint, then a voice front-end WE control: **ElevenLabs custom-LLM** = fastest to 'wow' (paid/cloud);
  **OpenJarvis** `vllm`→Gilligan = local/free/GUI … **Nothing built yet.**"* — the premise was wrong: the
  Hermes/Telegram channel already had a voice loop, so neither the endpoint nor a custom front-end was
  required. (The Claude-voice-can't-use-MCP finding above is still TRUE and still useful.)
- *(2026-08-01, superseded)* The endpoint MVP's next step read *"point ElevenLabs custom-LLM or OpenJarvis
  `vllm` host at `http://127.0.0.1:8831/v1`"*. Both front-ends are off; `gilligan-endpoint.service` is
  stopped+disabled. The endpoint itself remains **built and proven** (full agent turn, tools, localhost-only)
  and is the reusable piece if any external voice/LLM front-end is ever wanted.
- *(2026-08-01, superseded)* Browser chat UI was live at `https://gilligan.tail5807bd.ts.net/` over the
  tailnet (OpenJarvis serve on `127.0.0.1:8600` + Tailscale Serve). **That URL is dead** — do not hand it to
  the Skipper; the same hostname's serve config also carried the Crew Meter (see teardown collateral above).
- Test-rig teardown done (public tunnel + server killed). Reusable MCP-connector code: `~/gilligan-hermes/
  mcp-voice-test/server.py` (spec-correct handshake) — still valid for any future text-mode MCP connector.
