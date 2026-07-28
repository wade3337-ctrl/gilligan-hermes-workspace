---
title: TRIM IT server topology — which box is which, and which database I actually query
type: reference
domain: work
track: 1
status: active
confidentiality: black
tags: [infra, trimit, play, prod, database, topology]
applies: ["[[two-track-confidentiality]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-db-gotchas]]", "[[trimit-stack-and-tph]]", "[[capacity-growth-model]]"]
updated: 2026-07-27
---

# TRIM IT server topology

Mapped 2026-07-26 while diagnosing the Skipper's play login failures. **Read this before assuming which data you are looking at.**

## The boxes — full inventory, DNS-verified 2026-07-27
| Role | Address | DNS name | Evidence |
|---|---|---|---|
| **🔴 PRODUCTION DATABASE** | `198.207.148.168:1433` | *(none; PTR `198-207-148-168.ayera.net`)* | **PROVEN 2026-07-27** — see below |
| **Production website** | `198.207.148.169` | `www.greatscotttreeservice.com` + apex | DNS; IIS 10/ASP.NET; serves `/GSTS` |
| **Vendor DEV website** | `198.207.148.188` | `dev.greatscotttreeservice.com` | DNS; IIS 10; serves `/GSTS`. **CONFIRMED genuinely separate** — see the dev half of the Spyder test below. Its database is **not reachable from us at all** (1433 and 14333 both closed), so it lives on that box or behind its own segment |
| **Play website (ours)** | `173.208.162.142` | `play.greatscotttreeservice.com` | Windows host `GSTSDATABASE`; IIS 10 + CF2023 |
| **Play box local SQL** | `localhost,14333` on the play box | — | instance `GSTSDATABASE`: nightly GSTS restore + `Workbench` (564 override rows) |
| Ayera VPN endpoint | `208.74.10.5:51831` | — | WireGuard `Ayera-VPN`; play box sits at `172.20.3.3` |
| My SSH/SQL route | `Administrator@100.86.97.46` (Tailscale) | — | → `gsql.sh` → `localhost,14333` |
| ❓ **Unexplained** | `91.246.63.118` | `trimit.greatscotttreeservice.com` **(+ matching PTR)** | Forward **and** reverse DNS deliberately configured — not a wildcard (a random subdomain does not resolve) — but **nothing answers on :443**, and it is on a network unrelated to Ayera. Origin unknown. Worth asking about. |

**All three Ayera hosts (.168/.169/.188) are reached from the play box only through the `Ayera-VPN` tunnel** —
confirmed by `Find-NetRoute` for each. Production's own web→DB hop (.169→.168) stays inside Ayera and never
crosses it.

## 🚨 NAMES ON THESE BOXES LIE — do not trust them
- **`198.207.148.168` is PRODUCTION, but its Windows machine is named `WIN-GSTSDB-DEV`.** SQL's `@@SERVERNAME`
  there is `WIN-WBTRXGSTSDB` — the two disagreeing is the signature of a box cloned or renamed after SQL was
  installed. Anyone reading "DEV" would reasonably assume it is safe to experiment on. **It is not.**
- **The play box's webroot folder is literally `D:\home\dev.greatscotttreeservice.com\wwwroot\`** — also says
  "dev", but it is our play box at `173.208.162.142`.
- Judge a server by what its data does, never by its name or folder.

## ✅ What I query is a DAILY RESTORE OF PRODUCTION — and it is isolated
`D:\DownloadAndRestoreLatestGSTS.bat`, scheduled task **"GSTS DB RESTORE"**, runs ~07:00 daily:
1. Pulls the newest `GSTS_backup_*.bak` (**~113 GB**) from **rsync.net** offsite (`/data1/home/fm2760/database`) via WinSCP.
2. Restores it into `173.208.162.142,14333` — the play box's own SQL instance.

**So every number I produce comes from a point-in-time copy of production, restored locally. Nothing I run can touch live data.** Verified 2026-07-26: last restore 11:58 from the 03:00 backup; `restorehistory` confirms the chain.

