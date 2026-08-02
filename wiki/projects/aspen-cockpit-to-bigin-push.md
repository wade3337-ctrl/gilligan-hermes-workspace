---
title: Aspen — Cockpit → Bigin push (sales pipeline sync)
type: project
domain: work
track: 1
status: PAUSED 2026-08-02 — Skipper discussing with Nate before build; nothing built/written
tags: [aspen, bigin, cockpit, crm, pipeline, sync, build]
applies: ["[[external-comms-contract]]", "[[repair-contract]]"]
links: ["[[aspen-retention-agent]]", "[[sales-cockpit]]", "[[50m-growth-goal]]", "[[herman-agent]]"]
updated: 2026-08-02
---

# Aspen — Cockpit → Bigin push

**Objective (Skipper 2026-08-02):** Aspen reads the Sales Cockpit → pushes to Bigin → maintains the live SALES pipeline in Bigin. "Gilligan builds, Aspen runs."
> ⚠️ **This note is the canonical build-state (Gilligan owns it).** Do NOT keep it in the aspen-knowledge vault — that vault autosyncs FROM the Aspen board and **quarantines** files written directly into it (my first copy got swept to `_quarantine/` by the 02:52 autosync). Gilligan-owned build state lives HERE in the workspace wiki. Design/context still lives in `aspen-knowledge/business-development/bigin-structure-and-plan.md`.

## ⏸️ PAUSED 2026-08-02 — Skipper to discuss with NATE first
Verified + planned; **nothing built or written**. Resume when the Skipper gives the go + the answers below.
**Unblocks on:** (1) which book to pilot first (rec: Megan/OC = most existing accounts, or Chad/IE where the sub-pipeline+drip already exist); (2) whatever Nate wants re pipeline structure / stage translator / ownership; (3) **AUTONOMY LEVEL for Aspen's Bigin WRITES (open, discuss w/ Nate):** once verified, do Aspen's pipeline writes run FULLY AUTONOMOUS, or get a review gate like outbound emails? It's the team's SHARED CRM. Rails already in design: dry-run before writes · source-of-truth split (Aspen writes only its OWN fields, never the reps' sale-motion) · idempotent dedup. This is a trust-boundary call, not technical.
**On resume:** start at BUILD ORDER step 1 (owner map) → dry-run (step 4) before any Bigin write. Re-confirm the Bigin token refresh if it's been weeks.

## Access model — Aspen is DIRECT to Bigin (not through Gilligan)
- **Bigin = fully direct:** end-state = Aspen holds its OWN OAuth on its OWN runtime and calls the Bigin API itself. Gilligan only BUILDS + verifies, then hands off (creds + scripts move to Aspen's board). ⚠️ **Current:** token verified on jdog1 (Gilligan's box); making it truly Aspen-direct is a handoff step (provision OAuth on Aspen's runtime + deploy push scripts there).
- **TRIM IT = autonomous but SCOPED through a gateway** (by security design): Aspen's read hops through the `aspen-dispatch.sh` forced-command on jdog1 (read-only query only; arbor-core/crew hard-denied). Not a raw DB connection — least-privilege, Track-1 only.

## ✅ Verified LIVE 2026-08-02 (both ends of the pipe work)
- **Bigin API:** token in `~/.secrets/bigin-oauth.json` refreshes cleanly; scope `ZohoBigin.modules.ALL settings.ALL users.READ` (admin). Reads OK: **9 active users** (Chad `…2097047`, Megan `…1618001`, Nate `…2078003`, Jason, Garrett, Jeanie, Ethan, Rebekah, IT Admin); modules = Contacts/Accounts/**Pipelines**(=deals)/Tasks/Notes… Deals module reachable. → can create/update deals, link Accounts, read users.
- **Aspen → TRIM IT read:** already exists — `aspen-gateway/trimit-ro-query.sh` (read-only `HermanRO` on play GSTS) via `aspen-dispatch.sh` (Track-1 scoped; arbor-core/crew denied). → Aspen can read the cockpit's underlying data today.
- **Design:** complete + Skipper-approved → `aspen-knowledge/.../bigin-structure-and-plan.md`.

## ⚠️ Flags
- **Brent is NOT a Bigin user** (confirmed) → blocks the MUNICIPAL lane only; does NOT block sales (Chad/Megan/Nate/Scott). Add Brent later.
- **Security:** `trimit-ro-query.sh` has the `HermanRO` DB password in plaintext → rotate later (read-only login, low blast radius).
- **Data distinction:** old IE drip = NEW prospects → Chad's "Inland Empire Expansion" sub-pipeline. **THIS build = EXISTING TRIM IT customers from the cockpit** → each account's owning rep's STANDARD pipeline, stage-translated.

## Source-of-truth split (approved, no clobber)
TRIM IT/Cockpit = WORK facts (property, history, last service, LTV, contract-end, TPH, dry/rebid flags). Bigin = SALE motion (stage, owner, next action, close date, notes). Linchpin = shared ID: Bigin Deal custom field "TRIM IT ProjectID" + a `Workbench` link table (Deal ID ↔ TRIM IT key).

## Stage translator (cockpit 5 lanes → Bigin) — DRAFT, confirm at build
Follow up now → Potential Lead / Lost Job Follow Up · Bidding → Proposal Sent/Pre Bid · Scheduled(Won) → Go Ahead · Working → Job in Progress · Recently done → Closed Won/Recurring · 🔴 Running dry / 💰 Re-sell → tag + next-action.

## BUILD ORDER (dry-run before ANY write)
1. **Owner map:** TRIM IT `Projects.SalesRepID` → Bigin owner ID (Chad/Megan/Nate/Scott).
2. **Shared-ID link:** `Workbench` link table + Bigin "TRIM IT ProjectID" custom field on Pipelines.
3. **Cockpit read:** reuse the cockpit's exact stage SQL via `trimit-ro-query.sh` → accounts + lane + owner + flags.
4. **DRY-RUN push:** dedup vs existing Bigin Accounts/Deals; report what WOULD change; **Skipper reviews.**
5. **Go-live pilot** (one rep's book) → expand → pull-back/webhooks → Aspen drives (handoff).
