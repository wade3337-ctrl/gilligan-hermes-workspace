<cfparam name="URL.search" default="" type="string">
<cfparam name="URL.cols" default="" type="string">
<cfparam name="URL.mode" default="invoice" type="string">

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

<!--- =========================================================================
      SALES PERFORMANCE DETAIL EXPORT (mode=salesperf) — Steve ask #4/#5.
      Proposal grain; same universe as the dashboard SalesPerfByRep summary +
      SalesPerfDetail table (status set / city-exclusion PG=11 / measured reps /
      proposal-sent-date window). Ignores search (summary/detail don't filter by it)
      so the export reconciles with the on-screen counts. Self-contained; cfaborts.
      ========================================================================= --->
<cfif URL.mode EQ "salesperf">

  <!--- ordered column map for the detail export (index matches the dashboard toggle + table) --->
  <cfset spCols = [
    {field="ProposalNumber",    header="Proposal Number",  numeric=false},
    {field="ProposalDate",      header="Proposal Date",     numeric=false},
    {field="CompanyName",       header="Company Name",      numeric=false},
    {field="CompanyAddress",    header="Company Address",   numeric=false},
    {field="LocationName",      header="Location Name",     numeric=false},
    {field="ProjectType",       header="Project Type",      numeric=false},
    {field="Yard",              header="Yard",              numeric=false},
    {field="ProposalDesc",      header="Proposal Desc",     numeric=false},
    {field="SalesRep",          header="Sales Rep",         numeric=false},
    {field="ProposalAmount",    header="Proposal Amount",   numeric=true},
    {field="GoAheadDate",       header="Go-Ahead Date",     numeric=false},
    {field="FirstInvoiceNumber",header="First Invoice Number", numeric=false},
    {field="FirstInvoiceDate",  header="First Invoice Date",numeric=false},
    {field="InvoiceAmount",     header="Invoice Amount",    numeric=true},
    {field="InvoiceHrs",        header="Invoice Hours",     numeric=true},
    {field="TPH",               header="TPH",               numeric=true},
    {field="DirectCosts",       header="Direct Costs",      numeric=true},
    {field="YearsActual",       header="Years (actual)",    numeric=true},
    {field="SaleType",          header="Type",              numeric=false},
    {field="WinStatus",         header="Win Status",        numeric=false}
  ]>

  <!--- which 0-based columns are visible (default = all) --->
  <cfset spVisible = {}>
  <cfif URL.cols NEQ "">
    <cfloop list="#URL.cols#" index="colIndex"><cfset spVisible[colIndex] = true></cfloop>
  <cfelse>
    <cfloop from="0" to="#ArrayLen(spCols)-1#" index="i"><cfset spVisible[i] = true></cfloop>
  </cfif>

  <cfquery name="SalesPerfDetail" datasource="GSTS">
    SELECT
      prop.LegacyRef AS ProposalNumber,
      CONVERT(varchar(10), ISNULL(prop.ProposalSentDate,prop.ProposalDate),101) AS ProposalDate,
      c.Desc1 AS CompanyName,
      LTRIM(RTRIM(ISNULL(c.Street,'')+', '+ISNULL(c.City,'')+' '+ISNULL(c.State,''))) AS CompanyAddress,
      l.Desc1 AS LocationName,
      pt.Desc1 AS ProjectType,
      yard.Yard,
      LEFT(prop.Desc1,40) AS ProposalDesc,
      COALESCE(ov.OrigRepName, sr.FullName) AS SalesRep,  <!--- FIX 2: original-seller override (reassigned proposals) --->

      CAST(ISNULL(prop.EstValue,0) AS DECIMAL(18,0)) AS ProposalAmount,
      (SELECT CONVERT(varchar(10),MIN(ISNULL(g.ApprovedDate,g.Created)),101) FROM gsts.dbo.GoAheads g INNER JOIN gsts.dbo.StatusDefs gs ON g.StatusDefID=gs.StatusDefID
         WHERE g.ProposalID=prop.ProposalID AND gs.Desc1 IN ('Active','Pending','InProcess','Locked','Revised','Closed','Complete')) AS GoAheadDate,
      inv.FirstInvoiceNumber, inv.FirstInvoiceDate,
      CAST(ISNULL(inv.InvoiceAmount,0) AS DECIMAL(18,0)) AS InvoiceAmount,
      CAST(ISNULL(inv.InvoiceHrs,0) AS DECIMAL(18,1)) AS InvoiceHrs,
      CASE WHEN ISNULL(inv.InvoiceHrs,0)>0 THEN CAST(inv.InvoiceAmount/inv.InvoiceHrs AS DECIMAL(18,2)) ELSE 0 END AS TPH,
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
      <!--- FIX 1 (Gilligan 2026-07-10): include departed/unmeasured reps for historical accuracy; was current-roster gate sr.IsMeasured=1 AND sr.StatusDefID=188. Only system/placeholder accounts excluded. --->
      AND COALESCE(ov.OrigRepName, LTRIM(RTRIM(ISNULL(sr.FullName,sr.Desc1)))) NOT IN ('UNDEFINED','DELETE DELETE','A V','A H','G D','Great Scott')
    ORDER BY ISNULL(prop.ProposalSentDate,prop.ProposalDate) DESC
  </cfquery>

  <cfset spFilename = "SalesPerformance_#DateFormat(Now(), 'yyyymmdd')#_#TimeFormat(Now(), 'HHmmss')#.csv">
  <cfheader name="Content-Disposition" value="attachment; filename=#spFilename#">
  <cfcontent type="text/csv" reset="true"><cfoutput><cfset first=true><cfloop from="0" to="#ArrayLen(spCols)-1#" index="ci"><cfif StructKeyExists(spVisible, ci)><cfif NOT first>,</cfif>#spCols[ci+1].header#<cfset first=false></cfif></cfloop>#Chr(13)##Chr(10)#<cfloop query="SalesPerfDetail"><cfset first=true><cfloop from="0" to="#ArrayLen(spCols)-1#" index="ci"><cfif StructKeyExists(spVisible, ci)><cfif NOT first>,</cfif><cfset cv = SalesPerfDetail[spCols[ci+1].field][SalesPerfDetail.CurrentRow]><cfif spCols[ci+1].numeric>#Val(cv)#<cfelse>"#Replace(cv, '"', '""', 'ALL')#"</cfif><cfset first=false></cfif></cfloop>#Chr(13)##Chr(10)#</cfloop></cfoutput><cfabort>

</cfif>

<!--- Parse visible columns --->
<cfset visibleColumns = {}>
<cfif URL.cols NEQ "">
  <cfloop list="#URL.cols#" index="colIndex">
    <cfset visibleColumns[colIndex] = true>
  </cfloop>
<cfelse>
  <!--- If no cols parameter, show all columns --->
  <cfloop from="0" to="17" index="i">
    <cfset visibleColumns[i] = true>
  </cfloop>
</cfif>

<!--- Column mapping --->
<cfset columnMap = {
  "0": {field: "InvoiceNumber", header: "Invoice Number"},
  "1": {field: "InvoiceDate", header: "Invoice Date"},
  "2": {field: "CompanyName", header: "Company Name"},
  "3": {field: "CompanyAddress", header: "Company Address"},
  "4": {field: "LocationName", header: "Location Name"},
  "5": {field: "ProjectName", header: "Project Name"},
  "6": {field: "ProjectType", header: "Project Type"},
  "7": {field: "YardType", header: "Yard"},
  "8": {field: "ProposalNumber", header: "Proposal Number"},
  "9": {field: "ProposalDesc", header: "Proposal Desc"},
  "10": {field: "WorkOrderNumber", header: "Work Order Number"},
  "11": {field: "CrewLeader", header: "Crew Leader"},
  "12": {field: "SalesRep", header: "Sales Rep"},
  "13": {field: "InvoiceAmount", header: "Invoice Amount"},
  "14": {field: "InvoiceTotalHours", header: "Invoice Hours"},
  "15": {field: "WorkOrderTPH", header: "TPH"},
  "16": {field: "InvoiceDirectCosts", header: "Direct Costs"},
  "17": {field: "SaleType", header: "Type"}
}>

<cfquery name="ExportData" datasource="GSTS">
    SELECT
        i.InvoiceID AS InvoiceID,
        i.LegacyRef AS InvoiceNumber,
        i.Total AS InvoiceAmount,
        ISNULL(i.DirectCosts,0) AS InvoiceDirectCosts,
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
        prop.LegacyRef AS ProposalNumber,
        prop.Desc1 AS ProposalDesc,

        wo.WorkOrderID AS WorkOrderNumber,
        cn.Desc1 AS CrewLeader,

        i.TotalHours AS InvoiceTotalHours,
        wo.TPH AS WorkOrderTPH,
        ISNULL(yt.Desc1, '') AS YardType

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
</cfquery>

<cfset filename = "FinancialReport_#DateFormat(Now(), 'yyyymmdd')#_#TimeFormat(Now(), 'HHmmss')#.csv">

<cfheader name="Content-Disposition" value="attachment; filename=#filename#">
<cfcontent type="text/csv" reset="true"><cfoutput><cfloop from="0" to="17" index="colIdx"><cfif StructKeyExists(visibleColumns, colIdx)><cfif colIdx GT 0>,</cfif>#columnMap[colIdx].header#</cfif></cfloop>#Chr(13)##Chr(10)#<cfloop query="ExportData"><cfset isFirstCol = true><cfif StructKeyExists(visibleColumns, "0")><cfif NOT isFirstCol>,</cfif>"#Replace(InvoiceNumber, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "1")><cfif NOT isFirstCol>,</cfif>#InvoiceDate#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "2")><cfif NOT isFirstCol>,</cfif>"#Replace(CompanyName, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "3")><cfif NOT isFirstCol>,</cfif>"<cfif CompanyStreetLine1 NEQ "">#Replace(CompanyStreetLine1, '"', '""', 'ALL')#<cfif CompanyStreetLine2 NEQ "">, </cfif></cfif><cfif CompanyStreetLine2 NEQ "">#Replace(CompanyStreetLine2, '"', '""', 'ALL')#<cfif CompanyCity NEQ "" OR CompanyState NEQ "">, </cfif></cfif><cfif CompanyCity NEQ "" OR CompanyState NEQ "">#Replace(CompanyCity, '"', '""', 'ALL')#<cfif CompanyCity NEQ "" AND CompanyState NEQ "">, </cfif>#CompanyState# #CompanyZipCode#</cfif>"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "4")><cfif NOT isFirstCol>,</cfif>"#Replace(LocationName, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "5")><cfif NOT isFirstCol>,</cfif>"#Replace(ProjectName, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "6")><cfif NOT isFirstCol>,</cfif>"#Replace(ProjectType, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "7")><cfif NOT isFirstCol>,</cfif>"#Replace(YardType, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "8")><cfif NOT isFirstCol>,</cfif>"#Replace(ProposalNumber, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "9")><cfif NOT isFirstCol>,</cfif>"#Replace(ProposalDesc, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "10")><cfif NOT isFirstCol>,</cfif>#WorkOrderNumber#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "11")><cfif NOT isFirstCol>,</cfif>"#Replace(CrewLeader, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "12")><cfif NOT isFirstCol>,</cfif>"#Replace(SalesRep, '"', '""', 'ALL')#"<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "13")><cfif NOT isFirstCol>,</cfif>#LSNumberFormat(InvoiceAmount, '0.00')#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "14")><cfif NOT isFirstCol>,</cfif>#LSNumberFormat(InvoiceTotalHours, '0.00')#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "15")><cfif NOT isFirstCol>,</cfif>#LSNumberFormat(WorkOrderTPH, '0.00')#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "16")><cfif NOT isFirstCol>,</cfif>#LSNumberFormat(InvoiceDirectCosts, '0.00')#<cfset isFirstCol = false></cfif><cfif StructKeyExists(visibleColumns, "17")><cfif NOT isFirstCol>,</cfif>#SaleType#<cfset isFirstCol = false></cfif>#Chr(13)##Chr(10)#</cfloop></cfoutput>
