---
title: Boss Herman's TRIM IT (play) web login
type: fact
domain: work-arbor-core
tags: [herman, trimit, login, credentials, play, security]
links: ["[[herman-agent]]", "[[play-dev-access]]"]
updated: 2026-07-08
---

# Boss Herman's TRIM IT play login (created 2026-07-08)

Gilligan provisioned a **full-admin** TRIM IT **play** web login for Boss Herman (Skipper-directed).
- **User:** `hermes@greatscotttreeservice.com` · **UserID 90377** · FullName "Boss Herman" · Role001 **Developer** · SecurityLevelID 5 · **97 UserActions** (cloned from the fullest-access account, UserID 115).
- **Password:** stored ONLY in Herman's container at **`/opt/data/home/.secrets/trimit-web-login.env`** (chmod 600, owned `hermes`) — the env he asked for (`TRIMIT_PLAY_URL` / `TRIMIT_WEB_USER` / `TRIMIT_WEB_PASS`). Not written anywhere else. To retrieve: `docker exec -u hermes hermes cat /opt/data/home/.secrets/trimit-web-login.env`.
- **Verified:** the login's own validation query (`gsts/Login/LoginResults$Split.cfm`) authenticates it (returns Internal / 90377 / Boss Herman / Developer).
- Created neutral: `SalesRepID`/`ShowOnSchedule`/`IsPayrollItem` NULL/0 so Herman isn't a fake employee/crew/rep.

## TRIM IT web-login model (reusable)
- Users live in **`flow.Users`** (`LoginName`, `UserEmail`, `Password`, `StatusDefID`, `Role001`, `SecurityLevelID`, `DefaultUserGroupID`). Per-user permissions = **`dbo.UserActions`** (UserID, ActionDefID, IsAllowed). Active = StatusDefID **143**.
- Login form (`ClientLogin.cfm` → iframe `gsts/Login/index.cfm` → POST `LoginResults$Split.cfm`) validates internal users with: `gsts.dbo.Profiles INNER JOIN flow.Users ON Profiles.userID=Users.UserID` WHERE `UserEmail` (or `LoginName`) = login AND `Password` = pw AND status Active. **A `Profiles` row (userID=UserID) is REQUIRED** — a trigger auto-creates it on flow.Users insert.
- ⚠️ **SECURITY: passwords are stored PLAINTEXT** in `flow.Users.Password` (and `WebUsers.Password`). Worth flagging to the Skipper as a system-level risk (not fixed here).
- ⚠️ **Persistence:** created on **play**. Skipper believes play isn't fully refreshed from prod (maybe the DB only) — if the play DB ever gets restored from prod, this user + its UserActions would be wiped and need re-creating.

## Backup + re-provision (if wiped)
- **Credential backup (host):** `~/.secrets/trimit-herman-login.env` (chmod 600) — same email+password as Herman's container copy, so re-creating the user with these keeps his env file working.
- **One-command re-provision:** `bash ~/arbor-stack/tools/reprovision-herman-trimit-login.sh` (idempotent — recreates the flow.Users clone-from-115 + copies UserActions from the stored creds). `--check` reports status only (OK / WIPED).
- **Wipe-test cron:** one-shot job `herman-trimit-login-wipe-test` fires **2026-07-09 09:00 PT** → runs `--check` → reports to Skipper whether the overnight refresh wiped it (answers the persistence question).
