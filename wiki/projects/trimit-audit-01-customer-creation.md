---
title: TRIM IT Audit 01 — Customer Creation
type: project
domain: work
track: 1
status: done
tags: [trimit, audit, customer-creation, company, schema-map]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-db-cleanup]]"]
updated: 2026-08-01
---

# TRIM IT Audit 01 — Customer Creation

> Stage 1 of the [[trimit-deep-audit]]. **Map-only pass (Skipper chose A, 2026-08-01)** — zero writes to
> the app/DB. Every figure below is from a command run THIS session (gsql.sh / SSH to the play box).

## 0. Where the app actually lives (foundational, verified 2026-08-01)
- **Live TRIM IT webroot = `D:\home\dev.greatscotttreeservice.com\wwwroot\GSTS\` on the play box (100.86.97.46) — 8,645 `.cfm`.** This is the real ERP.
- ⚠️ NOT `C:\ColdFusion2023\cfusion\wwwroot\GSTS\` — that's only *our* 11-file dashboard drop folder. Easy to confuse.
- The vendor's separate SaaS product sits alongside at `D:\home\arbortools.net\wwwroot\` (1,264 cfm; 1,151 in `auto/`).
- **Color folders (Steel, Tan, Water, Yellow, Chrome, Red, Blue…) are NOT full app copies** — `Client.ControlPanel.Master.cfm` exists only at the GSTS root (single canonical copy). They're theme/section folders, audited later.
- **Vocabulary:** a "customer" = a **`Company`**; the record screen is `Client.ControlPanel.Master.cfm` ("Client" = the customer-facing term). Below a Company sit **Contacts** (people) and **Locations** (sites).

## 1. Entry points (code) — CONFIRMED end-to-end
The customer-create write path, verified by reading each file/proc this session:
- **UI form:** `Profile.Company.Focus.cfm` (the company edit/detail "Focus" screen). Dead twins alongside it: `Profile.Company.Focus$dev.cfm`, `$dev2.cfm`.
- **Executor:** **`Synch.CodeGenerateCompany.cfm`** — a 4-line page that does `<CFSTOREDPROC procedure="dbo.GenerateCompany"><CFPROCPARAM @ZCompanyID=#ZCompanyID#></CFSTOREDPROC>` then `parent.location.reload()`. (Sibling: `Synch.CodeGenerateCompanyByUserID.cfm`.)
- **Proc (the write):** `dbo.GenerateCompany(@ZCompanyID INT)` → `INSERT INTO [GSTS].[dbo].[Companies] (Desc1, Created, CreatedByID, StatusDefID, SalesRepID, …)`. Variants: `GenerateCompany$FromPS`, `GenerateCompanyByUserID`, `UpdateNewCompany`, `Duplicate$Company` (clone-an-account).
- **Triggers fire on write:** `CompaniesPostInsert`, `CompaniesPostUpdate`.
- **`NewCompany.cfm` is a DEAD STUB** — 2005 Dreamweaver template, zero form fields, zero logic. NOT the create path. → cleanup candidate.
- **No `.cfm` does an inline `INSERT INTO Companies`** (grep of all 8,645 files = 0 hits) — every write is proc-driven.

### 🏗️ TRIM IT architecture pattern (discovered here — applies to EVERY stage)
This naming convention is the key to auditing the whole ERP fast:
- **`Profile.<Entity>.Focus.cfm`** = the edit/detail form (UI). (e.g. `Profile.Company.Focus`, `Profile.Contacts.Focus`, `Profile.Project.Focus`.)
- **`Synch.Code<ProcName>.cfm`** = a thin page whose only job is to run ONE stored proc via `<CFSTOREDPROC>`, then reload the parent frame. This is how the UI triggers all writes.
- **`Synch.<Entity>.Focus.cfm` / `.Update.cfm`** = the save/synch handlers.
- **Business logic lives in the ~3,600 stored procs, not the `.cfm` files.** Audit procs, not just pages.
- ⚠️ **`$dev` / `$dev2` / `.Dev` twins are everywhere** = dead copies (flag per stage).
- ⚠️ **A "test" file can be wired into a LIVE page:** `Client.ControlPanel.Master.cfm`'s logo links to `Client.ControlPanel.Master_MP_Test.cfm` — so "_MP_Test"/"$2" names are NOT automatically safe to drop; check inbound references first (repair-contract).

