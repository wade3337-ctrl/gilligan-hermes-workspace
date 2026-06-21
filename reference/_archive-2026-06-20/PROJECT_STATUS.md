# Great Scott / Arbor — Project Status
*Snapshot by Gilligan · 2026-06-09 · (running detail lives in `memory/2026-06-0X.md`)*

## ✅ Daily Monitor (live + healthy)
- Emails a clean outline report **6:30am PT** to **wade3337@gmail.com + jwade@gstsinc.com**, from
  the dedicated sender **gilligan.gsts@gmail.com** (From≠To so it lands in the inbox).
- Metrics: Daily Job **TPH** (vs $130 + vs scheduled), Overtime, **daily Monthly-Revenue** (earned +
  🎯 booked-to-goal, measured in Mon–Sat **working days** minus holidays/rain), Monday adds Municipal
  contract burn-down.
- **Fixed 6/9:** multi-crew TPH bug — dollars + hours now summed per **work order** across all crews
  (reconciles to the penny with the GSTS Production-Day page).
- Data freshness: reads **play** (restored nightly from prod). Backup pipeline was stalled 6/4–6/8;
  **fixed 6/9**, data flowing again.

## 🗄️ TrimIT Database Cleanup (in progress — replacing devs' 1yr/$300k quote with AI-assisted)
- Grounded on the June-3 6-item **health assessment** + completed schema discovery.
- **Pass 1 census DONE (6/9):** 918 tables → **272 high-confidence dead (~5.6 GB)**, **26 normal-named
  parked** for human review (look like planned/Arbor features), Codex's KEEP-traps respected.
- **Drop plan written** (`Arbor AI/Trim IT Repairs/DB_CLEANUP_DROP_PLAN_PHASE2.md`): reversible
  method (backup → quarantine to `_graveyard` schema → soak → drop), test-bed → play → prod.
- **Waiting on:** test-bed server specs (your former in-house TrimIT host); Codex moving census
  artifacts out of the public web root.
- Codex access confirmed: reads all CF source + proc bodies + catalog on **play** (login is `sa` —
  itself a cleanup item).

## 🤖 Herman (your 2nd bot)
- Two context docs delivered: working-style brief + Arbor/TrimIT background (`workspace/files/`).
- Herman's job = an **interactive guide character** for Arbor AI (not building the app).
- The Bid Manager = an improved version of the existing **Price Buddy** inventory pricing tool.
- **Open:** Herman→Gilligan file transfer (SSH dropbox — securing it, see status note); and the
  Discord **workshop channel** for Gilligan↔Herman collaboration (parked, needs a channel ID).

## 🔒 Security / access
- Discord bot set **private**; DMs gated (pairing); commands owner-only → only you can use Gilligan.
- Removed my stored copy of your **wade3337** Gmail key (you revoke it on Google's side); sending now
  runs entirely through gilligan.gsts.

## 🎙️ Voice (parked)
- Live Discord "phone-call" voice approved — **female** voice. Needs: a voice channel + ID, my config
  + restart, and confirming your OpenAI realtime access. Then async voice-messages as phase 2.

## ⏳ Waiting on you
1. Test-bed server specs (DB cleanup execution).
2. Decision on Herman's file-transfer method (secure dropbox vs dedicated user vs Discord channel).
3. Voice channel ID (when you want voice).
4. Gut-check on the 26 "parked" tables (planned feature vs junk) — low priority, tiny.
