---
title: Inland Empire Expansion — BD Target Research
type: project
domain: work
track: 1
status: active
tags: [business-development, inland-empire, expansion, hoa, commercial, target-list, deep-research, chad, scott, nate]
applies: []
links: ["[[anomaly-monitor-suite]]"]
updated: 2026-07-08
---

# Inland Empire Expansion — BD Target Research

**One-liner:** A prioritized target list for Great Scott Tree Care to expand into the Inland Empire — affluent managed HOAs + commercial parks in the urban western IE — built for business developer **Chad**.
**Status:** 🔵 active — **v1 + Round-2 delivered & emailed to Skipper; Top-6 emailed to Scott (CEO) + Nate 2026-07-08.** Chad can start dialing. Next = close the ⚠️ loose ends + scale on CAI-GRIE.
**📁 Location:** report `inland-empire-expansion-targets.md` (workspace root). Built via the `deep-research` workflow (2 runs, 200+ agents, adversarially fact-checked) + enrichment/entity-resolution passes.
**▶️ Resume:** the report file. Loose ends: Vellano's residential HOA manager; a landscape-PM contact for Daytona; per-community on-site manager names; scale to 100+ via CAI-GRIE + transparencyhoa.org.

## Scope (Skipper's spec, 2026-07-08)
- **Segments:** (A) managed HOAs / master-planned + (B) commercial (office/retail/industrial). NOT municipal.
- **Box:** urban western IE — Pomona/Chino Hills fringe → east to ~San Bernardino city → south down I-15/I-215 to Temecula. Exclude east of San Bernardino + all Coachella/Palm Springs.
- **Filter:** established ≥3-4 yrs (mature canopy); rank by affluence × tree density × scale × budget. Deliver tight ~20-25, scale to 100+.

## ⭐ THE TOP 6 (emailed to Scott + Nate) — Chad's hit-list, best first
1. **Redhawk** (Temecula, ~3,000-home master-planned) → **Avalon Management, 951-699-2918** — ✅ verified current. Biggest + reachable now.
2. **Daytona Business Park** (Perris, 7-bldg commercial, I-215) → **Jon Kelly, Core5 Industrial, 949-467-3290 / jkelly@c5ip.com** — ✅ verified named contact (owner/developer; confirm landscape scope).
3. **Paloma del Sol** (Temecula, HOA est. 1991) → **Packard Management, 858-277-4305** — 🟡 re-verify; ⚠️ **weak incumbent (1.8★)** = easiest flip.
4. **The Lakes / Menifee Lakes** (Menifee, 1,021-home gated) → **Powerstone, 951-823-1011** (Tim Peckham) — 🟡 (2022 source). Gateway to Powerstone's **261-HOA** book (~$838K avg budget).
5. **Los Serranos Ranch** (Chino Hills — best affluence+maturity city; 1920s canopy) → **Keystone Pacific, 949-833-2600** — 🟡.
6. **Haven View Estates** (Rancho Cucamonga, custom homes $800K–2.2M) → **FirstService Residential, 909-981-4131** — 🟡. National door, two IE offices.
- Suggested call order: #1 & #2 now (verified), then #3 (weakest incumbent); #4–6 = land-the-manager-win-the-portfolio.

## Key findings
- **Strategic takeaway:** go through the **management companies that control portfolios**, not scattershot managers — one door = many communities.
- **7 verified management doors:** Powerstone (951-823-1011), FirstService Residential (909-981-4131 RC / 951-296-2272 Murrieta), Keystone Pacific/KPPM (949-833-2600), Avalon (951-244-0048 / 951-699-2918), Weldon L. Brown (951-682-5454, ~39-yr-old HOAs), IPA Commercial, CBRE/Cushman/JLL. Scaling engine = **CAI-GRIE directory**.
- **Hypotheses:** (b) **Perris commercial CONFIRMED** (17M+ sq ft in dev; Daytona hard-verified) — nuance: Ontario/RC/Fontana bigger total. (a) **I-15 HOA toward Temecula SUPPORTED** (manager offices + Round-2 real HOAs: Redhawk 3,000, Lakes 1,021, Paloma del Sol).
- **Affluence:** Chino Hills best (affluent + mature); Eastvale richest ~$160K but newer; Rancho Cucamonga large/established.

