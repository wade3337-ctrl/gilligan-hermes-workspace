---
title: TRIM IT Audit 02 — Contact / Location Setup
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, contact, location, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-01-customer-creation]]", "[[trimit-db-cleanup]]"]
updated: 2026-08-01
---

# TRIM IT Audit 02 — Contact / Location Setup

> Stage 2 of the [[trimit-deep-audit]]. **Map-only pass (Skipper "A")** — zero writes. Every figure below is
> from a `gsql.sh` query or a file read run THIS session. Entities that hang directly off a `Company`
> ([[trimit-audit-01-customer-creation]]): **Contacts** (people) and **Locations** (sites).

## ⭐ Headline: TRIM IT has TWO write architectures (discovered here)
Stage 1 saw only proc-driven creation. Stage 2 shows the full picture:
- **CREATE = proc-driven** (same as Stage 1): `CodeGenerateContact.cfm` → `dbo.GenerateContact(@ZCompanyID)`; `GenerateLocation.cfm` → `dbo.GenerateLocation(@ZCompanyID)`. Both take **only `@ZCompanyID`** → a new Contact/Location is born **blank, attached to a Company**, then filled in by editing.
- **EDIT = inline `UPDATE` in the .cfm** (a *different* pattern): `Synch.Contact.Update.cfm` does a literal `UPDATE dbo.Contacts SET …`; `Synch.Location.Update.cfm` does `UPDATE dbo.Locations SET …`. These are **Dreamweaver "MM_UpdateRecord" auto-generated forms** (2005 Macromedia templates), NOT stored procs.
- **Audit implication:** for each entity you must check BOTH the `Generate*` proc (create/derived fields) AND the `Synch.*.Update.cfm` (the real column-by-column edit path). They can disagree.

## 1. Entry points (code) — verified by reading each file
**Contacts**
- Create: `CodeGenerateContact.cfm` (4-line `<CFSTOREDPROC dbo.GenerateContact>`, `@ZCompanyID`, then `parent.location.reload()`).
- Edit form + handler (one file, self-posting): `Synch.Contact.Update.cfm` → inline `UPDATE dbo.Contacts` (16 cols) gated on `FORM.MM_UpdateRecord EQ "ContactForm"`.
- Other: `Profile.Contact.Update.cfm`, `Profile.Contact.Detail.cfm`, `Synch.Contacts.Content.Merge.cfm` (dedupe/merge UI — relevant to §5).
**Locations**
- Create: `GenerateLocation.cfm` (`<CFSTOREDPROC dbo.GenerateLocation>`, `@ZCompanyID`, reload).
- Edit: `Synch.Location.Update.cfm` → inline `UPDATE dbo.Locations` gated on `MM_UpdateRecord EQ "LocationForm"`.
- Location is a whole subsystem: ~40 `Synch.Location*` pages (map, inventory, service types, streets, zip-regions).

## 2. Data model (verified live)
**`dbo.Contacts` — 12,827 rows, 34 columns.** Lean people table: name (`FirstName`/`LastName`/`FullName` computed), phones, address, `email`, `ContactTitle`, `ContactTypeID`, `IsPrimary`, `ParentContactID` (self-ref for merge), merge flags `IsMergeFrom`/`IsMergeTo`.
- **Parent FK: only `Companies`** (`FK_Contacts_Companies`). A contact belongs to one company.
- **Child tables (4):** `CompanyContracts`, `ContactNotes`, `Contracts`, `Projects` (contacts are referenced as the billing/site contact on projects & contracts).

**`dbo.Locations` — 30,708 rows, 123 columns.** The site/inventory hub, heavily denormalized:
- Real data: address block, `Latitude`/`Longitude`, `TotalTrees`/`GSTSTrees`/`LandscaperTrees`, inventory defaults, access flags (`IsBucketAccess`, `IsPermitRequired`).
- **~40 columns are pure MAP RENDERING STATE** (`MapDisplayBoundaries`, `MapDisplayTrees`, `MapDisplayMarkers`, `MapForceRedisplay`, font sizes, offsets…) — UI state stored on the data row. Big normalization/cleanup question for later.
- **10 parent FKs:** `Companies`, `StatusDefs`, `ServiceTypes` (×3), `SizeModelSizes` (×2), `SizeUOMs`, `HeightRanges`, `HeightModels`.
- **40 child tables FK to `LocationID`** — it's the anchor for the entire inventory/mapping/service-type graph.

## 3. Used vs. dead
- **Used:** `GenerateContact`, `GenerateLocation`, `Synch.Contact.Update.cfm`, `Synch.Location.Update.cfm`, the FK graphs.
- **Dead / orphan (flagged):** `Profile.Contact.Update$dev.cfm`, `Synch.Contacts.Content$dev.cfm`, `Profile.Location.Update.New$dev.cfm`, `Synch.LocationServiceTypes.Content$dev.cfm`, `Synch.LocationZipRegion.Update$dev.cfm`, `Synch.LocationZipRegion.UpdateTest.cfm`, `CompanyLocationsContent1212.cfm`, `Demo0010.cfm`, `UpdateLocationGeneral$dev` proc.
- **Proc-bloat cluster:** `UpdateAddressDefs$DefaultLocationID` has **6 near-identical copies** (incl. `$06232015` date-stamped backups); the `EvaluateLocationZipRegion` family has ~15 variants incl. `EvaluateXXLocationZipRegion`, `EvaluateZZLocationZipRegion` (XX/ZZ prefixes = classic "parked/dead" markers). Flag, verify callers, don't drop.

