# Arbor AI + TrimIT — Background for Herman
*Prepared by Gilligan. If anything here conflicts with what Jason tells you directly, his word wins.
Contains project context only — no credentials or secrets.*

---

## 0. Your job, Herman (read this first)
You are building an **interactive character / guide that helps employees navigate Arbor AI** — a
friendly on-screen helper that explains features, answers "how do I…?" and "what does this mean?",
and walks people to the right place. **You are NOT building the app's structure or screens** — other
hands build those. Your job is the *guide experience that sits on top of them.*

So why all the context below? Because a good guide has to **understand the world it's guiding people
through** — what Arbor does, the tree-care vocabulary, and the look/voice of the product — or it'll
sound generic and wrong. Read §2 (what the app does) and §5 (the vocabulary) so your answers are
accurate, and §4 (the design language + the existing "Pro Tip" help pattern) so your character looks
and *talks* like it belongs in this product. Think of yourself as the **conversational evolution of
the Pro-Tip help system** described in §4.

---

## 1. The big picture (who, what, why)
- **The company:** Great Scott Tree Care (GSTS) — a ~$25M, 50-year-old tree-care company in
  Orange County, CA. Jason ("the Skipper") is COO.
- **TrimIT** = the company's existing ERP. Old, large, half-broken in places. Adobe ColdFusion 2023
  on IIS + SQL Server (~917 tables). It runs the business today.
- **Arbor AI** = the larger thing being built. A modern, AI-powered layer/app suite for the company.
- **The through-line:** the team has been **repairing TrimIT's UI** into a clean, consistent design
  system, and **that repaired UI framework is the foundation Arbor AI builds on.** So Arbor should
  *look and feel like* the repaired TrimIT screens (see §4), even where it's new code.

## 2. The flagship app you're supporting: "Municipal Tree Bid Manager"
An internal web app to run the **municipal bid pipeline** — track opportunities, estimate costs,
prepare compliant proposals, manage approvals, and track awarded work.

**Roles:** Admin · Estimator · Operations Manager · Sales/BD · Executive Reviewer · Read-only Viewer.

**The 12 functional areas (the PRD in one breath):**
1. **Dashboard** — open opportunities; bids due in 7/14/30 days; bids by stage (Lead → Reviewing
   Docs → Site Visit → Estimating → Internal Review → Submitted → Awarded → Lost); total est.
   revenue, win rate, pipeline value; **alerts** for missing docs / expired insurance / incomplete packages.
2. **Opportunity records** — bid name, agency, RFP/IFB #, service type, location, due date/time,
   pre-bid + site-visit dates, contract term/renewals, procurement type, status, est. value, bid/
   performance bond (y/n), **prevailing wage** (y/n), union reqs, **DBE/MWBE/small-business** reqs,
   insurance reqs, agency contact, notes.
3. **Document management** — upload/store RFP package, addenda, plans/specs, insurance certs, W-9,
   licenses, references, proposal drafts, pricing sheets, site photos, maps, checklists.
4. **Estimating module** (the heart) — line items; labor hours by role; crew size; equipment hours;
   disposal/dump fees; mobilization; traffic control; subs; permits; overhead; markup; contingency;
   tax; alternates. **Estimate by:** tree count, DBH size class, tree height class, access
   difficulty, pruning type, removal complexity, stump count, haul distance, emergency multiplier.
   **Outputs:** direct cost, burdened labor cost, total cost, margin, sell price, price per tree,
   price per crew day.
5. **Crew & production assumptions** — editable reference tables: crew templates, equipment, labor
   rates, burden rates, production rates by task, disposal rates, fuel + travel assumptions.
6. **Compliance checklist** — per opportunity: signed forms, acknowledgements, addenda receipt, bid
   bond, insurance docs, references, pricing sheet, exceptions, safety docs, schedule, licensing.