## ✅ RESOLVED 2026-07-27 — `198.207.148.168` **IS PRODUCTION**
**The decisive test (the Skipper's idea, and it beat my inference):** he created a new Spyder under Booms in
the Fleet area **on the production website**, then I looked for it.

| | `.168` | local restore |
|---|---|---|
| Equipment rows | **436** | 435 |
| Max `EquipmentID` | **466** | 465 |
| ID 466 | **`Spyder (Copy)`, EquipmentTypeID 1 = Boom** | **absent** |

His production save was on `.168` within minutes. **`.168` carries live production writes.**

**Then the control, same night:** he created the *same* record on **dev** (`.188`). Production stayed at
**436 rows / max ID 466**, with only the two Spyders (424 original, 466 his prod one). **Dev's writes do not
reach production — the two environments are genuinely separate.** One test, run twice, settled both directions.

**Where dev's data actually lives is unknown and not reachable from us:** `.188:1433` and `.188:14333` are both
closed from the play box. `.169:1433` is closed too — prod web is web-only and uses `.168`. So `.168` is the only
TRIM IT SQL server we can see.

### 🔑 `GSTSREADONLY` is correctly scoped — GSTS only
On `.168` that login can open **`GSTS` and nothing else**. `Workbench` → error 916; `ARBORTOOLS` → "Login failed
/ cannot open database". `sys.databases` still *lists* them (name visibility isn't restricted), but access is
denied. **That scoping is why Steve's dashboard broke** — Travis created `Workbench` on 7/26 without extending
the grant. Good hygiene on his part; it just wasn't matched to what the page needed.

⚠️ **How I got it wrong first, so I don't repeat it.** Before the test I compared `.168` against the restore and
found **identical row counts to the exact row** — RFPs 1,685,753 · Proposals 266,852 · CrewSheets 158,160 — plus
five matching MAX timestamps, and leaned toward "`.168` is a copy." **It was Sunday evening and nothing had been
entered since Friday 16:55.** A live database with a quiet weekend is indistinguishable from a frozen copy.
**Static data never proves a database is not live — only a write you control does.** I had flagged the weakness
and still leaned the wrong way; the machine being named `-DEV` reinforced the error.

### What that meant in practice
Until **2026-07-27 ~02:30 UTC**, the play website's `GSTS` datasource pointed at **production**. Read-only
(`GSTSREADONLY`), so nothing could be written — but **everyone treating play as a sandbox was reading live
production data.** [[herman-agent]]'s write access goes to `localhost,14333` via `gsql.sh`, not through the
website, so his writes never reached prod.

### Current state (changed 2026-07-27, Skipper-authorised)
| DSN | Now points at |
|---|---|
| `GSTS` | **`localhost,14333`** (the local restore) |
| `GSTSAPI` | **`localhost,14333`** |
| `GSTSREADONLY` | `198.207.148.168` — untouched, the deliberate read-only production link |

**Play is genuinely isolated at the data layer for the first time.** Revert kit + full write-up:
`arbor-stack/dev-tasks/play-dsn-revert/`. **Do NOT point play back at `.168`** — that is aiming a sandbox at
production. If Steve's dashboard needs to work against `.168` again, the fix is a `Workbench` grant there, not
a datasource change here.

**Consequence to keep straight:** play now shows the **nightly restore** (data through the last backup), while
production is live. Numbers will legitimately differ by a day or so.

## 🔑 THE LINK EVERYTHING HANGS ON — the Ayera WireGuard VPN
The play box reaches **all** TRIM IT infrastructure through a **WireGuard tunnel named `Ayera-VPN`** (seen on the box itself, 2026-07-26):

| | |
|---|---|
| Play box address inside Ayera's network | **`172.20.3.3/32`** |
| Endpoint (Ayera's VPN server) | `208.74.10.5:51831` |
| MTU | 1420 |
| Persistent keepalive | 21 s |
| **Allowed IPs — what it routes** | `208.74.8.128/25`, `208.74.9.0/24`, `208.74.11.0/24`, `74.112.192-196.0/24`, **`198.207.148.0/24`**, `172.20.0.0/18` |

**`198.207.148.0/24` is in there — so the DB (.168), production web (.169) and the vendor dev box (.188) are ALL on the far side of this tunnel.**
Confirmed by routing: `Find-NetRoute 198.207.148.168` → interface **`Ayera-VPN`**.

### 🚨 The tunnel is LOSSY — this is the real fault
Measured from the play box, 2026-07-26 evening:
- **ICMP: 14 of 20 replies (30% loss)**, RTT 59 ms when packets arrive.
- **TCP 1433: 10 of 12 connects succeeded, 2 FAILED** (6 s cap); successful connects averaged **363 ms** (vs ~60 ms clean).

**That is what produces the "site is down" experience.** A dropped SYN gets no rejection — WireGuard just swallows it — so Windows retries on a backoff and gives up around **21 s**. A refresh sends a new SYN, which usually gets through. Nothing is "down"; the path is dropping packets.

⭐ **Why only play suffers:** production's web server (.169) and its database (.168) are **both inside Ayera's network** — that hop never crosses the tunnel. **Play is the only system reaching across it**, which is why play is flaky and prod is not. **Do not conclude from play's behaviour that prod has the same problem.**

### 📅 This is NOT new — it dates to the tunnel going up on 14 July
A Codex session transcript (supplied by the Skipper 2026-07-26) shows the **same 20-second stall being investigated at 08:48 on 14 July — twenty-one minutes after the `Ayera-VPN` tunnel process started at 08:27 that morning.** Their measurement then: *"every page load is paying about 19-20 seconds to open/acquire the first GSTSREADONLY SQL connection… actual SQL queries are fast, about 60ms."* Identical to what I measured on 26 July.
**So: not caused by the Jordan email, the prod dashboard deploy, or yesterday's `GSTSAPI` repoint. It arrived with the tunnel.**

### ⚠️ Connection pooling is a MASK, not the fix
That session diagnosed it as ColdFusion not maintaining pooled connections, and proposed **Maintain Connections + a `zDBKeepAlive.cfm` hit every 5 minutes**. That will hide the symptom — a permanently warm pool never pays the reconnect — **but the link underneath is dropping packets** (measured: 30% ICMP loss, **2 of 12 TCP connects fail outright**). A keepalive does not fix packet loss; it just means you notice it later, as mid-session query failures and timeouts under load instead of a slow first page.
*(To their credit the same session did flag the real suspect at the end — "the ~20 sec delay looks like connection/login negotiation or network fallback, not query time… CF may be opening through a route that works only after a timeout/fallback." That line is the correct diagnosis; it just wasn't the headline.)*
**Fix the tunnel with Ayera. Pool warming is worth doing anyway, but it is a comfort measure.**

## 🐛 The 21-second blackhole (cause of "play is down / I can't log in")
First TCP connect from the play box to `198.207.148.168:1433` **after the link idles fails after ~21,152 ms**; attempts 2–5 connect in ~60 ms. Surfaces as a 20–23 s hang on first page load or login POST, then everything is instant. A refresh appears to fix it because the retry rides the now-open path. **Firewall/NAT session-table idle timeout between web and DB — not a TRIM IT bug.**
Diagnose with `curl -w time_starttransfer` from outside, then `TcpClient.ConnectAsync` in a loop **from the web server itself**. Pinging the web server proves nothing.

## 🔴 2026-07-27 ~21:24 UTC — the box WEDGED (services hung, TCP still answering)
Full signature, the one-command test, the disk-full hypothesis and the Nocix/IPMI fix path:
**[[play-box-wedge-signature]]**. ⚠️ **Do not read Tailscale `offline` as "the box is down"** — I did,
and it was wrong; `tailscaled` was simply one of the wedged services.
🔑 Host is **WholeSale Internet, Inc. (nocix.net)**, not Ayera. **Travis holds that account.**

## Change log observed
- **2026-07-14 08:27** — `Ayera-VPN` tunnel configured and started. **The 20s stall appears the same morning.**
- **2026-07-26 ~10:00** — vendor/Codex hardened `D:\DownloadAndRestoreLatestGSTS.bat` (listing snapshots, candidate logging, manual date override, delete-after-confirm) and edited `zDBTest.cfm` to print step timings — *which is why that page's output changed size between my two fetches.*
- **2026-07-25 18:35** — `neo-datasource.xml` edited: **`GSTSAPI` repointed `localhost` → `198.207.148.168`**. `GSTS` and `GSTSREADONLY` were already remote. (CF's own `.bak` from the same minute is the diff source.) Plausibly the vendor wiring up the read-only access we asked for.

## Don'ts
- `https://<bare-IP>` fails TLS **by design** — no cert bound to the IP. Use `play.greatscotttreeservice.com`. It is not a fault.
- ColdFusion debugging output is **disabled** (`enabled=false`, IP list localhost only) — a dump on screen is an explicit `cfdump` in a page, not debug output.
- The restore script holds SQL credentials. **Do not extract or echo them.**
