# Hands-Free Discord Voice — CHECKPOINT (paused 2026-06-10)

Goal (Skipper's words): *"just talk to you about what I want, like talking to a person. I don't want to have to hold a button."* → open-mic, interruptible, **female** voice, natural turn-taking.

## STATUS: PAUSED at a hard credential blocker. Config UNTOUCHED.
- **Nothing was changed.** `openclaw.json` not edited, gateway NOT restarted. Fully clobber-safe — no restore needed.

## The blocker (verified, not theory)
- Hands-free natural voice = **OpenAI Realtime API** (`agent-proxy` realtime mode). That endpoint lives ONLY on the OpenAI **platform** (`api.openai.com`) and needs a **platform API key (`sk-…`) with pay-as-you-go billing**.
- Our only OpenAI auth is the **ChatGPT/Codex login** (`~/.codex/auth.json` → `auth_mode: chatgpt`, `OPENAI_API_KEY: null`). Tested its token against `api.openai.com/v1/models` → **HTTP 401**. Zero platform access. (ChatGPT/Codex door ≠ Platform API door; separate keys.)
- **No fallback configured either:** no ElevenLabs / TTS / STT / Deepgram keys anywhere. Every route to voice needs Skipper to add one paid credential.

## DECISION PENDING (Skipper to choose)
- **A (recommended) — OpenAI platform API key.** Only path that delivers what he asked for (open-mic, barge-in, female voice). ~5 min: create key at platform.openai.com + add a small billing balance. Meters per-minute of talking (~pennies for a check-in, ~$1–2 for a long convo) vs his flat Codex sub.
- **B — ElevenLabs batch (stt-tts).** Walkie-talkie feel (goes deaf while talking, lag, no interrupting). Still a paid key. A downgrade from what he described.

## WHEN RESUMED (after Skipper supplies an OpenAI `sk-` key) — exact steps
1. **Back up** `/home/wade3337/.openclaw/openclaw.json` first (clobber history — back up + merge-patch, NEVER overwrite).
2. Add the platform key to OpenClaw's OpenAI provider/auth (so realtime can authenticate). Confirm with `curl …/v1/models` → HTTP 200 before proceeding.
3. Merge-patch `channels.discord.voice`:
   ```json5
   voice: {
     enabled: true,
     model: "openai/gpt-5.5",                 // agent brain for voice
     realtime: { provider: "openai", model: "gpt-realtime-2", speakerVoice: "<female>" },
     autoJoin:        [{ guildId: "1510295992480825447", channelId: "1510295993013506152" }],
     allowedChannels: [{ guildId: "1510295992480825447", channelId: "1510295993013506152" }]
   }
   ```
   Female OpenAI realtime voices to pick from: `shimmer`, `coral`, `sage`, `marin`. (`cedar` = masculine, don't use.)
4. Enable native slash-commands: `channels.discord.commands.native: true` (currently `commands` only has `ownerAllowFrom`).
5. Discord Dev Portal: ensure **Message Content Intent** + **Server Members Intent** on; re-invite bot with **`bot` + `applications.commands`** scopes (bot is PRIVATE now); grant Connect/Speak/Send/Read-History on the voice channel.
6. **Restart gateway** (briefly drops this Discord chat — warn Skipper first).
7. Test: `/vc join channel:1510295993013506152` → talk → verify open-mic + female voice + barge-in.

## Local-model option — explored Jun 10, DEFERRED (Skipper "revisit later")
Skipper asked what it'd take to run voice on a **local machine + local model** (driver = BOTH cost AND privacy).
- **This box (the OpenClaw host) is a laptop:** Intel i7-7700HQ (2017), **14 GB RAM**, 8 cores; discrete **NVIDIA GTX 1050 Ti Mobile but only 4 GB VRAM** and the **NVIDIA driver isn't even loaded** (running on Intel iGPU); 848 GB free. Local model present: `llama3.2:3b` (small/weak).
- **Voice = 3 parts.** STT (faster-whisper) ✅ local-able. TTS (Piper/Kokoro) ✅ local-able. **Brain** — Ollama local works but a 3B model is *far* dumber than Opus (can't do TPH/SQL/reasoning). Trading a genius for an intern.
- **Hard limit:** OpenClaw's **open-mic "like a person" realtime is OpenAI-cloud-ONLY.** Going local FORCES `stt-tts` "walkie-talkie" mode (deaf while talking, ~2–5s lag on this HW, no barge-in). Also OpenClaw's STT/TTS slots look cloud-oriented (docs show only OpenAI/ElevenLabs) → local would likely need a local OpenAI-compatible shim (real glue work, unverified).
- **Privacy reality check (the deciding logic):** the *crown jewels* (payroll, customers, TPH, SQL) ALREADY flow to Anthropic + OpenAI Codex daily. A voice chat is far less sensitive. Local voice = locking the side window while the front door's open → near-zero real exposure change.
- **Cost reality:** realtime voice ≈ a couple $/month personal use; a "proper local" GPU box = **$1,000–1,800 one-time** (used RTX 3090 24GB / 4060 Ti 16GB) and STILL only walkie-talkie via OpenClaw. ~$1.5k to get a *worse* experience to save ~$2/mo = bad ROI **if it's only for voice.**
- **Where local DOES make sense:** buy a real GPU box **for the whole Arbor stack** (private bulk SQL, local experiments, no metering on those) → then voice rides along for free. Decide that on ITS merits, separately. **Skipper declined a full price-out for now — revisit when/if a GPU box is on the table for Arbor.**

## Reference facts
- Voice channel: **1510295993013506152** (guild **1510295992480825447**). Existing TEXT channel allowlisted = `…3506151` (one digit off — don't confuse).
- Docs: `…/openclaw/docs/channels/discord.md` §Voice (~line 1163). Auto-join + realtime example ~line 1194.
- Bot is PRIVATE; `commands.ownerAllowFrom = ["discord:1301226640130445323"]` (Skipper only).
- Discord config today: `channels.discord` = { enabled, token, groupPolicy:allowlist, guilds }. NO `voice`, NO `commands.native` yet.
