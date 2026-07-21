<cfparam name="URL.view" default="1" type="string">

<cfif URL.view NEQ 1 AND URL.view NEQ 2>
  <cfset URL.view = 1>
</cfif>

<cfset currentYear = Year(Now())>
<cfset minYear = currentYear - 9>
<cfparam name="URL.startYear" default="#currentYear#" type="string">
<cfparam name="URL.endYear" default="#currentYear#" type="string">

<cfif NOT IsNumeric(URL.startYear) OR URL.startYear LT minYear OR URL.startYear GT currentYear>
  <cfset URL.startYear = currentYear>
</cfif>

<cfif NOT IsNumeric(URL.endYear) OR URL.endYear LT minYear OR URL.endYear GT currentYear>
  <cfset URL.endYear = currentYear>
</cfif>

<!--- Start Month selector (used when no date range is provided) --->
<cfparam name="URL.startMonth" default="1" type="string">
<cfif NOT IsNumeric(URL.startMonth) OR URL.startMonth LT 1 OR URL.startMonth GT 12>
  <cfset URL.startMonth = 1>
</cfif>

<!--- End Month selector (used when no date range is provided) --->
<cfparam name="URL.endMonth" default="#Month(Now())#" type="string">
<cfif NOT IsNumeric(URL.endMonth) OR URL.endMonth LT 1 OR URL.endMonth GT 12>
  <cfset URL.endMonth = Month(Now())>
</cfif>

<!--- Date range parameters for searching (optional) --->
<cfparam name="URL.startDate" default="" type="string">
<cfparam name="URL.endDate" default="" type="string">

<!--- Validate and parse dates --->
<cfif URL.startDate NEQ "" AND IsDate(URL.startDate)>
  <cfset startDateValue = CreateODBCDate(URL.startDate)>
<cfelse>
  <cfset startDateValue = "">
</cfif>

<cfif URL.endDate NEQ "" AND IsDate(URL.endDate)>
  <cfset endDateValue = CreateODBCDate(URL.endDate)>
<cfelse>
  <cfset endDateValue = "">
</cfif>

<!--- Keep existing period range calcs (unused by the updated queries, but leaving intact) --->
<cfset yearsSince2000 = URL.startYear - 2000>
<cfset URL.startPeriod = (yearsSince2000 * 12) + 16>
<cfset URL.endPeriod = URL.startPeriod + 11>

<cfparam name="URL.step" default="10" type="string">

<cfif URL.step NEQ 10 AND URL.step NEQ 25 AND URL.step NEQ 50 AND URL.step NEQ 100 AND URL.step NEQ 250 AND URL.step NEQ 500 AND URL.step NEQ 1000>
  <cfset URL.step = 100>
</cfif>

<cfparam name="URL.search" default="" type="string">

<cfparam name="URL.page" default="1" type="string">

<cfif URL.page LT 1>
  <cfset URL.page = 1>
</cfif>

<cfset URL.start_row = URL.page * URL.step - URL.step>
<cfset URL.end_row = (URL.page+1) * URL.step - URL.step - 1>

<cfif IsDefined("URL.completeDocumentActions") AND URL.completeDocumentActions EQ 1>

  <CFSTOREDPROC procedure="dbo.CURSOR$BumpProjectBillingAddressConfirmed$SelectedNew" datasource="GSTS"></CFSTOREDPROC>

  <cflocation url="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=1&completed=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#&startDate=#URL.startDate#&endDate=#URL.endDate#" addtoken="false">

</cfif>

<cfif IsDefined("URL.stageDocumentActions") AND URL.stageDocumentActions EQ 1>

  <CFSTOREDPROC procedure="dbo.CURSOR$BumpDocumentActions$Stage" datasource="GSTS">
    <CFPROCPARAM type="IN" dbvarname="@ZDocumentActionModelID" value="2" cfsqltype="CF_SQL_INTEGER">
  </CFSTOREDPROC>

  <cflocation url="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=1&staged=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#&startDate=#URL.startDate#&endDate=#URL.endDate#" addtoken="false">

</cfif>