7. **Proposal generator** — produce a polished bid summary + package from app data (project summary,
   scope, assumptions, exclusions, pricing summary, alternates, schedule, contacts).
8. **Workflow & approvals** — Estimator drafts → Ops Mgr reviews production assumptions → Exec
   approves pricing → Sales/BD submits. Track timestamps + approval status.
9. **Notifications** — email/in-app for due dates, missing compliance, new addenda, approval
   requests, awarded/lost.
10. **Reports** — bids submitted by month; awarded vs lost; est. value vs awarded; win rate by
    municipality; margin by service type; upcoming due dates.
11. **Search/filter** — by municipality, due date, service type, status, estimator, awarded/lost,
    prevailing wage, bond requirement.
12. **Mobile-friendly** — update opportunities, notes, and site-visit observations from phone/tablet.

**Data model (entities):** Users, Roles, Municipalities/Agencies, Opportunities, Contacts,
Documents, Addenda, Estimate Versions, Estimate Line Items, Crew Templates, Equipment, Labor Rates,
Production Rates, Compliance Checklist Items, Approvals, Proposal Outputs, Site Visits, Notes,
Submission Records, Award Records.

**Business rules:** keep estimate version history; **lock approved estimate versions**; require all
compliance items before "Ready to Submit"; audit log for major changes; only Admins edit reference
tables; **Executive approval required above a configurable price threshold.**

## 3. The AI features you'll be guiding people to
Arbor's Bid Manager is an **improved version of the existing Inventory Pricing tool ("Price Buddy")**
the team already built — so users already know that lineage. Beyond plain data entry, these are the
smart features your character should understand and point people toward (so when someone's stuck, you
can say "drop the RFP here and it'll fill this in for you"):
- **RFP intake:** drop in an RFP PDF → AI extracts agency, due dates, bond/insurance/prevailing-wage
  requirements, service types → pre-fills the opportunity record. (Huge time-saver; bids are
  document-heavy.)
- **Compliance autopilot:** AI reads the bid package and flags missing/required items against the
  checklist automatically.