## Round 2 — mapped managers (entity resolution)
- ✅ Redhawk→Avalon (current, 2025 site); Daytona→Core5/Jon Kelly (named contact).
- 🟡 (dated / re-verify): The Lakes→Powerstone (2022 PR); Los Serranos Ranch→KPPM (testimonial); Paloma del Sol→Packard (Dec-2025, weak incumbent); The Colony (Murrieta)→PCM Foothill Ranch (949-768-7261); Haven View/Terra Vista/Victoria→FirstService.
- ⚠️ unresolved: **Vellano** residential HOA manager (golf course = Western Golf Properties, separate entity); Fairway at Redhawk (mgmt paywalled); per-community on-site manager *names* (rarely public).
- ⚠️ **Harness note:** Round-2's auto-synthesis stalled on the last agent; findings recovered from the verified run journal (all passed adversarial fact-check). Resume failed (args not re-passed) — recovered manually instead.

## 📧 Comms log
- **2026-07-08 ~23:42 UTC — Top-6 emailed to Scott (CEO, sgriffiths@gstsinc.com) + Nate (nperkins@gstsinc.com), CC Jason (jwade@gstsinc.com).** From `gilligan.gsts@gmail.com` (same sender as the daily COO report). Subject "Inland Empire Expansion — Initial Target List (Top 6)". Skipper drafted-approved then said send. ⚠️ Deliverability: gilligan.gsts not yet M365-allowlisted → may hit Scott/Nate Junk; advised Skipper to give them a heads-up.
- v1 report emailed to Skipper (wade3337@gmail.com + jwade@gstsinc.com) 2026-07-08 ~17:xx; Round-2 update emailed ~19:4x.

## 🔗 Bigin CRM integration (2026-07-08) — LIVE
- **Connected** to Zoho **Bigin** via OAuth self-client (Skipper generated creds). Refresh token + client id/secret stored `~/.secrets/bigin-oauth.json` (600). US DC, api `https://www.zohoapis.com/bigin/v2`, accounts `https://accounts.zoho.com`. Scopes: `ZohoBigin.modules.ALL, settings.ALL, users.READ`.
- **Access is create + edit, NOT delete** (`Crm_Implied_Delete_Accounts` denied) — safe guardrail; I cannot destroy CRM data. Deletions = Skipper/Chad in UI, or he grants delete perm.
- **Structure:** module "Pipelines" (deals), layout **"Chad Pipeline"** id `5275136000002190772`. Two sub-pipelines: "Chad Pipeline Standard" (Chad's 194 live deals — DO NOT TOUCH) + **"Inland Empire Expansion"** (ours). First stage "Potential Lead". Deal owner = **Chad Bouck** id `5275136000002097047`. Deal create REQUIRES: Deal_Name, Stage, Sub_Pipeline (string), Layout{id}, Closing_Date, Contact_Name. Sub_Pipeline is a picklist STRING (not a lookup).
- **⚠️ Dedup lesson:** the org already has ~175 accounts incl. many mgmt companies (Powerstone, FirstService, Keystone Pacific…). ALWAYS GET /Accounts and link to the existing account; only create if none. (First load made 3 dup accounts → re-linked deals to existing, but the 3 orphans can't be API-deleted — pending manual delete: newest "Powerstone Property Management", "FirstService Residential", "Keystone Pacific Property Management".)
- **Wave 1 LOADED** (Top 6): Redhawk→Avalon, Daytona→Core5(Jon Kelly), Paloma del Sol→Packard, The Lakes→Powerstone, Los Serranos Ranch→Keystone Pacific, Haven View→FirstService. Owner Chad, stage Potential Lead, phones+why+confidence in Description.
- **🤖 Weekly automation:** Gateway cron **"IE pipeline weekly push"** id `42ec822d-1573-4208-ad53-4a4d8718b00c` — Mondays 8:12am PT (isolated agentTurn): reads `ie-pipeline-backlog.md` next wave → web-verifies mgmt/contact → loads 6 into Bigin (dedup-safe) → updates backlog → Discord-summarizes to Skipper. Backlog + waves 2–5 in `ie-pipeline-backlog.md`.

## Next
- Close ⚠️: Vellano residential HOA manager; Daytona landscape-PM (vs owner Core5); per-community managers at call time.
- Manual: delete the 3 orphan dup accounts in Bigin UI (see Bigin section).
- Scale to 100+ on CAI-GRIE + transparencyhoa.org (where Round 1 confirmed Haven View→FirstService).
- Optional: quantify HOA counts per I-15 city to hard-prove hypothesis (a).

## Related
- [[anomaly-monitor-suite]] — the email-send infrastructure (gilligan.gsts sender) used to deliver reports + the Scott/Nate email.
- Method: the `deep-research` workflow (fan-out search → adversarial verify → synthesize).