<!---
  FIXED QUERY LOGIC:
  - Drive from Invoices (so invoices can't disappear due to CrewSheets joins)
  - Match INV report invoice-status filter (invoice status, not workorder status)
  - If start/end dates provided -> filter by InvoiceDate (optional restriction)
    Else -> filter by accounting period month/year via Periods.StartDate (INV report behavior)
  - Avoid Location row multiplication using OUTER APPLY TOP 1
--->
<cfquery name="Projects" datasource="GSTS">
    SELECT
        i.InvoiceID AS InvoiceID,
        i.LegacyRef AS InvoiceNumber,
        i.Total AS InvoiceAmount,
        i.DirectCosts AS InvoiceDirectCosts,
        CASE WHEN EXISTS (SELECT 1 FROM gsts.dbo.InvoiceLines il_t
                          WHERE il_t.InvoiceID = i.InvoiceID
                            AND il_t.ServiceTypeID IN (
                              SELECT ServiceTypeID FROM gsts.dbo.ServiceTypes
                              WHERE (Desc1 LIKE '%treat%' OR Desc1 LIKE '%spray%' OR Desc1 LIKE '%inject%' OR Desc1 LIKE '%fertil%'
                                  OR Desc1 LIKE '%psyllid%' OR Desc1 LIKE '%thrip%' OR Desc1 LIKE '%aphid%' OR Desc1 LIKE '%onyx%' OR Desc1 LIKE '%roundup%')
                                AND Desc1 NOT LIKE '%trim%' AND Desc1 NOT LIKE '%pineapple%' AND Desc1 NOT LIKE '%sound%'))
             THEN 'Treatment' ELSE 'Standard' END AS SaleType,
        i.InvoiceDate AS InvoiceDateRaw,
        CONVERT(varchar(10), i.InvoiceDate, 101) AS InvoiceDate,

        c.Desc1 AS CompanyName,
        c.Street AS CompanyStreetLine1,
        c.Street2 AS CompanyStreetLine2,
        c.City AS CompanyCity,
        c.State AS CompanyState,
        c.ZipCode AS CompanyZipCode,

        l.Desc1 AS LocationName,
        pt.Desc1 AS ProjectType,
        sr.FullName AS SalesRep,

        prj.Desc1 AS ProjectName,
        prop.ProposalID AS ProposalID,
        prop.LegacyRef AS ProposalNumber,
        prop.Desc1 AS ProposalDesc,

        wo.WorkOrderID AS WorkOrderNumber,
        cn.Desc1 AS CrewLeader,

        i.TotalHours AS InvoiceTotalHours,
        wo.TPH AS WorkOrderTPH,
        ISNULL(yt.Desc1, '') AS YardType,
        ISNULL(ds.Desc1, 'Style001') AS InvoiceDocumentStyleDesc1

    FROM gsts.dbo.Invoices i WITH (NOLOCK)
    INNER JOIN gsts.dbo.StatusDefs invSD WITH (NOLOCK)
        ON i.StatusDefID = invSD.StatusDefID
    INNER JOIN gsts.dbo.Periods p WITH (NOLOCK)
        ON i.PeriodID = p.PeriodID

    INNER JOIN gsts.dbo.WorkOrders wo WITH (NOLOCK)
        ON i.WorkOrderID = wo.WorkOrderID
    INNER JOIN gsts.dbo.Proposals prop WITH (NOLOCK)
        ON i.ProposalID = prop.ProposalID
    INNER JOIN gsts.dbo.Projects prj WITH (NOLOCK)
        ON prop.ProjectID = prj.ProjectID
    LEFT JOIN gsts.dbo.DocumentStyles ds WITH (NOLOCK)
        ON prj.InvoiceDocumentStyleID = ds.DocumentStyleID
    LEFT JOIN gsts.dbo.ProjectType pt WITH (NOLOCK)
        ON prj.ProjectTypeID = pt.ProjectTypeID
    LEFT JOIN gsts.dbo.YardTypes yt WITH (NOLOCK)
        ON wo.YardTypeID = yt.YardTypeID
    INNER JOIN gsts.dbo.Companies c WITH (NOLOCK)
        ON prop.CompanyID = c.CompanyID

    LEFT JOIN gsts.dbo.SalesReps sr WITH (NOLOCK)
        ON prop.SalesRepID = sr.SalesRepID

    LEFT JOIN gsts.dbo.CrewNames cn WITH (NOLOCK)
        ON wo.DefaultCrewNameID = cn.CrewNameID

    LEFT JOIN gsts.dbo.Locations l WITH (NOLOCK)
        ON l.ProjectID = prj.ProjectID 
        AND l.LocationID = (SELECT MIN(LocationID) FROM gsts.dbo.Locations WHERE ProjectID = prj.ProjectID)

    WHERE
        invSD.Desc1 IN ('InProcess','Pending','Open','Paid','Locked')

        <!--- Date range provided? Use InvoiceDate filter. Otherwise use Period month/year range filter. --->
        <cfif startDateValue NEQ "" OR endDateValue NEQ "">
            <cfif startDateValue NEQ "" AND endDateValue NEQ "">
                AND i.InvoiceDate BETWEEN <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
                                      AND <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
            <cfelseif startDateValue NEQ "">
                AND i.InvoiceDate >= <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
            <cfelseif endDateValue NEQ "">
                AND i.InvoiceDate <= <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
            </cfif>
        <cfelse>
            AND (
                (YEAR(p.StartDate) > <cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer"> 
                 OR (YEAR(p.StartDate) = <cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer"> 
                     AND MONTH(p.StartDate) >= <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">))
                AND
                (YEAR(p.StartDate) < <cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer"> 
                 OR (YEAR(p.StartDate) = <cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer"> 
                     AND MONTH(p.StartDate) <= <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">))
            )
        </cfif>

        <!--- Text search filter --->
        <cfif URL.search NEQ "">
        AND (
               c.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR prj.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR i.LegacyRef LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR prop.LegacyRef LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR sr.FullName LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR cn.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR l.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
        )
        </cfif>

    ORDER BY i.InvoiceDate DESC, c.Desc1, i.InvoiceID
    OFFSET      #URL.start_row# ROWS
    FETCH NEXT  #URL.step# ROWS ONLY
</cfquery>

<cfquery name="ProjectCount" datasource="GSTS">
    SELECT COUNT(*) AS MYCOUNT
    FROM gsts.dbo.Invoices i WITH (NOLOCK)
    INNER JOIN gsts.dbo.StatusDefs invSD WITH (NOLOCK)
        ON i.StatusDefID = invSD.StatusDefID
    INNER JOIN gsts.dbo.Periods p WITH (NOLOCK)
        ON i.PeriodID = p.PeriodID
    
    <cfif URL.search NEQ "">
        INNER JOIN gsts.dbo.WorkOrders wo WITH (NOLOCK)
            ON i.WorkOrderID = wo.WorkOrderID
        INNER JOIN gsts.dbo.Proposals prop WITH (NOLOCK)
            ON i.ProposalID = prop.ProposalID
        INNER JOIN gsts.dbo.Projects prj WITH (NOLOCK)
            ON prop.ProjectID = prj.ProjectID
        INNER JOIN gsts.dbo.Companies c WITH (NOLOCK)
            ON prop.CompanyID = c.CompanyID
        LEFT JOIN gsts.dbo.SalesReps sr WITH (NOLOCK)
            ON prop.SalesRepID = sr.SalesRepID
        LEFT JOIN gsts.dbo.CrewNames cn WITH (NOLOCK)
            ON wo.DefaultCrewNameID = cn.CrewNameID
        LEFT JOIN gsts.dbo.Locations l WITH (NOLOCK)
            ON l.ProjectID = prj.ProjectID 
            AND l.LocationID = (SELECT MIN(LocationID) FROM gsts.dbo.Locations WHERE ProjectID = prj.ProjectID)
    </cfif>

    WHERE
        invSD.Desc1 IN ('InProcess','Pending','Open','Paid','Locked')

        <cfif startDateValue NEQ "" OR endDateValue NEQ "">
            <cfif startDateValue NEQ "" AND endDateValue NEQ "">
                AND i.InvoiceDate BETWEEN <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
                                      AND <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
            <cfelseif startDateValue NEQ "">
                AND i.InvoiceDate >= <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
            <cfelseif endDateValue NEQ "">
                AND i.InvoiceDate <= <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
            </cfif>
        <cfelse>
            AND (
                (YEAR(p.StartDate) > <cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer"> 
                 OR (YEAR(p.StartDate) = <cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer"> 
                     AND MONTH(p.StartDate) >= <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">))
                AND
                (YEAR(p.StartDate) < <cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer"> 
                 OR (YEAR(p.StartDate) = <cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer"> 
                     AND MONTH(p.StartDate) <= <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">))
            )
        </cfif>

        <cfif URL.search NEQ "">
        AND (
               c.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR prj.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR i.LegacyRef LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR prop.LegacyRef LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR sr.FullName LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR cn.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
            OR l.Desc1 LIKE <cfqueryparam value="%#URL.search#%" cfsqltype="cf_sql_varchar">
        )
        </cfif>
</cfquery>

<cfset URL.max_page = Ceiling(ProjectCount.MyCount / URL.step)>
<cfset URL.myCount = ProjectCount.MyCount>

<cfquery name="SalesPerfByRep" datasource="GSTS">
  SELECT e.effRep AS RepName,
    COUNT(*) AS WrittenN, SUM(X.Won) AS WonN,
    CAST(100.0*SUM(X.Won)/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS WinPctJobs,
    CAST(SUM(X.EstValue) AS DECIMAL(18,0)) AS WrittenVal,
    CAST(SUM(CASE WHEN X.Won=1 THEN X.EstValue ELSE 0 END) AS DECIMAL(18,0)) AS WonVal,
    CAST(100.0*SUM(CASE WHEN X.Won=1 THEN X.EstValue ELSE 0 END)/NULLIF(SUM(X.EstValue),0) AS DECIMAL(5,1)) AS WinPctDollars
  FROM (
    SELECT p.ProposalID, p.SalesRepID, ISNULL(p.EstValue,0) AS EstValue,
      CASE WHEN EXISTS (SELECT 1 FROM gsts.dbo.GoAheads g INNER JOIN gsts.dbo.StatusDefs gs ON g.StatusDefID=gs.StatusDefID
           WHERE g.ProposalID=p.ProposalID AND gs.Desc1 IN ('Active','Pending','InProcess','Locked','Revised','Closed','Complete')) THEN 1 ELSE 0 END AS Won
    FROM gsts.dbo.Proposals p INNER JOIN gsts.dbo.StatusDefs ps ON p.StatusDefID=ps.StatusDefID
    WHERE ps.Desc1 IN ('Active','Pending','InProcess','Locked','Lost','Closed')
      AND NOT EXISTS (SELECT 1 FROM gsts.dbo.Projects p2 JOIN gsts.dbo.ProjectGroups pg ON pg.ProjectID=p2.ProjectID
                      WHERE p2.CompanyID = p.CompanyID AND pg.ProjectGroupDefID = 11)  <!--- exclude CITY/municipal-contract work (PG=11): recurring revenue, not net-new sales (Skipper Jun 30) --->
      AND ISNULL(p.ProposalSentDate,p.ProposalDate) >= DATEFROMPARTS(<cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">, 1)
      AND ISNULL(p.ProposalSentDate,p.ProposalDate) <  DATEADD(month, 1, DATEFROMPARTS(<cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">, 1))
  ) X
  INNER JOIN gsts.dbo.SalesReps sr ON X.SalesRepID = sr.SalesRepID
  <!--- FIX 1 (Gilligan 2026-07-10): show EVERY rep who sold in the window, incl. departed/unmeasured
        (e.g. Chris Mello, Nathan Nevois). WAS the current-roster gate `sr.IsMeasured=1 AND sr.StatusDefID=188`,
        which erased the real producers from historical years (Steve/CFO caught it: 2024 showed reps who
        did not work here yet). Only obvious system/placeholder accounts excluded. --->
  <!--- FIX 2 (Gilligan 2026-07-10): re-credit proposals reassigned onto recent hires (Rebekah/Ethan/Omar)
        back to the ORIGINAL seller. Workbench.dbo.ProposalOriginalRep = reviewed effective-date overrides
        (RFP/commission evidence; snapshot only AFTER reassignment confirmed by hire date). Survives nightly
        refresh (Workbench db). effRep = override name, else the current rep. --->
  LEFT JOIN Workbench.dbo.ProposalOriginalRep ov ON ov.ProposalID = X.ProposalID
  CROSS APPLY (SELECT COALESCE(ov.OrigRepName, LTRIM(RTRIM(ISNULL(sr.FullName,sr.Desc1)))) AS effRep) e
  WHERE e.effRep NOT IN ('UNDEFINED','DELETE DELETE','A V','A H','G D','Great Scott')
  GROUP BY e.effRep
  HAVING COUNT(*) > 0
  ORDER BY WonVal DESC
</cfquery>

<cfquery name="SalesPerfTreatments" datasource="GSTS">
  <!--- Treatments (PHC) = BILLED grain. An invoice line is treatment if its ServiceType is in the PHC bin
        (sprays, soil/trunk injections, fertilize, treat) — NOT the old WO-name text match, which missed
        Soil Inject/Fertilize and mislabeled rows. Mixed "Trim & Treat" palm jobs excluded (mostly trim).
        Same invoice-status set + window as the main report. Skipper-confirmed, Jun 27 2026. --->
  SELECT COUNT(DISTINCT il.InvoiceID) AS TreatWOs, CAST(SUM(ISNULL(il.TotalPrice,0)) AS DECIMAL(18,0)) AS TreatRevenue
  FROM gsts.dbo.InvoiceLines il
  INNER JOIN gsts.dbo.Invoices i ON il.InvoiceID = i.InvoiceID
  INNER JOIN gsts.dbo.StatusDefs invSD ON i.StatusDefID = invSD.StatusDefID
  WHERE invSD.Desc1 IN ('InProcess','Pending','Open','Paid','Locked')
    AND il.ServiceTypeID IN (
                              SELECT ServiceTypeID FROM gsts.dbo.ServiceTypes
                              WHERE (Desc1 LIKE '%treat%' OR Desc1 LIKE '%spray%' OR Desc1 LIKE '%inject%' OR Desc1 LIKE '%fertil%'
                                  OR Desc1 LIKE '%psyllid%' OR Desc1 LIKE '%thrip%' OR Desc1 LIKE '%aphid%' OR Desc1 LIKE '%onyx%' OR Desc1 LIKE '%roundup%')
                                AND Desc1 NOT LIKE '%trim%' AND Desc1 NOT LIKE '%pineapple%' AND Desc1 NOT LIKE '%sound%')
    <cfif startDateValue NEQ "" OR endDateValue NEQ "">
        <cfif startDateValue NEQ "" AND endDateValue NEQ "">
            AND i.InvoiceDate BETWEEN <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
        <cfelseif startDateValue NEQ "">
            AND i.InvoiceDate >= <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
        <cfelse>
            AND i.InvoiceDate <= <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
        </cfif>
    <cfelse>
        AND i.InvoiceDate >= DATEFROMPARTS(<cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">, 1)
        AND i.InvoiceDate <  DATEADD(month, 1, DATEFROMPARTS(<cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">, 1))
    </cfif>
</cfquery>

<cfquery name="SalesPerfTreatByRep" datasource="GSTS">
  <!--- Per-rep treatments (PHC) billed in window — same PHC bin + invoice-status + window as SalesPerfTreatments,
        attributed to the rep via Invoice -> Proposal -> SalesRep. (Skipper Jun 30 2026) --->
  <!--- FIX 2 (Gilligan 2026-07-10): same original-seller override as the main table, so treatments credit the
        real seller and the rep names line up with SalesPerfByRep. --->
  SELECT COALESCE(ov.OrigRepName, LTRIM(RTRIM(ISNULL(sr.FullName, sr.Desc1)))) AS RepName,
         COUNT(DISTINCT il.InvoiceID) AS TreatWOs, CAST(SUM(ISNULL(il.TotalPrice,0)) AS DECIMAL(18,0)) AS TreatRevenue
  FROM gsts.dbo.InvoiceLines il
  INNER JOIN gsts.dbo.Invoices i ON il.InvoiceID = i.InvoiceID
  INNER JOIN gsts.dbo.StatusDefs invSD ON i.StatusDefID = invSD.StatusDefID
  INNER JOIN gsts.dbo.Proposals prop ON i.ProposalID = prop.ProposalID
  INNER JOIN gsts.dbo.SalesReps sr ON prop.SalesRepID = sr.SalesRepID
  LEFT JOIN Workbench.dbo.ProposalOriginalRep ov ON ov.ProposalID = prop.ProposalID
  WHERE invSD.Desc1 IN ('InProcess','Pending','Open','Paid','Locked')
    AND il.ServiceTypeID IN (
                              SELECT ServiceTypeID FROM gsts.dbo.ServiceTypes
                              WHERE (Desc1 LIKE '%treat%' OR Desc1 LIKE '%spray%' OR Desc1 LIKE '%inject%' OR Desc1 LIKE '%fertil%'
                                  OR Desc1 LIKE '%psyllid%' OR Desc1 LIKE '%thrip%' OR Desc1 LIKE '%aphid%' OR Desc1 LIKE '%onyx%' OR Desc1 LIKE '%roundup%')
                                AND Desc1 NOT LIKE '%trim%' AND Desc1 NOT LIKE '%pineapple%' AND Desc1 NOT LIKE '%sound%')
    <cfif startDateValue NEQ "" OR endDateValue NEQ "">
        <cfif startDateValue NEQ "" AND endDateValue NEQ "">
            AND i.InvoiceDate BETWEEN <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
        <cfelseif startDateValue NEQ "">
            AND i.InvoiceDate >= <cfqueryparam value="#startDateValue#" cfsqltype="cf_sql_date">
        <cfelse>
            AND i.InvoiceDate <= <cfqueryparam value="#endDateValue#" cfsqltype="cf_sql_date">
        </cfif>
    <cfelse>
        AND i.InvoiceDate >= DATEFROMPARTS(<cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">, 1)
        AND i.InvoiceDate <  DATEADD(month, 1, DATEFROMPARTS(<cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">, 1))
    </cfif>
  GROUP BY COALESCE(ov.OrigRepName, LTRIM(RTRIM(ISNULL(sr.FullName, sr.Desc1))))
</cfquery>
<cfset treatByRep = {}>
<cfloop query="SalesPerfTreatByRep">
  <cfset treatByRep[SalesPerfTreatByRep.RepName] = {wos=Val(SalesPerfTreatByRep.TreatWOs), rev=Val(SalesPerfTreatByRep.TreatRevenue)}>
</cfloop>

<!--- Proposal-grain detail behind the Sales Performance tab (Steve ask #5). Same universe as SalesPerfByRep
      (status set + city-exclusion PG=11 + measured/active reps + proposal-sent-date window) so the row count
      reconciles with the summary's Proposals Written. OUTER APPLYs keep 1 row per proposal (no fan-out;
      verified 1805 rows == SUM(WrittenN) for Jan-Jun 2026). Only runs on view=2. --->
<cfif URL.view EQ 2>
<cfquery name="SalesPerfDetail" datasource="GSTS">
  SELECT
    prop.ProposalID AS ProposalID,
    prop.LegacyRef AS ProposalNumber,
    CONVERT(varchar(10), ISNULL(prop.ProposalSentDate,prop.ProposalDate),101) AS ProposalDate,
    c.Desc1 AS CompanyName,
    LTRIM(RTRIM(ISNULL(c.Street,'')+', '+ISNULL(c.City,'')+' '+ISNULL(c.State,''))) AS CompanyAddress,
    l.Desc1 AS LocationName,
    pt.Desc1 AS ProjectType,
    yard.Yard,
    LEFT(prop.Desc1,40) AS ProposalDesc,
    COALESCE(ov.OrigRepName, sr.FullName) AS SalesRep,  <!--- FIX 2: original-seller override --->
    CAST(ISNULL(prop.EstValue,0) AS DECIMAL(18,0)) AS ProposalAmount,
    (SELECT CONVERT(varchar(10),MIN(ISNULL(g.ApprovedDate,g.Created)),101) FROM gsts.dbo.GoAheads g INNER JOIN gsts.dbo.StatusDefs gs ON g.StatusDefID=gs.StatusDefID
       WHERE g.ProposalID=prop.ProposalID AND gs.Desc1 IN ('Active','Pending','InProcess','Locked','Revised','Closed','Complete')) AS GoAheadDate,
    inv.FirstInvoiceNumber, inv.FirstInvoiceDate,
    CAST(ISNULL(inv.InvoiceAmount,0) AS DECIMAL(18,0)) AS InvoiceAmount,
    CAST(ISNULL(inv.InvoiceHrs,0) AS DECIMAL(18,1)) AS InvoiceHrs,
    CASE WHEN ISNULL(inv.InvoiceHrs,0)>0 THEN CAST(inv.InvoiceAmount/inv.InvoiceHrs AS DECIMAL(18,2)) ELSE NULL END AS TPH,
    CAST(ISNULL(inv.DirectCosts,0) AS DECIMAL(18,0)) AS DirectCosts,
    CASE WHEN ISNULL(yr.YearsActual,0)>=1 THEN yr.YearsActual ELSE 1 END AS YearsActual,
    CASE WHEN thc.HasPHC=1 THEN 'Tree Health Care' ELSE 'Standard' END AS SaleType,
    CASE WHEN EXISTS (SELECT 1 FROM gsts.dbo.GoAheads g2 INNER JOIN gsts.dbo.StatusDefs gs2 ON g2.StatusDefID=gs2.StatusDefID
         WHERE g2.ProposalID=prop.ProposalID AND gs2.Desc1 IN ('Active','Pending','InProcess','Locked','Revised','Closed','Complete')) THEN 'Won' ELSE 'Open' END AS WinStatus
  FROM gsts.dbo.Proposals prop WITH (NOLOCK)
  INNER JOIN gsts.dbo.StatusDefs ps WITH (NOLOCK) ON prop.StatusDefID=ps.StatusDefID
  INNER JOIN gsts.dbo.Companies c WITH (NOLOCK) ON prop.CompanyID=c.CompanyID
  INNER JOIN gsts.dbo.Projects prj WITH (NOLOCK) ON prop.ProjectID=prj.ProjectID
  LEFT JOIN gsts.dbo.ProjectType pt WITH (NOLOCK) ON prj.ProjectTypeID=pt.ProjectTypeID
  LEFT JOIN gsts.dbo.SalesReps sr WITH (NOLOCK) ON prop.SalesRepID=sr.SalesRepID
  LEFT JOIN Workbench.dbo.ProposalOriginalRep ov WITH (NOLOCK) ON ov.ProposalID = prop.ProposalID  <!--- FIX 2 original-seller override --->
  LEFT JOIN gsts.dbo.Locations l WITH (NOLOCK) ON l.ProjectID=prj.ProjectID AND l.LocationID=(SELECT MIN(LocationID) FROM gsts.dbo.Locations WHERE ProjectID=prj.ProjectID)
  OUTER APPLY (SELECT COUNT(*) InvCount, MIN(i.LegacyRef) FirstInvoiceNumber, CONVERT(varchar(10),MIN(i.InvoiceDate),101) FirstInvoiceDate,
       SUM(i.Total) InvoiceAmount, SUM(i.TotalHours) InvoiceHrs, SUM(i.DirectCosts) DirectCosts
     FROM gsts.dbo.Invoices i INNER JOIN gsts.dbo.StatusDefs isd ON i.StatusDefID=isd.StatusDefID
     WHERE i.ProposalID=prop.ProposalID AND isd.Desc1 IN ('InProcess','Pending','Open','Paid','Locked')) inv
  OUTER APPLY (SELECT COUNT(DISTINCT wo.ProjectYearLabel) YearsActual FROM gsts.dbo.WorkOrders wo WHERE wo.ProposalID=prop.ProposalID AND ISNULL(wo.ProjectYearLabel,'')<>'') yr
  OUTER APPLY (SELECT TOP 1 yt.Desc1 Yard FROM gsts.dbo.WorkOrders wo INNER JOIN gsts.dbo.YardTypes yt ON wo.YardTypeID=yt.YardTypeID WHERE wo.ProposalID=prop.ProposalID) yard
  OUTER APPLY (SELECT CASE WHEN EXISTS (SELECT 1 FROM gsts.dbo.Invoices i2 INNER JOIN gsts.dbo.InvoiceLines il ON il.InvoiceID=i2.InvoiceID
       WHERE i2.ProposalID=prop.ProposalID AND il.ServiceTypeID IN (SELECT ServiceTypeID FROM gsts.dbo.ServiceTypes
          WHERE (Desc1 LIKE '%treat%' OR Desc1 LIKE '%spray%' OR Desc1 LIKE '%inject%' OR Desc1 LIKE '%fertil%' OR Desc1 LIKE '%psyllid%' OR Desc1 LIKE '%thrip%' OR Desc1 LIKE '%aphid%' OR Desc1 LIKE '%onyx%' OR Desc1 LIKE '%roundup%')
            AND Desc1 NOT LIKE '%trim%' AND Desc1 NOT LIKE '%pineapple%' AND Desc1 NOT LIKE '%sound%')) THEN 1 ELSE 0 END HasPHC) thc
  WHERE ps.Desc1 IN ('Active','Pending','InProcess','Locked','Lost','Closed')
    AND NOT EXISTS (SELECT 1 FROM gsts.dbo.Projects p2 JOIN gsts.dbo.ProjectGroups pg ON pg.ProjectID=p2.ProjectID
                    WHERE p2.CompanyID=prop.CompanyID AND pg.ProjectGroupDefID=11)
    AND ISNULL(prop.ProposalSentDate,prop.ProposalDate) >= DATEFROMPARTS(<cfqueryparam value="#URL.startYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.startMonth#" cfsqltype="cf_sql_integer">, 1)
    AND ISNULL(prop.ProposalSentDate,prop.ProposalDate) <  DATEADD(month, 1, DATEFROMPARTS(<cfqueryparam value="#URL.endYear#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#URL.endMonth#" cfsqltype="cf_sql_integer">, 1))
    <!--- FIX 1+2 (Gilligan 2026-07-10): was `sr.IsMeasured=1 AND sr.StatusDefID=188` (hid departed reps from the detail too). Now excludes only junk on the EFFECTIVE (override) rep, matching the summary universe. --->
    AND COALESCE(ov.OrigRepName, LTRIM(RTRIM(ISNULL(sr.FullName,sr.Desc1)))) NOT IN ('UNDEFINED','DELETE DELETE','A V','A H','G D','Great Scott')
  ORDER BY ISNULL(prop.ProposalSentDate,prop.ProposalDate) DESC
</cfquery>
</cfif>


<cfoutput>
<!doctype html>
<html lang="en">

  <head>

    <cfinclude template="FinancialReportDashboardHeader.cfm">
  
  </head>

  <body>
    
    <cfinclude template="FinancialReportDashboardNavBar.cfm">

    <div class="container">
  
      <div class="float-start">
        <h1>Financial Report Dashboard</h1>
      </div>

      <div class="float-end">
        <button onclick="exportReport();" type="button" class="btn btn-success" style="margin-top:8px;">Export to Excel</button>
      </div>

      <div class="clearfix"></div>

      <ul class="nav nav-tabs" style="margin-bottom:15px;margin-top:15px;">
        <li class="nav-item">
          <a class="nav-link <cfif URL.view EQ 1>active</cfif>" aria-current="page" href="FinancialReportDashboard.cfm?view=1&step=#URL.step#&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">Invoice Details Report <span class="badge bg-light">#NumberFormat(ProjectCount.MyCount,'___,___')#</span></a>
        </li>
        <li class="nav-item">
          <a class="nav-link <cfif URL.view EQ 2>active</cfif>" href="FinancialReportDashboard.cfm?view=2&step=#URL.step#&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">Sales Performance</a>
        </li>
      </ul>

      <div class="col-md-2 mx-auto" style="float:left;margin-bottom:15px;margin-right:15px !important;">
        <label for="startYear" class="form-label" style="font-size:12px;margin-bottom:2px;">Start Year</label>
        <input type="number" class="form-control" id="startYear" name="startYear" min="#minYear#" max="#currentYear#" value="#URL.startYear#" onchange="searchNow()">
      </div>

      <div class="col-md-2 mx-auto" style="float:left;margin-bottom:15px;margin-right:15px !important;">
        <label for="startMonth" class="form-label" style="font-size:12px;margin-bottom:2px;">Start Month</label>
        <select class="form-control" id="startMonth" name="startMonth" onchange="searchNow()">
          <cfloop index="m" from="1" to="12">
            <option value="#m#" <cfif URL.startMonth EQ m>selected</cfif>>#MonthAsString(m)#</option>
          </cfloop>
        </select>
      </div>

      <div class="col-md-2 mx-auto" style="float:left;margin-bottom:15px;margin-right:15px !important;">
        <label for="endYear" class="form-label" style="font-size:12px;margin-bottom:2px;">End Year</label>
        <input type="number" class="form-control" id="endYear" name="endYear" min="#minYear#" max="#currentYear#" value="#URL.endYear#" onchange="searchNow()">
      </div>

      <div class="col-md-2 mx-auto" style="float:left;margin-bottom:15px;margin-right:15px !important;">
        <label for="endMonth" class="form-label" style="font-size:12px;margin-bottom:2px;">End Month</label>
        <select class="form-control" id="endMonth" name="endMonth" onchange="searchNow()">
          <cfloop index="m" from="1" to="12">
            <option value="#m#" <cfif URL.endMonth EQ m>selected</cfif>>#MonthAsString(m)#</option>
          </cfloop>
        </select>
      </div>

      <div class="col-md-2 mx-auto" style="float:left;margin-bottom:15px;margin-right:15px !important;">
        <label for="mySearch" class="form-label" style="font-size:12px;margin-bottom:2px;">Search</label>
        <div class="input-group">

          <input class="form-control border-end-0 border" type="search" value="#URL.search#" id="mySearch" name="mySearch" placeholder="Search" onkeypress="if(event.keyCode==13) searchNow();">
          
          <span class="input-group-append">
            <button class="btn btn-outline-secondary bg-white border-start-0 border-bottom-0 border ms-n5" type="button" onclick="searchNow()">
              <i class="fa fa-search"></i>
            </button>
          </span>

        </div>

      </div>

      <div class="col-md-1" style="float:left;margin-bottom:15px;">
        <label class="form-label" style="font-size:12px;margin-bottom:2px;">Columns</label>
        <div class="dropdown">
          <button class="btn btn-outline-secondary dropdown-toggle form-control" type="button" id="columnFilterBtn" data-bs-toggle="dropdown" aria-expanded="false">
            Columns
          </button>
          <div class="dropdown-menu dropdown-menu-end p-3" aria-labelledby="columnFilterBtn" style="min-width:250px;" onclick="event.stopPropagation()">
            <cfif URL.view EQ 1>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_invoice" checked data-column="0">
              <label class="form-check-label" for="col_invoice">Invoice ##</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_date" checked data-column="1">
              <label class="form-check-label" for="col_date">Invoice Date</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_company" checked data-column="2">
              <label class="form-check-label" for="col_company">Company</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_address" checked data-column="3">
              <label class="form-check-label" for="col_address">Address</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_location" checked data-column="4">
              <label class="form-check-label" for="col_location">Location</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_project" checked data-column="5">
              <label class="form-check-label" for="col_project">Project</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_type" checked data-column="6">
              <label class="form-check-label" for="col_type">Project Type</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_yard" checked data-column="7">
              <label class="form-check-label" for="col_yard">Yard</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_proposal" checked data-column="8">
              <label class="form-check-label" for="col_proposal">Proposal ##</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_propdesc" checked data-column="9">
              <label class="form-check-label" for="col_propdesc">Proposal Desc</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_wo" checked data-column="10">
              <label class="form-check-label" for="col_wo">Work Order ##</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_crew" checked data-column="11">
              <label class="form-check-label" for="col_crew">Crew Leader</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_sales" checked data-column="12">
              <label class="form-check-label" for="col_sales">Sales Rep</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_amount" checked data-column="13">
              <label class="form-check-label" for="col_amount">Invoice Amount</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_hours" checked data-column="14">
              <label class="form-check-label" for="col_hours">Invoice Hrs</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_tph" checked data-column="15">
              <label class="form-check-label" for="col_tph">TPH</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_directcosts" checked data-column="16">
              <label class="form-check-label" for="col_directcosts">Direct Costs</label>
            </div>
            <div class="form-check">
              <input class="form-check-input column-toggle" type="checkbox" id="col_saletype" checked data-column="17">
              <label class="form-check-label" for="col_saletype">Type</label>
            </div>
            <cfelse>
            <!--- Sales Performance detail columns (view=2). Indices match the detail table below + the salesperf export mode. --->
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_0" checked data-column="0"><label class="form-check-label" for="spc_0">Proposal ##</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_1" checked data-column="1"><label class="form-check-label" for="spc_1">Proposal Date</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_2" checked data-column="2"><label class="form-check-label" for="spc_2">Company</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_3" checked data-column="3"><label class="form-check-label" for="spc_3">Address</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_4" checked data-column="4"><label class="form-check-label" for="spc_4">Location</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_5" checked data-column="5"><label class="form-check-label" for="spc_5">Project Type</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_6" checked data-column="6"><label class="form-check-label" for="spc_6">Yard</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_7" checked data-column="7"><label class="form-check-label" for="spc_7">Proposal Desc</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_8" checked data-column="8"><label class="form-check-label" for="spc_8">Sales Rep</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_9" checked data-column="9"><label class="form-check-label" for="spc_9">Proposal $</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_10" checked data-column="10"><label class="form-check-label" for="spc_10">Go-Ahead Date</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_11" checked data-column="11"><label class="form-check-label" for="spc_11">First Invoice ##</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_12" checked data-column="12"><label class="form-check-label" for="spc_12">First Invoice Date</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_13" checked data-column="13"><label class="form-check-label" for="spc_13">Invoice $</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_14" checked data-column="14"><label class="form-check-label" for="spc_14">Invoice Hrs</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_15" checked data-column="15"><label class="form-check-label" for="spc_15">TPH</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_16" checked data-column="16"><label class="form-check-label" for="spc_16">Direct Costs</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_17" checked data-column="17"><label class="form-check-label" for="spc_17">Years (actual)</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_18" checked data-column="18"><label class="form-check-label" for="spc_18">Type</label></div>
            <div class="form-check"><input class="form-check-input column-toggle" type="checkbox" id="spc_19" checked data-column="19"><label class="form-check-label" for="spc_19">Win Status</label></div>
            </cfif>
            <hr class="my-2">
            <button class="btn btn-sm btn-outline-secondary w-100" onclick="resetColumns()">Reset All</button>
          </div>
        </div>
      </div>

      <div class="clearfix"></div>

      <cfif URL.view EQ 1>
        <div style="margin:6px 0 12px 0;padding:8px 12px;background:##eef7e6;border-left:3px solid ##5C743D;display:inline-block;border-radius:3px;">
          <strong>&##127807; Tree Health Care (PHC) billed in window:</strong> $#NumberFormat(SalesPerfTreatments.TreatRevenue,'___,___')# across #NumberFormat(SalesPerfTreatments.TreatWOs,'___,___')# invoices
          <span style="font-size:11px;color:##666;display:block;">Tree Health Care identified by PHC service type on the invoice line. Per-rep totals are on the Sales Performance tab.</span>
        </div>

      <cfif Projects.RecordCount EQ 0 AND URL.search NEQ "">

          <div class="alert alert-info" role="alert">
          Your search yielded no results. You may want to try broadening your search criteria or try a different search term.
          </div>

        <cfelseif Projects.RecordCount EQ 0>

          <div class="alert alert-info" role="alert">
          No projects exist at this time.
          </div>

        <cfelse>

          <div style="overflow-x:auto;">
          <table id="invoiceDetailTable" class="table table-bordered table-sm sortable-table">

            <thead>
              <tr>

                <th scope="col">Invoice ##</th>
                <th scope="col">Invoice Date</th>
                <th scope="col">Company</th>
                <th scope="col">Address</th>
                <th scope="col">Location</th>
                <th scope="col">Project</th>
                <th scope="col">Project Type</th>
                <th scope="col">Yard</th>
                <th scope="col">Proposal ##</th>
                <th scope="col">Proposal Desc</th>
                <th scope="col">Work Order ##</th>
                <th scope="col">Crew Leader</th>
                <th scope="col">Sales Rep</th>
                <th scope="col" style="text-align:right;">Invoice Amount</th>
                <th scope="col" style="text-align:right;">Invoice Hours</th>
                <th scope="col" style="text-align:right;">TPH</th>
                <th scope="col" style="text-align:right;">Direct Costs</th>
                <th scope="col">Type</th>
              </tr>
            </thead>
            
            <tbody>

              <cfloop index="i" from="1" to="#Projects.RecordCount#">

                <tr>

                 
                  <td><a href="/gsts/Profile.Invoice.Detail.cfm?ZInvoiceID=#Projects.InvoiceID[i]#" target="_blank">#Projects.InvoiceNumber[i]#</a></td>
                  <td>#Projects.InvoiceDate[i]#</td>
                  <td>#Projects.CompanyName[i]#</td>

                  <td>
                    <cfif Projects.CompanyStreetLine1[i] NEQ "">
                      #Projects.CompanyStreetLine1[i]#<br>
                    </cfif>
                    <cfif Projects.CompanyStreetLine2[i] NEQ "">
                      #Projects.CompanyStreetLine2[i]#<br>
                    </cfif>
                    <cfif Projects.CompanyCity[i] NEQ "" OR Projects.CompanyState[i] NEQ "">
                      #Projects.CompanyCity[i]#<cfif Projects.CompanyCity[i] NEQ "" AND Projects.CompanyState[i] NEQ "">, </cfif>#Projects.CompanyState[i]# #Projects.CompanyZipCode[i]#
                    </cfif>
                  </td>

                  <td>#Projects.LocationName[i]#</td>
                  <td>#Projects.ProjectName[i]#</td>
                  <td>#Projects.ProjectType[i]#</td>
                  <td>#Projects.YardType[i]#</td>
                  <td><a href="/gsts/Profile.Proposal.Detail.cfm?ZProposalID=#Projects.ProposalID[i]#" target="_blank">#Projects.ProposalNumber[i]#</a></td>
                  <td>#Projects.ProposalDesc[i]#</td>
                  <td><a href="/gsts/Profile.WorkOrder.Detail.cfm?ZWorkOrderID=#Projects.WorkOrderNumber[i]#" target="_blank">#Projects.WorkOrderNumber[i]#</a></td>
                  <td>#Projects.CrewLeader[i]#</td>
                  <td>#Projects.SalesRep[i]#</td>

                  <td style="text-align:right;">
                    <cfif IsNumeric(Projects.InvoiceAmount[i])>
                      $#Trim(LSNumberFormat(Projects.InvoiceAmount[i],',99999999999.99'))#
                    <cfelse>
                      $0.00
                    </cfif>
                  </td>

                  <td style="text-align:right;">
                    <cfif IsNumeric(Projects.InvoiceTotalHours[i])>
                      #Trim(LSNumberFormat(Projects.InvoiceTotalHours[i],',99999999999.99'))#
                    <cfelse>
                      0.00
                    </cfif>
                  </td>

                  <td style="text-align:right;">
                    <cfif IsNumeric(Projects.WorkOrderTPH[i])>
                      $#Trim(LSNumberFormat(Projects.WorkOrderTPH[i],',99999999999.99'))#
                    <cfelse>
                      $0.00
                    </cfif>
                  </td>
                  <td style="text-align:right;">
                    <cfif IsNumeric(Projects.InvoiceDirectCosts[i]) AND Projects.InvoiceDirectCosts[i] GT 0>
                      $#Trim(LSNumberFormat(Projects.InvoiceDirectCosts[i],',99999999999.99'))#
                    <cfelse>
                      &mdash;
                    </cfif>
                  </td>
                  <td>
                    <cfif Projects.SaleType[i] EQ "Treatment"><span style="color:##5C743D;font-weight:bold;">Tree Health Care</span><cfelse>Standard</cfif>
                  </td>

                </tr>

              </cfloop>

            </tbody>
            
          </table>
          </div>

        </cfif>     

      <div class="float-end">
        <nav aria-label="Page navigation example">
          <ul class="pagination">

            <li style="margin-right:15px;padding-top:5px;">#Int(URL.start_row+1)# - #Int(URL.end_row+1)# of #URL.myCount#</li>

            <cfif URL.page NEQ 1>
              <li class="page-item hideMobile"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#"><<</a></li>
            </cfif>

            <cfif #Int(URL.page-1)# GTE 1>
              <li class="page-item"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#Int(URL.page-1)#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#"><</a></li>
            </cfif>

            <cfloop index="i" from="#Int(URL.page-2)#" to="#Int(URL.page-1)#">
              <cfif i GTE 1>
                <li class="page-item hideMobile"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#i#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">#NumberFormat(i,'___,___')#</a></li>
              </cfif>
            </cfloop>

            <li class="page-item hideMobile active"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#URL.page#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">#NumberFormat(URL.page,'___,___')#</a></li>
            
            <cfloop index="i" from="#Int(URL.page+1)#" to="#Int(URL.page+2)#">
              <cfif i LTE URL.max_page>
                <li class="page-item hideMobile"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#i#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">#NumberFormat(i,'___,___')#</a></li>
              </cfif>
            </cfloop>

            <cfif #Int(URL.page+1)# LTE URL.max_page>
              <li class="page-item"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#Int(URL.page+1)#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">></a></li>
            </cfif>

            <cfif URL.page LT URL.max_page>
              <li class="page-item hideMobile"><a class="page-link" href="FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&search=#URL.search#&page=#URL.max_page#&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">>></a></li>
            </cfif>

            <li style="margin-left:15px;">
              <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false" style="margin-bottom:15px;">
                  #step# / Page
                </button>
                <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
                  <li><a class="dropdown-item <cfif URL.step EQ 10>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=10&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">10</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 25>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=25&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">25</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 50>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=50&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">50</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 100>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=100&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">100</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 250>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=250&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">250</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 500>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=500&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">500</a></li>
                  <li><a class="dropdown-item <cfif URL.step EQ 1000>active</cfif>" href="FinancialReportDashboard.cfm?view=#URL.view#&step=1000&search=#URL.search#&page=1&startYear=#URL.startYear#&startMonth=#URL.startMonth#&endYear=#URL.endYear#&endMonth=#URL.endMonth#">1000</a></li>
                </ul>
              </div>
            </li>

          </ul>
        </nav>
      </div>

      </cfif>

      <cfif URL.view EQ 2>
        <h4 style="margin-bottom:2px;">Sales Performance by Salesperson</h4>
        <p style="font-size:12px;color:##666;margin-bottom:10px;">Win rate = of proposals written in the window, the share that won a go-ahead (includes <b>Complete</b>). Superseded &ldquo;Revised&rdquo; duplicates excluded. <b>City/municipal-contract work excluded</b> (recurring revenue, not net-new sales). Measured &amp; active reps. Use the Year/Month filters above.</p>
        <div style="overflow-x:auto;">
        <table class="table table-bordered table-sm sortable-table">
          <thead><tr style="background:##eef0ee;">
            <th scope="col">Salesperson</th>
            <th scope="col" style="text-align:right;">Proposals Written</th>
            <th scope="col" style="text-align:right;">Won</th>
            <th scope="col" style="text-align:right;">Win % (Jobs)</th>
            <th scope="col" style="text-align:right;">Win % ($)</th>
            <th scope="col" style="text-align:right;">Proposed $</th>
            <th scope="col" style="text-align:right;">Won $</th>
            <th scope="col" style="text-align:right;">Tree Health Care (##)</th>
            <th scope="col" style="text-align:right;">Tree Health Care $</th>
          </tr></thead>
          <tbody>
          <cfloop query="SalesPerfByRep">
            <tr>
              <td>#SalesPerfByRep.RepName#</td>
              <td style="text-align:right;">#NumberFormat(SalesPerfByRep.WrittenN,',')#</td>
              <td style="text-align:right;">#NumberFormat(SalesPerfByRep.WonN,',')#</td>
              <td style="text-align:right;">#SalesPerfByRep.WinPctJobs#%</td>
              <td style="text-align:right;">#SalesPerfByRep.WinPctDollars#%</td>
              <td style="text-align:right;">$#NumberFormat(SalesPerfByRep.WrittenVal,',')#</td>
              <td style="text-align:right;">$#NumberFormat(SalesPerfByRep.WonVal,',')#</td>
              <td style="text-align:right;"><cfif StructKeyExists(treatByRep, SalesPerfByRep.RepName)>#NumberFormat(treatByRep[SalesPerfByRep.RepName].wos,',')#<cfelse>0</cfif></td>
              <td style="text-align:right;"><cfif StructKeyExists(treatByRep, SalesPerfByRep.RepName)>$#NumberFormat(treatByRep[SalesPerfByRep.RepName].rev,',')#<cfelse>$0</cfif></td>
            </tr>
          </cfloop>
          </tbody>
        </table>
        </div>

        <h4 style="margin-top:26px;margin-bottom:2px;">Proposal Detail</h4>
        <p style="font-size:12px;color:##666;margin-bottom:10px;">One row per proposal written in the window (same universe as the summary above &mdash; #NumberFormat(SalesPerfDetail.RecordCount,'___,___')# proposals). Won = a go-ahead exists (includes Complete). <b>Years (actual)</b> = distinct project-year labels the proposal&rsquo;s work orders span, floored at 1 &mdash; a fresh multi-year sale under-counts until its later years schedule (TRIM IT has no reliable sold-term field). Use <b>Columns</b> to show/hide and <b>Export to Excel</b> above.</p>
        <div style="overflow-x:auto;">
        <table id="salesPerfDetailTable" class="table table-bordered table-sm sortable-table">
          <thead><tr style="background:##eef0ee;">
            <th scope="col">Proposal ##</th>
            <th scope="col">Proposal Date</th>
            <th scope="col">Company</th>
            <th scope="col">Address</th>
            <th scope="col">Location</th>
            <th scope="col">Project Type</th>
            <th scope="col">Yard</th>
            <th scope="col">Proposal Desc</th>
            <th scope="col">Sales Rep</th>
            <th scope="col" style="text-align:right;">Proposal $</th>
            <th scope="col">Go-Ahead Date</th>
            <th scope="col">First Invoice ##</th>
            <th scope="col">First Invoice Date</th>
            <th scope="col" style="text-align:right;">Invoice $</th>
            <th scope="col" style="text-align:right;">Invoice Hrs</th>
            <th scope="col" style="text-align:right;">TPH</th>
            <th scope="col" style="text-align:right;">Direct Costs</th>
            <th scope="col" style="text-align:right;">Years (actual)</th>
            <th scope="col">Type</th>
            <th scope="col">Win Status</th>
          </tr></thead>
          <tbody>
          <cfloop query="SalesPerfDetail">
            <tr>
              <td><a href="/gsts/Profile.Proposal.Detail.cfm?ZProposalID=#SalesPerfDetail.ProposalID#" target="_blank">#SalesPerfDetail.ProposalNumber#</a></td>
              <td>#SalesPerfDetail.ProposalDate#</td>
              <td>#SalesPerfDetail.CompanyName#</td>
              <td>#SalesPerfDetail.CompanyAddress#</td>
              <td>#SalesPerfDetail.LocationName#</td>
              <td>#SalesPerfDetail.ProjectType#</td>
              <td>#SalesPerfDetail.Yard#</td>
              <td>#SalesPerfDetail.ProposalDesc#</td>
              <td>#SalesPerfDetail.SalesRep#</td>
              <td style="text-align:right;">$#NumberFormat(SalesPerfDetail.ProposalAmount,',')#</td>
              <td>#SalesPerfDetail.GoAheadDate#</td>
              <td>#SalesPerfDetail.FirstInvoiceNumber#</td>
              <td>#SalesPerfDetail.FirstInvoiceDate#</td>
              <td style="text-align:right;"><cfif Val(SalesPerfDetail.InvoiceAmount) GT 0>$#NumberFormat(SalesPerfDetail.InvoiceAmount,',')#<cfelse>&mdash;</cfif></td>
              <td style="text-align:right;"><cfif Val(SalesPerfDetail.InvoiceHrs) GT 0>#NumberFormat(SalesPerfDetail.InvoiceHrs,'9.9')#<cfelse>&mdash;</cfif></td>
              <td style="text-align:right;"><cfif IsNumeric(SalesPerfDetail.TPH)>$#NumberFormat(SalesPerfDetail.TPH,',')#<cfelse>&mdash;</cfif></td>
              <td style="text-align:right;"><cfif Val(SalesPerfDetail.DirectCosts) GT 0>$#NumberFormat(SalesPerfDetail.DirectCosts,',')#<cfelse>&mdash;</cfif></td>
              <td style="text-align:right;">#NumberFormat(SalesPerfDetail.YearsActual,'0')#</td>
              <td><cfif SalesPerfDetail.SaleType EQ "Tree Health Care"><span style="color:##5C743D;font-weight:bold;">Tree Health Care</span><cfelse>Standard</cfif></td>
              <td><cfif SalesPerfDetail.WinStatus EQ "Won"><span style="color:##2e7d32;font-weight:bold;">Won</span><cfelse><span style="color:##888;">Open</span></cfif></td>
            </tr>
          </cfloop>
          </tbody>
        </table>
        </div>
      </cfif>

      <div class="clearfix"></div>

    </div>

    <cfinclude template="FinancialReportDashboardJS.cfm">

    <script>
    // View-aware column persistence + export. view=1 = Invoice Details, view=2 = Sales Performance detail.
    var CURRENT_VIEW = #URL.view#;
    var COLUMN_STORAGE_KEY = '#(URL.view EQ 2) ? "salesPerfDetailColumns" : "financialReportColumns"#';
    var COLUMN_TABLE_SELECTOR = '#(URL.view EQ 2) ? "##salesPerfDetailTable" : "##invoiceDetailTable"#';

    function searchNow()
    {
        var startYear = document.getElementById('startYear').value;
        var startMonth = document.getElementById('startMonth').value;
        var endYear = document.getElementById('endYear').value;
        var endMonth = document.getElementById('endMonth').value;
        var search = document.getElementById('mySearch').value;

        location.href='FinancialReportDashboard.cfm?view=#URL.view#&step=#URL.step#&page=1'
          +'&search='+encodeURIComponent(search)
          +'&startYear='+encodeURIComponent(startYear)
          +'&startMonth='+encodeURIComponent(startMonth)
          +'&endYear='+encodeURIComponent(endYear)
          +'&endMonth='+encodeURIComponent(endMonth);
    }

    function exportReport()
    {
        var startYear = document.getElementById('startYear').value;
        var startMonth = document.getElementById('startMonth').value;
        var endYear = document.getElementById('endYear').value;
        var endMonth = document.getElementById('endMonth').value;
        
        // Get visible columns
        var visibleCols = [];
        document.querySelectorAll('.column-toggle').forEach(function(checkbox) {
            if (checkbox.checked) {
                visibleCols.push(checkbox.dataset.column);
            }
        });

        var modeParam = (CURRENT_VIEW == 2) ? '&mode=salesperf' : '';

        window.open('FinancialReportExport.cfm?search=#URLEncodedFormat(URL.search)#'
          +'&startYear='+encodeURIComponent(startYear)
          +'&startMonth='+encodeURIComponent(startMonth)
          +'&endYear='+encodeURIComponent(endYear)
          +'&endMonth='+encodeURIComponent(endMonth)
          +modeParam
          +'&cols='+visibleCols.join(','), '_blank');
    }

    // Column visibility management
    function toggleColumn(columnIndex, show) {
        var table = document.querySelector(COLUMN_TABLE_SELECTOR);
        if (!table) return;
        
        // Toggle header
        var headers = table.querySelectorAll('thead th');
        if (headers[columnIndex]) {
            headers[columnIndex].style.display = show ? '' : 'none';
        }
        
        // Toggle body cells
        var rows = table.querySelectorAll('tbody tr');
        rows.forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells[columnIndex]) {
                cells[columnIndex].style.display = show ? '' : 'none';
            }
        });
        
        // Save to localStorage
        saveColumnPreferences();
    }

    function saveColumnPreferences() {
        var prefs = {};
        document.querySelectorAll('.column-toggle').forEach(function(checkbox) {
            prefs[checkbox.dataset.column] = checkbox.checked;
        });
        localStorage.setItem(COLUMN_STORAGE_KEY, JSON.stringify(prefs));
    }

    function loadColumnPreferences() {
        var prefs = localStorage.getItem(COLUMN_STORAGE_KEY);
        if (prefs) {
            try {
                prefs = JSON.parse(prefs);
                Object.keys(prefs).forEach(function(col) {
                    var checkbox = document.querySelector('.column-toggle[data-column="' + col + '"]');
                    if (checkbox) {
                        checkbox.checked = prefs[col];
                        toggleColumn(parseInt(col), prefs[col]);
                    }
                });
            } catch(e) {
                console.error('Error loading column preferences:', e);
            }
        }
    }

    function resetColumns() {
        document.querySelectorAll('.column-toggle').forEach(function(checkbox) {
            checkbox.checked = true;
            toggleColumn(parseInt(checkbox.dataset.column), true);
        });
        localStorage.removeItem(COLUMN_STORAGE_KEY);
    }

    // Initialize column toggles
    document.addEventListener('DOMContentLoaded', function() {
        // Load saved preferences
        loadColumnPreferences();
        
        // Add event listeners to checkboxes
        document.querySelectorAll('.column-toggle').forEach(function(checkbox) {
            checkbox.addEventListener('change', function() {
                toggleColumn(parseInt(this.dataset.column), this.checked);
            });
        });
    });
    </script>

    <style>
    @media only screen and (max-width: 715px) 
    {
        .nav-link { font-size:12px !important; }
        .floatLeft { float:left !important; }
    }

    @media (min-width: 576px) 
    {
      .container, .container-sm { max-width:1800px !important; }
    }

    .border { border:1px solid ##9DAC8A !important; }

    /* Proposal Detail table: keep numbers & dates on one line so the $ can't wrap above the value
       (Skipper: TPH column). Long text columns (Company / Address / Location / Proposal Desc) still wrap. */
    ##salesPerfDetailTable th, ##salesPerfDetailTable td { white-space: nowrap; }
    ##salesPerfDetailTable td:nth-child(3), ##salesPerfDetailTable td:nth-child(4),
    ##salesPerfDetailTable td:nth-child(5), ##salesPerfDetailTable td:nth-child(8) { white-space: normal; min-width: 130px; }
    ##salesPerfDetailTable th:nth-child(16), ##salesPerfDetailTable td:nth-child(16) { min-width: 66px; }
    </style>

  <script>
  (function(){
    function sortTable(table, idx, th){
      var tb = table.tBodies[0]; if(!tb) return;
      var rows = Array.prototype.slice.call(tb.rows);
      var dir = th.getAttribute('data-sd')==='asc' ? 'desc' : 'asc';
      Array.prototype.forEach.call(table.querySelectorAll('th'), function(h){ h.removeAttribute('data-sd'); var x=h.querySelector('.sind'); if(x) x.parentNode.removeChild(x); });
      th.setAttribute('data-sd', dir);
      function v(r){ var c=r.cells[idx]; var t=c?(c.innerText||c.textContent||'').trim():''; var n=parseFloat(t.replace(/[$,%\s]/g,'')); return {n:n,t:t,num:(t!==''&&!isNaN(n))}; }
      rows.sort(function(a,b){ var x=v(a),y=v(b),r; if(x.num&&y.num){r=x.n-y.n;} else {r=x.t.localeCompare(y.t);} return dir==='asc'?r:-r; });
      rows.forEach(function(r){ tb.appendChild(r); });
      var sp=document.createElement('span'); sp.className='sind'; sp.textContent = dir==='asc'?' \u25B2':' \u25BC'; th.appendChild(sp);
    }
    Array.prototype.forEach.call(document.querySelectorAll('table.sortable-table'), function(table){
      var head=table.tHead; if(!head||!head.rows.length) return;
      var hr=head.rows[head.rows.length-1];
      Array.prototype.forEach.call(hr.cells, function(th){
        th.style.cursor='pointer'; if(!th.title) th.title='Click to sort';
        th.addEventListener('click', function(){ sortTable(table, th.cellIndex, th); });
      });
    });
  })();
  </script>
  </body>

</html>
</cfoutput>
