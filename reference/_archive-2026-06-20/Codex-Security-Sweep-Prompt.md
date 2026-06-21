# Codex Prompt — TRIM IT (V1) Read-Only Security Sweep

Paste everything in the box below into Codex. It is **read-only** — it scans and writes ONE report file; it changes nothing in the app, database, or config.

---

```
ROLE: Perform a READ-ONLY security assessment of the Great Scott "TRIM IT" system (V1). Produce a findings report only.

ABSOLUTE CONSTRAINTS — READ-ONLY (do not violate):
- DO NOT modify, create, delete, or rename ANY application file, ColdFusion template, stored procedure, table, row, datasource, or configuration.
- Database access is SELECT / metadata reads ONLY. No INSERT/UPDATE/DELETE/ALTER/DROP/CREATE, and do not EXECUTE any stored procedures.
- The ONLY thing you may write is the single findings REPORT file named below. Create nothing else.
- DO NOT print, export, copy, or store any actual secret values (passwords, connection-string passwords, API keys) or dump user rows. Report only their LOCATION and MECHANISM, with values redacted.
- If you are unsure whether an action is read-only, SKIP it and note it in the report. Take no action that changes system state.

ENVIRONMENT:
- ColdFusion code / web root: D:\home\dev.greatscotttreeservice.com\wwwroot  (ERP lives under \GSTS)
- SQL Server: GSTS database (localhost:14333). For any DB reads use the PLAY database if available; reads are metadata/definitions only.
- Output folder (create only this folder if missing): D:\trimit-analysis\discovery\security-sweep\
- Report file: security-findings-<YYYYMMDD-HHMM>.md

TASKS — scan and QUANTIFY each:

1) SQL INJECTION — ColdFusion (highest priority)
   - Scan every .cfm and .cfc under the web root.
   - Find <cfquery> blocks AND cfscript queryExecute() calls that build SQL with interpolated variables (#...#) or string concatenation WITHOUT <cfqueryparam> (or without bound params in queryExecute).
   - Report: total query blocks; number that appear UNPARAMETERIZED (vulnerable); breakdown by module/folder; and the top 30 examples as  filepath : line# : short redacted snippet.
   - Also flag evaluate(), setVariable() used with SQL, and dynamic table/column names taken from user input.

2) SQL INJECTION — SQL Server stored procedures
   - From sys.sql_modules + sys.objects (read-only), scan all stored procedure definitions.
   - Flag procs using dynamic SQL: EXEC(@...), EXECUTE('...'+...), or sp_executesql with concatenated/unparameterized input.
   - Report: total procs; number using dynamic SQL; number that look unparameterized; top 30 proc names + the concerning line.

3) DATABASE LOGIN PRIVILEGE (the "sa" issue)
   - Determine which SQL login the application's ColdFusion datasource uses (check CF datasource config e.g. neo-datasource.xml and any connection strings in code/config — REDACT passwords).
   - Confirm that login's privilege: is it 'sa' or a member of the sysadmin server role? (Read-only: SELECT name, is_disabled FROM sys.server_principals; role membership via sys.server_role_members / IS_SRVROLEMEMBER.)
   - Report the login NAME (never its password) and exactly which server/database roles it holds.

4) PASSWORD STORAGE
   - Inspect login logic (e.g. \GSTS\Login\LoginResults$Split.cfm) and the Users table DEFINITION to determine how passwords are stored & compared (plaintext vs hashed/salted).
   - Report the mechanism and the table/column involved. DO NOT output any password values or dump user rows.

5) OTHER QUICK SIGNALS (lightweight)
   - Hardcoded credentials/secrets/connection strings in code or config (location only, REDACT values).
   - Detailed error exposure (cferror, robust exception/debug output enabled).
   - Session/cookie config (httponly/secure cookie flags, clientmanagement, session timeout).
   - Any obviously unrestricted file-upload handlers.

OUTPUT — write the report file with this structure:
   - EXECUTIVE SUMMARY: a table listing each category with COUNT and SEVERITY (Critical/High/Med/Low) and a one-line status.
   - One section per category: the counts, top examples (path:line:redacted snippet), and a one-line remediation note.
   - "SCOPE TO FIX": rough number of code sites needing parameterization, number of procs to fix, and the discrete config fixes (sa login, password hashing). 
   - Also print the EXECUTIVE SUMMARY to the console.

Reminder: READ-ONLY. The single report file is the only artifact you create. Redact all secret values.
```

---

**After it runs:** send me the `security-findings-*.md` file. I'll turn it into a prioritized remediation scope (effort per item) and the real, numbers-based comparison to Travis's $300K quote.
