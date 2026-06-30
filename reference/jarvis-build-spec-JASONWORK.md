# REFERENCE — "Jarvis" local voice assistant (Skipper's JASONWORK laptop)

> **Gilligan's note (filed 2026-06-30).** The Skipper's personal, local-first **voice assistant** built on
> **OpenJarvis**, running on his Acer Predator gaming laptop (JASONWORK, RTX 5070 Ti 12GB / 64GB RAM, Win11 + WSL2).
> Separate machine + stack from me (I'm OpenClaw on the `jdog1` Ubuntu host). He flagged it as "a useful tool later."
> Cross-ref: `~/arbor-core/docs/research-openjarvis.md` (our earlier OpenJarvis research). No secrets in this doc
> (his API keys live only in `~/.openjarvis/secrets.env`, chmod 600, never synced).

## Why it could matter to us (the reusable parts)
1. **Decoupled voice client over an OpenAI-compatible API.** The Windows voice client (faster-whisper STT → routing →
   Kokoro neural TTS) talks to the backend purely via `localhost:8000/v1/chat/completions` and only picks a *model
   name*. That means the **same voice front end could be repointed at Gilligan/OpenClaw or Arbor** instead of
   OpenJarvis (OpenClaw can expose an OpenAI-compatible API server). → a proven path to giving me / Herman / Arbor a voice.
2. **Local-default, escalate-when-hard routing.** llama3.1:8b local by default (free/private) → auto-escalate to
   Claude for hard questions, GPT-5.5 for code. Same philosophy as our crew's local-Ollama-backs-cheap-work pattern,
   but more developed (word-count complexity trigger, voice "ask Claude / ask Codex" overrides).
3. **Real local-GPU compute on hand.** The RTX 5070 Ti (12GB) + 64GB box is genuine inference hardware the Skipper
   owns — a candidate for things we lack on jdog1 (e.g. local models, the headless-browser gap, Arbor local inference).
4. **Voice tech stack proven:** Kokoro (kokoro-onnx) = most natural local TTS; faster-whisper = local STT; Piper as
   fallback. If we ever want offline voice, this is a working recipe.

## Honest limitations as "infrastructure"
- It's an **on-demand personal assistant on a gaming laptop**, not an always-on server (nothing auto-starts at boot;
  Stop button does `wsl --shutdown` to free the GPU for gaming). So it's a *tool/pattern to borrow*, not a service to depend on.
- Mic only works on the **native Windows** side (WSL mic is unreliable) — voice capture is Windows-bound.

## ⭐ TEST-TARGET STATUS (noted 2026-06-30, Skipper's call)
**JASONWORK is our designated candidate for local-model testing / private local inference.** It has the muscle:
- **JASONWORK:** RTX 5070 Ti 12GB (working NVIDIA driver) → runs **llama3.1:8b on GPU**. Strong.
- **jdog1 (my host):** has an NVIDIA **GTX 1050 Ti Mobile 4GB** + Intel iGPU, but the **NVIDIA driver is NOT installed**
  (`nvidia-smi` fails) → my Ollama **llama3.2:3b runs on CPU only**. Weaker chip *and* a dormant GPU stack.
→ For any "test a bigger local model" or "keep it fully private/local" experiment, JASONWORK is the better box.
(Possible future tweak on jdog1: install the NVIDIA driver to wake its 1050 Ti — but it's old/4GB, marginal; needs Skipper sudo.)

## Forward hook
When we reach "give Arbor/Herman a voice," start here: keep his voice client, repoint its API base at our agent's
OpenAI-compatible endpoint, reuse Kokoro/whisper. Minimal new work.

---
# Original spec (as provided by the Skipper, JASONWORK · Acer Predator PHN16-73, built June 2026)

**What it is:** A private, local-first voice assistant ("Jarvis") on his own hardware — natural neural voice, calls in
frontier cloud models (Claude / GPT-5.5) only when a question is genuinely hard. Local by default; keys never leave WSL.

**Three brains:** local Ollama `llama3.1:8b` (RTX 5070 Ti, default/private) · `claude-sonnet-4-6` (hard questions /
"ask Claude" / "think hard") · OpenAI `gpt-5.5` (coding / "ask Codex" / "ask GPT").

**Architecture:** Windows `jarvis_voice.py` (Py3.12): mic → faster-whisper STT → route → Kokoro TTS; POSTs to WSL2
OpenJarvis server (`uv run jarvis serve`, OpenAI-compatible `localhost:8000`) which routes by model name to
Ollama / Anthropic / OpenAI. Keys from `~/.openjarvis/secrets.env`; the voice client never holds keys.

**Backend:** OpenJarvis (`open-jarvis/OpenJarvis`, via `uv`) + Ollama + `llama3.1:8b`; `uv sync --extra server
--extra inference-cloud`; Rust toolchain. **Client:** sounddevice, numpy, faster-whisper, openai, pyttsx3,
piper-tts, kokoro-onnx (primary). Project folder: `C:\Users\wadej\Claude\Projects\op`.

**Key knobs (top of `jarvis_voice.py`):** TTS_ENGINE=kokoro · KOKORO_VOICE=am_michael · KOKORO_SPEED=1.1 ·
JARVIS_MODEL=llama3.1:8b · ESCALATE_MODEL=claude-sonnet-4-6 · CODER_MODEL=gpt-5.5 · AUTO_ESCALATE=True ·
COMPLEXITY_WORDS=28 · WHISPER_MODEL=small.en.

**Daily use:** desktop "Start Jarvis" / "Stop Jarvis" .bat buttons (Stop frees all 12GB VRAM for gaming).

**Known gotchas:** llama3.1:8b can vanish after `wsl --shutdown` (start script auto-pulls now); re-running quickstart
prunes the cloud SDK (redo `uv sync --extra server --extra inference-cloud`); `.bat`=CRLF / `.sh`=LF; Codex Responses-API
models won't work through the chat-completions server (use gpt-5.5); WSL mic unreliable (client runs on Windows).

**Costs:** local lane free; Claude sonnet ~$3/$15 per Mtok; GPT-5.5 ~$5/$30 per Mtok — only escalated questions cost.
Recommended: monthly spend caps on both consoles.

*Full original runbook + the .bat/.sh/.py files live on JASONWORK in `C:\Users\wadej\Claude\Projects\op`.*
