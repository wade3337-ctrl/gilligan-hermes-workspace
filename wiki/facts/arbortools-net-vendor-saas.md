---
title: arbortools.net — the vendor's "Automate" low-code SaaS (ArborTools tree-care vertical), inert on the play box
type: fact
domain: work
track: 1
status: active
tags: [trimit, vendor, arbortools, automate, saas, play-box, cleanup, competitive-intel, arbor-core]
applies: ["[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]", "[[trimit-audit-01-customer-creation]]", "[[vendor-fieldapp-build]]", "[[trimit-server-topology]]", "[[arbor-mission-strategy]]"]
created: 2026-08-01
updated: 2026-08-01
---

# arbortools.net — the vendor's Automate/ArborTools SaaS (detailed)

Found in [[trimit-deep-audit]] Stage 1; the Skipper asked for a detailed understanding (2026-08-01).
Investigated live on the play box (100.86.97.46, `D:\home\arbortools.net\wwwroot`). **Bottom line: it is the
vendor's own commercial, multi-tenant, low-code SaaS platform ("Automate"), branded for arborists as
"ArborTools" — and it is a MORE modern codebase than TRIM IT. On our play box it is inert (dead code copy).**

## 1. What it is (evidenced)
- **Product pitch (from `index.cfm`):** *"Built for Safe, Efficient Tree Work · Built for Professional Arborists · Safe. Efficient. Professional. · Member Registration."* → a subscription SaaS for the tree-care industry.
- **Platform = "Automate"**, a low-code/no-code business-app builder; **ArborTools is its arborist vertical.** Datasource `APPLICATION.dsnName = "ARBORTOOLS"` (`scripts/global-variables.cfm`); `APPLICATION.PRODUCT_NAME` derives generically from the DB product name (framework behavior — the same code ships under many brands).