## 4. Works vs. broken
- 🐛 **Blank-overwrite data-loss trap (BOTH edit handlers).** Every field is written as `<cfif FORM.x NEQ ""> value <cfelse> '' </cfif>` (or `NULL`). So saving the edit form with a field left blank **overwrites the stored value with empty** rather than preserving it. A partial edit silently wipes data. Present in `Synch.Contact.Update.cfm` and `Synch.Location.Update.cfm`.
- 🔓 **Contact edit has no company/ownership binding.** `UPDATE dbo.Contacts … WHERE ContactID=<FORM.ContactID>` — the target ID comes from a hidden form field with no check that the contact belongs to the current company/user. Editing is by raw ID. (Consistent with the framework-level "trusts the cookie/ID" pattern seen in the dashboard-auth work.)
- ⚠️ **`FullName` is stored, not derived at read** (81-char col) — can drift from `FirstName`+`LastName` if one path updates parts but not the whole.

## 5. Cleanup candidates (FLAG only — map-only pass)
- **Contacts duplication is REAL and quantified (reconciles the 2026-07-20 ~30% claim):**
  - 12,827 total; **1,904 (15%) have a blank `FullName`.**
  - **1,359 duplicate groups** by (`FullName`,`CompanyID`) covering **5,189 rows → 3,830 excess rows (~30% of non-blank contacts).** Matches the July-20 audit's "~30% dupes."
  - **9,200 (72%) have NULL `StatusDefID`** (no Active/Inactive status set) — only 3,499 are marked Active. Status hygiene is nearly absent.
  - Merge machinery already exists (`IsMergeFrom`/`IsMergeTo`, `ParentContactID`, `Synch.Contacts.Content.Merge.cfm`) → dedupe is a designed-for operation, good candidate for the "cleanup as testing" rehearsal later.
- **Locations:** 30,708 rows; the ~40 `MapDisplay*` UI-state columns are a denormalization cleanup candidate (move render prefs off the data row). Verify usage before touching.
- **Dead .cfm / proc clusters** from §3.

## 6. Knowledge delta
- **Already knew:** [[trimit-audit-01-customer-creation]] (Company is the parent; proc-driven create pattern), [[trimit-db-cleanup]] (~30% contact dupes claim — now reconciled with live counts).
- **NEW this pass:** the **two-write-architecture** finding (proc create vs. inline-UPDATE edit); Contacts = 34 cols / lean / only-Companies parent / 4 children; Locations = 123 cols (40 are map-render state) / 10 parents / 40 children; the **blank-overwrite data-loss trap** in both edit handlers; contact edit has no ownership binding; live dupe/blank/NULL-status counts; the `UpdateAddressDefs`×6 and `Evaluate*LocationZipRegion`×15 (XX/ZZ) proc clusters.

## ✅ WRITE-TEST VERIFICATION (2026-08-01, Skipper-directed) — findings exercised with real writes
**Method:** PLAY only (prod write blocked), every write `BEGIN TRAN … ROLLBACK` (executes for real, then reverts); zero residue confirmed; create procs already proven in Stage 1 (T4/T5). Test contact: ContactID 222182 (Jennifer Eldair, jeldair@actionlife.com).

| # | Finding (map-only claim) | Write-test | Verdict |
|---|---|---|---|
| 1 | **Blank-overwrite data-loss trap** in the edit handler (blank field → `''` wipes stored value) | S2-T1: ran the handler's blank-email branch (`SET email=''`) on a contact with a real email | ✅ **CONFIRMED — populated email `jeldair@actionlife.com` wiped to empty.** A partial edit that leaves a field blank destroys the stored value. Real data-loss risk. |
| 2 | `FullName` is STORED (not derived) and can DRIFT from First/Last | S2-T2: changed `LastName`→`ZZWRITETEST` via the handler (which never sets FullName) | ❌ **REFUTED — `FullName` auto-updated (`Jennifer Eldair`→`Jennifer ZZWRITETEST`).** Something (trigger/computed col) maintains it, so it does NOT go stale. My drift concern was wrong. |
| 3 | Contact parent FK = `Companies` | S2-T3: `SET CompanyID=-99999` | ✅ CONFIRMED enforced (`FK_Contacts_Companies` rejected it) |
| 4 | Edit targets `WHERE ContactID=<form value>` with no ownership check | UPDATE by raw ContactID succeeded with no company binding | ✅ consistent (edit-by-raw-ID; structural, read+write consistent) |

**Correction to §4 of this note:** the "`FullName` stored, can drift" concern is refuted — FullName IS auto-maintained. (The 1,904 blank-FullName contacts are blank because First+Last are both empty, not a maintenance failure.) The **blank-overwrite trap (§4) is CONFIRMED real** and is the more important defect. Residue: identity/counter ticks only; test contact left intact after rollback.

## Resume pointer
**Stage 2 COMPLETE (map-only, 2026-08-01).** Create + edit paths for Contact & Location confirmed by file read;
data model, FK graphs, and cleanup signals captured live. **Next = Stage 3: Lead → Proposal / Bid**
(`GenerateProposal*` — the biggest proc family in the app; `Profile.Project.Detail.cfm`, `Proposals` table).
Deferred details: read the full `GenerateContact`/`GenerateLocation` proc bodies for which columns they seed on
create; confirm whether the blank-overwrite trap has ever caused real data loss (would need history/audit). Cleanup
execution still deferred (map-first) — but the **contact dedupe** is the standout candidate for the first rehearsal.
