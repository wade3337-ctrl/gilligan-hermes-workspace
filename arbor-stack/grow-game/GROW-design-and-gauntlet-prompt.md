# GROW! — Design Brief + Kimi K3 One-Shot Gauntlet Prompt

_Fun side project: a browser game embedded (via iframe) in the TRIM IT V1.5 landing page._
_Owner: Jason (Skipper). Drafted with Gilligan, 2026-08-06._

---

## 1. Locked design decisions

| Decision | Choice |
|---|---|
| Core mechanic | **Hybrid**: vertical **Climb** levels (Donkey-Kong/redwood) + side-scroll **Run** levels (Mario), alternating |
| Hero | A **sapling that grows** — collect **water** (grow/strength), **sunlight** (speed + short "canopy dash"); pest hit **shrinks** you a stage instead of instant death |
| Art | **Cute cartoon storybook**; **pixel-art = explicit fallback** if cartoon assets fail QC |
| Brand | **Light GSTS wink** — company-green palette, tiny hard-hat / GSTS truck Easter egg in background |
| Scope | **Short adventure**: 4–5 alternating levels → **boss pest finale** → win screen |
| Controls | **Full responsive** — keyboard/WASD desktop, on-screen touch on mobile, canvas scales |
| Delivery | **Single self-contained `.html`** (no external files), embedded via `<iframe>` |
| Finale | Beat the boss (**"The Blight"**, a giant bark-borer beetle) at the summit → sapling **blooms into a mighty full-grown tree** |
| Title | **GROW!** |

## 2. Level plan (5 levels)
1. **Climb** — Roots to Trunk. Teach growth: water/sunlight, first pests (aphids).
2. **Run** — The Low Canopy. Teach jump/dash across branch gaps; stomp beetles.
3. **Climb** — The Tall Timber. Falling hazards (pinecones), moving branches.
4. **Run** — The High Canopy. Faster, gaps + wind gusts + more pests.
5. **Boss** — The Summit. Fight **The Blight** → on defeat, bloom sequence + win screen + score/high-score.

## 3. Growth system (the heart)
- 3 growth stages: **Sprout → Sapling → Young Tree** (bigger hitbox = higher reach + tougher).
- **Water** = grow one stage (max 3). **Sunlight** = 6s speed boost + double-tap = dash.
- Pest hit = drop one stage; hit at stage 1 = lose a life. **3 lives.**
- Score: collectibles + pests cleared + height/distance + level clear bonus. Persist high score in `localStorage`.

## 4. Technical guardrails (why single-file matters)
- **Everything inline**: game code, styles, and assets. **No external requests** (no CDN, no image/audio files).
- **Assets drawn in-code** (canvas primitives + inline SVG data-URIs), so nothing can 404 and art stays consistent — this is the realistic path to a first-try success. Pixel fallback is *also* code-drawn.
- **Audio synthesized** via WebAudio (chiptune SFX + light loop) — keeps it one file.
- **Isolation**: renders inside its own `<iframe>`, so it cannot collide with TRIM IT CSS/JS. When we embed, we still **backup the landing page first** and render-verify the served output (repair-contract habit).

## 5. Acceptance criteria (the gauntlet gates)
A build is DONE only if ALL pass:
- Loads as a **single .html**, opened directly (file://) with **zero network requests** and **zero console errors**.
- Runs at **~60fps**, canvas **scales** to window, playable on **desktop keyboard AND mobile touch**.
- All **5 levels reachable and completable**; growth, lives, scoring, and the **boss + bloom finale + win screen** all work.
- Title screen, pause, game-over, restart, and **persisted high score** all work.
- Art is **consistent** (one coherent style); if cartoon fails consistency QC → auto-switch to pixel fallback and still pass.
- Light **GSTS-green wink** present but tasteful.

---

## 6. THE ONE-SHOT GAUNTLET PROMPT (paste into Kimi K3)

See `GAUNTLET-PROMPT.md` in this folder for the copy-paste version.