## 2. Scale & tech stack (~35,000 files, ~380 MB)
| Area | Files | What |
|---|---|---|
| **Porto** | 7,541 (105 MB) | Commercial Bootstrap website theme (the public site) |
| **PortoAdmin** | 5,617 (75 MB) | Porto admin-dashboard theme (the app backend UI) |
| **fontawesome** | 14,839 (98 MB) | Icon library |
| **auto/** | 1,154 (6.5 MB) | The **Automate low-code engine** (api, calendar, databases, scripts) |
| **Automate/** | 269 (4.5 MB) | Platform library (`BackEnd/` + `FrontEnd/`) |
| **cfc/** | 15 (1 MB) | The ColdFusion logic layer (below) |
| img · js · css · calendar · emails · jobs · webhooks · OpenAITest · api | — | supporting modules |
- File mix: 21,584 `.svg`, 2,149 `.jpg`, **1,264 `.cfm`**, 1,179 `.js`, 1,027 `.html`, 663 `.png`, 625 `.css`, 351 `.scss`. Modern web stack (SCSS/LESS, Bootstrap) — unlike TRIM IT's 2005 Dreamweaver tables.

## 3. The engine (`cfc/` — a serious codebase)
`Backend.cfc` **257 KB** · `AutomateDatabaseSnapshot.cfc` **199 KB** (DB migration/snapshot engine) · `Frontend.cfc` 185 KB · `PayPal.cfc` **156 KB** (billing) · `Data.cfc` 121 KB (data-access layer) · `Utils.cfc` 100 KB · `AmazonS3.cfc` (file storage) · `Calendar.cfc` · `SecurityUtils.cfc` · `ErrorHandling.cfc` · `BlogNewsletterFrontend` · `PortfolioFrontend` · `MenuFrontend` · `TimezoneBackend`.

## 4. What it DOES — the 143-table `automate_*` data model
A full business suite, defined as data (the low-code hallmark):
- **Low-code core:** `automate_crud`, `crud_column_field_type`, `crud_form_section`, `global_table`, `system_table`, `database_snapshot`, `database_driver`, `webhook_data`, `javascript_event` → build tables/forms/automations through the UI.
- **Multi-tenant SaaS billing:** `website_plan`, `website_plan_feature`, `website_plan_subscription`, `website_plan_type`, `website_promo`, `subscriber`, `subscriber_admin`, `hostname` → **this is a product SOLD by subscription to many tenants.**
- **CRM / sales:** `lead_company`, `lead_contact`, `lead_industry`, `lead_keyword(+category/subcategory/assign)`, `lead_probability`, `lead_source`, `lead_status`, `lead_vertical`.
- **Accounting / billing:** `invoice`, `invoice_line`, `invoice_status`, `invoice_type`, `income`, `income_type`, `paypal_transaction`, `refund`, `product`, `product_category`, `store`, `currency_code`.
- **Helpdesk / ticketing:** `email_ticket(+priority/rating/status/support_tier/support_tier_agent/type/user_permission)`, `email_message(+recipient)`, `mailbox(+protocol/import_action)`, `email_method`.
- **CMS / community:** `blog(+category/comment/tag/subcategory)`, `newsletter(+comment/tag)`, `forum(category/post/topic)`, `faq(+category)`, `testimonial`, `portfolio(+category)`, `photo(+gallery)`, `video(+gallery)`, `webpage`, `homepage_slide`, `frontend_menu`, `sweepstakes(+entry)`, `feedback`.
- **HR:** `employee(+department_assign/filing_status)`, `department`, `skill`, `user_skill_assign`, `office`.
- **Security / moderation:** `user(+admin/permission/login_restriction)`, `group(+permission/user)`, `permission`, `activity_log`, `banning(_log/_type)`, `blocked_email`, `saved_search`, `history`, `note`.
- **AI (baked in):** `openai_audio_model`, `openai_image_model`, `openai_language_model` + `OpenAITest/OpenAI.cfc` (`chatCompletion`, `_apiCall` → `api.openai.com/v1/`). The vendor wired OpenAI (chat/image/audio) into the platform.
- **Arborist vertical bits:** `land_area`, `land_area_type`, `inventory_location`, `affiliate_referral`.

## 5. Status on OUR play box: INERT (dead code copy)
1. **Not served by IIS** — the box binds only `play.greatscotttreeservice.com` → the TRIM IT webroot (+ `playapi…`). `arbortools.net` has **no IIS binding**.
2. **Datasource undefined here** — `ARBORTOOLS` appears **0×** in ColdFusion's `neo-datasource.xml`; it cannot connect to a DB on this box.
3. **No ARBORTOOLS database** among the 10 on the play SQL server (GSTS · Workbench · GSTSBACKUP · system/DW DBs). Its data lives on the vendor's live SaaS servers, not here.
4. **Never developed here** — all files share one 2026-04-25 bulk-copy window (same restore that laid down TRIM IT). It rode along in the clone.

## 6. Relationship to TRIM IT + why it matters strategically
- **Same vendor, two products.** TRIM IT (`dev.greatscotttreeservice.com/GSTS`, 8,645 cfm, 2005 Dreamweaver era) = GSTS's **bespoke ERP**. ArborTools/Automate = the vendor's **modern, productized, multi-tenant SaaS** (Porto UI, S3, OpenAI, webhooks, subscription billing). See [[vendor-fieldapp-build]] (same vendor's newer field-app rebuild).
- **ArborTools/Automate is architecturally newer and broader than TRIM IT** — but it is a *generic* low-code platform with a thin arborist skin, NOT the deep tree-care ERP GSTS runs on. TRIM IT's depth (inventory, crew sheets, go-aheads, municipal contracts) is the moat; Automate is breadth.
- **Relevance to [[arbor-mission-strategy]] / arbor-core:** this is the vendor's "answer" in the same space we're building. Useful competitive intel for any build-vs-buy-vs-leverage-vendor conversation — and a reminder that the vendor already has a low-code CRUD + AI platform they could point at GSTS. It does **not** change our TRIM IT audit (no shared DB, inert here).

## 7. The OpenAI integration (detailed, read 2026-08-01)
**What it is: an AI programmatic-SEO content-farm engine** (in `OpenAITest/`, organized by content type: `Blog/`, `BlogComments/`, `Newsletter/`). Not deep, but a real, working pattern:
- **`OpenAI.cfc`** = a clean, thin, textbook OpenAI REST wrapper: `chatCompletion(messages, temperature, top_p, max_tokens, presence/frequency_penalty…)` → `cfhttp POST` to `api.openai.com/v1/chat/completions`, Bearer auth, JSON in/out. Well-written; nothing proprietary.
- **`Blog/OpenAITest.cfm`** = the driver: pulls up to **500 `automate_land_area` rows** (cities/counties/zips), builds keyword phrases like *"[Service] In [City, State]"*, and fires one AJAX call per phrase to `api.cfm`, marking each land area `_blog = 1` (processed-once). Placeholder service in the test is literally *"Accident Lawyers"* — generic high-value SEO copy, i.e. the platform is industry-agnostic; ArborTools is just one skin.
- **`Blog/api.cfm`** = the generation call: model **`gpt-3.5-turbo`**, single-shot prompt *"Write me a unique blog article with at least 1500 words and seven paragraphs about [keyword] … Optimize the content for SEO. Use an article spinner so that the content is unique …"*. Then it parses the HTML (`<h1>`→title, body→content, first 250 chars→preview), matches the text to a land area, and `INSERT`s an `automate_blog` row.
- **`findAndUpdateLandArea.cfm`** = backfill: loops existing blog posts, links each to its matching `land_area` by name.
- **Use case:** auto-generate a localized SEO blog post for every (service × city/zip) combo to capture local organic search → a lead-gen growth engine.
- **Assessment:** architecture is clean; the *tactic is crude* — `gpt-3.5-turbo` (dated), single-shot, explicit "article spinner", mass thin localized content = exactly the AI-SEO pattern Google now penalizes. Folder name `OpenAITest` + a `subscriberId=1/userId=10` fallback = a prototype/experiment, not a hardened shipped feature.
- 🔒 **SECURITY: a plaintext OpenAI API key (`sk-…`) is hardcoded in `Blog/api.cfm` source.** It's the vendor's leaked credential (their problem, not ours), but it's a real exposure in their codebase — noted, not reproduced here.
- **Relevance to arbor-core / [[aspen-retention-agent]] / [[inland-empire-expansion]]:** programmatic local-SEO via LLM is a legitimate BD tactic we could do FAR better (modern model, real editorial gate, genuine tree-care expertise vs. spun filler). The vendor proved the plumbing; the quality bar is wide open.

## 8. Modernization comparison — Automate vs TRIM IT (what the vendor rebuilt)
Same vendor, two eras. **Automate = modern BREADTH; TRIM IT = legacy DEPTH.**
| Dimension | TRIM IT (GSTS ERP) | Automate / ArborTools |
|---|---|---|
| **Era / UI** | 2005 Dreamweaver, `<table>` layouts, Spry | Porto Bootstrap theme, SCSS/LESS, responsive admin |
| **Write pattern** | proc-driven create + inline-`UPDATE` MM_UpdateRecord forms | low-code CRUD engine (`automate_crud*`) — tables/forms defined as DATA, generated lifecycle hooks (pre/post Insert/Delete) |
| **Tenancy** | single-tenant (GSTS only) | **multi-tenant SaaS** (`website_plan_subscription`, `subscriber`, `hostname`) |
| **Cash/payments** | none — QuickBooks owns it | native `invoice`/`income`/`paypal_transaction`/`refund` + PayPal.cfc |
| **Storage** | local `FilePath` on the box | Amazon S3 (`AmazonS3.cfc`, `automate_amazon_s3_bucket`) |
| **AI** | none (we bolt on Ollama/OpenAI externally) | **built-in** OpenAI chat/image/audio model tables + wrapper |
| **Integration** | none native | webhooks (`automate_webhook_data`), REST `api/`, JS event system |
| **CRM / marketing** | none (we built Aspen/Cockpit on top) | native leads, CMS, forum, newsletter, affiliate, SEO engine |
| **Scale** | **964 tables, 3,628 procs** (deep) | **143 tables** (broad, generic) |

**What TRIM IT has that Automate does NOT** (the moat): the entire tree-care operational spine — `Proposals`(221 cols)/`ProposalLines`, `GoAheads` + two-step activation, `WorkOrders`(168 cols), `CrewSheets`/`InventoryAssignments`, tree `InventoryDetail`, municipal contracts/DIR prevailing-wage, GPS inventory, TPH/production math. **Automate's only tree-care tables are `land_area`, `land_area_type`, `inventory_location` — a thin geographic skin.** It's a generic business platform (CRM+CMS+helpdesk+HR+billing) with an arborist label, NOT a tree-care ERP.

**The strategic read:** the vendor modernized the *plumbing* (multi-tenant, cloud storage, AI, low-code, modern UI) but did **not** rebuild TRIM IT's operational depth into it. So Automate is not a drop-in replacement for TRIM IT — it's a different animal. For [[arbor-mission-strategy]]: it validates our thesis (a modern platform layer is the right direction) AND shows the gap we'd own (real tree-care depth + better AI) that the vendor's generic platform doesn't cover. Build-vs-buy: buying Automate would trade our depth for their breadth — a bad trade; the arbor-core path (modern layer ON our depth) is the stronger play.

## 9. Cleanup / housekeeping
- **~35,000 files / ~380 MB of dead vendor code** on the play box (incl. a live PayPal integration in source). Not an exposure (IIS doesn't serve it), but clutter — **flag, don't delete without confirming with the vendor/Skipper** (it's their IP).
- Reading tooling: `arbor-stack/deep-audit/psrun.sh` (SSH+PowerShell helper; holds the key path so it isn't mangled by output masking).
