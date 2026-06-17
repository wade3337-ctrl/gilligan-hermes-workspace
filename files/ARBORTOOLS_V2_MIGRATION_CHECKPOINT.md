# ArborTools / V2 Migration — Vendor Assessment CHECKPOINT (2026-06-10)

Paused here at Skipper's request. This is the evidence + analysis for the **$300K "V2 migration"** decision. Resume by re-reading this; the live deeper-dive (full scope quote, SQLi findings, platform decision) is still pending.

## The situation
- Skipper **cut the third-party dev budget** (team going **140 → 70 hrs/week** per internal PM). Running ~**$40K/month** with "not much received."
- Vendor pitched a **new database / "V2"** at **~$300K + ~1 year**, citing **urgent security risks** in the current system.
- **Players:** **Travis Walters** (developer, `travis@dataprocessingllc.com`, **Data Processing LLC** — small Maryland ColdFusion shop, ~27 yrs CF, markets via hirephpagency.com / hireaicompany.com lead-gen sites; their OWN site's SSL cert is EXPIRED). **Jordan Kim** (`jkim@gstsinc.com`, internal GSTS "Technology Project Manager") forwards Travis's estimate.
- Source doc: email PDF "V2 Migration Estimation" (Travis→Jordan, Jun 8–9 2026). Saved inbound at `~/.openclaw/media/inbound/V2_Migration_Estimation-*.pdf`.

## What arbortools.net actually is (inspected live, logged in as SUPERADMIN)
- **Same stack as TRIM IT:** Adobe **ColdFusion + Microsoft IIS + SQL Server** (CFID/CFTOKEN/cfusion cookies, `.cfm` pages). The "new" system is the *same technology generation* as the one called dangerously outdated — re-skin, not re-platform.
- Built from **off-the-shelf ThemeForest templates**: "Porto" (public site) + "Porto Admin" (admin panel). GSTS logo/mission dropped in.
- Public "product" marketing pages (Pricing, Demo, Field App, Reporting, Proposals, Tree Inventory, Work Orders) **all 404** — labels pointing nowhere.
- Login `/login.cfm` (fields f0/f1, no CSRF/2FA seen) → redirects to `/auto/` admin.
- **`/auto/` and `/auto/migration_cost_dashboard.cfm` throw "Error Occurred" for me** — but **Skipper confirms V2 is NOT meant to be a working system yet** (WIP). So that's expected, NOT proof of non-delivery.
- Admin sidebar modules present are **generic website-CMS** (Blog, FAQ, Newsletter, Testimonials, Content, Accounting, Permissions, Portfolio, Migration Mgmt) — **NOT** the tree-care ERP guts (work orders, proposals, crew scheduling, tree inventory).
- **Credentials:** SUPERADMIN login — **held by Skipper, deliberately NOT stored here** (used only for the live inspection, session wiped).

## The V2 migration numbers (from the live cost dashboard, screenshotted in the email)
- **Total Budget (Estimated): $328,800**  ·  Spent to date: **$18,863 (8% complete)**  ·  Remaining: **$309,938**
- **~4,200+ estimated work-hours**, overwhelmingly "Not Started"; biggest cost in **complexity tier T1 (~$150K)**. Blended rate ≈ **$76/hr** (fair, not gouging). A slice of tickets marked "Do Not Do."
- **CRITICAL — $328,800 is ONLY data/table migration.** Travis: *"we would still need to create workflows, a web portal, a field app, a mapping application… do not have tickets scoped for the other necessary components… another 6 months to iron everything out."* → **V2 not usable until END of 2027**, and the unscoped 60% means **true all-in is likely $600K–$800K+**, not yet in writing.
- Travis's plan: keep **2 FT devs @ ~40 hrs/wk on V2 → June 2027** for data migration.

## My analysis (the decision logic)
1. **This is a legitimate, organized project** — real cost dashboard, tickets, complexity tiers. NOT a scam. Rate is fair.
2. **BUT the security justification is a non-sequitur.** Travis cites **SQL Injection on V1** as the urgent risk. SQLi is real & serious IF present — but it's a **code bug fixed by parameterizing queries (`cfqueryparam`)**, NOT by migrating. **V2 is the same CF+SQL stack** → migration doesn't remove SQLi; devs still must write secure queries either way. So "fund the $328K+ migration to fix security" doesn't follow. His "fixing V1 would cost hundreds of thousands" is almost certainly inflated. **Two separate decisions are being bundled.**
3. **Genuine V1 risks (already known from TRIM IT folder): `sa` datasource, plaintext passwords, missing FKs** — all **cheap config/code fixes**, not a $300K rebuild.
4. **Strategic collision with Arbor AI:** GSTS is already building Arbor AI to pull from a **repaired TRIM IT UI** (the work we're doing). Data Processing LLC's V2 = a **parallel rebuild of the same system on the same stack**. Risk of **paying twice** to rebuild TRIM IT. Needs ONE platform strategy.

## Recommended next steps (pending — Skipper paused before acting)
1. **Decouple security from migration** → have Travis scope the **SQLi + `sa` + plaintext fixes on V1 as a small fixed-price job, now.** Get safe cheaply without approving V2.
2. **Get the SQLi findings in writing** (which pages/queries, severity) → hand to Gilligan to judge weeks-patch vs. genuinely large.
3. **Demand the FULL V2 scope + all-in price** before approving anything past data migration. No blank check on the unscoped ~60%.
4. **Force the Arbor-vs-V2 platform decision** — one path, not two parallel rebuilds.
5. Offered but not yet done: a **written assessment + draft reply to Travis/Jordan**. Resume here if wanted.

## Artifacts (this session, in /tmp — ephemeral, may be gone on reboot)
- Rendered dashboard screenshots: `/tmp/dash_p1.png`, `/tmp/dash_p2.png`; page renders `/tmp/v2page_{1,2,3}.png`; extracted inner PDF `/tmp/v2extract/V2 Migration Estimation.pdf`.
- Extraction method (no poppler on box): pdfjs-dist + @napi-rs/canvas in `arbor-stack/pdf-tools/` to render PDF→PNG; `getAttachments()` to pull portfolio embed.
