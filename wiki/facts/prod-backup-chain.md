---
title: Production backup chain (prod → play) — fails ~weekly
type: fact
domain: env
tags: [infra, backup, restore, play, production, disaster-recovery, staleness, jordan]
links: ["[[play-dev-access]]", "[[play-gsts-is-ephemeral]]", "[[disaster-recovery]]", "[[prod-db-access-blocked]]", "[[trimit-db-gotchas]]", "[[data-freshness-contract]]"]
updated: 2026-07-25
---

# 💾 The prod → play backup chain — and why our reporting silently goes stale

**Everything we report from `play` is only as current as this chain. It breaks roughly once a week and nobody is watching it.**

## How it works
1. Production takes a **nightly full backup at 03:00** (`GSTS_backup_YYYY_MM_DD_030001_*.bak`, ~122 GB).
2. The file lands in **`D:\Backups\`** on the play server.
3. Play **restores it every morning ~04:50 UTC** (≈9:50 PM PT prior evening / see [[play-gsts-is-ephemeral]] for the wipe consequence).

**Step 3 is reliable. Steps 1–2 are not.**

## 🔴 The failure mode: no new file, so play re-restores the SAME stale backup
The restore job never errors — it faithfully restores whatever is in `D:\Backups\`. If no new file arrives, it re-applies the old one and **everything looks normal while the data silently ages**.

Measured 2026-07-25:
- `D:\Backups\` held **exactly one file**, from **22 July 03:03**. Nothing for 23/24/25 July.
- Play restored on 7/23, 7/24 and 7/25 — all three from that same 7/22 file (staleness 25h → 49h → **73h**).
- ⇒ Reports showed data through **Tue 21 July** (a backup finishing 03:03 Wed 7/22 contains through end of Tue 7/21).

**This is chronic, not a one-off.** Backup files were also missing for **8–9 July** and **19–20 July**; staleness also hit 73h on 7/10 and 7/21.

## 🔎 How to check it (do this before trusting any play-sourced number)
```sql
-- what did play last restore, and how old was it?
SELECT TOP 10 r.restore_date, b.backup_finish_date,
       DATEDIFF(hour, b.backup_finish_date, r.restore_date) AS staleness_hrs
FROM msdb.dbo.restorehistory r
JOIN msdb.dbo.backupset b ON r.backup_set_id = b.backup_set_id
ORDER BY r.restore_date DESC;
```
```cmd
dir D:\Backups\*.bak /O-D      :: should show a file from THIS morning
```
Rule of thumb: **`staleness_hrs` > ~30 means the chain is broken**, not merely lagging.

## Suspected cause (⚠️ hypothesis, not proven)
`D:` had **148.7 GB free** against a **121.9 GB** backup — room for one copy and very little margin. A copy-then-delete retention step would be tight; a slightly larger backup would fail outright. **Unconfirmed** — nobody has been able to see the production side.

## Why it matters beyond reporting
- **DR exposure:** if no new full backup is being *produced*, the recovery position is materially worse than assumed. A QoE/IT diligence review asks this. → [[disaster-recovery]], [[fort-point-acquisition]]
- **It destroys our work:** the 7/25 restore erased three days of Goodman builds → [[play-gsts-is-ephemeral]], [[goodman-rfp-bid]].
- **It is the reason for the live-prod read-only push** → [[prod-db-access-blocked]]. Live reads make reporting independent of this chain entirely; that is the whole argument.

## Ownership
**Unowned as of 2026-07-25.** Jordan owns the AWS/server side but is being exited ([[vendor-fieldapp-build]]), so the Skipper deliberately kept it OUT of the access email as a demand (it would have been an escape hatch) and used it purely as evidence. **Needs an owner when IT ops is reassigned.**
