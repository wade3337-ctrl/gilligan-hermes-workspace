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

## The boxes
| Role | Address | Notes |
|---|---|---|
| **Production website** | `198.207.148.169` | `greatscotttreeservice.com` / `www.` |
| **Database the PLAY WEBSITE uses** | `198.207.148.168:1433` | `198-207-148-168.ayera.net` — **adjacent to prod web** |
| **Play website** | `173.208.162.142` | `play.greatscotttreeservice.com` — ours |
| **Play box local SQL** | `localhost,14333` on the play box | server name `GSTSDATABASE` |
| Vendor dev box | `198.207.148.188` | `198-207-148-188.ayera.net` — **not ours** |
| My SSH/SQL route | `Administrator@100.86.97.46` (Tailscale) | → `gsql.sh` → `localhost,14333` |

## ✅ What I query is a DAILY RESTORE OF PRODUCTION — and it is isolated
`D:\DownloadAndRestoreLatestGSTS.bat`, scheduled task **"GSTS DB RESTORE"**, runs ~07:00 daily:
1. Pulls the newest `GSTS_backup_*.bak` (**~113 GB**) from **rsync.net** offsite (`/data1/home/fm2760/database`) via WinSCP.
2. Restores it into `173.208.162.142,14333` — the play box's own SQL instance.

**So every number I produce comes from a point-in-time copy of production, restored locally. Nothing I run can touch live data.** Verified 2026-07-26: last restore 11:58 from the 03:00 backup; `restorehistory` confirms the chain.

## ⚠️ The play WEBSITE does NOT use that copy
All three ColdFusion datasources (`GSTS`, `GSTSAPI`, `GSTSREADONLY`) point at **`198.207.148.168`**, not the local restore.
**Consequence: what the play website shows you and what my analysis reports are different databases.** Don't cross-check one against the other and expect a match.

❓ **UNRESOLVED — worth settling: is `198.207.148.168` the PRODUCTION database, or a separate play database?**
It sits adjacent to the prod web server (.169) on the same ayera.net range, which is suggestive but not proof. **If it is prod, the play website is not a sandbox at the data layer** — which matters a great deal given [[herman-agent]] has play write access and we treat play as safe. Could not inspect it: integrated auth does not cross the hop (`NT AUTHORITY\ANONYMOUS LOGON`); TCP reaches it fine once warm.

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

## Change log observed
- **2026-07-14 08:27** — `Ayera-VPN` tunnel configured and started. **The 20s stall appears the same morning.**
- **2026-07-26 ~10:00** — vendor/Codex hardened `D:\DownloadAndRestoreLatestGSTS.bat` (listing snapshots, candidate logging, manual date override, delete-after-confirm) and edited `zDBTest.cfm` to print step timings — *which is why that page's output changed size between my two fetches.*
- **2026-07-25 18:35** — `neo-datasource.xml` edited: **`GSTSAPI` repointed `localhost` → `198.207.148.168`**. `GSTS` and `GSTSREADONLY` were already remote. (CF's own `.bak` from the same minute is the diff source.) Plausibly the vendor wiring up the read-only access we asked for.

## Don'ts
- `https://<bare-IP>` fails TLS **by design** — no cert bound to the IP. Use `play.greatscotttreeservice.com`. It is not a fault.
- ColdFusion debugging output is **disabled** (`enabled=false`, IP list localhost only) — a dump on screen is an explicit `cfdump` in a page, not debug output.
- The restore script holds SQL credentials. **Do not extract or echo them.**
