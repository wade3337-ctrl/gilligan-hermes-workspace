---
title: Kling AI (video/image generation)
type: reference
domain: env
tags: [ai, video, generation, tooling]
status: live
updated: 2026-07-23
links: ["[[env-host-and-tooling]]"]
---

# 🎬 Kling AI — video & image generation

Set up 2026-07-23 (Skipper's request). **Working + first video generated.**

## Credentials & endpoint
- Key: **`~/.secrets/kling.json`** (0600, OUTSIDE the workspace so it never gets auto-committed). It's a **single Bearer token** (`api-key-kling-…`), NOT the AccessKey/SecretKey pair.
- Base: **`https://api.klingai.com`** · Auth header: **`Authorization: Bearer <key>`**.
- Model default `kling-v1` (works). Endpoints: `POST /v1/videos/text2video`, `GET /v1/videos/text2video/{task_id}`, `POST /v1/images/generations`.

## ⚠️ TWO SEPARATE WALLETS (the gotcha)
The **consumer subscription** (klingai.com) grants **ZERO API access** — the API bills a **separate prepaid "Resource Pack"** you buy in the dev console (`kling.ai/dev`). Sub credits ≠ API credits. **Failed API calls are free** (good for prompt iteration). Currently a **VIDEO pack** (Trial-Video-100Units) is loaded; **image gen needs a separate image pack** (image request against a video-only balance → `code 1102 balance not enough`).

## How to generate
- Client: **`kling/kling_gen.py`** — `python3 kling/kling_gen.py video "prompt" [--duration 5 --aspect 16:9]` or `image "prompt"`. Submits → polls → downloads to `kling/outputs/`.
- Skipper just asks in chat ("make me a video of X") and I run it.

## Delivering to Discord (8 MB cap)
Kling clips are ~9 MB → over Discord's limit. **ffmpeg is installed at `~/.local/bin/ffmpeg`** (static build). Compress before attaching: `~/.local/bin/ffmpeg -i in.mp4 -vcodec libx264 -crf 20 -preset slow -acodec aac -movflags +faststart out.mp4` → ~2–3 MB, still HQ. (Or share the API's signed video URL — but those **expire ~30 days**.)
