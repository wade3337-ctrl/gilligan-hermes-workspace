---
title: Email infrastructure
type: fact
domain: env
tags: [infra, email, gmail, imap, imapflow, watchers, anomaly-monitor, gotcha]
links: ["[[anomaly-monitor-suite]]", "[[trimit-web-pull]]", "[[env-host-and-tooling]]"]
updated: 2026-07-02
---

# 📧 Email infrastructure

Snapshot: `arbor-stack/gilligan-environment-snapshot.md`. IMAP gotcha detail: `memory/2026-06-19-2302.md`.

## Sending
- Sends from **`gilligan.gsts@gmail.com`** → **`jwade@gstsinc.com`** only.
- **Self From=To lands in Sent not Inbox** → keep **From ≠ To**.
- COO daily CCs `jkim` / `jroulson` / `sgriffiths` (**scheduled send only**).
- Helpers: `anomaly-monitor/send-email.js` + `send-files.js`; creds `.secrets/gmail.json` (0600).
- **Discord attachments unreliable → email files.**

## Reading inbox
- IMAP via Python **`imaplib`** (stdlib, no install) or **imapflow**.

## Watchers (2h cron)
- `check-replies.js` — forwards colleague replies → jwade as `.eml`, **never acts on them**.
- `check-bounces.js` — delivery failures → jwade.

## ⚠️ ImapFlow gotcha (fixed in check-replies Jun 20)
- By-UID lookup needs **`{uid:true}` in the OPTIONS arg** of `fetchOne`/`fetch` (**3rd arg**), **NOT** in the query.
- A bare-number range is a *sequence* number → silently returns false → crash.
- Object-range `{uid:[...]}` is self-describing & safe.

## Related
- [[anomaly-monitor-suite]] — the live email engines that send through this.
- [[trimit-web-pull]] — companion read-only data pull (also creds-in-`.secrets`).
