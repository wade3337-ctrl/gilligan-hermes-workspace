# Great Scott TRIM IT V1 Read-Only Security Findings

Generated: 2026-06-10 21:33 -05:00
Scope: D:\home\dev.greatscotttreeservice.com\wwwroot, CFML files under web root. Database live metadata reads were attempted with SELECT-only SQL Server connections, but Windows authentication failed before queries ran; no stored procedures were executed and no application files were modified.

## EXECUTIVE SUMMARY
| Category | Count | Severity | Status |
|---|---:|---|---|
| SQL injection - CFML | 8422 / 39966 query surfaces | Critical | Widespread interpolated SQL without cfqueryparam/bound params. |
| SQL injection - SQL Server procs | Live DB scan blocked; repo scripts show 5 / 59 dynamic-SQL signals | High | Live sys.sql_modules could not be read via Windows auth; checked-in proc scripts contain dynamic SQL. |
| Database login privilege | 2 datasource definitions use login sa | Critical | CF datasource config uses SQL Server sa for GSTS/GSTSAPI; live role query blocked, but sa is the built-in sysadmin login. |
| Password storage | 2 password columns compared directly | Critical | Login compares submitted password to WebUsers.Password and flow.Users.Password; admin UI writes/displays same column. |
| Other quick signals | 60 credential locations; 298 debug/error signals; 1204 cookie/session signals; 78 upload handlers | High | Hardcoded secrets, debug dumps, cookies without explicit Secure/HttpOnly, and many upload handlers need review. |

## SQL Injection - ColdFusion

Counts:
- CFML files scanned: 8711
- Total query surfaces: 39966 (39959 <cfquery> blocks, 7 queryExecute() calls)
- Appearing unparameterized/vulnerable: 8422
- evaluate()/setVariable() SQL-adjacent signals: 159

Breakdown by module/folder:
- GSTS\WebPortal: 1623
- GSTS\Chrome: 517
- GSTS\Steel: 516
- GSTS\Yellow: 509
- GSTS\Water: 464
- GSTS\Blue: 287
- GSTS\Orange: 209
- GSTS\Jasonsrepairs: 174
- GSTS\FieldApp: 69
- API\resources: 59
- GSTS\CallIns: 55
- GSTS\TanBackup: 49
- GSTS\Red: 30
- GSTS\Overview: 29
- GSTS\External$RFP$Queries_MyleDelete.cfm: 21
- GSTS\Company.Pending.RFPs_Queries.cfm: 21
- GSTS\Queries: 21
- GSTS\External$RFP$Queries.cfm: 21
- GSTS\External$RFP$Content.cfm: 19
- GSTS\External$RFP$Detail$Split$Version.cfm: 18
- GSTS\External$RFP$Detail$Print.cfm: 18
- GSTS\External$RFP$Detail$Frame.cfm: 18
- GSTS\External$RFP$Detail$EstablishedPriorVersion_DeleteLater.cfm: 17
- GSTS\External$RFP$Detail$dev2_DeleteLater.cfm: 17
- GSTS\External$RFP$Detail$dev4_DeleteLater.cfm: 17

