# Play server — 2026-07-26 login failures: diagnosis

**Symptom (Skipper):** couldn't log in; retried and failed; refresh loaded it.

## Root cause — a ~21s network blackhole to the database host, not an outage
The play website's ColdFusion datasources point at **`198.207.148.168:1433`** (`198-207-148-168.ayera.net`).
Measured **from the play server itself**, 5 consecutive TCP connects to that host:

| Attempt | Result |
|---|---|
| 1 (after idle) | **FAILED after 21,152 ms** |
| 2-5 | connected in ~60 ms |

The first SYN after the link goes idle is dropped silently (no RST), so Windows retries ~21s before failing.
Matching web timings: first page load **20.6s** to first byte, login POST **23.0s**, immediate repeat **0.49s**.
**A refresh appears to "fix" it because the retry rides the path once it is open.**
→ Firewall / NAT session-table idle timeout between the web server and the DB server. Not a TRIM IT bug.

## What changed on play — `neo-datasource.xml`, 2026-07-25 18:35
Diffed the live config against CF's own `.bak` written at the same minute:

| Datasource | Before | After | Changed |
|---|---|---|---|
| GSTS | 198.207.148.168 | 198.207.148.168 | no |
| **GSTSAPI** | **localhost** | **198.207.148.168** | **YES** |
| GSTSREADONLY | 198.207.148.168 | 198.207.148.168 | no |

**`GSTSAPI` was moved off the local SQL instance onto the remote DB host.** Anything using that datasource now
depends on the same fragile hop, so it is newly exposed to the 21s stall. The other two were already remote.

## ⚠️ Open question worth settling
- **The play WEBSITE queries `198.207.148.168`. My analysis queries the SQL instance ON the play box (`localhost,14333`, server name `GSTSDATABASE`, 50,283 invoices, last crew sheet 2026-07-25 15:35).** These are **different databases**. Which one is authoritative for what the website shows — and does PRODUCTION use `198.207.148.168` too? If so, "play" is not isolated at the data layer.
- Could not inspect the remote DB: integrated auth fails across the hop (`NT AUTHORITY\ANONYMOUS LOGON`). TCP reaches it fine once warm — an auth limitation, not connectivity.

## Ruled out
- ColdFusion debugging output is **disabled** server-side (`enabled=false`, IP list localhost only).
- `https://173.208.162.142` failing TLS is expected — no certificate bound to the bare IP. Use the hostname.
- No files changed under `C:\inetpub\wwwroot` in the last 3 days.