## 2. Data model (verified live)
- **Target table `dbo.Companies` = 3,203 rows, 133 columns.** Core identity cols: `CompanyID` (PK), `Desc1` (name), `Nickname`, address block (Street/City/State/ZipCode/ZipCodeID), phones, `StatusDefID`, `SalesRepID`, `Created`/`CreatedByID`/`LastModified`.
- **Must-exist-first (parent FKs):** `CommissionGroups`, `Markets`, `ZipCodes`.
- **The whole workflow hangs off `CompanyID` — 31 child tables FK to Companies**, incl. the entire lifecycle: `Contacts` (12,827), `Locations` (30,708), `Projects`, `Proposals`, `GoAheads`, `WorkOrders`, `Invoices`, `ContractPeriods`, `CrewPackets`, `WebUserAccounts`, `SystemLogs`. → Customer creation is the literal root of the data graph; every later stage inherits CompanyID.
- Supporting company sub-tables: `CompanyCalendars` (413,533), `CompanyPeriods` (13,578), `CompanyYears` (1,050), `CompanyContracts` (146), `CompanySummary` (12,773), `CustomerNumbers` (19,112).

## 3. Used vs. dead
- **Used:** `GenerateCompany` (+ FromPS/ByUserID), `Companies`, the 31-child FK graph, the two triggers.
- **Dead / orphan (flagged, not touched):**
  - `NewCompany.cfm` — 2005 stub, no logic.
  - Root `.cfm` litter in the Client subsystem: `Client.ControlPanel.Master$dev_DeleteLater.cfm`, `…$2.cfm`, `…_MP_Test.cfm`, `Client_InvoiceMaster_Summary_MP_Test.cfm`, and a `$dev` twin family (`Client-Observations$dev`, `-Calendars$dev`, `-Groups$dev`, `Client-ClientActions-Groups$dev`, `Client-PSHB-Observations$dev_DeleteLater`).
  - **Per-client-ID hardcoded pages:** `Web.Client.1094998.Location.Update.New.cfm`, `Web.Client.1096746.*` — client IDs baked into filenames (generated litter or one-off hacks).

## 4. Works vs. broken
- No functional defect found in the create path this pass (map-only). `GenerateCompany` inserts cleanly; triggers present.
- **Structural smell (not a bug):** `Companies` is heavily **denormalized** — ~80 of 133 columns are stored *derived rollups* (`Prior01–06`, `Future01–06`, `YTD/HTD*`, `*Hours`, `*TPH`, `CurrentBalance`, `Contract*`, min/mid/max lat-long). These are maintained by procs/triggers, so they can drift from source. Normalization = a later-stage question, not Stage 1.

## 5. Cleanup candidates (FLAG only — nothing dropped; map-only pass)
- **`zDelete-*` tables still LIVE in the DB (some from 2011):** `zDelete-LocationZipRegionsBackup` (56,223), `zDelete-MyProjectContacts` (15,238), `zDelete-TempCustomerSites` (6,279), `zDelete-Contacts$02282011` (3,378), `zDelete-Contacts$02232011` (3,375), `zDelete-CustomerExport08` (2,110), `zDelete-CustomerExport2` (2,005), `zDelete-ContactEmails` (627), `zDelete-DemoTables` (still FK'd to Companies!). → matches the 2026-07-20 audit's "5.63 GB dead tables."
- **Dead/backup/test stored procs** (from a `Generate%`/pattern sweep): `GenerateProposal$dev$03182010`, `$dev$09112013`, `GenerateProjectMaster$Current$dev$old`, an ~11-copy backup family `GetEmployeesWorkingHours_PayrollPeriod_npr_{BK…2019, test, nprTRAVISBACKUP}`, `SaleRepCommission_PayrollPeriod_npr{TEST,TEST1,ForScott,19032019}`, literal `test1/test2/test3/test25`.
- **Dead `.cfm`** listed in §3.
- `DevCompanies` (91), `MyCompanies` (181) — confirm dev/test vs. live before flagging.

## 6. Knowledge delta
- **Already knew** (extended, not re-derived): [[trimit-db-cleanup]] (2026-07-20 audit: dead tables/proc bloat, contact dupes ~30%), customer-verifier (CustomerList 414/414).
- **NEW this pass:** the real webroot path + the "wwwroot\GSTS is only our drop folder" trap; color folders aren't full dupes; **customer = `Company`, created by proc `GenerateCompany` (not a form page); `NewCompany.cfm` is dead;** Companies = 133 cols / 3,203 rows with 31 FK children (creation = root of the data graph); parent FKs Markets/ZipCodes/CommissionGroups; PostInsert/PostUpdate triggers; live 2011-era `zDelete-*` tables.

## Resume pointer
**Stage 1 COMPLETE (map-only, per Skipper "A", 2026-08-01).** Both loose ends closed with evidence: create
path confirmed `Profile.Company.Focus.cfm` → `Synch.CodeGenerateCompany.cfm` (CFSTOREDPROC) → `dbo.GenerateCompany`;
control-panel screen read. **Next = Stage 2: Contact / Location setup** (`GenerateContact`, `GenerateLocation`,
`Profile.Contacts.Focus.cfm`). One optional deferred detail: skim the full `GenerateCompany` body for which of
the ~80 derived columns it seeds vs. leaves to triggers. Cleanup execution stays deferred (map-first).
