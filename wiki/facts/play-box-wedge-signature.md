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

## ✅ CONFIRMED CAUSE 2026-07-28 — a GENUINE HARD FREEZE. Not planned work. Cause still unknown.
**Jordan (via Skipper, 2026-07-28): "they were not working on it. They hard rebooted to get it online again."**

### The timeline, from the box's own logs
| Local (CDT) | UTC | What |
|---|---|---|
| 07:00 7/27 | 12:00 | `GSTS DB RESTORE` ran — **Result=0, success** |
| ~16:24 7/27 | ~21:24 | **Box freezes.** Last Tailscale contact. |
| 16:24 → 21:58 | | **5.5 hours with ZERO System event-log entries** |
| 21:58 7/27 | 02:58 7/28 | **Jordan hard-resets it.** Kernel-Power **41** + **6008**, **no 1074** |
| — | 04:33 | Back up, healthy, `Workbench` intact and backed up |

### Why this is the decisive evidence
**The System event log is completely empty for the 5.5-hour window.** A network/firewall change leaves the box
running and logging. **An empty log means the machine itself stopped executing** — it could not even write its
own event log while the NIC kept completing TCP handshakes. Combined with **no 1074** (no graceful shutdown
was ever requested), this was a hard hang recovered by a power cycle.

### Both of my hypotheses were wrong — and the disk one is fully cleared
- ❌ **Disk full:** C: **38% free**, D: **15% free (138 GB)**, and the restore job succeeded 9 hours earlier.
- ❌ **Planned vendor work:** Jordan says no. See the lesson below — I abandoned a correct read too fast.

### ⚠️ Cause remains UNDIAGNOSED — a freeze this deep is storage, kernel, or host hardware
The hard reset destroyed the live state, so there is nothing left to examine. **If it recurs:**
1. **Tell Travis it FROZE HARD — not "it was down."** The distinction is what makes Nocix take a hardware look.
2. Ask Nocix (**WholeSale Internet**, RDAP `WII-NET-173-208`; **Travis holds the account**) to check the IPMI
   **System Event Log** — host-level power/thermal/storage faults land there, not in Windows.
3. **Screenshot the IPMI console BEFORE power-cycling.** A frozen Windows console often shows the fault; a
   hard reset erases it. That is exactly what we lost this time.
🔑 **Still the single point of failure: we have no Nocix portal access. Get the Skipper added.**

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
