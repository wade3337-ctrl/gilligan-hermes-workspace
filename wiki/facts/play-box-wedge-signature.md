---
title: The play box "wedge" — TCP answers, no service responds. How to tell it apart from a box that is DOWN.
type: fact
domain: work
track: 1
status: active
confidentiality: black
tags: [infra, play, trimit, outage, diagnosis, gotcha]
applies: ["[[trimit-server-topology]]", "[[only-trustworthy-data]]"]
links: ["[[play-dev-access]]", "[[async-report-rule]]"]
created: 2026-07-28
updated: 2026-07-28
---

# Play box wedge signature (first seen 2026-07-27 ~21:24 UTC / 14:24 PT)

## ⚠️ The mistake to not repeat
I reported the box as **DOWN**. It was not. I had tested only **Tailscale + ICMP + HTTPS** — three paths
that all fail the same way for a *wedged* host as for a *dead* one. **Tailscale showing `offline` is a
SYMPTOM** (`tailscaled` is just another wedged service), not evidence about the machine.
Same error class as calling `.168` a copy: **concluding about a machine from negative evidence on one path.**

## The actual signature — memorise this
| Probe | Dead box | **Wedged box (what we saw)** |
|---|---|---|
| TCP connect :22/:80/:443/:14333 | refused / timeout | ✅ **completes in ~0.18 s, uniformly** |
| SSH banner (sent unprompted on connect) | — | ❌ **0 bytes in 15 s** |
| SQL Server greeting (also unprompted) | — | ❌ **0 bytes in 15 s** |
| HTTP | no connect | connect fine, **`ttfb=0.000000`, code `000`** |
| Tailscale | offline | offline, **`tx` climbing, `rx 0`** |
| ICMP | loss | 100% loss (also normal here — likely filtered) |

**Read it as:** the kernel is completing handshakes into the accept queue and **no userland process is ever
accepting them.** Every service is hung — IIS, SQL, sshd, tailscaled, the VPN endpoint. The Skipper's VPN
also failed to connect, consistent with the same wedge.

### The one-command test
```
python3 - <<'PY'
import socket,time
for port,label in ((22,'ssh'),(443,'https'),(14333,'sql')):
    s=socket.socket(); s.settimeout(20)
    try:
        t0=time.time(); s.connect(('173.208.162.142',port)); tc=time.time()-t0
        s.settimeout(15)
        try: print(f"{label}: connect={tc:.2f}s RECEIVED {len(s.recv(256))} bytes")
        except socket.timeout: print(f"{label}: connect={tc:.2f}s CONNECTED BUT NO DATA  <-- WEDGED")
    except Exception as e: print(f"{label}: FAILED {e}   <-- genuinely down/blocked")
    finally: s.close()
PY
```
**Fast connect + zero bytes = wedged, not down.** Services that greet you unprompted (SSH, SQL Server) are
the good probes; HTTP is a poor one because it waits for a request.

## ✅ REVISED 2026-07-28 — most likely PLANNED VENDOR WORK, not a fault
**Skipper:** *"Jordan and Travis are working on a way for us to share the dev server with Travis and his
team along with a repository for changes. I think the play server is offline because they are working
through these changes."*

**My own evidence favours his read over mine.** The connect time was **0.18 s uniformly across four very
different services** (sshd, IIS, IIS-TLS, SQL Server). A wedged Windows host would not be that consistent —
but **a firewall/NAT that answers SYNs on forwarded ports with no live backend behind them produces exactly
this**. Supporting: **:3389 did NOT answer** (fits a new forward list that omits RDP), and **the Skipper's
own VPN stopped connecting** — far better explained by "they changed the VPN config" than by "a service hung."

➡️ **DO NOT escalate to Nocix for a power cycle.** If this is planned work, a hard reboot could interrupt a
migration mid-flight. **Confirm with Jordan/Travis before touching the provider portal.**

⚠️ **Keep the signature below anyway** — the probe and the read-out are correct and reusable; only the
*cause* changed. "Fast connect + zero bytes" means **something is answering that is not the service** —
that is either a wedged host **or** a proxying middlebox with a dead backend. The probe cannot tell them
apart; ask a human what changed.

## 🚨 RISK — play-only data with no local backup
If the box is rebuilt/reimaged as part of this work, data that exists **only on play** is lost:
`Workbench` overrides (~564 rows), `BidQueue` (16 rows of our working data), the `DashboardAccess` list
(23 users, edited via the UI since seeding), and saved `GoalSettings`/`DashboardPrefs`.
We hold **create+seed scripts** (`RC-DashboardAccess-create-seed-PROD.sql`, `RC-02-SalesGoal-create-seed-PROD.sql`,
`dev-tasks/spm-results-prod-fix/01-create-workbench-objects-PROD.sql`) — **but no current data dump**, and it
cannot be taken while the box is unreachable.
▶️ **FIRST ACTION when play returns: dump `Workbench` and commit it.** Also re-check the DSN repoint
(`GSTS`/`GSTSAPI` → `localhost,14333`) survived — revert kit at `arbor-stack/dev-tasks/play-dsn-revert/`.

## Superseded hypothesis (kept for the record — disk-full)
**The nightly restore filled the disk.** `D:\DownloadAndRestoreLatestGSTS.bat` (scheduled task
**"GSTS DB RESTORE"**, ~07:00 daily) pulls a **~113 GB** `GSTS_backup_*.bak` from rsync.net and restores it
into `localhost,14333`. A full volume wedges Windows services in exactly this pattern while the kernel keeps
answering SYNs.
Two supports: (1) the box went silent ~14:24 PT — a plausible landing time for a 7-hour 113 GB transfer that
started at 07:00; (2) **the vendor rewrote that exact script on 2026-07-26**, two days before, adding
"delete-after-confirm" logic — if the confirm fails, the previous `.bak` is never deleted and the volume fills.

## How it gets fixed — and why we could not
The box is a **rented dedicated server at WholeSale Internet, Inc. (`nocix.net`)** — *not* Ayera.
(RDAP: `WII-NET-173-208`, 173.208.128.0–173.208.255.255.) Such a box has **IPMI remote console + hard power
cycle** in the provider portal. That is the fix.
🔑 **Travis holds the Nocix account (Skipper, 2026-07-28). We have no portal credentials on file — that is
the single point of failure.** A wedged box means waiting on someone else's login. **Get the Skipper added.**

**When someone does get console access — screenshot BEFORE rebooting.** A blind power cycle fixes tonight and
destroys the evidence, and if it *is* the restore job it re-wedges at 07:00 the next morning.

## First three things to check the moment it is reachable
1. **Free space on D: (and C:)** — the hypothesis stands or falls here.
2. **Leftover `GSTS_backup_*.bak`** — two of them, or a partial with today's date.
3. **"GSTS DB RESTORE" task history** + the script's own log → did the 7/26 rewrite cause this?

## Worth building
A watchdog on the banner probe above (every ~5 min) so we learn in minutes. This ran wedged for **4+ hours**
and was caught only because I happened to check while chasing something else.
