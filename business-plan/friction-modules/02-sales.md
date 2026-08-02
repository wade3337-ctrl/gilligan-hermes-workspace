# Friction Module 02 — Sales

**Status: node COMPLETE (2026-08-02).** Part of the Friction Hit List → 5-Year Business Plan.
🔒 Fort Point / owner-tier.

---

## The people / structure
- **Sales Admin (3):** Rosa, Evie, **Lorena** (Lorena replaced Luly Arita, who left — turnover realized the bus-factor risk).
- **Sales Arborists (4):** **Scott (the CEO, backfilling a seat while hiring — and enjoys it)**, Garrett, Ethan, Rebekah. ⇒ **short a permanent arborist.**
- The BD reps feed RFPs in *through* the admin trio.

**What the structure tells us:**
- The **admin trio is the manual workflow engine** — RFP setup → proposal send → go-ahead activation → scheduling handoff. Every Section-A friction item runs through these three people; the process lives in their hands, not the system (bus-factor).
- The **arborists hold pricing + scope judgment** (no formula; Price Buddy only assists) — speed risk (the bottleneck on the 6-day bid turnaround), consistency risk (4 instincts), key-person risk.

## The thesis (the Skipper's own words = the operating-leverage case)
> "I need to facilitate **$50M in sales without adding admin**, and that's impossible with today's tools, process, and structure."

Target state he added: **decouple revenue from admin** — the arborist does the whole bid on-site; admin shifts from *bid assembly* to **staging the job upfront, follow-up, and scheduling** (force-multiplier, not bottleneck).

## The committed fix + our access
- **Committed fix = the Travis/Jordan "WorkPhloem" build** on the dev server (ArborNote-style Field App). **Our arbor-core work is exploration / benchmark / fallback, not the production path** (Skipper's call, 2026-08-02).
- **We now have live visibility into it** — built a server-side browser (see `[[dev-browser-access]]`), logged into dev as the Skipper, walked all 5 stages observe-only.

## WorkPhloem verdict — evidence-based (this is the nuanced part)
Walked Company Setup → Project Setup → Map Setup → Field App BETA → Pricing Worksheet on a real project (Quail Hill, ProjectID 1103460).

**It is neither "just a reskin" nor "the 5× disease survives." Both readings were too simple.**
- **The 4 prior critical-path defects are FIXED** — the map renders on the real property with **401 tree markers plotted** (was 6 assets / ocean-zoom 9 days ago).
- **It writes to the REAL shared tables** — `Field.Company.Create.cfm` / `Field.Project.Create.cfm` create real `Companies`/`Projects`/`Locations` records (same `Desc1`/`ZipCodeID` columns as legacy), with a **search-first duplicate check** on new company. A customer made here is a real TRIM IT customer, not a parallel copy.
- **Identity/address data already flowed** down the chain in *legacy* TRIM IT (RFP carries the project address; `GenerateProposal` reads Project/RFP/Location and copies the address into the Proposal). Not new, not re-keyed.
- **Scope also flows via generator procs** — `GenerateProposal` reads the **worksheet**; the `GenerateWorkOrderLines*` family reads `ProposalLines` and writes the work-order scope. `RFPItems` do **not** feed `ProposalLines` — scope is built in the **inventory worksheet** and generated forward.

**⇒ The genuine value:** the FieldApp digitizes **inventory/scope CAPTURE** (401-tree map → worksheet) — which is the *actual* manual origin (replacing Excel photo sheets + Google-Earth maps + hand counts). The object-to-object flow was already automated; this attacks the part that wasn't.

**⇒ Two unclosed seams (the real gaps):**
1. **It does not create the RFP** — that's still done in old TRIM IT.
2. **No one-click proposal generation in the UI** — the `GenerateProposal` engine exists in the backend, but the worksheet UI only offers **Apply / Export**.

**⇒ Missing vs our own future-state spec:** live-totals/TPH reconciliation, inline Price Buddy at pricing, and a customer-facing map + approve-by-click — **none present.** The pricing worksheet is still the arborist filling cells by hand (digital paper).

## 🚨 Correction this node forced (must propagate)
**The "data re-keyed 5×" headline is refutable as written.** The DB shows scope is *generated* between objects (Worksheet→Proposal→WorkOrder), not hand-typed. The **defensible** friction is more precisely located:
- field inventory/scope **capture** (photo sheets, Google Earth, hand counts),
- **out-of-system artifacts** (PDF assembly, maps, attachments),
- the confirmed **transcription points** (production paper → keyed; QuickBooks re-key),
- and the **"created-after-the-fact" back-entry** — people work *outside* the tool and back-fill it, which **bypasses the auto-generation entirely.**

**The deepest reframe:** the tool already has the plumbing to flow data; the fix is making it fast/usable enough on-site that people work **in** it instead of around it — which is exactly the FieldApp's premise. So the build is aimed correctly; it just hasn't closed the two seams.
→ **Re-precise Section A (A2/A3) of `FRICTION-HIT-LIST.md` and the investor case before any Fort Point use.**

## Sources / evidence (all this session, 2026-08-02)
Live dev walkthrough (`~/.local/devscout/`), and read-only play-DB traces: create-JS (`main.js`), `sys.triggers` (no RFP cascade on Project/Company insert), `GenerateProposal`/`GenerateWorkOrderLines*` proc definitions, Quail Hill instance trace (RFP street = project address).