- **Estimating assistant:** natural-language or photo-driven entry ("80 mature oaks, prune class
  III, tight street access") → proposed line items, crew, production rates, and a draft price the
  estimator reviews. Explain *why* it priced that way.
- **Proposal drafting:** generate the scope/assumptions/exclusions narrative from the estimate data.
- **Conversational dashboard:** "which bids are due next week missing insurance?" answered in plain
  English over the live data.
- **Smart alerts:** proactive nudges (due-date risk, expiring insurance, margin below threshold).
Keep a **human-in-the-loop** on anything money or compliance related — AI proposes, a person approves.

## 4. The UI design language you MUST match (so Arbor feels like the repaired TrimIT)
There is a canonical design spec: **`gsts-ui-spec-v1.0.md`** (in the TrimIT Repairs folder — ask
Jason for it; it's the source of truth). The essentials:
- **Green brand palette** via CSS custom properties on `:root` (never hard-code hex). Key tokens:
  `--gsts-green-800 #4d6d31` (header bars/banners), `--gsts-green-700 #5a7a3a` (primary buttons,
  active tab, accents), KPI badges `--gsts-green-200 / --gsts-yellow-200 / --gsts-red-200`
  (good/watch/poor), chart blue `--gsts-blue-500 #3d7dd6`, text `#1f2a14`, panel bg `#f6f7f3`.
- **Components:** sticky green header bar (56px) with title + date-range pill; dark-green section
  banners; **KPI tiles** (white card, label top, big value, status badge bottom); tabs with green
  active underline; charts use the existing library + brand colors; warning "totals strip."
- **Typography:** system UI font stack (no web fonts). rem-based sizes defined in the spec.
- **Spacing/radius:** 4px base unit; cards radius 8px, buttons/badges 6px.
- **Responsive, mobile-first** (usable from ~360px up); single column < 640px.
- **Accessibility baseline:** contrast ≥ 4.5:1; visible focus rings (`--gsts-green-700`); keyboard
  reachable; status conveyed by **text as well as color**.
- **"Pro Tip" contextual help pattern:** every meaningful element gets a `data-protip-key`; a shared
  controller shows a friendly plain-English popover on hover (1.5s) / touch ("?" badge) / keyboard
  (?/F1, Esc). Copy lives in a JSON dictionary, executive-readable, 1–3 sentences. **Use this same
  pattern in Arbor** so users get the same help experience.
- **TrimIT's existing app rule:** vanilla JS/CSS, additive, no new third-party libs, **backup-first**
  before editing existing files. (This applies if you work *inside* TrimIT — see §6 open question.)

## 5. Domain glossary (so the UI speaks the language)
- **TPH (Trim-Per-Hour)** = dollars of production earned per crew-hour ($/crew-hour). The company's
  central productivity metric. **2026 target = $130** (higher is better). Surfaces everywhere.
- **WorkOrder** = a job. **GoAhead** = approved work not yet scheduled. **CrewSheet** = the crew's
  daily production record. **RFP/IFB** = the municipal solicitation document. **DBH** = diameter at
  breast height (tree size). **Prevailing wage** = government-mandated pay rates on public jobs.
  **DBE/MWBE** = disadvantaged/minority/women business-enterprise participation requirements.
  **Bid bond / performance bond** = financial guarantees often required on municipal work.
- Service types span pruning, removals, stump grinding, emergency response, inspection, inventory,
  planting, vegetation management. (Note: TrimIT historically has ~419 messy service types being
  rationalized toward ~50 ANSI A300-aligned ones — keep service-type lists clean/configurable.)

## 6. Tech notes + open decisions (confirm with Jason before architecting)
- **TrimIT stack:** ColdFusion 2023 + IIS + SQL Server. Data-driven menu. File naming `Name$Sub.cfm`.
- **Build target (RESOLVED):** the Bid Manager is **not greenfield** — it's an improved version of
  the existing **Inventory Pricing tool ("Price Buddy")**, which lives in the repaired TrimIT
  framework. So it inherits TrimIT's stack + the design language in §4. (You're building the *guide
  character* on top, not the app itself — see §0.)
- **For your character specifically, confirm with Jason:**
  - **Where it lives / how it embeds** — is the character a widget inside the web app, a side panel,
    a floating avatar? How does it get invoked?
  - **What it can see/do** — does it just answer questions and navigate (point/explain), or can it
    also take actions on the user's behalf (open a screen, pre-fill a field)?
  - **Its AI backend** — which model/service powers your character, and does it have read access to
    Arbor's data so it can answer live questions ("which bids are due this week?")?
  - **Persona** — name, voice, look. Match the GSTS brand (§4) and keep the friendly, plain-English,
    executive-readable tone of the Pro-Tip help copy.

## 7. Where to go deeper (canonical source docs — ask Jason)
- `Arbor AI/A.I/Arbor AI plan.docx` — the full Municipal Tree Bid Manager PRD.
- `Arbor AI/Trim IT Repairs/gsts-ui-spec-v1.0.md` — the canonical UI/design spec (palette, components, Pro Tips).
- `Arbor AI/Trim IT Repairs/TRIMIT_KNOWLEDGE_BASE.md` — how TrimIT is structured.
- The shipped TrimIT dashboard repairs (Sales Pipeline, Revenue Performance, Executive Financial
  Overview, Market Focus, Price Buddy) — living examples of the design language in action.

---
*Net: you're building the **interactive guide character** for Arbor AI (§0) — not the app itself.
Know what the app does (§2) and the smart features to point people to (§3), speak the tree-care
vocabulary (§5), and look + talk like it belongs in the GSTS green product as a conversational
evolution of the Pro-Tip help system (§4). Settle the character-specific questions in §6 with Jason.*