Top 30 examples:
- Application.cfc:186: <cfquery name="AppVariables" datasource="#application.dsnName#"> SELECT dbo.GetAppVariable('FrontEndPath') AS FrontEndPath, dbo.GetAppVariable('FrontEndDrivePath') AS FrontEndDrivePath </cfquery>
- Client-Observations-Project-Calendars.cfm:8: <cfquery name="SelectedObservationDef" datasource="GSTS"> SELECT ObservationDefs.ObservationDefID, ISNULL(ObservationDefs.CodeDesc1, ObservationDefs.Desc1) AS CodeDesc1 FROM dbo.ObservationDefs WITH (NOLOCK) WH...
- Exec$UserCalendars.ContentTravisTest.cfm:30: <cfquery datasource="#application.dsn#" name="MYDATE"> select datediff(day,'1899-12-30','#PAYROLL_PERIODS.StartDate#') AS DATE </cfquery>
- GroupTemp.cfm:9: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.InventoryGroups SET ImagePath = NULL WHERE InventoryGroupID = #TEST.InventoryGroupID[i]# </cfquery>
- TravisTemp44.cfm:14: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.InventoryDetail SET ReplacementCost = '#DATA.EstValue[i]#' WHERE ProjectID = 1098977 AND GSTSID = '#DATA.ID[i]#' </cfquery>
- TravisTemp44.cfm:20: <cfquery datasource="GSTS"> UPDATE HistoryDataTravisTemp SET Updated = 1 WHERE ID = '#DATA.ID[i]#' </cfquery>
- zDataFix2.cfm:11: <cfquery datasource="GSTS" name="DATA2"> SELECT InventoryDetailID FROM GSTS.dbo.InventoryDetail WHERE ExternalSystemID = #DATA.ExternalSystemID[i]# AND PROJECTID = 1095104 </cfquery>
- zDataFix2.cfm:18: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.InventoryDetail SET SizeCode = '07-12', DBHRange = '07-12' WHERE InventoryDetailID = #DATA2.InventoryDetailID# AND PROJECTID = 1095104 </cfquery>
- ZFixCompanyYears.cfm:11: <cfquery datasource="gsts"> DECLARE @return_value int EXEC @return_value = [dbo].[UpdateCompanyYear$Figures] @ZCompanyID = '#years.companyid[i]#', @ZCompanyYearID = '#years.CompanyYearID[i]#' SELECT 'Return Val...
- ZTest2.cfm:666: <cfquery name="Invoices" datasource="GSTS"> SELECT Invoices.InvoiceID, Invoices.Desc1, Invoices.InvoiceDate, Invoices.CompanyID, Invoices.StatusDefID, Invoices.CollectionValue, Invoices.RetentionValue, Invoices...
- API\resources\bulkImportCSVFromGSTS.cfc:90: <cfquery datasource="GSTS"> SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON; CREATE TABLE [dbo].[#LOCAL.TABLE#] ( [InventoryDetailID] [varchar](50) NULL, [PruningFrequency] [varchar](50) NULL, ...
- API\resources\bulkImportCSVFromGSTS.cfc:173: <cfquery datasource="GSTS" name="BCP_OUTPUT"> DECLARE @InputFilePath NVARCHAR(500) = '#APPLICATION.BULK_IMPORT_DB_PATH#\#csvFileName#'; DECLARE @myCommand NVARCHAR(2000) SET @myCommand = 'bcp #LOCAL.TABLE# in "...
- API\resources\bulkImportCSVFromGSTS.cfc:190: <cfquery datasource="GSTS"> UPDATE [dbo].[#LOCAL.TABLE#] SET Size = REPLACE(SUBSTRING(Size, 2, LEN(Size)-2), '~~', '"'), DBHRange = REPLACE(SUBSTRING(DBHRange, 2, LEN(DBHRange)-2), '~~', '"') WHERE Size LIKE '"...
- API\resources\bulkImportCSVFromGSTS.cfc:203: <cfquery datasource="GSTS"> UPDATE [dbo].[#LOCAL.TABLE#] SET InventoryDetailID = NULLIF(NULLIF(LTRIM(RTRIM(InventoryDetailID)), ''), 'NULL'), PruningFrequency = NULLIF(NULLIF(LTRIM(RTRIM(PruningFrequency)), '')...
- API\resources\bulkImportCSVFromGSTS.cfc:258: <cfquery datasource="GSTS" name="DATA"> SELECT COUNT(*) AS MYCOUNT FROM #LOCAL.TABLE# </cfquery>
- API\resources\bulkImportProcessData.cfc:64: <cfquery datasource="GSTS" name="PROJECT"> SELECT DISTINCT ProjectID FROM #BULKIMPORT.BulkImportMaster_Table# </cfquery>
- API\resources\bulkImportProcessData.cfc:69: <cfquery datasource="GSTS" name="LOCATION"> SELECT DISTINCT LocationID FROM #BULKIMPORT.BulkImportMaster_Table# </cfquery>
- API\resources\bulkImportProcessData.cfc:205: <cfquery datasource="GSTS" name="COUNT"> SELECT COUNT(*) AS MYCOUNT FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE InventoryDetailID IS NULL </cfquery>
- API\resources\bulkImportProcessData.cfc:211: <cfquery datasource="GSTS" name="LOCATION_DATA"> SELECT TOP 1 ProjectID, LocationID FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# </cfquery>
- API\resources\bulkImportValidateData.cfc:101: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# SET #myCol# = SUBSTRING(cast(#myCol# as varchar(8000)), 2, LEN(#myCol#)) WHERE LEFT(#myCol#, 1) = '"' </cfquery>
- API\resources\bulkImportValidateData.cfc:107: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# SET #myCol# = SUBSTRING(cast(#myCol# as varchar(8000)), 1, LEN(#myCol#)-1) WHERE RIGHT(#myCol#, 1) = '"' </cfquery>
- API\resources\bulkImportValidateData.cfc:115: <cfquery datasource="GSTS"> UPDATE GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# SET #myCol# = '' WHERE UPPER(CAST(#myCol# AS VARCHAR(8000))) = 'NULL' </cfquery>
- API\resources\bulkImportValidateData.cfc:143: <cfquery datasource="GSTS" name="PROJECT"> SELECT DISTINCT ProjectID FROM #BULKIMPORT.BulkImportMaster_Table# </cfquery>
- API\resources\bulkImportValidateData.cfc:194: <cfquery datasource="GSTS" name="LOCATION"> SELECT DISTINCT LocationID FROM #BULKIMPORT.BulkImportMaster_Table# </cfquery>
- API\resources\bulkImportValidateData.cfc:388: <cfquery datasource="GSTS" name="ZIP_CODES"> SELECT DISTINCT ZipCode FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE ZipCode NOT IN ( SELECT ZipCode FROM GSTS.dbo.ZipCodes WHERE ZipCodes.ZipCode = GSTS....
- API\resources\bulkImportValidateData.cfc:598: <cfquery datasource="GSTS" name="MAINT_NEEDS"> SELECT DISTINCT MaintenanceNeed FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE LTrim(RTrim(MaintenanceNeed)) NOT IN ( SELECT Desc1 FROM GSTS.dbo.MaintNeed...
- API\resources\bulkImportValidateData.cfc:619: <cfquery datasource="GSTS" name="MAINT_NEEDS"> SELECT DISTINCT MaintenanceNeed FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE LTrim(RTrim(MaintenanceNeed)) NOT IN ( SELECT Desc1 FROM GSTS.dbo.MaintNeed...
- API\resources\bulkImportValidateData.cfc:648: <cfquery datasource="GSTS" name="CONDITION_DEFS"> SELECT DISTINCT Condition FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE UPPER(LTrim(RTrim(Condition))) NOT IN ( SELECT Desc1 FROM GSTS.dbo.ConditionDe...
- API\resources\bulkImportValidateData.cfc:669: <cfquery datasource="GSTS" name="CONDITION_DEFS"> SELECT DISTINCT Condition FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE UPPER(LTrim(RTrim(Condition))) NOT IN ( SELECT Desc1 FROM GSTS.dbo.ConditionDe...
- API\resources\bulkImportValidateData.cfc:698: <cfquery datasource="GSTS" name="INVENTORY_CLASSES"> SELECT DISTINCT InventoryClass FROM GSTS.dbo.#BULKIMPORT.BulkImportMaster_Table# WHERE UPPER(LTrim(RTrim(InventoryClass))) NOT IN ( SELECT Desc1 AS Inventory...

Additional dynamic/evaluate signals, first 10:
- API\taffy\core\factory.cfc:180: evaluate("arguments.bean.#local.fname#(getBean('#local.propName#'))") /> </cfif> </cfif> </cfloop> </cfif> <cfif structKeyExists(arguments.metaData, "properties") and isArray(arguments.metaData.properties)> <cf...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:10: Evaluate("LineNumber" & ThisRow)#,0) ,Desc1 = ISNULL('#Evaluate("Desc1" & ThisRow)#','') ,AreaRef = ISNULL('#Evaluate("AreaRef" & ThisRow)#','') ,SpeciesRef = ISNULL('#Evaluate("SpeciesRef" & ThisRow)#','') ,Sp...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:11: Evaluate("Desc1" & ThisRow)#','') ,AreaRef = ISNULL('#Evaluate("AreaRef" & ThisRow)#','') ,SpeciesRef = ISNULL('#Evaluate("SpeciesRef" & ThisRow)#','') ,SpeciesName = ISNULL('#Evaluate("SpeciesName" & ThisRow)#...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:12: Evaluate("AreaRef" & ThisRow)#','') ,SpeciesRef = ISNULL('#Evaluate("SpeciesRef" & ThisRow)#','') ,SpeciesName = ISNULL('#Evaluate("SpeciesName" & ThisRow)#','') ,ItemSize = ISNULL('#Evaluate("ItemSize" & ThisR...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:13: Evaluate("SpeciesRef" & ThisRow)#','') ,SpeciesName = ISNULL('#Evaluate("SpeciesName" & ThisRow)#','') ,ItemSize = ISNULL('#Evaluate("ItemSize" & ThisRow)#','') ,Qty = ISNULL(#Evaluate("Qty" & ThisRow)#,0) ,Ite...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:14: Evaluate("SpeciesName" & ThisRow)#','') ,ItemSize = ISNULL('#Evaluate("ItemSize" & ThisRow)#','') ,Qty = ISNULL(#Evaluate("Qty" & ThisRow)#,0) ,ItemNote = ISNULL('#Evaluate("ItemNote" & ThisRow)#','') WHERE Inv...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:15: Evaluate("ItemSize" & ThisRow)#','') ,Qty = ISNULL(#Evaluate("Qty" & ThisRow)#,0) ,ItemNote = ISNULL('#Evaluate("ItemNote" & ThisRow)#','') WHERE InventoryWorksheetLineID=#Evaluate("InventoryWorksheetLineID" & ...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:16: Evaluate("Qty" & ThisRow)#,0) ,ItemNote = ISNULL('#Evaluate("ItemNote" & ThisRow)#','') WHERE InventoryWorksheetLineID=#Evaluate("InventoryWorksheetLineID" & ThisRow)# </cfquery> </cfloop> <script> history.back...
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:17: Evaluate("ItemNote" & ThisRow)#','') WHERE InventoryWorksheetLineID=#Evaluate("InventoryWorksheetLineID" & ThisRow)# </cfquery> </cfloop> <script> history.back(-1); </script> </BODY> </HTML>
- GSTS\CodeUpdateInventoryWorksheetLines.Complex.cfm:18: Evaluate("InventoryWorksheetLineID" & ThisRow)# </cfquery> </cfloop> <script> history.back(-1); </script> </BODY> </HTML>

Remediation: replace interpolated SQL values with <cfqueryparam> or bound queryExecute() params; whitelist dynamic table/column names before SQL construction.

## SQL Injection - SQL Server Stored Procedures

Live sys.sql_modules status:
- Attempted SELECT-only metadata reads using integrated authentication against localhost,14333, 127.0.0.1,14333, GSTSDATABASE,14333, and ..
- All attempts failed before query execution with SSPI target-principal errors, so live stored procedure totals could not be confirmed without using credentials or creating a diagnostic file, both skipped under the read-only constraints.

Supporting checked-in SQL-script scan:
- SQL files scanned: 88
- Procedure definitions in checked-in scripts/backups: 59
- Dynamic SQL signals: 5
- Dynamic SQL signals that look unparameterized/concatenated: 5

Top examples:
- SQLScripts\AddExternalSystemID2-BulkImport.sql:244: EXECUTE sp_executesql @Sql
- SQLScripts\AddExternalSystemID2-BulkImport.sql:412: EXECUTE sp_executesql @Sql
- SQLScripts\CreateDefaultLanguage.sql:84: EXEC('ALTER TABLE dbo.StaffMembers ADD CONSTRAINT DF_StaffMembers_DefaultLanguageID DEFAULT (' + @EnglishID + ') FOR DefaultLanguageID');
- SQLScripts\CreateDefaultLanguage.sql:87: EXEC('ALTER TABLE dbo.CrewMembers ADD CONSTRAINT DF_CrewMembers_DefaultLanguageID DEFAULT (' + @EnglishID + ') FOR DefaultLanguageID');
- SQLScripts\TREE-168-dbo.DeleteWorkOrderLine(after).sql:91: EXEC (@VTempstring);

Remediation: inventory live procs from sys.sql_modules, then replace concatenated dynamic SQL with strongly typed sp_executesql parameters and whitelist dynamic identifiers.

## Database Login Privilege

Findings:
- C:\ColdFusion2023\cfusion\lib\neo-datasource.xml: datasource GSTS uses username sa; password value redacted.
- C:\ColdFusion2023\cfusion\lib\neo-datasource.xml: datasource GSTSAPI uses username sa; password value redacted.
- JDBC URL: localhost:14333, database GSTS.
- Live sys.server_principals / sys.server_role_members confirmation was blocked by SQL auth/SSPI access from this shell. Because the configured login is sa, the effective server role is SQL Server built-in system administrator (sysadmin).

Remediation: create least-privilege SQL logins for app/API datasources, grant only required database roles/permissions, disable direct sa application use, and rotate datasource passwords.

## Password Storage

Findings:
- GSTS\Login\LoginResults.cfm:10-11: external login compares WebUsers.EmailAddress and WebUsers.Password directly to submitted form values via cfqueryparam.
- GSTS\Login\LoginResults.cfm:24-25 and 50-51: internal login compares low.Users.UserEmail/LoginName and low.Users.Password directly to submitted form values.
- GSTS\Admin-User-Update.cfm:31-32: admin update writes FORM.Password directly into low.Users.Password.
- GSTS\Admin-User-Update.cfm:133 and 225-226: admin screen selects and renders the Password column back into a password input.
- Live table definition for Users/WebUsers could not be read due the same SQL Server authentication block. Code evidence indicates reversible/plaintext-style password storage rather than salted password hashes.

Remediation: migrate to per-user salted adaptive password hashing (Argon2id/bcrypt/PBKDF2), remove password display from admin forms, and force password reset/rehash on next login.

## Other Quick Signals

Hardcoded credentials/secrets/connection strings:
- Count: 60
- Application.cfc:206: APPLICATION.azureTranslatorKey
- Application.cfc:212: APPLICATION.FTP_PASSWORD
- cfc\Translation.cfc:267: APPLICATION.azureTranslatorKey
- cfc\Translation.cfc:291: APPLICATION.azureTranslatorKey
- GSTS\CodeGenerateProjectMaster$Current.cfm:28: cfhttp method="POST" username="apiUser" password=
- GSTS\CodeGenerateProposal$NoBlanks.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\CodeGenerateProposal$Placeholder.cfm:24: cfhttp method="POST" username="apiUser" password=
- GSTS\Dev$Mail.cfm:37: uid=
- GSTS\ImportInventoryDetailData.cfm:63: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\ImportInventoryDetailData.cfm:97: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\ImportInventoryDetailData.cfm:133: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\New.CodeGenerateMapProposal.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\New.CodeGenerateProposal.cfm:50: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$FutureSnapshot$NoBlanks.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$FutureSnapshot.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$Immediate.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$ImmediateAll.cfm:33: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$MultiYearImmediate.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$SeasonalImmediate.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\Synch.CodeGenerateProposal$YearInReview.cfm:43: cfhttp method="POST" username="apiUser" password=
- GSTS\ZProcessBulkImports.cfm:14: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\API\apiCall.cfm:166: cfhttp method="POST" username="apiUser" password=
- GSTS\API\apiCallOld.cfm:153: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\API\apiCallOld.cfm:223: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=
- GSTS\API\refreshCache.cfm:29: cfhttp method="POST" url="#VARIABLES.myURL#" username="apiUser" password=

Remediation: move secrets to a managed secret store/environment config, rotate exposed values, and keep only secret references in code.

Detailed error/debug exposure:
- Count: 298
- Application.cfc:696: cfdump
- Application.cfc:705: cfdump
- Exec$UserCalendars.ContentTravisTest.cfm:34: cfdump
- test1.cfm:1: cfdump
- TestEnv.cfm:1: cfdump
- TravisTemp$09272023.cfm:38: cfdump
- TravisTemp$09272023.cfm:38: cfdump
- TravisTemp$09272023.cfm:38: cfdump
- TravisTemp$09272023.cfm:38: cfdump
- TravisTemp44.cfm:10: cfdump
- ZTest2.cfm:332: cfdump
- ZTest2.cfm:351: cfdump
- ZTest2.cfm:1673: cfdump
- API\Application - Copy.cfc:104: writeDump(
- API\Application - Copy.cfc:176: cfdump
- API\Application.cfc:349: cfdump
- API\taffy\bonus\LogToBugLogHQ.cfc:7: cfdump
- API\taffy\bonus\LogToEmail.cfc:32: cfdump
- API\taffy\bonus\LogToEmail.cfc:34: cfdump
- API\taffy\bonus\LogToEmail.cfc:39: cfdump

Remediation: remove public cfdump/writeDump/trace/debug artifacts and route errors through centralized sanitized handlers.

Session/cookie configuration:
- Count: 1204
- Application.cfc:9: THIS.SessionManagement = true />
- Application.cfc:10: THIS.SetClientCookies = false />
- Application.cfc:11: THIS.SessionTimeout = CreateTimeSpan(0, 6, 0, 0) />
- Application.cfc:307: <cfcookie name="ZUserID" value="" expires="now" /
- Application.cfc:308: <cfcookie name="ZWebUserID" value="" expires="now" /
- Application.cfc:309: <cfcookie name="IsInternalUser" value="" expires="now" /
- Application.cfc:310: <cfcookie name="CurrentUserRoles" value="" expires="now" /
- API\Application - Copy.cfc:11: This.Sessiontimeout = createtimespan( 0, 1, 0, 0 )>
- API\Application - Copy.cfc:12: THIS.SessionManagement = true>
- API\Application - Copy.cfc:13: THIS.SetClientCookies = true>
- API\Application - Copy.cfc:64: cfapplication name="TrimIT" setclientcookies="No" sessionManagement="yes" sessiontimeout = "#CreateTimeSpan(2,0,0,0)#"
- API\Application.cfc:12: THIS.Sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
- API\Application.cfc:13: THIS.SessionManagement = true>
- API\Application.cfc:14: THIS.SetClientCookies = true>
- GSTS\Application_Good11032020.cfm:1: cfapplication name="TrimIT" setclientcookies="No" sessionManagement="yes" sessiontimeout = "#CreateTimeSpan(2,0,0,0)#"
- GSTS\CodeGenerateInventoryDetailImageObject$FromType$OUT.cfm:25: <cfcookie name = "CInventoryDetailImageObjectID" value = "#out_XInventoryDetailImageObjectID#" expires = "30"
- GSTS\CodeGenerateInventoryDetailImageObject$FromType$OUT.cfm:30: <cfcookie name="CInventoryDetailImageObjectID" value="0" expires="now"
- GSTS\CodeGenerateInventoryDetailImageObject$FromType$OUT.cfm:31: <cfcookie name = "CInventoryDetailImageObjectID" value = "#out_XInventoryDetailImageObjectID#" expires = "30"
- GSTS\CodeSetCookie.cfm:10: <cfcookie name = "#ZCookieName#" value = "#ZCookieValue#" expires = "#ZExpires#"
- GSTS\CodeSetCookie.cfm:15: <cfcookie name="#ZCookieName#" value="0" expires="now"

Remediation: set Secure, HttpOnly, and SameSite on auth/session cookies; avoid identity/role values in client-controlled cookies; review long session/application timeouts.

File-upload handlers:
- Count: 78
- GSTS\Email.InventoryDetail.Image.Upload.cfm:21: <cffile action="upload
- GSTS\HR-CrewMember-Image-Upload.cfm:16: <cffile action="upload
- GSTS\HR-StaffMember-Image-Upload.cfm:16: <cffile action="upload
- GSTS\ImportInventoryDetailData.cfm:10: <cffile action="upload
- GSTS\Maint.InventoryGroup.ImageUpload.cfm:16: <cffile action="upload
- GSTS\Profile$ProfileCommentImageAddOnForm.cfm:6: <cffile action="upload
- GSTS\Profile.Image.Attach.cfm:7: <cffile action="upload
- GSTS\Profile.Image.Upload.cfm:28: <cffile action="upload
- GSTS\Profile.Image.Upload.cfm:31: <cffile action="upload
- GSTS\Profile.ImportFile.Upload.cfm:21: <cffile action="upload
- GSTS\Profile.InventoryDetail.Image.Upload.cfm:21: <cffile action="upload
- GSTS\Profile.InventoryDetail.Image.UploadAndDynamicallyResize.cfm:23: <cffile action="upload
- GSTS\Profile.InventoryDetail.Image.UploadAndResize.cfm:21: <cffile action="upload
- GSTS\Profile.Map.Company.Upload.cfm:21: <cffile action="upload
- GSTS\Profile.Map.CompanyContract.Upload.cfm:21: <cffile action="upload
- GSTS\Profile.Map.Update.cfm:21: <cffile action="upload
- GSTS\Profile.Map.Upload$dev.cfm:21: <cffile action="upload
- GSTS\Profile.Map.Upload$raw.cfm:21: <cffile action="upload
- GSTS\Profile.Map.Upload.cfm:36: <cffile action="upload
- GSTS\Profile.RepairOrderImage.Upload.cfm:28: <cffile action="upload
- GSTS\Profile.RFPPackage.Attach$Master.cfm:23: <cffile action="upload
- GSTS\Profile.RFPPackage.Upload.cfm:21: <cffile action="upload
- GSTS\Remote$Profile.Map.Upload.cfm:21: <cffile action="upload
- GSTS\Remote$Profile.PayrollPeriod.Update.New.cfm:20: <cffile action="upload
- GSTS\Synch.Company.Update$dev.cfm:21: <cffile action="upload

Remediation: require authentication/authorization, enforce extension and MIME allowlists, store outside executable web paths, randomize names, virus-scan uploads, and disable legacy upload managers.

## SCOPE TO FIX

- CFML parameterization sites: approximately 8422 query blocks/calls need review and likely parameterization or identifier whitelisting.
- SQL Server procs: live count unavailable; checked-in scripts show 5 dynamic-SQL sites across 59 procedure definitions/scripts requiring review, with 5 likely unparameterized/concatenated.
- Configuration fixes: replace sa datasource login for GSTS and GSTSAPI; rotate datasource/FTP/API/Azure secrets; configure secure cookie flags; disable/debug-gate dumps and verbose error output; lock down upload endpoints.
- Password fixes: migrate WebUsers.Password and low.Users.Password away from direct stored password comparison to salted adaptive hashes and remove display of stored password material in admin UI.