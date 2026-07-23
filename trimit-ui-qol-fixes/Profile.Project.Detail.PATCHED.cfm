<cfparam name="URL.ZCompanyID" default="1">
<cfparam name="URL.ZProjectID" default="1">

<iframe name="SystemLogProfileProject" id="SystemLogProfileProject" width="1" height="1" src="CodeGenerateSystemLog.cfm?ZDesc1=ProjectPageHit&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>&amp;ZFormName=Begin-Profile.Project.Detail.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZLongDesc1=None"></iframe>


<cfquery name="Company" datasource="GSTS">
SELECT CompanyID, CompanyGroupID, Desc1, LTRIM(RTRIM(ISNULL(Nickname, FileAs))) AS Nickname, Created, CreatedByID, AddressDesc1, Street, Street2, City, "State", ZipCode, ZipCodeID, PrimaryPhone, SecondaryPhone, FaxPhone, WebAddress, EstValue, MarketID, GeoSegmentID, QualifyValue, SolveValue, CloseValue, SchedulingValue, ProductionValue, BillingValue, CollectionValue, RetentionValue, YTDValue, HTDValue, CurrentBalance, LegacyRef, ExternalRef, StatusDefID, SalesRepID, "LastModified", WorksheetID, FilePath, GPSInventory, WorkByZone, CompanyGateway, CompanyProfile, FileAs, Prior02, Prior01, CurrentYear, CurrentYearBooked, Future01, Future02, AccountCodeID, TermsCodeID, DupTagID, ShowOnLit, RequiresReview, ModifiedDate, ModifiedDetails, IsOnList
FROM dbo.Companies  WITH (NOLOCK)
WHERE CompanyID = 
(SELECT CompanyID
 FROM gsts.dbo.Projects WITH (NOLOCK)
 WHERE ProjectID = <cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric">) 
</cfquery>
<cfquery name="Location" datasource="GSTS">
SELECT LocationID, Desc1, CompanyID, InventoryLevel, LocationName, LocationContact, LocationStreet, LocationStreet2, LocationCity, LocationState, LocationZip, ZipCodeID, LocationPhone, LocationFax, LocationEmail, StatusDefID, LegacyRef,ISNULL(InventoryGateway,'Synch.InventoryDetail.Grid.cfm?ZLocationID='+CAST(LocationID AS VARCHAR)) AS InventoryGateway, dbo.GetLocation$LastGSTSID(Locations.LocationID) AS LastGSTSID
FROM dbo.Locations WITH (NOLOCK)
WHERE LocationID =
(SELECT LocationID
 FROM gsts.dbo.Projects WITH (NOLOCK)
 WHERE ProjectID = <cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric">)
 
 
</cfquery>
<cfquery name="Projects" datasource="GSTS">
SELECT YEAR(GetDate()) AS VThisYear, ProjectID, Desc1, SolveValue, CloseValue, SchedulingValue, ProductionValue, BillingValue, CollectionValue, RetentionValue, YTDValue, HTDValue, CompanyID, BillingName, BillingContact, BillingStreet, BillingStreet2, BillingCity, BillingState, BillingZipCode, ZipCodeID, BillingPhone, BillingFax, BillingEmail, LocationID, StatusDefID, GeoMarketID, LegacyRef, Created, EstValue, ISNULL(Projects.IsInventoryLocked,0) AS IsInventoryLocked, ISNULL(WebAddress,'AllBlank.cfm') AS WebAddress, ISNULL(Projects.IsProjectTotalsLocked,0) AS IsProjectTotalsLocked, ROUND(ISNULL(Projects.HTDTPH,0),2) AS HTDTPH,
 ROUND(ISNULL(Projects.HTDTotalPrice,0)/1000,0) AS HTDTotalPrice, Projects.LastModified, ISNULL(Projects.IsExcludeFromConvert,0) AS IsExcludeFromConvert
FROM dbo.Projects WITH (NOLOCK)
WHERE ProjectID=<cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric">
</cfquery>

<cfquery name="ProposalUsers" datasource="GSTS">
SELECT Users.UserID, Users.Desc1, Users.SeqOrder
FROM flow.Users
	INNER JOIN dbo.UserActions ON UserActions.UserID = Users.UserID
    INNER JOIN dbo.Actiondefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
    INNER JOIN dbo.StatusDefs ON Users.StatusDefID = StatusDefs.StatusDefID
WHERE StatusDefs.Desc1 = 'Active'
  AND ISNULL(IsExternal,0) = 0
  AND ActionDefs.Desc1 = 'Generate Proposal'
  AND Users.UserID = <cfoutput>#Cookie.ZUserID#</cfoutput>
 </cfquery>

 <cfparam name="AllowCreatingProposal" default="0">
 <cfif ProposalUsers.RecordCount>
 	<cfset AllowCreatingProposal = #ProposalUsers.UserID#>
</cfif>
 
<cfquery name="ProjectYears" datasource="GSTS">
SELECT 	ProjectYears.ProjectYearID, 
		ProjectYears.Desc1 AS Desc1, 
        ProjectYears.Desc1 AS ProjectYearDesc1,  
        ProjectYears.Desc2,  
        ProjectYears.StartDate,  
        ProjectYears.EndDate,  
        ProjectYears.ProjectID,  
        ProjectYears.PeriodLabelID,  
        Projects.CurrentYearLabel,  
        ISNULL(ProjectYears.TotalPrice,0) AS TotalPrice,  
        ProjectYears.TotalHours,  
        ProjectYears.TPH,
        ISNULL(ProjectYears.IsCurrentYear,0) AS IsCurrentYear,
        ISNULL(ProjectYears.TotalApproved,0) AS TotalApproved,
        ISNULL(ProjectYears.TotalRemaining,0) AS TotalRemaining,
		ISNULL(ProjectYears.BudgetQty,0) AS BudgetQty,
        ISNULL(ProjectYears.BudgetTotalPrice,0) AS BudgetTotalPrice
FROM dbo.ProjectYears
	INNER JOIN dbo.Projects ON ProjectYears.ProjectID = Projects.ProjectID
WHERE ProjectYears.ProjectID = <cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric">
  AND ProjectYears.StartDate BETWEEN GetDate() - 400 AND GetDate()
  --AND (ISNULL(ProjectYears.TotalHours,0) != 0 OR ProjectYears.Desc1 = Projects.CurrentYearLabel)
ORDER BY ProjectYears.StartDate DESC
</cfquery>

<cfquery name="LocationZipCode" datasource="GSTS">
SELECT LocationZipCodes.LocationZipCodeID
FROM gsts.dbo.LocationZipCodes WITH (NOLOCK)
WHERE LocationZipCodes.LocationID =
(SELECT Projects.LocationID
 FROM gsts.dbo.Projects WITH (NOLOCK)
 WHERE Projects.ProjectID = <cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric">)
  AND LocationZipCodes.ZipCodeID =
(SELECT Locations.ZipCodeID
 FROM gsts.dbo.Locations WITH (NOLOCK)
 WHERE Locations.LocationID =
(SELECT Projects2.LocationID
 FROM gsts.dbo.Projects AS Projects2 WITH (NOLOCK)
 WHERE Projects2.ProjectID = #URL.ZProjectID#))
</cfquery>
<cfif IsDefined("Cookie.ZUserID") is "False">
  <cfcookie name = "ZUserID"
    value = "0"
    expires = "30">        
</cfif>
<cfquery datasource="GSTS" name="CanGenerateProposal">
SELECT ISNULL(UserActions.IsAllowed,0) AS IsAllowed
FROM gsts.dbo.UserActions  WITH (NOLOCK)
  INNER JOIN gsts.dbo.ActionDefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
WHERE ActionDefs.Desc1 = 'Generate Proposal'
  AND UserActions.UserID = #Cookie.ZUserID#
</cfquery>
<!---<cfquery datasource="GSTS" name="CanLockInventory">
SELECT ISNULL(UserActions.IsAllowed,0) AS IsAllowed
FROM gsts.dbo.UserActions WITH (NOLOCK)
  INNER JOIN gsts.dbo.ActionDefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
WHERE ActionDefs.Desc1 = 'Lock Inventory'
  AND UserActions.UserID = #Cookie.ZUserID#
</cfquery>--->

<cfquery datasource="GSTS" name="CanConvertInventory">
SELECT ISNULL(UserActions.IsAllowed,0) AS IsAllowed
FROM gsts.dbo.UserActions WITH (NOLOCK)
  INNER JOIN gsts.dbo.ActionDefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
WHERE ActionDefs.Desc1 = 'Convert Inventory'
  AND UserActions.UserID = #Cookie.ZUserID#
</cfquery>
<cfquery name="HasPortal" datasource="GSTS">
SELECT COUNT(WebUserID) AS VCount
FROM dbo.WebUsers WITH (NOLOCK)
WHERE ProjectID = <cfqueryparam value="#URL.ZProjectID#" cfsqltype="cf_sql_numeric"> 
</cfquery>
<cfquery name="SelectedContract" datasource="gsts">
SELECT TOP 1 Contracts.ContractID
FROM dbo.Contracts WITH (NOLOCK)
	INNER JOIN dbo.StatusDefs ON Contracts.StatusDefID = StatusDefs.StatusDefID 
    INNER JOIN dbo.Projects ON Contracts.ProjectID = Projects.ProjectID
    INNER JOIN dbo.ProjectGroups ON ProjectGroups.ProjectID = Projects.ProjectID
    INNER JOIN dbo.ProjectGroupDefs ON ProjectGroups.ProjectGroupDefID = ProjectGroupDefs.ProjectGroupDefID
WHERE Contracts.ProjectID = #URL.ZProjectID#
  AND StatusDefs.Desc1 = 'Approved'
  AND GetDate() BETWEEN Contracts.StartDate AND Contracts.EndDate
  AND ProjectGroupDefs.ProjectGroupDefID = 11
</cfquery>


<cfquery name="SelectedWebUser" datasource="gsts">
SELECT TOP 1 WebUsers.WebUserID, WebUserAccounts.WebUserAccountHash AS ref
FROM dbo.Projects
	INNER JOIN dbo.WebUsers ON WebUsers.ProjectID = Projects.ProjectID
    INNER JOIN dbo.WebUserAccounts ON WebUsers.WebUserAccountID = WebUserAccounts.WebUserAccountID
	INNER JOIN flow.Users ON WebUsers.EmailAddress = Users.UserEmail
WHERE Projects.ProjectID = #URL.ZProjectID#
  AND Users.UserID = #Cookie.ZUserID#
</cfquery>

<cfquery name="ProjectHistory" datasource="gsts">
SELECT	Invoices.ProjectYearLabel,
		ServiceClasses.Desc1,
		SUM(InvoiceLines.Qty) AS Qty,
		SUM(InvoiceLines.TotalPrice) AS Total
FROM	dbo.InvoiceLines WITH (NOLOCK)
	INNER JOIN dbo.Invoices ON InvoiceLines.InvoiceID = Invoices.InvoiceID
    INNER JOIN dbo.StatusDefs ON Invoices.StatusDefID = StatusDefs.StatusDefID
	INNER JOIN dbo.Periods ON Invoices.CustomerPeriodID = Periods.PeriodID
	INNER JOIN dbo.InventoryDetail ON InvoiceLines.InventoryDetailID = InventoryDetail.InventoryDetailID
	INNER JOIN dbo.InventoryGroups ON InventoryDetail.InventoryGroupID = InventoryGroups.InventoryGroupID
	INNER JOIN dbo.InventoryClasses ON InventoryGroups.InventoryClassID = InventoryClasses.InventoryClassID
	INNER JOIN dbo.LocationZipRegions ON InventoryDetail.LocationZipRegionID = LocationZipRegions.LocationZipRegionID
	INNER JOIN dbo.Districts ON LocationZipRegions.DistrictID = Districts.DistrictID
	INNER JOIN dbo.ZoneDefs ON Districts.ZoneDefID = ZoneDefs.ZoneDefID
	INNER JOIN dbo.ServiceTypes ON InvoiceLines.ServiceTypeID = ServiceTypes.ServiceTypeID
	INNER JOIN dbo.ServiceClasses ON ServiceTypes.ServiceClassID = ServiceClasses.ServiceClassID
WHERE Invoices.ProjectID = #URL.ZProjectID#
  AND InvoiceLines.ParentInvoiceLineID IS NULL
  AND StatusDefs.Desc1 != 'Deleted'
  AND StatusDefs.Desc1 != 'Voided'
GROUP BY Invoices.ProjectYearLabel, ServiceClasses.Desc1
ORDER BY Invoices.ProjectYearLabel DESC, ServiceClasses.Desc1
</cfquery>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- DW6 -->
<head>
<!-- Copyright 2005 Macromedia, Inc. All rights reserved. -->
<title>Project Focus</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="mm_health_nutr.css" type="text/css" />

<script src="SpryAssets/SpryTabbedPanels.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	var Paint=null;
	function PaintFrame(VPage,VFrame,VKey)  {
		frames[VFrame].location.href=[VPage];
	  }
</script>  
<script language="JavaScript" type="text/javascript">
//--------------- LOCALIZEABLE GLOBALS ---------------
var d=new Date();
var monthname=new Array("January","February","March","April","May","June","July","August","September","October","November","December");
//Ensure correct for language. English is "January 1, 2004"
var TODAY = monthname[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear();
//---------------   END LOCALIZEABLE   ---------------
</script>
<script language="javascript" type="text/javascript">
var win=null;
function NewWindow(mypage,myname,w,h,scroll,pos){
if(pos=="random"){LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
if(pos=="center"){LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h)/2:100;}
else if((pos!="center" && pos!="random") || pos==null){LeftPosition=0;TopPosition=20}
settings='width='+w+',height='+h+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=yes';
win=window.open(mypage,myname,settings);}

function showAjaxSpinner() {
	var link = document.getElementById('projectSummaryLink');
	var spinner = document.getElementById('projectSummarySpinner');
	if(link && spinner) {
		link.style.display = 'none';
		spinner.style.display = 'inline-block';
	}
}

function hideAjaxSpinner() {
	var link = document.getElementById('projectSummaryLink');
	var spinner = document.getElementById('projectSummarySpinner');
	if(link && spinner) {
		spinner.style.display = 'none';
		link.style.display = 'inline';
	}
}
// -->
</script>

<link href="SpryAssets/SpryTabbedPanels.css" rel="stylesheet" type="text/css" />

<style type="text/css">
<!--
#MainDiv {
	/* was position:absolute; top:43px - now flows below #ProjHdrBar so a tall (wrapped) title never overlaps the tabs */
	position: relative;
	margin: 4px 0 0 9px;
	width: 1160px;
	height: 817px;
	z-index: 1;
	background-color: #D5EDB3;
}
#apDiv1 {
	position:absolute;
	left:81px;
	top:176px;
	width:900px;
	height:30px;
	z-index:2;
}
#HeaderDiv {
	position:absolute;
	left:-2px;
	top:0px;
	width:990px;
	height:81px;
	z-index:2;
}
#FooterDiv {
	position:absolute;
	left:3px;
	top:570px;
	width:984px;
	height:29px;
	z-index:3;
}
.style10 {font-size: 14px}
.style15 {
	color: #FFFFFF;
	font-weight: bold;
}
.style17 {
	color: #000099;
	font-weight: bold;
	font-size: 12px;
}
#apDiv2 {
	position:absolute;
	left:684px;
	top:7px;
	width:406px;
	height:29px;
	z-index:2;
}
.style18 {color: #006633}
.style19 {color: #006600}
.style20 {color: #333333}
#apDiv {
	/* was a fixed 535x29 absolute box that clipped/overflowed long project names - now a flex item that grows with the text */
	flex: 1 1 auto;
	min-width: 0;
	z-index: 2;
}
.style21 {font-size: 18px}
.style22 {
	color: #00CC33;
	font-size: 18px;
	font-weight: bold;
}
.style24 {color: #FFFF00; font-size: 18px; font-weight: bold; }
.style26 {color: #FF0000; font-size: 18px; font-weight: bold; }
#apDiv3 {
	/* HTD box - now pinned to the right end of the header bar */
	flex: 0 0 auto;
	white-space: nowrap;
	z-index: 3;
}

.inline-spinner {
	display: none;
	vertical-align: middle;
}

@keyframes spin {
	0% { transform: rotate(0deg); }
	100% { transform: rotate(360deg); }
}

.spinner-wheel {
	display: inline-block;
	border: 3px solid #cccccc;
	border-top: 3px solid #3498db;
	border-radius: 50%;
	width: 16px;
	height: 16px;
	animation: spin 0.8s linear infinite;
	vertical-align: middle;
	margin-right: 5px;
}
-->
</style>
</head>
<body bgcolor="#D5EDB3">

<!--- Header bar: title (grows with text) on the left, HTD on the right. Flows above #MainDiv so long/wrapped names never overlap the tabs (header-overlap fix 2026-07-23). --->
<div id="ProjHdrBar" style="display:flex; align-items:center; justify-content:space-between; gap:14px; width:1086px; margin:0 0 0 19px; padding:6px 0 2px;">
<div id="apDiv"><span class="pageName  style6"><cfoutput><span class="style18">#Projects.Desc1#</span></cfoutput> &nbsp;&nbsp;(<span class="style19"><cfoutput>#Company.Nickname#</cfoutput></span>)</span></div>
<div id="apDiv3"><iframe name="HTDContent" id="HTDContent" height="29" width="545" frameborder="0" scrolling="no" src="Profile.ProjectYears.HTD.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></div>
</div>

<div id="MainDiv">
  <div id="TabbedPanels1" class="TabbedPanels" style="background-color:#D5EDB3">
    <ul class="TabbedPanelsTabGroup">
      <li class="TabbedPanelsTab" tabindex="0">  Project</li>
      <li class="TabbedPanelsTab" tabindex="0"> Location</li>
      <li class="TabbedPanelsTab" tabindex="0">Attachments</li>
      <li class="TabbedPanelsTab" tabindex="0"> Inventory</li>
      <li class="TabbedPanelsTab" tabindex="0"> Species</li>
      <li class="TabbedPanelsTab" tabindex="0"> Areas</li>
<li class="TabbedPanelsTab" tabindex="0">Totals</li>
<li class="TabbedPanelsTab" tabindex="0"> RFPs</li>
      <li class="TabbedPanelsTab" tabindex="0"> Proposals</li>
      <li class="TabbedPanelsTab" tabindex="0">GoAheads</li>
      <li class="TabbedPanelsTab" tabindex="0">GPS</li>
      <li class="TabbedPanelsTab" tabindex="0"> Work Orders</li>
<li class="TabbedPanelsTab" tabindex="0">Crew Packets</li>
<li class="TabbedPanelsTab" tabindex="0"> Invoices</li>
<li class="TabbedPanelsTab" tabindex="0">History</li>
<li class="TabbedPanelsTab" tabindex="0"> Setup</li>
      <cfif #Projects.WebAddress# NEQ 'AllBlank.cfm'>
</cfif>
    </ul>
    <div class="TabbedPanelsContentGroup">
      <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
        <table border="0">
          <tr>
            <td width="291" colspan="2" align="left">
            <cfoutput><span class="quote">#Company.FileAs#</span></cfoutput>&nbsp;</td>
            <td width="689" align="center"><table width="100%" border="0" cellpadding="5">
              <tr>
                <td width="52" align="center"><a href="Profile.Company.Focus.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>" class="navText">Company</a></td>
                <td width="56" align="center"><a href="Synch.Contracts.Content.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="ProjectContent">Contracts</a></td>
                <td width="50" align="center"><a href="Synch.ProjectSeasons.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent">Seasons</a></td>
                <td width="37" align="center"><a href="Profile.ProjectYears$Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="ProjectContent" class="navText">Years</a></td>
                <td width="37" align="center"><a href="Profile.ProjectYears.Budgets$New.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="ProjectContent" class="navText">Budgets</a></td>
                <td width="37" align="center"><a href="Synch.ProjectProfiles.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent">Profile</a></td>
                <td width="33" align="center">
                <cfif #SelectedWebUser.WebUserID# NEQ '' OR #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
                <a href="Client-Observations-Project.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&ZWebUserID=<cfoutput>#SelectedWebUser.WebUserID#</cfoutput>" target="ClientObservationsWindow">Observations</a>
                <cfelse>
                	&nbsp;
                </cfif>
                
                </td>
                <td width="33" align="center"><a href="Synch.Project.Notes.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent" onClick="parent.ProposalContent.location='AllBlank.cfm';">Notes</a></td>
                <td width="64" align="center"><a href="Synch.Project.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent" onClick="parent.ProposalContent.location='AllBlank.cfm';">Refresh</a></td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td colspan="3"><iframe name="ProjectContent" id="ProjectContent" height="550" width="1080" frameborder="0" src="Synch.Project.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
          </tr>
          <tr>
            <td align="left">Created: <cfoutput><span class="style18">#LSDateFormat(Projects.Created,'M/DD/YY')#</span></cfoutput></td>
            <td align="right"><cfif #Projects.LastModified# NEQ ''>Modified: <cfoutput><span class="style18">#LSDateFormat(Projects.LastModified,'M/DD/YY')#</span></cfoutput><cfelse>&nbsp;</cfif>              <cfif #Projects.LastModified# NEQ ''>
            <cfoutput><span class="style18">#LSTimeFormat(Projects.LastModified,'hh:mm')#</span></cfoutput><cfelse>&nbsp;</cfif></td>
            <td align="center"><table width="100%" border="0">
              <tr>
                <td width="97"><a href="ReportDev/Project$Traveler.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Traveler</a></td>
                <td width="133"><a href="ReportDev/Worksheet$Project.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Worksheet</a></td>
                <td width="94"><a href="CodeUpdateProjectGeneral.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update Project</a></td>
                <td width="115"><a href="Synch.Project.Invoices.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="_self">Project History</a></td>
                <td width="71"><a href="ReportDev/Yearly$Greenwaste$ByProject.cfr?ZYear=<cfoutput>#Projects.VThisYear#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Greenwaste</a></td>
                <td><a href="WebPortal/Profile.WebUserLogs.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent">Web Logs</a></td>
                <td width="29"><cfif #Cookie.ZUserID# EQ 1 OR #Cookie.ZUserID# EQ 42><a href="SystemLogs$Project.cfm?ZLocationID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent">Logs</a><cfelse>&nbsp;</cfif></td>
                </tr>
            </table></td>
          </tr>
        </table>
      </div>
      
      <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
<table border="0">
  <tr>
    <td>&nbsp;</td>
    <td align="center" class="quote">&nbsp;</td>
    <td align="left"><table width="100%" border="0" cellpadding="5">
      <tr>
        <td width="62" align="center"><a href="Profile.Company.Focus.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>" class="navText">Company</a></td>
        <td width="19" align="center">&nbsp;</td>
        <td width="177" align="center"><a href="Synch.LocationServiceTypes.Content.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LocationContent">Schedule of Compensation</a></td>
        <td width="67" align="center">&nbsp;</td>

        <td width="80" align="center"><a href="Profile.ProjectAddresses.Framet.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="LocationContent">Addresses</a></td>
        <td width="67" align="center">&nbsp;</td>
        <td width="65" align="center"><a href="Profile.Project.Detail.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZCompanyID=<cfoutput>#URL.ZCompanyID#</cfoutput>" class="style10 navText" target="_self"><strong>Refresh</strong></a><a href="Synch.Project.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectContent" onClick="parent.ProposalContent.location='AllBlank.cfm';"></a></td>
        <td width="53" align="center">&nbsp;</td>
        <td width="6" align="center">&nbsp;</td>
        <td width="126" align="center"><a href="Web.Client.Standard.Inline$Species.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="CustomerPortalWindow" class="navText">Portal</a></td>
        <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
	        <td width="15"><a href="GenerateLocationsLatLong.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="ProjectContent">Generate LatLong</a></td>
        </cfif>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td colspan="3"><iframe name="LocationContent" id="LocationContent" height="550" width="1080" frameborder="0" src="Profile.Location.Update.New.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>"></iframe></td>
  </tr>
  <tr>
    <td colspan="3" align="right"><table width="100%" border="0">
      <tr>
        <td align="center" valign="middle"><a href="Command$CreateLocationFolder.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" target="SystemLogProfileProject">Make Folder</a></td>
        <td align="center" valign="middle"><a href="ReportDev/Project$Traveler.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Traveler</a></td>
        <td align="center" valign="middle"><a href="ReportDev/Project$Interview.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Marketing Target Sheet</a></td>
        <td align="center" valign="middle"><a href="ReportDev/Worksheet$Project.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Worksheet</a></td>
        <td align="center" valign="middle"><a href="ReportDev/Project$Species$Worksheet.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Blank Species Worksheet</a></td>
        <td align="center" valign="middle"><a href="CodeUpdateProjectGeneral.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update Project</a></td>
        <td align="center" valign="middle"><a href="CodeUpdateLocationQty.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="SynchCodeFrame">Update History</a></td>
        <td align="center" valign="middle" bgcolor="#CCFF66"><a href="CodeGenerateRFP$User$General$Project.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="_self">Add to My Queue</a></td>
       <!--- <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
			<cfif #Projects.IsInventoryLocked# EQ 1>
                <td align="center" valign="middle" bgcolor="#FF0000">
                    <cfif #CanLockInventory.IsAllowed# EQ 1>
                        <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame"><span class="navText style15">Inventory Locked</span></a>
                    <cfelse>
                        <span class="navText style15">Inventory Locked</span>
                    </cfif>            </td>
            <cfelse>
                <td align="center" bgcolor="#FFFF99">
                    <cfif #CanLockInventory.IsAllowed# EQ 1> 
                        <span class="style17">
                            <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame">Inventory Unlocked</a>                    </span>
                    <cfelse>
                        <span class="style17">
                            Inventory Unlocked                    </span>
                    </cfif>
                    <span class="style15">&nbsp;</span>            </td>
            </cfif>
        </cfif>--->
           	<cfif #Projects.IsInventoryLocked# EQ 1>
                <td align="center" valign="middle" bgcolor="#FF0000">
                   <!--- <cfif #CanLockInventory.IsAllowed# EQ 1>--->
                   <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
                        <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame"><span class="navText style15">Inventory Locked</span></a>
                    <cfelse>
                        <span class="navText style15">Inventory Locked</span>
                    </cfif>            
                </td>
            <cfelse>
                <td align="center" bgcolor="#FFFF99">
                    <!---<cfif #CanLockInventory.IsAllowed# EQ 1> --->
                    <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
                        <span class="style17">
                            <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame">Inventory Unlocked</a>                    </span>
                    <cfelse>
                        <span class="style17">
                            Inventory Unlocked                    </span>
                    </cfif>
                    <span class="style15">&nbsp;</span>           
                </td>
            </cfif>

    <td align="center" class="quote">&nbsp;</td>
        </tr>
    </table></td>
  </tr>
</table>
      </div>
      
           <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
             <table border="1">
               <tr>
                 <td align="right">&nbsp;</td>
               </tr>
               <tr>
                 <td><iframe name="LocationContent" id="LocationContent2" height="550" width="1075" frameborder="0" src="Profile.Attachments.Content.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>"></iframe></td>
               </tr>
               <tr>
                 <td>&nbsp;</td>
               </tr>
             </table>
           </div>
           <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
             <table width="100%" border="1">
               <tr>
                 <td align="right"><table width="100%" border="0">
                   <tr>
                     <td width="122" align="center"><a href="Synch.InventoryBatches.Content.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="InventoryDetailContent">Inventory Batches</a></td>
                      <td width="122" align="center"><a href="Profile.ProjectLayers.Frame.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="InventoryDetailContent">Layers</a></td>
                     <td width="101" align="center"><a href="Synch.InventoryDetail.Content.List$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="InventoryDetailContent">Refresh</a></td>
                     <td width="72" align="center"><a href="Synch.InventoryDetail.Search$V9.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="InventoryDetailContent">Search</a></td>
                     <td width="129" align="center">
                       <a href="Profile.InventoryDetail.Images.Content.All.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="InventoryDetailContent">Images</a>
</td>
                     <td width="129" align="center"><a href="ReportDev/ProjectHistory$ServiceClass.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZServiceClassDesc1=Trimming" class="navText" target="NewInventoryWindow">Trimming History</a></td>
                     <td width="111" align="center"><a href="ReportDev/ProjectHistory$ServiceClass.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZServiceClassDesc1=Removals" class="navText" target="NewInventoryWindow">Removal History</a></td>
                     <td width="133" align="center"><a href="ReportDev/ProjectHistory$ServiceClass$CustomerVersion.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZServiceClassDesc1=Removals" class="navText" target="NewInventoryWindow">Removal History (Customer)</a></td>
                     <td width="133" align="center"><a href="Profile.ServiceClassHistory.List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZServiceClassDesc1=Trimming" class="navText" target="NewInventoryWindow">Completed Trimming</a></td>
                     <td width="133" align="center"><a href="Profile.ServiceClassHistory.List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&ZServiceClassDesc1=Removals" class="navText" target="NewInventoryWindow">Completed Removals</a></td>
                     <td width="74" align="center"><a href="Profile.ServiceClassHistory.List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&ZServiceClassDesc1=Planting" class="navText" target="NewInventoryWindow">Completed Planting</a></td>
                     <td width="98" align="center"><a href="CodeEvaluate$SpecialServices$Watering.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Watering Panel</a></td>
                     <td width="98" align="center"><a onclick="return confirm('Upon clicking this link, an export is automatically being prepared for download. You will be given a link here shortly. Click OK to confirm');" href="ExportInventoryDetailData.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="InventoryDetailContent" class="navText">Export Data</a></td>
					 
<td width="98" align="center"><a href="ImportInventoryDetailData.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="InventoryDetailContent" class="navText">Import Data</a></td>

<td width="98" align="right">&nbsp;</td>
                     <td width="201" align="left"><iframe frameborder="0" height="50px" width="100px" scrolling="no" src="Profile.Location.LastGSTSID.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>"></iframe></td>
                   </tr>
                 </table></td>
               </tr>
               <tr>
                 <td><iframe name="InventoryDetailContent" id="InventoryDetailContent" height="675" width="100%" frameborder="0" scrolling="Auto" src="Synch.InventoryDetail.Content.List$UpperLevel-New.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>"></iframe></td>
               </tr>
               <tr>
                 <td align="right"><table width="100%" border="0">
                   <tr>
                     <cfif #CanConvertInventory.IsAllowed# EQ 1 AND #Projects.IsExcludeFromConvert# EQ 0>
                       <td width="127" align="center" valign="middle"><a href="CodeCURSOR$ConvertProject$Override.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Convert Inventory</a></td>
                     <cfelse>
                     	<td>&nbsp;</td>
                     </cfif>
                     <cfif #CanConvertInventory.IsAllowed# EQ 1  AND #Projects.IsExcludeFromConvert# EQ 0>
                       <td width="127" align="center" valign="middle"><a href="CodeCURSOR$DeconstructProject$Override.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Deconstruct Inventory</a></td>
                     <cfelse>
                     	<td>&nbsp;</td>
                     </cfif>
                     <td width="127" align="center" valign="middle"><a href="ReportDev/Project$Traveler.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Traveler</a></td>
                     <td width="123" align="center" valign="middle"><a href="ReportDev/Worksheet$Project.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Worksheet</a></td>
                     <td width="112" align="center" valign="middle"><a href="CodeUpdateProjectGeneral.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update Project</a></td>
                     <td width="105" align="center" valign="middle"><a href="Profile.SnapshotDefs.Content.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="NewSnapshotWindow">Snapshots</a></td>
                     <td width="105" align="center" valign="middle"><a href="ReportDev/Yearly$Greenwaste$ByProject.cfr?ZYear=<cfoutput>#Projects.VThisYear#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Greenwaste</a></td>
                     <td width="105" align="center" valign="middle"><a href="Synch.Project.Invoices.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="_self">Project History</a></td>
                     <td width="106" align="center" valign="middle" bgcolor="#CCFF66"><a href="CodeGenerateRFP$User$General.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame">Add to My Queue</a></td>
<!---                     <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
						 <cfif #Projects.IsInventoryLocked# EQ 1>
                           <td align="center" valign="middle" bgcolor="#FF0000"><a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame"><span class="navText style15">Inventory Locked</span></a></td>
                           <cfelse>
                           <td align="center" bgcolor="#FFFF99"><cfif #CanLockInventory.IsAllowed# EQ 1>
                             <span class="style17"><a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame">Inventory Unlocked</a></span>
                           </cfif>
                             <span class="style15">&nbsp;</span></td>
                         </cfif>
                     </cfif>--->
                   	<cfif #Projects.IsInventoryLocked# EQ 1>
                        <td align="center" valign="middle" bgcolor="#FF0000">
                           <!--- <cfif #CanLockInventory.IsAllowed# EQ 1>--->
                           <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
                                <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame"><span class="navText style15">Inventory Locked</span></a>
                            <cfelse>
                                <span class="navText style15">Inventory Locked</span>
                            </cfif>            
                        </td>
                    <cfelse>
                        <td align="center" bgcolor="#FFFF99">
                            <!---<cfif #CanLockInventory.IsAllowed# EQ 1> --->
                            <cfif #findNoCase("inventoryadmin", GetUserRoles(), 0)# GTE 1>
                                <span class="style17">
                                    <a href="CodeMarkProjectIsInventoryLocked$User.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="SynchCodeFrame">Inventory Unlocked</a>                    </span>
                            <cfelse>
                                <span class="style17">
                                    Inventory Unlocked                    </span>
                            </cfif>
                            <span class="style15">&nbsp;</span>           
                        </td>
                    </cfif>

                     <td align="center" class="quote">&nbsp;</td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
           <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
             <table border="1">
               <tr>
                 <td align="right"><table width="100%" border="0">
                   <tr>
                     <td width="35" align="center">&nbsp;</td>
                     <td width="73" align="center"><a href="Synch.ProjectSeasons.Content$UpperLevel.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="InventoryContent">By Season</a></td>
                     <td width="73" align="center">&nbsp;</td>
                     <td width="73" align="center"><a href="Synch.InventorySummary.BySize.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Projects.LocationID#</cfoutput>" class="navText" target="InventoryContent">By Size</a></td>
                     <td width="73" align="center">&nbsp;</td>
                     <td width="120" align="center"><a href="CodeGenerateProjectPalette.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="InventoryContent">Tree Palette</a></td>
                     <td width="26" align="center">&nbsp;</td>
                     <td width="129" align="center"><a href="Synch.InventoryDetail.ExpiredRemovals.Content.List$UpperLevel.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="InventoryContent">Expired Removals</a></td>
                     <td width="15" align="center">&nbsp;</td>
                     <td width="60" align="center"><a href="Synch.InventorySummary.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>&amp;ZReconcile=1" class="navText" target="InventoryContent">Reconcile</a></td>
                     <td width="60" align="center">&nbsp;</td>
                     <td width="60" align="center"><a href="Synch.InventorySummary.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="InventoryContent">Refresh</a></td>
                     <td width="60" align="center">&nbsp;</td>
                     <td width="60" align="center">&nbsp;</td>
                     <td width="60" align="center">&nbsp;</td>
                   </tr>
                 </table></td>
               </tr>
               <tr>
                 <td><iframe name="InventoryContent" id="InventoryContent" height="585" width="1080" frameborder="0" scrolling="Auto" src="Synch.InventorySummary.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>"></iframe></td>
               </tr>
               <tr>
                 <td><table width="100%" border="0">
                   <tr>
                     <td><a href="CodeUpdateISQty.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update All Species</a></td>
                     <td valign="top">&nbsp;</td>
                     <td valign="top">&nbsp;</td>
                     <td valign="top"><img src="Art/Folder-TrmiIT-blue.png" border="0" height="20" alt="Folder" /></td>
                     <td valign="middle">- Multiple Services</td>
                     <td valign="top"><img src="Art/Folder-TrmiIT-red.png" border="0" height="20" alt="Folder" /></td>
                     <td valign="middle"> - Multiple  Lines</td>
                     <td valign="top">&nbsp;</td>
                     <td valign="middle">&nbsp;</td>
                     <td>&nbsp;</td>
                     <td>&nbsp;</td>
                     <td><a href="ReportDev/Report$SOC.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Schedule of Compensation</a></td>
                     <td>&nbsp;</td>

                     
                     <td><a href="ReportDev/Project$PricingWorksheet$Portrait.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet</a></td>
                    
                     <td>&nbsp;</td>
                     <td><a href="ReportDev/Project$PricingWorksheet$LandscapeNewest.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet Landscape</a></td>
                      <td>&nbsp;</td>
                     <td><a href="ReportDev/Project$PricingWorksheet$Portrait$NoPrices.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet<br />(No Prices)</a></td>
                     <td>&nbsp;</td>
                     <td><a href="ReportDev/Report$SpeciesBySize$Landscape$WithTrimmingTotalsAndNoPrice.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet<br />(Landscape/<br />No Prices)</a></td>
                     <td>&nbsp;</td>
                     <td><a href="ReportDev/Project$PricingWorksheet$LandscapeNewest2.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet<br>(Current Price)</a></td>
                     <td>&nbsp;</td>
                     <td><a href="ReportDev/Project$PricingWorksheet$LandscapeNewestFuture.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Worksheet<br>(Future Price)</a></td>
                     <td>&nbsp;</td>
                     <td><a target="InventoryContent" href="updateToFuturePrice.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText">Update to Future Price</a></td>
                     <td>&nbsp;</td>
                   


                     <td><a href="ReportDev/Project$PricingWorksheet$PricingGuide$Portrait.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Pricing Guide</a></td>
                     <td>&nbsp;</td>
                     <td>&nbsp;</td>
                     <td>&nbsp;</td>
                     <td>&nbsp;</td>
                     <td><cfif #Cookie.ZUserID# EQ 1 OR #Cookie.ZUserID# EQ 42>
                       <a href="CodeGenerateInventorySizes.cfm?ZLocationID=<cfoutput>#Projects.LocationID#</cfoutput>" target="SynchCodeFrame" class="navText">Update Sizes</a>
                       <cfelse>
                       &nbsp;
                     </cfif></td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
           <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
             <table width="100%" border="1">
               <tr>
                 <td align="right"><table width="100%" border="0">
                   <tr>
                     <td width="21" align="center">&nbsp;</td>
                     <td width="21" align="center"><a href="Profile.Project.ZoneDefs.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="LZRInventory">Zones</a></td>
                     <td width="21" align="center">&nbsp;</td>
                     <td width="21" align="center">&nbsp;</td>
                     <td width="21" align="center"><a href="Synch.Districts.Content.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LZRInventory">Districts</a></td>
                     <td width="67" align="center">&nbsp;</td>
                     <td width="67" align="center"><a href="Profile.LocationZipRegions.Focus.Mini.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LZRInventory">Search</a></td>
                     <td width="67" align="center">&nbsp;</td>
                     <td width="67" align="center"><a href="CodeGenerateLocationZipRegion.cfm?ZLocationZipCodeID=<cfoutput>#LocationZipCode.LocationZipCodeID#</cfoutput>" class="navText" target="SynchCodeFrame">New</a></td>
                     <td width="64" align="center">&nbsp;</td>
                     <td width="64" align="center"><a href="Synch.LocationZipRegions.Planning.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LZRInventory">Planning</a></td>
                     <td width="64" align="center">&nbsp;</td>
                     <td width="64" align="center"><a href="Synch.LocationStreets.Inventory.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Projects.LocationID#</cfoutput>" class="navText" target="LZRInventory">By Street</a></td>
                     <td width="64" align="center">&nbsp;</td>
                     <td width="64" align="center"><a href="Synch.LocationZipRegions.Inventory.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LZRInventory">Refresh</a></td>
                     <td width="64" align="center">&nbsp;</td>
                     <td width="64" align="center">&nbsp;</td>
                     <td width="64" align="center">&nbsp;</td>
                   </tr>
                 </table></td>
               </tr>
               <tr>
                 <td><iframe name="LZRInventory" id="LZRInventory" height="685" width="100%" frameborder="0" src="Synch.LocationZipRegions.Inventory.Content$UpperLevel.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" scrolling="Auto"></iframe></td>
                 <!---                      <td><iframe name="LZRInventory" id="LZRInventory" height="585" width="1080" frameborder="0" src="Synch.LocationZipRegions.Inventory.Content$UpperLevel$Simple.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" scrolling="Auto"></iframe></td>
--->
               </tr>
               <tr>
                 <td align="left"><table width="992" border="0">
                   <tr>
                     <td width="59" align="center"><a href="CodeUpdateLZRQty.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update All Areas</a></td>
                     <td width="215" align="center"><cfif #Projects.IsInventoryLocked# EQ 0>
                       <a href="CodeCURSOR$UpdateLZRSeqOrderAll$Alpha.cfm?ZLocationID=<cfoutput>#Projects.LocationID#</cfoutput>" class="navText" target="SynchCodeFrame">Re-sort Alpha</a>
                       <cfelse>
                       &nbsp;
                     </cfif></td>
                     <td width="12" align="center">&nbsp;</td>
                     <td width="153" align="center"><a href="ReportDev/Project$PricingWorksheet$ByArea$Portrait.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Inventory Worksheet</a></td>
                     <td width="1">&nbsp;</td>
                     <td width="52" nowrap="nowrap"><a href="ReportDev/Project$SlopeSheet.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="NewSlopeWorksheetWindow" class="navText">Slope Worksheet</a></td>
                     <td width="1">&nbsp;</td>
                     <td width="212" align="right"><a href="ReportDev/Project$PricingWorksheet$ByArea$ByService$Portrait.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Inventory Worksheet by Service</a></td>
                     <td width="249" align="center"><a href="Swap.LocationZipRegions.Inventory.Content$SideBySide.cfm?ZLocationID=<cfoutput>#Location.LocationID#</cfoutput>" class="navText" target="LZRInventory">Swap</a></td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
<div class="TabbedPanelsContent" style="background-color:#F4FFE4">
        <table border="1">
               <tr>
                 <td align="right"><table width="100%" border="0">
                   <tr>
                     <td width="215"><cfif #Projects.IsProjectTotalsLocked# EQ 0>
                       <a href="CodeBumpProjectTotalsLocked.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Lock Totals</a>
                       <cfelse>
                       <a href="CodeBumpProjectTotalsLocked.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Totals Locked</a>
                     </cfif></td>
                     <td width="43">&nbsp;</td>
                     <td width="43" align="left">&nbsp;</td>
                     <td width="52" align="left">&nbsp;</td>
                     <td width="145" align="left">&nbsp;</td>
                     <td width="145" align="left">&nbsp;</td>
                     <td width="145" align="left"><a href="CodeGenerateProjectTotals.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" target="ProjectTotalsContent" class="navText">Import Totals</a></td>
                     <td width="253" align="right"><a href="CodeGenerateProjectTotals$SplitRemovals.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" target="ProjectTotalsContent" class="navText">Import Totals (w/Removals)</a></td>
                   </tr>
                 </table></td>
               </tr>
               <tr>
                 <td><iframe name="ProjectTotalsContent" id="ProjectTotalsContent" height="500" width="1075" frameborder="0" src="Profile.ProjectTotals.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
               </tr>
               <tr>
                 <td align="right"><table width="258" border="0">
                   <tr>
                     <td width="7">&nbsp;</td>
                     <td width="7">&nbsp;</td>
                     <td width="7">&nbsp;</td>
                     <td width="53"><a href="Profile.ProjectLayers.Performance.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="NewReportWindow" class="navText">Scope History</a></td>
                     <td width="59">&nbsp;</td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
<cfif #HasPortal.VCount# GT 0>
</cfif>
                <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
                  <table border="1">
                    <tr>
                      <td align="left"><table width="95%" border="0">
                          <tr>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="114"><a href="Profile.ProjectActivity.Worksheet.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="RFPContent">RFP History</a></td>
                            <td width="10">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                           <td width="162"><a href="Profile.RFPs.Focus.Mini.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="RFPContent">Search</a></td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="12">&nbsp;</td>
                            <td width="111"><cfif #Cookie.ZUserID# NEQ 0>
                                <a href="CodeGenerateRFP$User$General$Project.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="_self">New</a>
                                <cfelse>
                              &nbsp;
                            </cfif></td>
                            <td width="162"><a href="Synch.RFPs.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="RFPContent">Details</a></td>
                            <td width="44">&nbsp;</td>
                            <td width="44"><a href="Synch.RFPs.Content.Progress.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="RFPContent">Refresh</a></td>
                            <td width="74">&nbsp;</td>
                            <td width="74">&nbsp;</td>
                            <td width="74"><a href="Profile.Pending.RFPs.cfm?ZCompanyID=<cfoutput>#Company.CompanyID#</cfoutput>&ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="RFPContent">Handoff's</a></td>
                            <td width="74">&nbsp;</td>
                          </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="RFPContent" id="RFPContent" height="600px" width="1080px" frameborder="0" src="Synch.RFPs.Content.Progress.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                    <tr>
                      <td align="right"><table width="258" border="0">
                          <tr>
                            <td width="7">&nbsp;</td>
                            <td width="7">&nbsp;</td>
                            <td width="7">&nbsp;</td>
                            <td width="53">&nbsp;</td>
                            <td width="59">&nbsp;</td>
                          </tr>
                      </table></td>
                    </tr>
                  </table>
      </div>
                <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
                  <table border="1">
                    <tr>
                      <td colspan="5" align="right"><table width="87%" border="0">
<tr>
                  <td width="21%"><cfif #CanGenerateProposal.IsAllowed# EQ 1>
                  <cfelse>&nbsp;</cfif></td>
                  <td width="21%" align="center">
                    <cfif #HasPortal.VCount# GT 0>
                  <a href="Profile.WorkRequests.Content$List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProposalContent">Work Requests</a>
                  	<cfelse>
                      &nbsp;
                    </cfif>
                  </td>
                  <td width="11%" align="center">&nbsp;</td>
                  <td width="11%" align="center"><a href="Profile.Proposals.Focus.Mini.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProposalContent">Search</a></td>
                  <td width="11%" align="center">&nbsp;</td>
                  <td width="11%" align="center"><a href="Profile.Proposals.Content$List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProposalContent">Proposals</a></td>
                  <td width="14%" align="center"><cfif AllowCreatingProposal gt 0><a href="Profile.Proposal.Parameters.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProposalContent">New Proposal</a></cfif></td>
                        </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td colspan="5"><iframe name="ProposalContent" id="ProposalContent" height="675" width="100%" frameborder="0" src="Profile.Proposals.Content$List.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                    <tr valign="middle">
                      <td width="309" align="left" valign="middle">&nbsp;<img src="Art/Calendar002.png" alt="Multi-Year" width="15" height="15" border="1" style="vertical-align:middle" /> -  Multi-Year Proposal</td>
                      <td width="87" align="left">&nbsp;<img src="Art/RedCircleMED.png" alt="Multi-Year" width="15" border="1" style="vertical-align:middle" /> -  Removals</td>
                      <td width="152" align="left">&nbsp;<img src="Art/mapiconMED.png" alt="Multi-Year" width="15" border="1" style="vertical-align:middle" /> -  Removal Map</td>
                      <td width="34" align="right">&nbsp;</td>
                      <td width="481" align="right"><table width="258" border="0">
                        <tr>
                          <td width="7">&nbsp;</td>
                          <td width="7">&nbsp;</td>
                          <td width="7">&nbsp;</td>
                          <td width="53">&nbsp;</td>
                          <td width="59">&nbsp;</td>
                          <td width="99">
                            <a href="CodeGenerateProjectSummary.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame" id="projectSummaryLink" onclick="showAjaxSpinner(); return true;">Project Summary</a>
                            <span id="projectSummarySpinner" class="inline-spinner"><span class="spinner-wheel"></span>Loading...</span>
                          </td>
                        </tr>
                      </table></td>
                    </tr>
                  </table>
      </div>
                <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
                  <table border="1">
                    <tr>
                      <td width="1076" align="right"><table width="200" border="1">
                        <tr>
                          <td><a href="Wizard$GoAhead$detail.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="GoAheadsByProjectContent">Use Wizard</a></td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td><a href="Synch.GoAheads.ByProject.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="GoAheadsByProjectContent">Refresh</a></td>
                        </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="GoAheadsByProjectContent" id="GoAheadsByProjectContent" height="550" width="1075" frameborder="0" src="Synch.GoAheads.ByProject.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                  </table>
                </div>
                <div class="TabbedPanelsContent"  style="background-color:#F4FFE4">
                  <table width="100%" border="1">
                    <tr>
                      <td align="right"><table width="100%" border="0">
                        <tr>
                          <td align="center"><a href="Synch.GPSWorkOrders.ByProject.Content-New.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZStatusDesc1=All" class="navText" target="WorkOrdersByProjectContent">Refresh</a></td>
                        </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td valign="top"><iframe name="GPSWorkOrdersByProjectContent" id="GPSWorkOrdersByProjectContent" height="650" width="1050" frameborder="0" src="Synch.GPSWorkOrders.ByProject.Content-New.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZStatusDesc1=All"></iframe></td>
                    </tr>
                  </table>
                </div>
                <div class="TabbedPanelsContent" style="background-color:#F4FFE4">
                  <table border="1">
                    <tr>
                      <td align="right"><table width="100%" border="0">
                        <tr>
                          <td align="center">&nbsp;</td>
                          <td align="center">&nbsp;</td>
                          <td align="center"><a href="Synch.WorkOrders.ByProject.Select.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" target="WorkOrdersByProjectContent" class="navText">Multi-Map</a></td>
                          <td align="center">&nbsp;</td>
                          <td align="center"><cfif #SelectedContract.RecordCount# EQ 1>
                            <a href="Yellow/Field-Performance-Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorkOrdersByProjectContent">Performance</a>
                            <cfelse>
                            &nbsp;
                          </cfif></td>
                          <td align="center">&nbsp;</td>
                          <td align="center">&nbsp;</td>
                          <td align="center"><a href="Profile.WorkOrders.Focus.Mini.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorkOrdersByProjectContent">Search</a></td>
                          <td align="center">&nbsp;</td>
                          <td align="center">&nbsp;</td>
                          <td align="center"><a href="Synch.WorkOrders.ByProject.Content-New.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZStatusDesc1=All" class="navText" target="WorkOrdersByProjectContent">Refresh</a></td>
                        </tr>
                      </table></td>
                      <td align="right">&nbsp;</td>
                    </tr>
                    <tr>
                      <td valign="top"><iframe name="WorkOrdersByProjectContent" id="WorkOrdersByProjectContent" height="650" width="850" frameborder="0" src="Synch.WorkOrders.ByProject.Content-New.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZStatusDesc1=All"></iframe></td>
                      <td valign="top"><iframe name="CrewHistoryFrame" height="650" width="175" frameborder="0" src="Sched.WorkOrderCrews.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                  </table>
                </div>
<div class="TabbedPanelsContent" style="background-color:#F4FFE4">
        <table border="1">
                    <tr>
                      <td width="1076" align="right"><table width="200" border="1">
                        <tr>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td><a href="Synch.CrewPackets.ByProject.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="CrewPacketsByProjectContentFrame">Refresh</a></td>
                        </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="CrewPacketsByProjectContentFrame" id="CrewPacketsByProjectFrame" height="550" width="1075" frameborder="0" src="Synch.CrewPackets.ByProject.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                  </table>
                </div>
<div class="TabbedPanelsContent" style="background-color:#F4FFE4">
  <table width="949" border="1">
    <tr>
      <td colspan="10" align="right"><table width="100%" border="0" cellspacing="3" cellpadding="3">
        <tr>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">&nbsp;</th>
          <th scope="col">
              <table border="0" cellpadding="5">
                <tr>
                <td>Client Console:</td>
                <cfoutput query="ProjectYears">
                    <td><a href="#application.currentSite#/Client.ControlPanel.Master.cfm?ref=asdkfjhaipeufijvnae@&Key=rivn'afvaerg22344lkasjdfipuhasdpujnadfglkijeroinv'zokmSD%22OIcvj%5bzdfgpozdkf&Hash='giomnzdfg'kopmzdf'giojno'IA:FION%22SDOifm&ZCompanyID=#Projects.CompanyID#&amp;ZProjectID=#URL.ZProjectID#&ZProjectYearLabel=#ProjectYears.Desc1#" target="NewClientWindow" class="navText">#ProjectYears.Desc1#</a></td>
                </cfoutput>
                </tr>
              </table>
</th>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td colspan="10"><iframe name="InvoicesByProjectContent" id="InvoicesByProjectContent" height="500" width="980" frameborder="0" src="Synch.Invoices.ByProject.Content$Split$New.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>&amp;ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
    </tr>
    <tr>
      <td width="49">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="72">&nbsp;</td>
      <td width="101" align="center"><a href="ReportDev/Report$CustomerInvoices$Project.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" onFocus="this.blur()" onClick="NewWindow(this.href,'Proposal','1150','900','yes','left');return false" >Invoice Report</a></td>
      <td width="174" align="center"><a href="Widget$Sales$ByServiceClass$ByProject$ThreeYears.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" onFocus="this.blur()" onClick="NewWindow(this.href,'ServiceClassPage','1150','900','yes','left');return false" >Service Type Graph</a></td>
      <td width="174">&nbsp;</td>
    </tr>
  </table>
</div>
<div class="TabbedPanelsContent" style="background-color:#F4FFE4">
  <table border="1" cellpadding="3">
    <tr>
      <td>YEAR</td>
      <td>SERVICE</td>
      <td align="right">Qty</td>
      <td align="right">Total</td>
    </tr>
    <cfoutput query="ProjectHistory" group="ProjectYearLabel">
    <cfoutput>
      <tr>
        <td>#ProjectHistory.ProjectYearLabel#</td>
        <td>#ProjectHistory.Desc1#</td>
        <td align="right">#LSNumberFormat(ProjectHistory.Qty,'999,999')#</td>
        <td align="right">#LSNumberFormat(ProjectHistory.Total,'999,999.99')#</td>
      </tr>
	    </cfoutput>
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>

    </cfoutput>
  </table>
</div>
<div class="TabbedPanelsContent" style="background-color:#F4FFE4">
        <table border="0">
                    <tr>
                      <td width="423" align="left"><cfoutput><span class="quote">#Company.FileAs#</span></cfoutput>&nbsp;</td>
                      <td width="557" align="right"><table width="761" border="0" cellpadding="5">
                          <tr>
                            <td width="1">&nbsp;</td>
                            <td width="1">&nbsp;</td>
                            <td width="52"><a href="Profile.Company.Focus.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>" class="navText">Company</a></td>
                            <td width="56"><a href="Synch.Contracts.Content.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Contracts</a></td>
                            <td width="50"><a href="Synch.ProjectSeasons.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Seasons</a></td>
                            <td width="37" align="center"><a href="Synch.ProjectGroups.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Groups</a></td>
                            <td width="37" align="center"><a href="Yellow/Maint-SolutionRecs-Content.cfm?ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>" class="navText" target="ProjectSetupFrame">Solution Recs</a></td>
                            <td width="37" align="center"><a href="Synch.ProjectProfiles.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Profile</a></td>
                            <td width="33" align="center"><a href="Synch.Project.Notes.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame" onClick="parent.ProposalContent.location='AllBlank.cfm';">Notes</a></td>
                            <td width="120" align="center"><a href="Profile.ProjectCrews.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Default Crew</a></td>
                            <td width="120" align="center"><a href="Synch.ProjectSetup.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame" onClick="parent.ProposalContent.location='AllBlank.cfm';">Refresh</a></td>
                            <td width="120" align="center">&nbsp;</td>
                          </tr>
                      </table></td>
                    </tr>
                    <tr>
                      <td colspan="2"><iframe name="ProjectSetupFrame" id="ProjectSetupFrame" height="620" width="1080" frameborder="0" src="Synch.ProjectSetup.Update.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>"></iframe></td>
                    </tr>
                    <tr>
                      <td colspan="2" align="right"><table width="100%" border="0">
                          <tr>
                            <td width="121" align="center"><a href="ReportDev/Project$Traveler.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Traveler</a></td>
                            <td width="126" align="center"><a href="ReportDev/Worksheet$Project.cfr?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="WorksheetWindow">Project Worksheet</a></td>
                            <td width="112" align="center"><a href="CodeUpdateProjectPerformanceFigures.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="SynchCodeFrame">Update Project Figures</a></td>
                            <td width="97" align="center"><a href="Synch.Project.Invoices.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="_self">Project History</a></td>
                            <td width="101" align="center"><a href="IMP$Standard$Panel.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Import</a></td>
                            <td width="101" align="center"><a href="Profile.Projects.MergeProject.Content.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Merge Project</a></td>
                            <cfif #HasPortal.VCount# GT 0>
                            <td width="101" align="center"><a href="Yellow/CodeEvaluate$ProjectContact$Me$FromDesktop.cfm?ZProjectID=<cfoutput>#Projects.ProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Web Portal</a></td>
                            </cfif>
                            <td width="101" align="center"><a href="Tan/CodeEvaluate$ProjectContact$System$FromGeoSetup.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="ProjectSetupFrame">Geo Setup</a></td>
                            <td width="101" align="center"><a href="Profile.Companies.MoveProject.Select.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZCompanyID=<cfoutput>#Projects.CompanyID#</cfoutput>" class="navText" target="ProjectSetupFrame">Move Project</a></td>
                            <td width="101" align="center"><a href="GSTSArborNoteProjectsDashboard.cfm?ProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>" class="navText" target="_blank">Arbor Note</a></td>
                          </tr>
                      </table></td>
                    </tr>
                  </table>
                  </div>
                 <cfif #Projects.WebAddress# NEQ 'AllBlank.cfm'>
</cfif>
    </div>
  </div>
</div>
<!--- #apDiv (title) + #apDiv3 (HTD) relocated to #ProjHdrBar at the top of <body> (header-overlap fix 2026-07-23); pre-existing stray </div> removed here too --->
<blockquote>&nbsp;</blockquote>
<iframe name="SynchCodeFrame" id="SynchCodeFrame" width="1" height="1" onload="hideAjaxSpinner();"></iframe>

<cfif IsDefined("Cookie.ZLocationID") is "False">
  <cfcookie name = "ZLocationID"
    value = "0"
    expires = "30">        
<cfelse>
    <cfset cookie.ZLocationID="0">
</cfif>


<script type="text/javascript">
<!--
var TabbedPanels1 = new Spry.Widget.TabbedPanels("TabbedPanels1", {defaultTab:1});
//-->
</script>
<div style="visibility:hidden">
<iframe name="SystemLogProfileProject" id="SystemLogProfileProject" width="1" height="1" src="CodeGenerateSystemLog.cfm?ZDesc1=ProjectPageHit&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>&amp;ZFormName=End-Profile.Project.Detail.cfm?ZProjectID=<cfoutput>#URL.ZProjectID#</cfoutput>&amp;ZLongDesc1=None"></iframe>
</div>

</body>
</html>
