# Friction Module 01 — Marketing / Business Development

**Status: node COMPLETE (2026-08-02).** Part of the Friction Hit List → 5-Year Business Plan.
🔒 Fort Point / owner-tier. Compiled from the Skipper's brain-dump + verification.

---

## What this function actually is
Not "marketing" in the demand-gen sense — it's **3 field business developers / door-openers**, one per region, whose job is relationship access ("get us in to actually sell"):
- **Chad — Inland Empire**
- **Megan — Orange County**
- **Rick — Los Angeles County** (just started; not yet in the commission process)

They feed RFPs to the sales admin trio, who enter them into TRIM IT.

## The friction (what's broken)
- **No standard method.** Chad = referrals / walk-ins / office drops. Megan = office drops / trade shows, but her real value is her **personal contact list** (calls people for intel others can't get). Rick = unknown (new). Everyone freelances their own style.
- **Value is locked in the person, not the company.** Megan's rolodex *is* the OC channel — if she leaves, it leaves. Key-person risk on the top of the funnel.
- **The top of the funnel is invisible.** Nothing is tracked before an RFP lands in TRIM IT — who they saw, what's in the pipe, what's warming — lives in their heads or an unseen spreadsheet.
- **No capacity or ROI model.** Can't answer "can we get more?" — no denominator (cost per rep, activity → result) and no target.
- **Reporting is an informal Nate email** — "who they may have chatted with," nothing documented.
- **Compensation is pay-for-presence, not performance.** ~**$120k base** each + **1% commission on new sites** ≈ **~$1,500/mo (~$18k/yr)**. Commission ≈ 13% of comp — too weak to change behavior. **≈$415k cash / ~$540k loaded/yr across the three, with no ROI visibility.** This is *also why Bigin sits empty*: nothing they log affects their pay.
- **🔥 Commission reconciliation — QUANTIFIED (Nate's reply, 2026-08-02).** Nate (Sales Manager) hand-reconciles the TRIM IT commission report **every pay period (biweekly, ~26×/yr)**, and it takes **4–6 hours on average, up to 2 full days** with corrections (≈**110–160+ manager-hrs/yr**).
  - **Process:** TRIM IT *HR tab → sales rep commission report → current week → generate* → **two reports**: (a) new-site commission (marketing team + Nate, **1% of all new sites**), (b) per-rep commission (**1% new site + 5% plant-health-care + 1–4% TPH for $115–$130**).
  - **The time-sink is the checking** — Nate opens **every single project** on the report, dives into *Project History* + *Invoices* to confirm start date + last-serviced date, because the report mislabels recurring jobs as "new site" and vice-versa. TPH/PHC checks are quick by comparison.
  - **Root cause of the errors (~7 New-Site errors/report):** (1) the **internal team doesn't toggle "new site"** when entering a job into TRIM IT — *manual error, the most frequent*; (2) TRIM IT **doesn't auto-remove the new-site toggle after 1 year** of service — was frequent, **less so since Jordan patched it ~a month ago**. TPH errors (~8/report) also **mostly fixed by Jordan** (none on the last 2 reports).
  - **🔑 The fix is clean and definable:** "new site" = *a project started within the past 12 months with a 2+ year gap since last worked there.* That's a **rule TRIM IT can auto-classify** — eliminating the manual toggle (the #1 error source) and most of the 4–6 hrs. Jordan's partial fixes already prove the TPH/auto-untoggle side is tractable.
  - **Deploy caveat:** the tune-up lives in TRIM IT; **likely not on play yet** (deploy lag), so I can't fully verify the current-state proc from here.

## The fix path
- **Bigin is the right tool, sitting unused** — a lightweight CRM to capture BD contacts, activity, lead source, and the marketing→sales handoff → makes ROI computable.
- **Aspen is already wired to feed these exact regional reps** (IE→Chad, OC→Megan, LA→Rick) — the BD engine for the $50M goal.
- **Fix the commission report = triple win:** kills Nate's biweekly manual mess, stops mispaid commissions, **and** turns the same rep→new-site-by-area data into **BD ROI per rep per region** (the missing measurement).
- Incentive redesign is part of it: tracked activity won't happen until the paycheck notices.

## Status / open
- ✅ **Nate replied 2026-08-02 (forwarded by the Skipper)** — details folded in above (quantified: 4–6 hrs/pay-period, ~7 new-site errors/report, root cause = manual new-site toggle + auto-untoggle bug). Raw email: `media/inbound/nate-commission/`.
- Rick's style/ROI TBD (new).
- Cross-cutting friction confirmed here too: **undeployed-fix / play-server lag** (our tuned report may not even be on play).

## Sources
Skipper brain-dump 2026-08-02; comp figures Skipper-stated; Aspen/Bigin state from `[[aspen-cockpit-to-bigin-push]]` + `[[aspen-retention-agent]]`.
