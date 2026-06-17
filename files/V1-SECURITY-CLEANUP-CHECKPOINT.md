# V1 Security & Cleanup — Execution CHECKPOINT (2026-06-11)

Where the AI-assisted V1 (TRIM IT) cleanup stands. Resume from here. Companion docs: `GSTS-Software-AI-Strategy.{png,html}` (strategy), `ARBORTOOLS_V2_MIGRATION_CHECKPOINT.md` (the vendor decision this feeds), `V1-Cleanup-Plan.html` (method), `V1-Security-Remediation-Roadmap.html` (the plan), `security-findings-20260610.md` (raw evidence).

## Strategy context (locked Jun 10)
"Own the edge, rent nothing strategic." Evolve V1 → V1.5 in place (secure/reliable/AI-accessible), build Arbor AI on top **in-house**, vendor (Data Processing LLC) → legacy maintenance only, **skip the $600–800K V2 rebuild**. The security cleanup below = both the V1.5 foundation AND Arbor's backend (same work, double duty).

## What's DONE
- Read-only **security sweep** run via Codex (Jun 10 21:31). Report: `security-findings-20260610.md` (also still on server at `D:\trimit-analysis\discovery\security-sweep\`).
- Findings analyzed; **remediation roadmap** built (`V1-Security-Remediation-Roadmap.html`).
- Email sent to **Jordan/Travis** asking for (a) standalone fixed-price V1 security quote + (b) how V2 fixes the same issues. **Awaiting their reply.**

## Findings — confirmed criticals
- **CFML SQL injection:** 8,422 / 39,966 query surfaces flagged. *(Upper bound to REVIEW, not live holes — see reframe.)*
- **`sa` datasource:** BOTH `GSTS` and `GSTSAPI` ColdFusion datasources connect as `sa` (full sysadmin). In `C:\ColdFusion2023\cfusion\lib\neo-datasource.xml`.
- **Plaintext passwords:** login compares `WebUsers.Password` / `low.Users.Password` directly; **admin screen (`Admin-User-Update.cfm`) writes & displays the password column**.
- **60 hardcoded secrets** (FTP_PASSWORD, apiUser passwords in cfhttp, azureTranslatorKey).
- **Client-cookie trust:** role/identity in cookies (`CurrentUserRoles`, `IsInternalUser`, `ZUserID`) = privilege-escalation risk.
- **78 upload handlers**, **298 debug/cfdump** spots (mostly in junk files).
- ⚠️ **Stored-proc scan BLOCKED** — live `sys.sql_modules` read failed on Windows/SSPI auth; only 5/59 dynamic-SQL from checked-in scripts. **Needs a read-only re-run with a SQL login.**

## The honest "8,422" reframe
Upper bound of sites to review, not live holes. Three buckets:
- 🗑️ **Dead/temp/dev code → DELETE not fix** (`TravisTemp*`, `zDataFix*`, `*_DeleteLater`, `ZTest2`, `test1`, `TestEnv`, `*Copy*`, `Jasonsrepairs` 174, `TanBackup` 49). Erases a big slice + removes risk (shouldn't be web-reachable).
- 🟡 Internal loop-IDs / app constants / ETL table names → low risk, batch-fixable, some false positives.
- 🔴 **URGENT = user-facing subset:** WebPortal (1,623, external customer portal), `External$RFP*`, `API\resources` (59), FieldApp (69), login flow.

## The plan — four tiers
- **TIER 0 (days) — cap blast radius:** replace `sa` → least-privilege logins on `GSTS`+`GSTSAPI`; rotate/vault the 60 secrets. *(sa fix = #1 move; caps damage of ALL sites before any query is touched.)*
- **TIER 1 (weeks) — close front doors:** parameterize user-facing SQLi (WebPortal/RFP/API/FieldApp/login); plaintext passwords → salted hashing + remove admin password display; harden cookies (Secure/HttpOnly/SameSite, stop trusting role cookies).
- **TIER 2 (cheap, parallel):** delete dead/temp files (backup first); lock down 78 upload handlers; strip cfdump/debug.
- **TIER 3 (ongoing, AI-batched):** parameterize remaining internal queries module-by-module; finish proc scan + fix dynamic-SQL procs; FK/dead-table cleanup (broader V1.5).

## NEXT ACTIONS (pending)
1. **▶ Skipper is standing up a NEW dedicated SANDBOX SERVER** to safely execute fixes (separate from PLAY = nightly prod restore). **First real job once it's up: TIER-0 `sa` → least-privilege fix, sandbox-first, backup-first** — also the proof-of-concept that the AI-cleanup path works vs Travis's quote.
2. Re-run the **stored-proc scan read-only with a SQL login** (close the blocked gap).
3. When Travis/Jordan reply with their security quote → compare against this roadmap (numbers vs numbers).

## What the new sandbox needs to be useful (confirm when up)
- A **full copy of the GSTS SQL Server database** + the **ColdFusion codebase/web root** (so fixes can be tested end-to-end).
- **Codex access on it** (same drafts→run→verify workflow), or however Skipper wires our access.
- A **SQL login with metadata/admin rights** on the sandbox (lets us finish the proc scan AND create/test the least-privilege login for the `sa` fix without prod risk).
- Confirm it's **isolated** (no prod data egress / safe to break).

## Workflow guardrails (unchanged)
Gilligan drafts & verifies · Codex executes · Skipper approves. **Backup-first, SANDBOX → verify → PROD, one batch at a time, rollback chain, nothing deleted without a backup.** Gilligan never touches prod DB directly.

## Access notes
- TrimIT read-only: `gilligan-bot` (UserID 376) + `MonitorData.ReadOnly.cfm` endpoint (creds in `anomaly-monitor/.secrets/gilligan-trimit.json`).
- arbortools.net (V2) SUPERADMIN creds held by Skipper, NOT stored.
- security-findings + full discovery.zip pulled to my box via IMAP (gilligan.gsts inbox); report copy in `workspace/files/`.
